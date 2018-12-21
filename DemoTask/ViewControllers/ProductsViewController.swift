//
//  ProductsViewController.swift
//  DemoTask
//
//  Created by Sanket Nagar on 18/12/18.
//  Copyright © 2018 nagar. All rights reserved.
//

import UIKit

class ProductsViewController: UIViewController {

    @IBOutlet weak var productsCollectioView: UICollectionView!
    public var categoryObj: CategoryInfo!
    var arrayProducts = [ProductInfo]();
    var selectedProductObject:ProductInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func loadAllProducts(){
        
        if categoryObj.products.count > 0 {
            arrayProducts = categoryObj.products
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushToDetail"
        {
            if let destinationVC = segue.destination as? ProductDetailsViewController {
                destinationVC.productObject = selectedProductObject
            }
        }
    }
}


extension ProductsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : ProductCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath as IndexPath) as! ProductCell
        
        let productObj = self.arrayProducts[indexPath.item]
        cell.lblProductTitle.text = productObj.name
        cell.imageView.backgroundColor = UIColor.red
        cell.imageView.image = nil;
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedProductObject = self.arrayProducts[indexPath.item]
        performSegue(withIdentifier: "pushToDetail", sender: nil)
    }
}
