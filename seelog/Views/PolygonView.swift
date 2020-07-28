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
    var polygonExteriors: [[(x: Double, y: Double)]]
    var polygonColors: [Color]
    var polygonOpacities: [Double]
    var points: [(x: Double, y: Double)]
    var rectangles: [(x: Double, y: Double, width: Double, height: Double)]
    var pointColors: [Color]
    var pointSizes: [CGFloat]
    var pointOpacities: [Double]
    var minX: Double
    var maxX: Double
    var maxY: Double
    var minY: Double
    var width: Double { return maxX - minX }
    var height: Double { return maxY - minY }

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
                .opacity(self.polygonOpacities[polygon.id])
            }

            ForEach(self.processedRectangles(width: geometry.size.width, height: geometry.size.height)) { rectangle in
                Rectangle()
                    .fill(Color.white)
                    .frame(width: CGFloat(rectangle.width), height: CGFloat(rectangle.height))
                    .opacity(0.4)
                    .offset(x: CGFloat(rectangle.x), y: CGFloat(rectangle.y))
            }

            ForEach(self.processedPoints(width: geometry.size.width, height: geometry.size.height)) { point in
                Circle()
                    .fill(self.pointColors[point.id])
                    .frame(width: self.pointSizes[point.id], height: self.pointSizes[point.id])
                    .opacity(self.pointOpacities[point.id])
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

struct RectanglePosition: Identifiable {
    var id: Int
    var x: Double
    var y: Double
    var width: Double
    var height: Double
}

extension PolygonView {
    func scale(width: CGFloat, height: CGFloat) -> (Double, Double, Double) {
        let scale = max(
            (maxX - minX) / Double(width),
            (maxY - minY) / Double(height)
        )
        return (
            scale,
            max(0, (Double(width) - self.width / scale) / 2),
            max(0, (Double(height) - self.height / scale) / 2)
        )
    }
    
    func processedRectangles(width: CGFloat, height: CGFloat) -> [RectanglePosition] {
        let (scale, paddingX, paddingY) = self.scale(width: width, height: height)
        
        return rectangles.enumerated().map { (i, rectangle) in
            RectanglePosition(
                id: i,
                x: getX(rectangle.x, scale: scale, paddingX: paddingX),
                y: getY(rectangle.y, scale: scale, paddingY: paddingY),
                width: rectangle.width / scale,
                height: rectangle.height / scale
            )
        }
    }

    func processedPolygons(width: CGFloat, height: CGFloat) -> [PolygonPoints] {
        let (scale, paddingX, paddingY) = self.scale(width: width, height: height)

        return polygonExteriors.enumerated().map { (i, points) in
            PolygonPoints(
                id: i,
                points: points.map { (x, y) in
                    (
                        getX(x, scale: scale, paddingX: paddingX),
                        getY(y, scale: scale, paddingY: paddingY)
                    )
                }
            )
        }
    }

    func processedPoints(width: CGFloat, height: CGFloat) -> [PointPosition] {
        let (scale, paddingX, paddingY) = self.scale(width: width, height: height)

        return points.enumerated().map { (i, point) in
            PointPosition(
                id: i,
                x: getX(point.x, scale: scale, paddingX: paddingX),
                y: getY(point.y, scale: scale, paddingY: paddingY)
            )
        }
    }
    
    func getX(_ x: Double, scale: Double, paddingX: Double) -> Double {
        return (max(min(x, maxX), minX) - minX) / scale + paddingX
    }
    
    func getY(_ y: Double, scale: Double, paddingY: Double) -> Double {
        return (max(min(y, maxY), minY) - minY) / scale + paddingY
    }

    init(
        shapes: [(geometryDescription: GeometryDescription, color: Color, opacity: Double)],
        points: [(x: Double, y: Double, color: Color, size: Double, opacity: Double)],
        rectangles: [(x: Double, y: Double, width: Double, height: Double)],
        minX: Double,
        maxX: Double,
        minY: Double,
        maxY: Double
    ) {
        self.polygonExteriors = shapes.flatMap { shape in
            shape.geometryDescription.polygonPoints
        }
        self.polygonColors = shapes.flatMap { shape in
            shape.geometryDescription.polygons.map { _ in shape.color }
        }
        self.polygonOpacities = shapes.flatMap { shape in
            shape.geometryDescription.polygons.map { _ in shape.opacity }
        }

        self.minX = minX
        self.minY = minY
        self.maxX = maxX
        self.maxY = maxY

        self.points = points.map { (x: $0.x, y: $0.y) }
        self.pointColors = points.map { $0.color }
        self.pointSizes = points.map { CGFloat($0.size) }
        self.pointOpacities = points.map { $0.opacity }
        self.rectangles = rectangles
    }
}

struct PolygonView_Previews: PreviewProvider {
    static var previews: some View {
        let geoDB = GeoDatabase()
        let country = geoDB.countryInfoFor(countryKey: "ARG")!
        let city = geoDB.cityInfoFor(cityKey: 7266)
        let geometry = country.geometry10mDescription
        return PolygonView(
            shapes: [(geometryDescription: geometry, color: .red, opacity: 1)],
            points: [(
                x: Helpers.longitudeToX(city?.longitude ?? 0),
                y: Helpers.latitudeToY(city?.latitude ?? 0),
                color: .black,
                size: 10,
                opacity: 0.7
            )],
            rectangles: [],
            minX: geometry.minX,
            maxX: geometry.maxX,
            minY: geometry.minY,
            maxY: geometry.maxY
        )
    }
}
