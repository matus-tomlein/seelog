//
//  RequestPermissionViewController.swift
//  seelog
//
//  Created by Matus Tomlein on 03/12/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import UIKit
import Photos

class RequestPermissionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueTriggered(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                self.performSegue(withIdentifier: "return", sender: nil)
            default:
                break
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
