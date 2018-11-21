//
//  synchronize.swift
//  seelog
//
//  Created by Matus Tomlein on 21/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

func synchronized<T>(_ lock: AnyObject, closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer {
        objc_sync_exit(lock)
    }
    return try closure()
}
