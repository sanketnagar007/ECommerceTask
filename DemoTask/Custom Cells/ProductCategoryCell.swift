//
//  ProductCategoryCell.swift
//  DemoTask
//
//  Created by nagar on 18/12/18.
//  Copyright © 2018 nagar. All rights reserved.
//

import UIKit

class ProductCategoryCell: UITableViewCell {
    
    @IBOutlet weak var collectionViewProducts: UICollectionView!
    @IBOutlet weak var lblCategoryTitle: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
       
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension ProductCategoryCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionViewProducts.delegate = dataSourceDelegate
        collectionViewProducts.dataSource = dataSourceDelegate
        collectionViewProducts.tag = row
       // collectionViewMovies.setContentOffset(collectionViewMovies.contentOffset, animated:false)
        collectionViewProducts.reloadData()
    }
   
    var collectionViewOffset: CGFloat {
        set { collectionViewProducts.contentOffset.x = newValue }
        get { return collectionViewProducts.contentOffset.x }
    }
}
