//
//  ProductCell.swift
//  DemoTask
//
//  Created by nagar on 18/12/18.
//  Copyright © 2018 nagar. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var lblColors: UILabel!

    var strColor:NSString = ""
    
    func setProductcolors(productObj:ProductInfo){
        var arrcolors:[String] = [String]()
        let arrVarients = productObj.variants
        
        for varient:VariantInfo in arrVarients! {
            
            if varient.color.count > 0{
                arrcolors.append((varient.color! as NSString) as String)
            }
        }
        
        if arrcolors.count > 0 {
            strColor = "colors: " + arrcolors.joined(separator: ", ") as NSString
            lblColors.text = strColor as String
        }else{
            lblColors.isHidden = true
        }
    }
}
