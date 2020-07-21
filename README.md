# JsonplaceholderDemoMvvmApp
*An hunble MVVN showcase App*

## Introduction

On this repository you will find an iOS App build around the endpoints available [JSONPlaceholder](https://jsonplaceholder.typicode.com/). More than trying to show fancy iOS effects I'm showing how you can model your MVVM Architecture, specifically: 

- Creating Services components 
- Creating Repository components 
- Using Use Cases components to manage biz logic
- Creating ModelView components to abstract interaction units 
- Binding COntrollers and models thru Observers 
- Adding Unit testing to test Repositories, Services and Models

## Software Engineering concepts

### Component Architecture

Instead to build abstraction using Classes MVVM enforce the 'Dependency inversion' principle [SOLID](https://en.wikipedia.org/wiki/SOLID), in which dependencies are modeled as protocols, which intances (classes) are injected (passed over inits) at runtime. This is an important for Unit Testing, under which you want to test only the componet unit (its concrete class) but not its dependencies (that can be passed as Mock object during testing)

### Asyn processsing and callbacks 

The low level layers of the Architecture ( Services, Repositories ) are intented for Async processing, on which the caller doesn't have to wait for the process to continue ( Sync processing ), this is particular important for iOS Apps on which the user doesn't want the UI to be blocked while the App is working. To achieve this Services and Repositories receive a callback (or completon block), which is a function that is called once the requested task completes. 

### Services and Repositories 

Data can arrive from external sources (Web services is the primal example) and from within the App (from internal storage). To make this distinction clear the terms Services (external) and Repositories (internal) are used. Borrowed from [Domain-driven design](https://en.wikipedia.org/wiki/Domain-driven_design)

### Observer pattern 

To decouple Controllers and their ViewModels a Observer pattern was used. Controllers only need to observe (or bind) to the properties of the ViewModel they are interested into.

## Service components 

This demo App has one Service component:

```
protocol JSONPlaceholderService {
    func fetchPosts(completion: @escaping (Result<[JSONEntity.PostItem], Error>) -> Void)
    func fetchUsers(completion: @escaping (Result<[JSONEntity.User], Error>) -> Void)
    func fetchComments(completion: @escaping (Result<[JSONEntity.Comment], Error>) -> Void)

}
```

To handle JSON some Decodable entities were created to model the response. Notice Swift's 5 Result<T,E> enum was used to return fetch's response data. This pattern is used all across the App to return results to clients components 

## Repository Components 

Data that it's brought by the JSONPlaceholderService is cached locally, for this the CacheRepository was created. 

```
protocol CacheRepository {
    
    func instance<T>(_ type: T.Type, from: NSManagedObjectID) -> T?
    func map<T>(_ type: T.Type, array: [NSManagedObjectID]) -> [T]
    func fetchAllPosts(completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void )
    func insertUserArray<S>(_ sourceType: S.Type, items: [S], initWith: @escaping (NSManagedObjectContext, S) -> UserEntity?, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void )
    func update(postId: Int32, asReaded: Bool, completion: @escaping (Result<[NSManagedObjectID], Error>) -> Void)
    func delete(postId: Int32, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteAll(completion: @escaping (Result<Void, Error>) -> Void )
    ....
}
```

This compont abstract CRUD operation over Core Data. As the JSONPlaceholderService component it also receives a completion block. This methods receives NSManagedObject classes created on Core Data, since passing these instances between threads is tricky some special considerations were observe for its implementation. ( Check teh underlying implementation )

## Use Cases 

Services and Repositories are not intended for direct use from the ViewModel. From this layer you reference Used Cases componets which abstract Biz logic units. Each use case handle one biz rule at a time (SOLID's Single-responsibility principle), so these components only have *one method* , which is usually named *execute*, for example:

```
protocol LoadPostsUseCase {
    func execute(completion: @escaping (Result<[PostItemEntity], Error>) -> Void)
}
``` 

## ModelViews

ModelViews abstract UI, and they must depend on Use Cases only, the App has two:

- PostListViewModel (For the main controller)
- PostDetailViewModel (for the detail controller)

The keep the View layer (Controllers) clean, these are the only abstractions they can use. It's also useful to use supporting view models to handle different aspects of the UI, and so the PostListItemViewModel, UserViewModel and CommentViewModel were also created. 

## Controllers

As was explained, controllers can only reference view models. Controllers can request data using normal methods but they usually receive data via its Modelview properties, to notify the controller the observer pattern is used on the relevant properties ( Check the Observable class ). 

## Unit Testing

MVVM can be a pain due to its high level of decoupling, but it pays back when it comes to Unit testing. It's easy to test components on isolation, and the only thing you need to do is to pass over component's dependencies. If you check the unit testing for this proyect you will see how easy ws to test the Services (Using a stub to pass fake responses) and respositories (handling a Core data instance in memory)

## TODO

Probably the bigest improvement this App can have would be to replace the completion/observer pattern for a reactive one. Applying something like RxSwift can solve the messy code handling different dependant asyn responses on some Use cases (like LoadAdditionalPostDataUseCase). Combine would be even better since is already integrated into Swift.

