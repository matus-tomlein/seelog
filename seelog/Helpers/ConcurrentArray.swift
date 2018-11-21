//
//  ConcurrentArray.swift
//  seelog
//
//  Created by Matus Tomlein on 21/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

class ConcurrentArray<T> {
    private var dataSource: Array<T>

    init() {
        self.dataSource = [T]()
    }

    func append(_ element: T) {
        synchronized(self) {
            dataSource.append(element)
        }
    }

    func removeLast() -> T {
        return synchronized(self) { () -> T in
            return dataSource.removeLast()
        }
    }

    func removeFirst() -> T {
        return synchronized(self) { () -> T in
            return dataSource.removeFirst()
        }
    }

    func removeAtIndex(_ index: Int) -> T {
        return synchronized(self) { () -> T in
            return dataSource.remove(at: index)
        }
    }

    func removeAll(_ keepCapacity: Bool = false) {
        synchronized(self) {
            dataSource.removeAll(keepingCapacity: keepCapacity)
        }
    }
}
