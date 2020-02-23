//
//  LogbookView.swift
//  seelog
//
//  Created by Matus Tomlein on 16/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct LogbookView: View {
    @EnvironmentObject var viewState: ViewState
    
    var body: some View {
        List(viewState.model.years.reversed()) { year in
            Text(String(year.year))
                .font(.headline)
        }
    }
}

struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DomainModel(trips: loadTrips(), seenGeometries: [], geoDatabase: GeoDatabase())
        
        return LogbookView()
            .environmentObject(ViewState(model: model))
    }
}
