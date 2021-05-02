//
//  Product+CoreDataProperties.swift
//  Trax
//
//  Created by Yosi Faroh Zada on 27/04/2021.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var name: String?
    @NSManaged public var category: Int64
    @NSManaged public var barcode: String?
    @NSManaged public var imgName: Data?

}

extension Product : Identifiable {

}
