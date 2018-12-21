//
//  ProductDetailsViewController.swift
//  DemoTask
//
//  Created by Sanket Nagar on 18/12/18.
//  Copyright © 2018 nagar. All rights reserved.
//

import UIKit

class ProductDetailsViewController: UIViewController {

    @IBOutlet weak var tblProductVariants: UITableView!
    public var productObject: ProductInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tblProductVariants.reloadData()
    }
}

extension ProductDetailsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productObject.variants.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ProductDetailCell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailCell") as! ProductDetailCell
        
        let variantDict:VariantInfo = productObject.variants[indexPath.item]
        cell.lblColor.text = variantDict.color
        cell.lblPrice.text = String(variantDict.price)
        cell.lblSize.text = String(variantDict.size)
        
        
       // if let size:String = (variantDict.size as? NSNumber)?.stringValue
        //{
        
//        }else{
//            cell.lblSize.text = ""
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 275.0
    }
}
