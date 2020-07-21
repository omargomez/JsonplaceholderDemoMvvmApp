//
//  MockDataStack.swift
//  ZemogaTestAppTests
//
//  Created by Omar Eduardo Gomez Padilla on 7/18/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation
import CoreData
@testable import ZemogaTestApp

class MockDataStack: CoreDataStack {
    var persistentContainer: NSPersistentContainer!
    
    static let shared: CoreDataStack = MockDataStack()
    
    init() {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        persistentContainer = NSPersistentContainer(name: "ZemogaTestApp", managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { (description, error) in
            precondition(description.type == NSInMemoryStoreType)
        }
    }
    
    func saveContext() {}

}
