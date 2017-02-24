//
//  ViewController.swift
//  Core Data Persistence
//
//  Created by Kim Topley on 10/26/15.
//  Copyright © 2015 Apress Inc. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    fileprivate static let lineEntityName = "Line"
    fileprivate static let lineNumberKey = "lineNumber"
    fileprivate static let lineTextKey = "lineText"
    @IBOutlet var lineFields:[UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let appDelegate =
                    UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ViewController.lineEntityName)
        
        do {
            let objects = try context.fetch(request)
            for object in objects {
                let lineNum =
                    ((object as AnyObject).value(forKey: ViewController.lineNumberKey)! as AnyObject).integerValue
                let lineText = (object as AnyObject).value(forKey: ViewController.lineTextKey) as? String ?? ""
                let textField = lineFields[lineNum!]
                textField.text = lineText
            }
            
            let app = UIApplication.shared
            NotificationCenter.default.addObserver(self,
                            selector: #selector(UIApplicationDelegate.applicationWillResignActive(_:)),
                            name: NSNotification.Name.UIApplicationWillResignActive,
                            object: app)
       } catch {
            // Error thrown from executeFetchRequest()
            print("There was an error in executeFetchRequest(): \(error)")
       }
    }

    func applicationWillResignActive(_ notification:Notification) {
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        for i in 0 ..< lineFields.count {
            let textField = lineFields[i]
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: ViewController.lineEntityName)
            let pred = NSPredicate(format: "%K = %d", ViewController.lineNumberKey, i)
            request.predicate = pred
            
            do {
                let objects = try context.fetch(request)
                var theLine:NSManagedObject! = objects.first as? NSManagedObject
                if theLine == nil {
                    // No existing data for this row – insert a new managed object for it
                    theLine =
                        NSEntityDescription.insertNewObject(
                                forEntityName: ViewController.lineEntityName,
                                into: context)
                                as NSManagedObject
                }
            
                theLine.setValue(i, forKey: ViewController.lineNumberKey)
                theLine.setValue(textField.text, forKey: ViewController.lineTextKey)
            } catch {
                print("There was an error in executeFetchRequest(): \(error)")
            }
        }
        appDelegate.saveContext()
    }
}

