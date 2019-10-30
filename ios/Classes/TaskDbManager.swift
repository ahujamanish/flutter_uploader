//
//  TaskDbManager.swift
//  flutter_uploader
//
//  Created by Max Onishi on 25/10/19.
//

import Foundation
import SQLite

public class TaskDbManager : NSObject {
    
    let DB_FILE_NAME = "flutter_uploader_db"
    let db: Connection?
    let tasks: Table = Table("tasks")
  
    let id = Expression<Int64>("id")
    let taskId = Expression<String>("taskId")
    let status = Expression<Int>("status")
    let progress = Expression<Int>("progress")
    let tag = Expression<String?>("tag")
    let requestFilePath = Expression<String?>("requestfilePath")
    let url = Expression<String>("url")
    let method = Expression<String>("method")
    
    
    public override init() {
         let path = NSSearchPathForDirectoriesInDomains(
                             .documentDirectory, .userDomainMask, true
         ).first!

        db = try? Connection("\(path)/\(DB_FILE_NAME).sqlite3")
        super.init()
    }
    
    public func initialize() -> Void {
        guard let conn = db else {
            NSLog("database connection is not initialized")
            return
        }
        
        do {
            try conn.run(tasks.create(ifNotExists: true) { t in
                   t.column(id, primaryKey: .autoincrement)
                   t.column(taskId, unique: true)
                   t.column(progress)
                   t.column(tag)
                   t.column(requestFilePath)
                   t.column(url)
                   t.column(method)
              
               })
            
            try conn.run(tasks.createIndex(taskId, ifNotExists: true))
            try conn.run(tasks.createIndex(tag, ifNotExists: true))
            try conn.run(tasks.createIndex(status, ifNotExists: true))
        }
        catch {
            print("table initialization falied")
        }
    }
    
    public func add(_ task: UploadTaskInfo) -> Int64 {
        guard let conn = db else {
            print("database connection is not initialized")
            return 0
        }
        
        do {
            let rowId = try conn.run(tasks.insert(taskId <- task.taskId, progress <- task.progress, tag <- task.tag, requestFilePath <- task.requestFilePath,
                                                url <- task.url, method <- task.method))
            return rowId
        } catch {
            print("insertion failed: \(error)")
        }
        
        return 0;
    }
    
    public func remove(taskId _taskId: String) -> Void {
        guard let conn = db else {
            print("database connection is not initialized")
            return
        }
        
        do {
            let task = tasks.filter(taskId == _taskId)
            try conn.run(task.delete())
        } catch {
            print("deletion failed: \(error)")
        }
    }

    public func removeByTag(tag _tag: String) -> Void {
           guard let conn = db else {
               NSLog("database connection is not initialized")
               return
           }
           
            do {
                 let tasksByTag = tasks.filter(tag == _tag)
                  try conn.run(tasksByTag.delete())
              } catch {
                  print("deletion failed: \(error)")
              }
    }
    
    public func update(taskId _taskId: String, _ task: UploadTaskInfo) -> Void {
              guard let conn = db else {
                  NSLog("database connection is not initialized")
                  return
              }
              
              do {
                  let item = tasks.filter(taskId == _taskId)
                try conn.run(item.update(
                progress <- task.progress,
                    url <- task.url, method <- task.method))
              } catch {
                  print("update failed: \(error)")
              }
    }
    
    
    public func update(tag _tag: String, _ task: UploadTaskInfo) -> Void {
                 guard let conn = db else {
                     NSLog("database connection is not initialized")
                     return
                 }
                 
                 do {
                     let item = tasks.filter(tag == _tag)
                   try conn.run(item.update(
                       progress <- task.progress,
                       status <- task.status))
                 } catch {
                     print("update failed: \(error)")
                 }
   }
    
    public func getByStatus(status _status: Int) ->  [UploadTaskInfo] {
      guard let conn = db else {
            NSLog("database connection is not initialized")
            return []
        }
        
        var results: [UploadTaskInfo] = []
        do {
            let items = tasks.filter(status == _status)
            for task in try conn.prepare(items) {
                results.append(UploadTaskInfo(
                    id: task[id],
                    taskId: task[taskId],
                    status: task[status],
                    progress: task[progress],
                    tag: task[tag],
                    requestFilePath: task[requestFilePath],
                    url:task[url],
                    method: task[method]
                ))
          }
        } catch {
            print("getByTaskId failed: \(error)")
        }
        
        return results
    }
    
    public func getByTaskId(taskId _taskId: String) -> [UploadTaskInfo] {
        guard let conn = db else {
            NSLog("database connection is not initialized")
            return []
        }
        
        var results: [UploadTaskInfo] = []
        do {
            let item = tasks.filter(taskId == _taskId)
            for task in try conn.prepare(item) {
                results.append(UploadTaskInfo(
                    id: task[id],
                    taskId: _taskId,
                    status: task[status],
                    progress: task[progress],
                    tag: task[tag],
                    requestFilePath: task[requestFilePath],
                    url:task[url],
                    method: task[method]
                ))
          }
        } catch {
            print("getByTaskId failed: \(error)")
        }
        
        return results
    }

    public func getByTag(tag _tag: String) ->  [UploadTaskInfo] {
        guard let conn = db else {
            NSLog("database connection is not initialized")
            return []
        }
        
        var results: [UploadTaskInfo] = []
        
        do {
            let items = tasks.filter(tag == _tag)
            for task in try conn.prepare(items) {
                results.append(UploadTaskInfo(
                    id: task[id],
                    taskId: task[taskId],
                    status: task[status],
                    progress: task[progress],
                    tag: task[tag],
                    requestFilePath: task[requestFilePath],
                    url:task[url],
                    method: task[method]
                ))
          }
        } catch {
            print("getByTaskId failed: \(error)")
        }
        
        return results
    }
}

public struct UploadTaskInfo {
    var id:Int64
    var taskId: String
    var status: Int
    var progress: Int
    var tag: String?
    var requestFilePath: String?
    var url: String
    var method: String


    init(id:Int64, taskId: String,
         status: Int,
         progress: Int,
         tag: String?,
         requestFilePath: String?,
         url:String,
         method: String
         ) {
        self.id = id
        self.taskId = taskId
        self.status = status
        self.progress = progress
        self.requestFilePath = requestFilePath
        self.url = url
        self.method = method
    }
}

