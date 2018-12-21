//
//  ViewController.swift
//  DemoTask
//
//  Created by nagar on 18/12/18.
//  Copyright © 2018 nagar. All rights reserved.
//

import UIKit
import Alamofire


struct CategoryInfo {
    var id: Int!
    var name: String!
    var products: [ProductInfo]!
    var isChildCategory: Bool!
    var child_categories:[SubcategoryInfo]
    var child_categories_ids:[Int]!
    
    init() {
        self.id = 0
        self.name = ""
        self.products = []
        self.isChildCategory = false
        self.child_categories = []
        self.child_categories_ids = []
    }
}

struct ProductInfo {
    var id: Int!
    var name: String!
    var dateAdded: String?
    var variants: [VariantInfo]!
    var taxType: String?
    var taxValue: Double!
    var viewCount: Int!
    var orderedCount: Int!
    var sharedCount: Int!
}

struct VariantInfo {
    var id: Int!
    var color: String!
    var price:  Int!
    var size:  Int!
}

struct SubcategoryInfo {
    var id: Int!
    var parent_id: Int!
    var name: String!
}


enum SortType:Int {
    case mostViewed = 0,mostOrdered,mostShared
}

class MainViewController: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    
    let baseUrlProducs = "https://stark-spire-93433.herokuapp.com/json"
    
    var arrayProductCategories = [CategoryInfo]();
    var selectedProductObject:ProductInfo!
    var selectedChildCategoryObject:SubcategoryInfo!
    var storedOffsets = [Int: CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DBManager.shared.createDatabase() {
            getAllCategories();
        }else{
            self.loadAllCategoriesAndProductsFromDB();
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func getAllCategories (){
        
        Alamofire.request(URL(string: baseUrlProducs)!)
            .validate()
            .response { (response) in
                
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Error: \(String(describing: response.error))")
                
                if let data = response.data {
                    do {
                        if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                            
                            let categoryArr = convertedJsonIntoDict["categories"] as! NSArray
                            let rankingArr = convertedJsonIntoDict["rankings"] as! NSArray
                            print(convertedJsonIntoDict)
                            
                            DBManager.shared.insertCategoryData(arrCategories: categoryArr)
                            DBManager.shared.insertProductRankingInDB(arrRankings: rankingArr)
                            
                            self.loadAllCategoriesAndProductsFromDB();
                        }
                        
                    } catch {
                        print("Error: ", error)
                    }
                }
        }
    }
    
    
    func loadAllCategoriesAndProductsFromDB() {
        
        let tempcategories:[CategoryInfo] =  DBManager.shared.loadCategories()
        self.arrayProductCategories = [CategoryInfo]()
        
        for var category:CategoryInfo in tempcategories {
            
            if category.isChildCategory{
                
                for catId:Int in category.child_categories_ids{
                    
                    let categoryObj = tempcategories.filter{ $0.id == catId }.first
                    var childCatObj:SubcategoryInfo = SubcategoryInfo()
                    childCatObj.parent_id = catId
                    childCatObj.name = categoryObj?.name ?? ""
                    category.child_categories.append(childCatObj)
                }
            }
            
            self.arrayProductCategories.append(category)
        }
        
        self.tblView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushToProducts"
        {
            if let destinationVC = segue.destination as? ProductsViewController {
                
                let categoryObj = self.arrayProductCategories.filter{ $0.id == selectedChildCategoryObject.parent_id }.first
                destinationVC.categoryObj = categoryObj
                destinationVC.loadAllProducts()
            }
        }
        else  if segue.identifier == "pushToDetail"
        {
            if let destinationVC = segue.destination as? ProductDetailsViewController {
                destinationVC.productObject = selectedProductObject
            }
        }
    }
    
    
    @IBAction func btnSortByTapped(_ sender: UIButton) {
        
        let tag = sender.tag
        let tempcategories:[CategoryInfo] =  self.arrayProductCategories
        self.arrayProductCategories.removeAll()
        
        for var category:CategoryInfo in tempcategories {
            
            if !category.isChildCategory{
                
                if tag == SortType.mostViewed.rawValue{
                    category.products = category.products.sorted(by: { $0.viewCount > $1.viewCount })
                }
                else if tag == SortType.mostOrdered.rawValue{
                    category.products = category.products.sorted(by: { $0.orderedCount > $1.orderedCount })
                }
                else if tag == SortType.mostShared.rawValue{
                    category.products = category.products.sorted(by: { $0.sharedCount > $1.sharedCount })
                }
            }
            
            self.arrayProductCategories.append(category)
        }
        
        tblView.reloadData()
    }
}


extension MainViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayProductCategories.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ProductCategoryCell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell") as! ProductCategoryCell
        
        let categoryObj = arrayProductCategories[indexPath.item]
        cell.lblCategoryTitle.text = categoryObj.name
        
        cell.collectionViewProducts.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? ProductCategoryCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? ProductCategoryCell else { return }
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
}


extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if self.arrayProductCategories[collectionView.tag].isChildCategory
            {
                let count = self.arrayProductCategories[collectionView.tag].child_categories_ids.count
                return count
            }else{
                return self.arrayProductCategories[collectionView.tag].products.count
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if self.arrayProductCategories[collectionView.tag].isChildCategory {
            
            let cell : ProductSubCategoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductSubCategoryCell", for: indexPath as IndexPath) as! ProductSubCategoryCell
            
            let childCategory = self.arrayProductCategories[collectionView.tag].child_categories[indexPath.item]
            cell.lblProductTitle.text = childCategory.name
            cell.imageView.backgroundColor = UIColor.red
           // cell.imageView.image = nil;
            
            return cell
            
        }else{
            
            let cell : ProductCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath as IndexPath) as! ProductCell
            
            let productObj = self.arrayProductCategories[collectionView.tag].products[indexPath.item]
            cell.lblProductTitle?.text = productObj.name
            cell.imageView.backgroundColor = UIColor.red
            cell.setProductcolors(productObj: productObj)
            
            //cell.imageView.image = nil;
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.arrayProductCategories[collectionView.tag].isChildCategory{
            selectedChildCategoryObject = self.arrayProductCategories[collectionView.tag].child_categories[indexPath.item]
            performSegue(withIdentifier: "pushToProducts", sender: nil)

        }else{
            selectedProductObject  = self.arrayProductCategories[collectionView.tag].products[indexPath.item]
            performSegue(withIdentifier: "pushToDetail", sender: nil)
        }
    }
}

