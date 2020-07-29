//
//  SelectedYearState.swift
//  seelog
//
//  Created by Matus Tomlein on 29/07/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

class SelectedYearState: ObservableObject {
    @Published var year: Int? = nil
}
