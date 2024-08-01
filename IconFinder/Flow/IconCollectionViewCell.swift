//
//  IconTableViewCell.swift
//  IconFinder
//
//  Created by Algun Romper on 1/8/24.
//

import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.layer.backgroundColor = CGColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        
        tagsLabel.numberOfLines = 0
        tagsLabel.lineBreakMode = .byWordWrapping
    }
}
