//
//  CacheRepository.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/18/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation
import CoreData

enum CacheRepositoryError: Error {
    case fetchError
}

protocol CacheRepository {
    
    func instance<T>(_ type: T.Type, from: NSManagedObjectID) -> T?
    func map<T>(_ type: T.Type, array: [NSManagedObjectID]) -> [T]
    func fetchAllPosts(completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void )
    func insertPost(_ initBlock: @escaping (NSManagedObjectContext) -> PostItemEntity, completion: @escaping (Result<Void, Error>) -> Void )
    func insertPostArray<S>(_ sourceType: S.Type, items: [S], initWith: @escaping (NSManagedObjectContext, S) -> PostItemEntity?, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void )
    func insertUserArray<S>(_ sourceType: S.Type, items: [S], initWith: @escaping (NSManagedObjectContext, S) -> UserEntity?, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void )
    func insertCommentArray<S>(_ sourceType: S.Type, items: [S], initWith: @escaping (NSManagedObjectContext, S) -> CommentEntity?, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void )
    func update(postId: Int32, asReaded: Bool, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void)
    func update(postId: Int32, asStarred: Bool, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void)
    func delete(postId: Int32, completion: @escaping (Result<Void, Error>) -> Void)
    func additionalDataAlreadyLoaded(completion: @escaping (Result<Bool, Error>) -> Void)
    func fetchPost(withId postId: Int32, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void )
    func fetchUser(userId: Int32, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void )
    func fetchComments(forPostId postId: Int32, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void )
    func deleteAll(completion: @escaping (Result<Void, Error>) -> Void )
}

class CacheRepositoryImpl: CacheRepository {
    
    let coredataStack: CoreDataStack
    let backgroundContext: NSManagedObjectContext
    
    init(stack: CoreDataStack = MainCoreDataStack.shared) {
        self.coredataStack = stack
        self.backgroundContext = stack.persistentContainer.newBackgroundContext()
    }
    
    func instance<T>(_ type: T.Type, from: NSManagedObjectID) -> T? {
        //        self.backgroundContext.object(with: from) as? T
        var result: T?
        self.backgroundContext.performAndWait {
            result = self.backgroundContext.registeredObject(for: from) as? T
        }
        return result
    }
    
    func map<T>(_ type: T.Type, array: [NSManagedObjectID]) -> [T] {
        var result: [T] = []
        self.backgroundContext.performAndWait {
            result = array.compactMap {self.backgroundContext.registeredObject(for: $0) as? T}
        }
        return result
    }
    
    // TODO: Error handling
    func fetchAllPosts(completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void ) {
        self.backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<PostItemEntity> = PostItemEntity.fetchRequest()
            do {
                let fetchResult = try self.backgroundContext.fetch(fetchRequest)
                completion(.success(fetchResult.map({ $0.objectID })))
            } catch {
                completion(.failure(error))
            }
            
        }
    }
    
    func insertPost(_ initBlock: @escaping (NSManagedObjectContext) -> PostItemEntity, completion: @escaping (Result<Void, Error>) -> Void ) {
        self.backgroundContext.perform({ [weak self] in
            guard let self = self else { return }
            let newItem = initBlock(self.backgroundContext)
            self.backgroundContext.insert(newItem)
            do {
                try self.backgroundContext.save()
                completion(.success(Void()))
            } catch {
                completion(.failure(error))
            }
        })
    }
    
    private func insertAnyArray<S, T>(_ sourceType: S.Type, _ targetType: T.Type, items: [S], initWith: @escaping (NSManagedObjectContext, S) -> T?, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void ) where T: NSManagedObject {
        self.backgroundContext.perform({ [weak self] in
            guard let self = self else { return }
            var inserted: Set<NSManagedObject> = []
            for item in items {
                guard let newItem = initWith(self.backgroundContext, item) else {
                    continue
                }
            }
            inserted = self.backgroundContext.insertedObjects
            do {
                try self.backgroundContext.save()
                let result = Array(inserted.map { $0.objectID })
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        })
    }
    

    func insertUserArray<S>(_ sourceType: S.Type, items: [S], initWith: @escaping (NSManagedObjectContext, S) -> UserEntity?, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void ) {
        self.insertAnyArray(sourceType, UserEntity.self, items: items, initWith: initWith , completion: completion)
    }
    
    func insertCommentArray<S>(_ sourceType: S.Type, items: [S], initWith: @escaping (NSManagedObjectContext, S) -> CommentEntity?, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void ) {
        self.insertAnyArray(sourceType, CommentEntity.self, items: items, initWith: initWith , completion: completion)
    }
    
    func insertPostArray<S>(_ sourceType: S.Type, items: [S], initWith: @escaping (NSManagedObjectContext, S) -> PostItemEntity?, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void ) {
        self.insertAnyArray(sourceType, PostItemEntity.self, items: items, initWith: initWith , completion: completion)
    }
    
    func update(postId: Int32, asReaded: Bool, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void) {
        self.backgroundContext.perform({ [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<PostItemEntity> = PostItemEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == \(postId)")
            do {
                let fetchResult = try self.backgroundContext.fetch(fetchRequest)
                
                guard let post = fetchResult.first else {
                    completion(.failure(CacheRepositoryError.fetchError))
                    return
                }
                
                post.readed = asReaded
                let updated = self.backgroundContext.updatedObjects
                try self.backgroundContext.save()
                let result = Array(updated.map { $0.objectID })
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        })
    }
    
    func update(postId: Int32, asStarred: Bool, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void) {
        self.backgroundContext.perform({ [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<PostItemEntity> = PostItemEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == \(postId)")
            do {
                // TODO refactor common code
                let fetchResult = try self.backgroundContext.fetch(fetchRequest)
                
                guard let post = fetchResult.first else {
                    completion(.failure(CacheRepositoryError.fetchError))
                    return
                }

                post.starred = asStarred
                let updated = self.backgroundContext.updatedObjects
                try self.backgroundContext.save()
                let result = Array(updated.map { $0.objectID })
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        })
    }
    
    func delete(postId: Int32, completion: @escaping (Result<Void, Error>) -> Void) {
        self.backgroundContext.perform({ [weak self] in
            guard let self = self else { return }
            // Todo refactor fetch
            let fetchRequest: NSFetchRequest<PostItemEntity> = PostItemEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == \(postId)")
            do {
                // TODO refactor common code
                let fetchResult = try self.backgroundContext.fetch(fetchRequest)
                
                guard let post = fetchResult.first else {
                    completion(.failure(CacheRepositoryError.fetchError))
                    return
                }
                
                self.backgroundContext.delete(post)
                try self.backgroundContext.save()
                completion(.success(Void()))
            } catch {
                completion(.failure(error))
            }
        })
    }
    
    func additionalDataAlreadyLoaded(completion: @escaping (Result<Bool, Error>) -> Void) {
        self.backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            do {
                let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
                let userCount = try self.backgroundContext.count(for: fetchRequest)
                let fetchRequestComments: NSFetchRequest<CommentEntity> = CommentEntity.fetchRequest()
                let commentCount = try self.backgroundContext.count(for: fetchRequestComments)
                print("addition data: \(userCount + commentCount)")
                completion(.success(userCount > 0 && commentCount > 0))

            } catch {
                completion(.failure(error))
            }
        }

    }
    
    func fetchPost(withId postId: Int32, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void ) {
        self.backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<PostItemEntity> = PostItemEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == \(postId)")
            do {
                let fetchResult = try self.backgroundContext.fetch(fetchRequest)
                print("fetchPost: \(fetchResult.count)")
                completion(.success(fetchResult.map({ $0.objectID })))
            } catch {
                completion(.failure(error))
            }
        }

    }
    
    func fetchUser(userId: Int32, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void ) {
        self.backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == \(userId)")
            do {
                let fetchResult = try self.backgroundContext.fetch(fetchRequest)
                print("fetchUser: \(fetchResult.count)")
                completion(.success(fetchResult.map({ $0.objectID })))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchComments(forPostId postId: Int32, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void ) {
        self.backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<CommentEntity> = CommentEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "postId == \(postId)")
            do {
                let fetchResult = try self.backgroundContext.fetch(fetchRequest)
                print("fetchComments: \(fetchResult.count)")
                completion(.success(fetchResult.map({ $0.objectID })))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func deleteAll(completion: @escaping (Result<Void, Error>) -> Void ) {
        self.backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<PostItemEntity> = PostItemEntity.fetchRequest()
            fetchRequest.includesPropertyValues = false // for efficiency
            do {
                let fetchResult = try self.backgroundContext.fetch(fetchRequest)
                for object in fetchResult {
                    self.backgroundContext.delete(object)
                }
                try self.backgroundContext.save()
                completion(.success(Void()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
