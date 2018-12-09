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
    var processingHeatmaps = false
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
    @IBOutlet weak var countingLabel: UILabel!

    private var updateTimer: Timer?

    var persistentContainer : NSPersistentContainer?
    var initializationState = CurrentInitializationState()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.persistentContainer = appDelegate.persistentContainer
        
        requestPhotoAccess()
    }

    @objc func updateCounts() {
        DispatchQueue.main.async {
            self.seenAreaLabel.text = "\(Int(self.initializationState.seenArea.rounded())) km²"
            self.countriesLabel.text = "\(self.initializationState.numberOfCountries) countries"
            self.statesLabel.text = "\(self.initializationState.numberOfStates) units"
            self.citiesLabel.text = "\(self.initializationState.numberOfCities) cities"
            self.continentsLabel.text = "\(self.initializationState.numberOfContinents) continents"
            self.timezonesLabel.text = "\(self.initializationState.numberOfTimezones) timezones"
            self.countingLabel.text = self.initializationState.processingHeatmaps ? "Processing" : "Counting"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func requestPhotoAccess() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            accessGranted()

        case .denied, .restricted:
            accessDenied()

        default:
            accessNotDetermined()
        }
    }

    private func accessGranted() {
        startUpdateTimer()
        
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
    }

    private func accessDenied() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "permissionDenied", sender: nil)
        }
    }

    private func accessNotDetermined() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "requestPhotoAccess", sender: nil)
        }
    }

    private func startUpdateTimer() {
        if let timer = updateTimer { timer.invalidate() }
        updateTimer = Timer.scheduledTimer(timeInterval: 0.5,
                                           target: self,
                                           selector: #selector(self.updateCounts),
                                           userInfo: nil,
                                           repeats: true)
    }
    
}

