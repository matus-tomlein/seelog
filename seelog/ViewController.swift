//
//  ViewController.swift
//  seelog
//
//  Created by Matus Tomlein on 07/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import UIKit
import Photos
import CoreLocation
import CoreData

class ViewController: UIViewController {
    
    var persistentContainer : NSPersistentContainer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.persistentContainer = appDelegate.persistentContainer
        
        requestPhotoAccess()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                if let persistentContainer = self.persistentContainer {
                    let databaseInitializer = DatabaseInitializer(context: persistentContainer.viewContext)
                    databaseInitializer.start()
                }
                
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            }
        }
    }
    
}

