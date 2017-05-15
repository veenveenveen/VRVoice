//
//  CoreDataManager.swift
//  VRClient
//
//  Created by 黄启明 on 2017/4/27.
//  Copyright © 2017年 黄启明. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    fileprivate let entityName = "AudioRecordItem"
    
    //FetchedResultsController控制器
//    var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult>!
    
    //单例
    static let `default`: CoreDataManager = CoreDataManager()
    fileprivate override init() {
        super.init()
        
//        //创建请求对象，并指明操作Note表
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
//        // 设置排序规则
//        let sort = NSSortDescriptor(key: "creatDate", ascending: false)
//        request.sortDescriptors = [sort];
//        //创建NSFetchedResultsController控制器实例，并绑定MOC
//        fetchedResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "creatDate", cacheName: nil)
//        
//        do {
//            try fetchedResultController.performFetch()
//        }
//        catch {
//            print(#function, "fetch error")
//        }
    }
    
    
    //MARK: - core data stack
    
    //管理对象模型
    fileprivate var modelURL: URL {
        if let url = Bundle.main.url(forResource: "VRClient", withExtension: "momd") {
            return url
        }
        fatalError("CoreDataManager : fetch modelURL error")
    }
    
    fileprivate lazy var managerObjectModel: NSManagedObjectModel = {
        guard let mom = NSManagedObjectModel(contentsOf: self.modelURL) else {
            fatalError("CoreDataManager : managerObjectModel error")
        }
        return mom
    }()
    
    //持久化存储调度器
    
    fileprivate let audioDBName = "VRClient_database_audio.sqlite"
    
    fileprivate var dbDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
    
    fileprivate var storeURL: URL {
        return dbDirectory.appendingPathComponent(audioDBName)
    }
    
    /*添加存储器
     Type:存储类型, 数据库/XML/二进制/内存
     configuration:不需要额外配置,可以为nil
     URL:数据保存的文件的URL 这里我们放到documents里
     options:可以为空
     */
    /** options
     * 0. 禁用数据库WAL日志记录模式: NSSQLitePragmasOption = ["journal_mode":"DELETE"]
     * 1. 低版本存储区迁移到新模型: NSMigratePersistentStoresAutomaticallyOption = true
     * 2. 轻量级的迁移方式: NSInferMappingModelAutomaticallyOption = true
     * 3. 默认的迁移方式: NSInferMappingModelAutomaticallyOption = false
     */
    fileprivate lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managerObjectModel)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: nil)
        }
        catch {
            print(#function, "add Persistent Store error")
        }
        
        return coordinator
    }()
    
    //管理对象上下文
    fileprivate lazy var managedObjectContext: NSManagedObjectContext = {
       let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }()
    
    //MARK: -
    
    //保存上下文
    func saveContext () {
        let context = managedObjectContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //插入数据
    func insert(item: AudioData) {
        let context = managedObjectContext
        context.perform { 
            let itemObj = NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: context) as! AudioRecordItem
            itemObj.creatDate = item.recordDate as NSDate
            itemObj.duration = item.duration
            itemObj.filename = item.filename
            itemObj.translation = item.translation
            self.saveContext()
        }
    }
    
    //删除数据
    @discardableResult
    func remove(data: AudioData) -> Bool{
        var flag = true
        
        let context = managedObjectContext
        context.performAndWait {
            do {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
//                request.predicate = NSPredicate(format: "createDate = %@", data.recordDate as NSDate)
                request.predicate = NSPredicate(format: "filename = %@", data.filename)
                
                let result = try context.fetch(request)
                result.forEach { context.delete($0 as! NSManagedObject) }
                
                self.saveContext()
            }
            catch {
                print(#function,error.localizedDescription)
                flag = false
            }
        }
        return flag
    }
    
    //查询本地数据 并返回
    func loadLocalData() -> [AudioData]? {
        let context = managedObjectContext
        //获取本地录音
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var result: [AudioData]?
        context.performAndWait {
            do {
                let res = try context.fetch(request) as! [AudioRecordItem]
                for r in res {
                    print(r.filename!)
                }
                result = res.map({ AudioData(filename: $0.filename!, duration: $0.duration, recordDate: $0.creatDate! as Date) })
            }
            catch {
                print(#function, error.localizedDescription)
            }
            
        }
        return result
    }
}
