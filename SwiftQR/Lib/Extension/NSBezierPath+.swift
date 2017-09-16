//
//  XXXX.swift
//  SwiftQR
//
//  Created by 马权 on 16/09/2017.
//  Copyright © 2017 马权. All rights reserved.
//


public extension NSBezierPath {
    
    public var CGPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveToBezierPathElement: path.move(to: points[0])
            case .lineToBezierPathElement: path.addLine(to: points[0])
            case .curveToBezierPathElement: path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePathBezierPathElement: path.closeSubpath()
            }
        }
        return path
    }
    
}
