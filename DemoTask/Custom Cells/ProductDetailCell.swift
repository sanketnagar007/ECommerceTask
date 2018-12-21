//
//  ProductDetailCell.swift
//  DemoTask
//
//  Created by Sanket Nagar on 18/12/18.
//  Copyright © 2018 nagar. All rights reserved.
//

import UIKit

class ProductDetailCell: UITableViewCell {

    @IBOutlet weak var imageViewProduct: UIImageView!
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
