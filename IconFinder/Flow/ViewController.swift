//
//  ViewController.swift
//  IconFinder
//
//  Created by Algun Romper on 1/8/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //if iconArray is empty
    private var noDataLabel: UILabel!
    //if iconArray is loading
    private var activityIndicator: UIActivityIndicatorView!
    
    private var icons: [IconModel] = []
    private var isLoading = false
    private var searchService = IconSearchService()
    private var currentQuery = ""
    private var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        searchTextField.placeholder = "Enter your search"
        
        
        searchButton.layer.cornerRadius = 10
        searchButton.layer.masksToBounds = true
        
        
        let nib = UINib(nibName: "IconCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "IconCell")
        
        setupNoDataLabel()
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
            activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true
            view.addSubview(activityIndicator)
        }
    
    private func setupNoDataLabel() {
            noDataLabel = UILabel()
            noDataLabel.text = "You haven't any icons results yet"
            noDataLabel.textColor = .gray
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 0
            
            noDataLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(noDataLabel)
            
            NSLayoutConstraint.activate([
                noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                noDataLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                noDataLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
            ])
            
            noDataLabel.isHidden = false
        }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
        
        guard let query = searchTextField.text, !query.isEmpty else { return }
        
        currentQuery = query
        currentPage = 1
        icons.removeAll()
        collectionView.reloadData()
        
        activityIndicator.startAnimating()
        searchService.searchIcons(query: query) { [weak self] (icons, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    print("Error fetching icons: \(error)")
                } else if let icons = icons {
                    self.icons = icons
                    self.collectionView.reloadData()
                    self.noDataLabel.isHidden = !self.icons.isEmpty
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCollectionViewCell", for: indexPath) as! IconCollectionViewCell
        
        let icon = icons[indexPath.item]
        
        guard let rasterSize = icon.raster_sizes.last,
              let format = rasterSize.formats.first else {
            cell.sizeLabel?.text = "No format available"
            cell.iconImageView?.image = nil
            return cell
        }
        
        cell.sizeLabel?.text = "\(rasterSize.size_width)x\(rasterSize.size_height)"
        cell.tagsLabel.text = "Tags: \(icon.tags.prefix(10).joined(separator: ", "))"

        cell.iconImageView?.image = IconCacheManager.shared.image(for: format.preview_url) ?? UIImage(named: "placeholder")
        
        if let cachedImage = IconCacheManager.shared.image(for: format.preview_url) {
            cell.iconImageView?.image = cachedImage
        } else {
            loadImage(from: format.preview_url) { image in
                guard let image = image else { return }
                IconCacheManager.shared.setImage(image, for: format.preview_url)
                DispatchQueue.main.async {
                    cell.iconImageView?.image = image
                }
            }
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let icon = icons[indexPath.item]
        
        guard let rasterSize = icon.raster_sizes.last,
              let format = rasterSize.formats.first else {
            return
        }
        
        loadImage(from: format.preview_url) { image in
            guard let image = image else { return }
            self.saveImageToPhotoLibrary(image: image)
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width) / 2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - frameHeight * 2 {
            guard !isLoading else { return }
            isLoading = true
            currentPage += 1
            
            searchService.loadNextPage(query: currentQuery) { [weak self] (icons, error) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        print("Error fetching more icons: \(error)")
                    } else if let newIcons = icons {
                        self.icons.append(contentsOf: newIcons)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
}


extension ViewController {
    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        guard let imageURL = URL(string: url) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageURL) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            let image = UIImage(data: data)
            completion(image)
        }
        task.resume()
    }

    func saveImageToPhotoLibrary(image: UIImage) {
        PhotoLibraryManager.shared.writeToPhotoAlbum(image: image)
    }
}
