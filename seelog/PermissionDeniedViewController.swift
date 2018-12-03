//
//  PermissionDeniedViewController.swift
//  seelog
//
//  Created by Matus Tomlein on 03/12/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import UIKit

class PermissionDeniedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func openSettingsTriggered(_ sender: Any) {
        DispatchQueue.main.async {
            if let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
