//
//  DBManager.swift
//  FMDBTut
//
//  Created by Gabriel Theodoropoulos on 07/10/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//


import UIKit

class DBManager: NSObject {

    //category table fields
    let field_CategoryID = "id"
    let field_CategoryName = "name"
    let field_CategoryIsChild = "isChildCategory"
    let field_CategoryChildArr = "childCategory"
    
     //product table fields
    let field_productID = "id"
    let field_ProductCategoryID = "catId"
    let field_productName = "name"
    let field_productDateAdded = "dateAdded"
    let field_productTaxType = "taxType"
    let field_productTaxAmount = "taxValue"
    let field_productViewcount = "viewcount"
    let field_productOrdercount = "orderCount"
    let field_productSharescount = "shareCount"
    
    //product variants table fields
    let field_variantID = "id"
    let field_productIDVar = "productId"
    let field_productColor = "color"
    let field_productPrice = "price"
    let field_productSize = "size"

    
    static let shared: DBManager = DBManager()
    
    let databaseFileName = "database.sqlite"
    var pathToDatabase: String!
    var database: FMDatabase!
    
    override init() {
        super.init()
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
    }
    
    func createDatabase() -> Bool {
        var created = false
        
        if !FileManager.default.fileExists(atPath: pathToDatabase) {
            database = FMDatabase(path: pathToDatabase!)
            
            if database != nil {
                // Open the database.
                if database.open() {
                    let createCategoriesTableQuery = "create table categories (\(field_CategoryID) integer primary key not null, \(field_CategoryName) text not null, \(field_CategoryIsChild) bool, \(field_CategoryChildArr) text not null)"
                    
                    let createProductsTableQuery = "create table products (\(field_productID) integer primary key not null, \(field_ProductCategoryID) integer not null, \(field_productName) text not null, \(field_productDateAdded) text not null, \(field_productTaxType) text not null, \(field_productTaxAmount) double not null, \(field_productViewcount) integer, \(field_productOrdercount) integer, \(field_productSharescount) integer, FOREIGN KEY (\(field_ProductCategoryID)) REFERENCES categories(\(field_CategoryID)))"
                    
                    let createProductsVariantsTableQuery = "create table variants (\(field_variantID) integer primary key not null, \(field_productIDVar) integer not null, \(field_productColor) text not null, \(field_productPrice) integer not null, \(field_productSize) integer not null, FOREIGN KEY (\(field_productIDVar)) REFERENCES products(\(field_productID)))"
                    
                    do {
                        try database.executeUpdate(createCategoriesTableQuery, values: nil)
                        try database.executeUpdate(createProductsTableQuery, values: nil)
                        try database.executeUpdate(createProductsVariantsTableQuery, values: nil)

                        created = true
                    }
                    catch {
                        print("Could not create table.")
                        print(error.localizedDescription)
                    }
                    
                    database.close()
                }
                else {
                    print("Could not open the database.")
                }
            }
        }
        
        return created
    }
    
    
    func openDatabase() -> Bool {
        
        if database == nil {
            if FileManager.default.fileExists(atPath: pathToDatabase) {
                database = FMDatabase(path: pathToDatabase)
            }
        }
        
        if database != nil {
            if database.open() {
                return true
            }
        }
        
        return false
    }
    
    
    func insertCategoryData(arrCategories: NSArray) {
        if openDatabase() {
            var query = ""
            for  category in arrCategories {
                
                let dictCategory:NSDictionary = category as! NSDictionary
                let catId = (dictCategory["id"] as? NSInteger)!
                let catName = (dictCategory["name"] as? String)!
                
                let arrProducts:[NSDictionary] = (dictCategory["products"] as? Array)!
                let arrChildCategories = (dictCategory["child_categories"] as? [Int])!
                let stringArray = arrChildCategories.map { String($0) }
                
                var ischildCat:Bool = false
                if arrChildCategories.count > 0 {
                    ischildCat = true
                }
                
                let strChildCat:String = stringArray.joined(separator: ",")
                
                query += "insert into categories (\(field_CategoryID), \(field_CategoryName), \(field_CategoryIsChild), \(field_CategoryChildArr)) values ('\(catId)', '\(catName)', '\(ischildCat)', '\(strChildCat)');"

                
                for  dictProduct in arrProducts{
                    let productId = (dictProduct["id"] as? NSInteger)!
                    let productName = (dictProduct["name"] as? String)!
                    let productDate = (dictProduct["date_added"] as? String)!
                    
                    let taxdict:NSDictionary = (dictProduct["tax"] as? NSDictionary)!
                    let taxType = (taxdict["name"] as? String)!
                    let taxValue = (taxdict["value"] as? Double)!
                    
                    query += "insert into products (\(field_productID), \(field_ProductCategoryID), \(field_productName), \(field_productDateAdded), \(field_productTaxType), \(field_productTaxAmount)) values ('\(productId)', '\(catId)', '\(productName)', '\(productDate)', '\(taxType)', '\(taxValue)');"
                    
                    let arrVariants:[NSDictionary] = (dictProduct["variants"] as? Array)!
                    
                    for  dictVariant in arrVariants{
                        let variantId = (dictVariant["id"] as? NSInteger)!
                        let variantColor = (dictVariant["color"] as? String)!
                        let variantPrice = (dictVariant["price"] as? NSInteger)!
                        var variantSize = 0
                        
                        if let _:String = (dictVariant["size"] as? NSNumber)?.stringValue{
                            variantSize = (dictVariant["size"] as? NSInteger)!
                        }
                        
                        query += "insert into variants (\(field_variantID), \(field_productIDVar), \(field_productColor), \(field_productPrice), \(field_productSize)) values ('\(variantId)', '\(productId)', '\(variantColor)', '\(variantPrice)', '\(variantSize)');"
                    }
                }
            }
            
            if !database.executeStatements(query) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
        }
        database.close()
    }
    
    
    func insertProductRankingInDB(arrRankings: NSArray){
        if openDatabase() {
            
            for  ranking in arrRankings{
                
                let dictRanking:NSDictionary = ranking as! NSDictionary
                let rankingType = (dictRanking["ranking"] as? String)!
                
                if rankingType == "Most Viewed Products"{
                    
                    let arrProducts:[NSDictionary] = (dictRanking["products"] as? Array)!

                    for  dictProduct in arrProducts{
                        
                        let productId = (dictProduct["id"] as? NSInteger)!
                        let viewCount = (dictProduct["view_count"] as? NSInteger)!
                        
                        var query = ""
                        query += "update products set \(field_productViewcount)=(?) where \(field_productID)=?"
                        
                        do {
                            try database.executeUpdate(query, values: [viewCount, productId])
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                else if rankingType == "Most OrdeRed Products"{
                    
                    let arrProducts:[NSDictionary] = (dictRanking["products"] as? Array)!
                    
                    for  dictProduct in arrProducts{
                        
                        let productId = (dictProduct["id"] as? NSInteger)!
                        let orderCount = (dictProduct["order_count"] as? NSInteger)!
                        
                        var query = ""
                        query += "update products set \(field_productOrdercount)=? where \(field_productID)=?"
                        
                        do {
                            try database.executeUpdate(query, values: [orderCount, productId])
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                else if rankingType == "Most ShaRed Products"{
                    
                    let arrProducts:[NSDictionary] = (dictRanking["products"] as? Array)!
                    
                    for  dictProduct in arrProducts{
                        
                        let productId = (dictProduct["id"] as? NSInteger)!
                        let sharesCount = (dictProduct["shares"] as? NSInteger)!
                        
                        var query = ""
                        query += "update products set \(field_productSharescount)=? where \(field_productID)=?"
                        
                        do {
                            try database.executeUpdate(query, values: [sharesCount, productId])
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        
        database.close()
    }
    
    
    
    func loadCategories() -> [CategoryInfo]! {
        var categoriesArr: [CategoryInfo] = [CategoryInfo]()
        
        if openDatabase() {
            let queryGetCategories = "select * from categories"
            
            do {
                print(database)
                let results = try database.executeQuery(queryGetCategories, values: nil)
                
                while results.next() {
                    
                    let catId =  Int(results.int(forColumn: field_CategoryID))
                    
                    let queryGetProducts = "select * from products where \(field_ProductCategoryID)=?"// order by \(field_productViewcount) desc
                    
                    do {
                        let productsResults = try database.executeQuery(queryGetProducts, values: [catId])

                        var category = CategoryInfo()
                        category.id = catId
                        category.name = results.string(forColumn: field_CategoryName)
                        
                        let strchildCat = results.string(forColumn: field_CategoryChildArr)
                        let childsArr:[String] = (strchildCat?.characters.split{$0 == ","}.map(String.init))!
                        category.child_categories_ids = childsArr.flatMap { Int($0) }
                        
                        if childsArr.count > 0{
                            category.isChildCategory = true
                        }
                        
                        var productsArr: [ProductInfo] = [ProductInfo]()
                        while productsResults.next() {
                            
                            let productId =  Int(productsResults.int(forColumn: field_productID))
                           
                            var product = ProductInfo()
                            product.id = productId
                            product.name = productsResults.string(forColumn: field_productName)
                            product.dateAdded = productsResults.string(forColumn: field_productDateAdded)
                            product.taxType = productsResults.string(forColumn: field_productTaxType)
                            product.taxValue = Double(productsResults.double(forColumn: field_productTaxAmount))
                            product.viewCount = Int(productsResults.int(forColumn: field_productViewcount))
                            product.orderedCount = Int(productsResults.int(forColumn: field_productOrdercount))
                            product.sharedCount = Int(productsResults.int(forColumn: field_productSharescount))
                            
                            let queryGetVariants = "select * from variants where \(field_productIDVar)=?"
                            let variantsResults = try database.executeQuery(queryGetVariants, values: [productId])
                            var variantsArr: [VariantInfo] = [VariantInfo]()
                            
                            while variantsResults.next() {
                                var variant = VariantInfo()
                                variant.id = Int(variantsResults.int(forColumn: field_variantID))
                                variant.color = variantsResults.string(forColumn: field_productColor)
                                variant.price = Int(variantsResults.int(forColumn: field_productPrice))
                                variant.size = Int(variantsResults.int(forColumn: field_productSize))
                                variantsArr.append(variant)
                            }
                            
                            product.variants = variantsArr
                            productsArr.append(product)
                        }
                        
                        category.products = productsArr
                        categoriesArr.append(category)
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
        
        return categoriesArr
    }
}
