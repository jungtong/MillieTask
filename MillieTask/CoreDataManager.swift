//
//  CoreDataManager.swift
//  MillieTask
//
//  Created by jungdongwon on 4/27/24.
//

import UIKit
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MillieTask")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let nsError = error as NSError? {
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } 
            catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // CoreData에 저장되어있는 NewsVO들을 불러온다.
    func getNews() -> [NewsVO]? {
        let fetchRequest = NewsCD.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let newsCDs = try persistentContainer.viewContext.fetch(fetchRequest)
            return newsCDs.map {
                guard let title = $0.title,
                      let urlToImage = $0.urlToImage,
                      let url = $0.url,
                      let publishedAt = $0.publishedAt else {
                    return nil
                }
                return NewsVO(author: $0.author,
                              title: title,
                              description: $0.desc,
                              url: url,
                              urlToImage: urlToImage,
                              publishedAt: publishedAt,
                              content: $0.content)
            }.compactMap({ $0 })
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    // CoreData에 저장되어있는 모든 News를 삭제한다.
    func removeAllNews() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "NewsCD")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.viewContext.execute(deleteRequest)
        } 
        catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    // NewsVO의 목록을 한번에 CoreData에 저장한다.
    func batchInsertNews(_ newsInfos: [NewsVO]) async {
        guard !newsInfos.isEmpty else { return }
        
        await persistentContainer.performBackgroundTask { context in
            let batchInsert = self.newBatchInsertRequest(items: newsInfos)
            do {
                try context.execute(batchInsert)
            }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // batchInsertNews 를 하기 위한 NSBatchInsertRequest
    private func newBatchInsertRequest(items: [NewsVO]) -> NSBatchInsertRequest {
        var index = 0
        let batchInsert = NSBatchInsertRequest(entity: NewsCD.entity()) { (managedObject: NSManagedObject) -> Bool in
            guard index < items.count else { return true }

            (managedObject as? NewsCD)?.author = items[index].author
            (managedObject as? NewsCD)?.content = items[index].content
            (managedObject as? NewsCD)?.desc = items[index].description
            (managedObject as? NewsCD)?.publishedAt = items[index].publishedAt
            (managedObject as? NewsCD)?.title = items[index].title
            (managedObject as? NewsCD)?.url = items[index].url
            (managedObject as? NewsCD)?.urlToImage = items[index].urlToImage

            index += 1
            return false
        }
        return batchInsert
    }

    func insertImage(url: String, image: UIImage) {
        let insertImage = ImageCD(context: persistentContainer.viewContext)
        insertImage.data = image.pngData()
        insertImage.imageUrl = url
    }

    // CoreData에 저장되어있는 ImageCD들을 불러온다.
    func getAllImages() -> [ImageCD]? {
        let fetchRequest = ImageCD.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false

        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    // CoreData에 저장되어있는 ImageCD들을 불러온다.
    func queryImage(imageUrl: String) -> ImageCD? {
        let fetchRequest = ImageCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "imageUrl == %@", imageUrl)
        fetchRequest.returnsObjectsAsFaults = false

        do {
            return try persistentContainer.viewContext.fetch(fetchRequest).first
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    // CoreData에 저장되어있는 모든 ImageCD를 삭제한다.
    func removeAllImages() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ImageCD")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.viewContext.execute(deleteRequest)
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
