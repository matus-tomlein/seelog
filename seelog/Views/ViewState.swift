//
//  File.swift
//  
//
//  Created by Matus Tomlein on 01/01/2020.
//

import Foundation
import SwiftUI
import Combine

final class ViewState: ObservableObject {
    var model: DomainModel

    init(model: DomainModel) {
        self.model = model
    }
}
