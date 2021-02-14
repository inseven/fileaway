//
//  RoundedCorner.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 09/12/2020.
//

import SwiftUI

struct RoundedCorner: Shape {

    let radius: CGFloat
    let corners: RectCorner

    func path(in rect: CGRect) -> Path {

        let topLeftRadius: CGFloat = corners.contains(.topLeft) ? radius : 0
        let bottomLeftRadius: CGFloat = corners.contains(.bottomLeft) ? radius : 0
        let bottomRightRadius: CGFloat = corners.contains(.bottomRight) ? radius : 0
        let topRightRadius: CGFloat = corners.contains(.topRight) ? radius : 0

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: topLeftRadius))
        path.addLine(to: CGPoint(x: 0, y: rect.height - bottomLeftRadius))
        path.addArc(center: CGPoint(x: bottomLeftRadius, y: rect.height - bottomLeftRadius),
                    radius: bottomLeftRadius,
                    startAngle: CGFloat.pi,
                    endAngle: (CGFloat.pi / 2),
                    clockwise: true)
        path.addLine(to: CGPoint(x: rect.width - bottomRightRadius, y: rect.height))
        path.addArc(center: CGPoint(x: rect.width - bottomRightRadius, y: rect.height - bottomRightRadius),
                    radius: bottomRightRadius,
                    startAngle: (CGFloat.pi / 2),
                    endAngle: 0,
                    clockwise: true)
        path.addLine(to: CGPoint(x: rect.width, y: topRightRadius))
        path.addArc(center: CGPoint(x: rect.width - topRightRadius, y: topRightRadius),
                    radius: topRightRadius,
                    startAngle: 0,
                    endAngle: (CGFloat.pi / 2) * 3,
                    clockwise: true)
        path.addLine(to: CGPoint(x: topLeftRadius, y: 0))
        path.addArc(center: CGPoint(x: topLeftRadius, y: topLeftRadius),
                    radius: topLeftRadius,
                    startAngle: (CGFloat.pi / 2) * 3,
                    endAngle: CGFloat.pi,
                    clockwise: true)
        path.closeSubpath()
        return Path(path)
    }
}
