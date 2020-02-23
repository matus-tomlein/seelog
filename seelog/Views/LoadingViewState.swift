//
//  LoadingViewState.swift
//  seelog
//
//  Created by Matus Tomlein on 23/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation

final class LoadingViewState: ObservableObject {
    @Published var loading: Bool = true
    @Published var permissionGranted: Bool = true
    var viewState: ViewState?
}
