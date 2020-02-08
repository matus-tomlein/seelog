//
//  BlockingQueue.swift
//  seelog
//
//  Created by Matus Tomlein on 21/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

class BlockingQueue<Element> {
    private var dataSource: ConcurrentArray<Element>
    private let dataSemaphore: DispatchSemaphore

    init() {
        dataSource = ConcurrentArray<Element>()
        dataSemaphore = DispatchSemaphore(value: 0)
    }

    func add(_ e: Element) {
        dataSource.append(e)

        // New data available.
        dataSemaphore.signal()
    }

    func take(_ timeout: TimeInterval? = nil) -> Element {
        let t: DispatchTime
        if let timeout = timeout {
            t = DispatchTime.now() + Double(Int64(timeout * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        } else {
            t = DispatchTime.distantFuture
        }

        let _ = dataSemaphore.wait(timeout: t)

        // This will throw error if there's no element.
        return dataSource.removeFirst()
    }
}
