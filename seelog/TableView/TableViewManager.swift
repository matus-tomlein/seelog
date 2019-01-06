//
//  TableViewManager.swift
//  Seelog
//
//  Created by Matus Tomlein on 06/01/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

protocol TableViewManager {
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell
    func scrolledToBottom()
    func numberOfSections() -> Int
    func titleForHeaderInSection(section: Int) -> String?
    func setSearchQuery(_ query: String)
}
