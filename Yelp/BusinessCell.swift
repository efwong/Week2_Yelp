//
//  BusinessCell.swift
//  Yelp
//
//  Created by Edwin Wong on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var ratingImageVIew: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var business: Business!{
        didSet{
            nameLabel.text = business.name
            if let imageURL = business.imageURL{
                thumbImageView.setImageWith(imageURL)
            }
            categoriesLabel.text = business.categories
            addressLabel.text = business.address
            reviewsCountLabel.text = "\(business.reviewCount!)"
            if let imageURL = business.ratingImageURL{
                ratingImageVIew.setImageWith(imageURL)
            }
            distanceLabel.text = business.distance
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true
        
        // fix word wrap issue to frame width
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }

}
