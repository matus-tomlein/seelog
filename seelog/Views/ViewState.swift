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
    @Published var selectedYear: Int?
    @Published var loading: Bool = false
    var model: DomainModel

    init(model: DomainModel) {
        self.model = model
    }
}
