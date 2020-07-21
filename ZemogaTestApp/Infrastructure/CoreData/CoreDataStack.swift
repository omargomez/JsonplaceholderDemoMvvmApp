//
//  CoreDataStack.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/18/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation
import CoreData

//TODO: Clean
protocol CoreDataStack {
    var persistentContainer: NSPersistentContainer! {get}
//    var managedObjectContext: NSManagedObjectContext! {get}
    func saveContext()
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) 
}

extension CoreDataStack {
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}
