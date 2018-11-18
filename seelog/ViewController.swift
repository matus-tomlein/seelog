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

class CurrentInitializationState {
    var seenArea: Double = 0
    var numberOfCountries: Int = 0
    var numberOfStates: Int = 0
    var numberOfCities: Int = 0
    var numberOfContinents: Int = 0
    var numberOfTimezones: Int = 0
}

class ViewController: UIViewController {
    @IBOutlet weak var seenAreaLabel: UILabel!
    @IBOutlet weak var countriesLabel: UILabel!
    @IBOutlet weak var statesLabel: UILabel!
    @IBOutlet weak var citiesLabel: UILabel!
    @IBOutlet weak var continentsLabel: UILabel!
    @IBOutlet weak var timezonesLabel: UILabel!

    private var updateTimer: Timer?

    var persistentContainer : NSPersistentContainer?
    var initializationState = CurrentInitializationState()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.persistentContainer = appDelegate.persistentContainer
        
        requestPhotoAccess()

        updateTimer = Timer.scheduledTimer(timeInterval: 0.5,
                                           target: self,
                                           selector: #selector(self.updateCounts),
                                           userInfo: nil,
                                           repeats: true)
    }

    @objc func updateCounts() {
        self.seenAreaLabel.text = "\(Int(initializationState.seenArea.rounded())) km²"
        self.countriesLabel.text = "\(initializationState.numberOfCountries) countries"
        self.statesLabel.text = "\(initializationState.numberOfStates) divisions"
        self.citiesLabel.text = "\(initializationState.numberOfCities) cities"
        self.continentsLabel.text = "\(initializationState.numberOfContinents) continents"
        self.timezonesLabel.text = "\(initializationState.numberOfTimezones) timezones"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                if let persistentContainer = self.persistentContainer {
                    let context = persistentContainer.newBackgroundContext()
                    context.perform {
                        let databaseInitializer = DatabaseInitializer(initializationState: &self.initializationState,
                                                                      context: context)
                        databaseInitializer.start()
                        DispatchQueue.main.async {
                            self.updateTimer?.invalidate()
                            self.performSegue(withIdentifier: "continue", sender: nil)
                        }
                    }
                }
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            }
        }
    }
    
}

