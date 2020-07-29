//
//  TextInfoView.swift
//  seelog
//
//  Created by Matus Tomlein on 27/07/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI

struct TextInfoInnerView: View {
    var info: TextInfo
    var addHeading: Bool = true
    var status: String {
        switch info.status {
        case .notVisited:
            return "You didn't visit."
            
        case .explored:
            return "You explored it here well!"
            
        case .native:
            return "You are basically a native!"

        case .new:
            return "First year here."
            
        case .stayed:
            return "You stayed here for a long time!"
            
        case .passedThrough:
            return "Just passed-through."
            
        case .regular:
            return "You are a regular!"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if !addHeading {
                Text(status).font(.headline)
            }

            if info.enabled {
                if addHeading {
                    Text(info.heading).font(.headline)
                }
                ForEach(info.body, id: \.self) { body in
                    Text(body).font(.footnote)
                }
            } else if addHeading {
                Text(info.heading)
                .bold()
                .foregroundColor(.gray)
            }
        }
    }
}

struct TextInfoView: View {
    @EnvironmentObject var viewState: ViewState
    var info: TextInfo
    var addHeading: Bool = true

    var body: some View {
        infoBodyWithBackground()
    }
}

extension TextInfoView {
    func infoBodyWithBackground() -> AnyView {
        let body = infoBody()
        switch info.status {
        case .new:
            return AnyView(body.listRowBackground(Color.blue.opacity(0.3)))
        case .explored:
            return AnyView(body.listRowBackground(Color.green.opacity(0.3)))
        case .stayed:
            return AnyView(body.listRowBackground(Color.yellow.opacity(0.3)))
        case .native:
            return AnyView(body.listRowBackground(Color.red.opacity(0.3)))
        case .regular:
            return AnyView(body.listRowBackground(Color.purple.opacity(0.3)))
        default:
            return AnyView(body.listRowBackground(Color(UIColor.systemBackground)))
        }
    }
    
    func infoBody() -> AnyView {
        if !addHeading {
            return AnyView(TextInfoInnerView(info: info, addHeading: false))
        }

        switch info.link {
        case .countries:
            return AnyView(NavigationLink(destination: CountriesView().environmentObject(self.viewState)) {
                TextInfoInnerView(info: info)
            })

        case .country(let country):
            return AnyView(NavigationLink(destination: CountryView(country: country).environmentObject(self.viewState)) {
                TextInfoInnerView(info: info)
            })

        case .region(let region):
            return AnyView(NavigationLink(destination: StateView(state: region).environmentObject(self.viewState)) {
                TextInfoInnerView(info: info)
            })

        case .cities:
            return AnyView(NavigationLink(destination: CitiesView().environmentObject(self.viewState)) {
                TextInfoInnerView(info: info)
            })
                
        case .city(let city):
            return AnyView(NavigationLink(destination: CityView(city: city).environmentObject(self.viewState)) {
                TextInfoInnerView(info: info)
            })

        case .timezones:
            return AnyView(NavigationLink(destination: TimezonesView().environmentObject(self.viewState)) {
                TextInfoInnerView(info: info)
            })

        case .timezone(let timezone):
            return AnyView(NavigationLink(destination: TimezoneView(timezone: timezone).environmentObject(self.viewState)) {
                TextInfoInnerView(info: info)
            })

        case .continents:
            return AnyView(NavigationLink(destination: ContinentsView().environmentObject(self.viewState)) {
                TextInfoInnerView(info: info)
            })

        case .continent(let continent):
            return AnyView(NavigationLink(destination: ContinentView(continent: continent).environmentObject(self.viewState)) {
                TextInfoInnerView(info: info)
            })

        default:
            return AnyView(TextInfoInnerView(info: info))
        }
    }
}

struct TextInfoView_Previews: PreviewProvider {
    static var previews: some View {
        TextInfoView(info: TextInfo(
            id: "test",
            link: .none,
            heading: "Hello darkness, my old friend.",
            status: .passedThrough,
            body: ["I've come to live with you again."]
        ))
    }
}
