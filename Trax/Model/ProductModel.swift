//
//  ProductModel.swift
//  Trax
//
//  Created by Yosi Faroh Zada on 27/04/2021.
//

import UIKit
import CoreData

class ProductModel: NSObject {
    var models = [Category:[Product]]()
    
    private static var sharedProductModel: ProductModel = {
        let shared = ProductModel()

        return shared
    }()
    
    // MARK: - Initialization

    private override init() {
        super.init()
    }

    // MARK: - Accessors

    class func shared() -> ProductModel {
        return sharedProductModel
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Trax")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func getAllItems() {
        do {
            let request = Product.fetchRequest() as NSFetchRequest<Product>
            for category in Category.allCases {
                request.predicate = NSPredicate(format: "category == %d", category.rawValue)
                request.sortDescriptors = [.init(key: "name", ascending: true)]
                models[category] = try persistentContainer.viewContext.fetch(request)
            }
        } catch {
            
        }
    }
    
    func addNewItem(with name:String, barCode:String, category:Category, imgData: Data) -> Bool {
        let newItem = Product(context: persistentContainer.viewContext)
        
        newItem.name = name
        newItem.barcode = barCode
        newItem.category = Int64(category.rawValue)
        newItem.imgName = imgData
        
        do {
            try persistentContainer.viewContext.save()
            return true
        } catch {
            return false
        }
    }
    
    func deleteItems(indexPaths:[IndexPath]) {
        for indexPath in indexPaths {
            if let category = Category(rawValue: indexPath.section),
               let productsArray = ProductModel.shared().models[category] {
                let product = productsArray[indexPath.row]
                
                persistentContainer.viewContext.delete(product)
            }
        }
        
        do {
            try persistentContainer.viewContext.save()
            getAllItems()
        } catch {
        }
    }
    
    func update() {
        do {
            if persistentContainer.viewContext.hasChanges {
                try persistentContainer.viewContext.save()
            }
        } catch  {
            
        }
    }
}
