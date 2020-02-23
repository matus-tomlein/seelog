//
//  WorldView.swift
//  seelog
//
//  Created by Matus Tomlein on 16/02/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import SwiftUI
import GEOSwift

struct PolygonView: View {
    var polygonExteriors: [[(Double, Double)]]
    var polygonColors: [Color]
    var points: [(Double, Double)]
    var pointColors: [Color]
    var minX: Double
    var maxX: Double
    var maxY: Double
    var minY: Double

    var body: some View {
        GeometryReader { geometry in
            ForEach(self.processedPolygons(width: geometry.size.width, height: geometry.size.height)) { polygon in
                Path { path in
                    path.move(
                        to: CGPoint(
                            x: 0,
                            y: 0
                        )
                    )

                    for (x, y) in polygon.points {
                        path.addLine(
                            to: .init(
                                x: x,
                                y: y
                            )
                        )
                    }
                }
                .fill(self.polygonColors[polygon.id])
            }

            ForEach(self.processedPoints(width: geometry.size.width, height: geometry.size.height)) { point in
                Circle()
                    .fill(self.pointColors[point.id])
                    .frame(width: CGFloat(10), height: CGFloat(10))
                    .opacity(0.7)
                    .offset(x: CGFloat(point.x), y: CGFloat(point.y))
            }
        }
    }
}

struct PolygonPoints: Identifiable {
    var id: Int
    var points: [(Double, Double)]
}

struct PointPosition: Identifiable {
    var id: Int
    var x: Double
    var y: Double
}

extension PolygonView {
    func processedPolygons(width: CGFloat, height: CGFloat) -> [PolygonPoints] {
        let scale = max(
            (maxX - minX) / Double(width),
            (maxY - minY) / Double(height)
        )

        return polygonExteriors.enumerated().map { (i, points) in
            PolygonPoints(
                id: i,
                points: points.map { (x, y) in
                    ((x - minX) / scale, (y - minY) / scale)
                }
            )
        }
    }

    func processedPoints(width: CGFloat, height: CGFloat) -> [PointPosition] {
        let scale = max(
            (maxX - minX) / Double(width),
            (maxY - minY) / Double(height)
        )

        return points.enumerated().map { (i, point) in
            PointPosition(
                id: i,
                x: (point.0 - minX) / scale,
                y: (point.1 - minY) / scale
            )
        }
    }

    init(shapes: [(geometry: Geometry?, color: Color)], points: [(lat: Double, lng: Double, color: Color)]) {
        let polygonsAndColors = shapes.flatMap { (geometry, color) ->
            [(Polygon, Color)] in
            var polygons: [Polygon] = []
            if let geometry = geometry {
                switch geometry {
                case let .multiPolygon(p):
                    polygons = p.polygons
                    
                case let .polygon(p):
                    polygons = [p]

                default:
                    polygons = []
                }
            }
            return polygons.map { polygon in (polygon, color)}
        }
        let polygons = polygonsAndColors.map { $0.0 }
        
        let polygonPoints = polygons.map { polygon in
            polygon.exterior.points.map { (
                (180 + $0.x) / 360,
                (90 - $0.y) / 180
            ) }
        }
        let ranges = polygonPoints.map { points -> (maxX: Double, maxY: Double, minX: Double, minY: Double, points: [(Double, Double)]) in
            let allX = points.map({ $0.0 })
            let allY = points.map({ $0.1 })
            let maxX = allX.max() ?? 0
            let minX = allX.min() ?? 0
            let maxY = allY.max() ?? 0
            let minY = allY.min() ?? 0
            return (
                maxX: maxX,
                maxY: maxY,
                minX: minX,
                minY: minY,
                points: points
            )
        }
        self.minX = ranges.map { $0.minX }.min() ?? 0
        self.maxX = ranges.map { $0.maxX }.max() ?? 0
        self.maxY = ranges.map { $0.maxY }.max() ?? 0
        self.minY = ranges.map { $0.minY }.min() ?? 0
        self.polygonExteriors = ranges.map { $0.points }
        
        self.polygonColors = polygonsAndColors.map { $0.1 }
        self.points = points.map { (
            (180 + $0.lng) / 360,
            (90 - $0.lat) / 180
        ) }
        self.pointColors = points.map { $0.2 }
    }
}

struct PolygonView_Previews: PreviewProvider {
    static var previews: some View {
        let geoDB = GeoDatabase()
        let country = geoDB.countryInfoFor(countryKey: "GBR")!
        let city = geoDB.cityInfoFor(cityKey: 7266)
        let geometry = country.geometry10m!
        return PolygonView(
            shapes: [(geometry: geometry, color: .red)],
            points: [(lat: city?.latitude ?? 0, lng: city?.longitude ?? 0, color: .black)]
        )
    }
}
