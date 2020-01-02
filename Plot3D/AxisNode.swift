//
//  AxisNode.swift
//  Plot3D
//
//  Created by Shant Tokatyan on 12/19/19.
//  Copyright © 2019 Stokaty. All rights reserved.
//

import SceneKit

public struct AxisConfiguration {
    
    let axisRadius: CGFloat
    let axisHeight: CGFloat
    let gridlineRadius: CGFloat
    let arrowBottomRadius: CGFloat
    let arrowHeight: CGFloat
    
    let xyGridSpacing: CGFloat
    let xzGridSpacing: CGFloat
    let yzGridSpacing: CGFloat
        
    let xyGridColor: UIColor
    let xzGridColor: UIColor
    let yzGridColor: UIColor
    
    static let defaultConfig = AxisConfiguration(axisRadius: 0.035,
                                                 axisHeight: 7,
                                                 gridlineRadius: 0.009,
                                                 arrowBottomRadius: 0.15,
                                                 arrowHeight: 0.3,
                                                 xyGridSpacing: 0.5,
                                                 xzGridSpacing: 0.5,
                                                 yzGridSpacing: 0.5,
                                                 xyGridColor: .red,
                                                 xzGridColor: .green,
                                                 yzGridColor: .yellow)
}

class AxisNode: SCNNode {
    
    // MARK: - Properties
    
    // Axis
    let axisHeight: CGFloat
    let axisRadius: CGFloat
    let gridlineRadius: CGFloat
    let xAxis: SCNGeometry
    let yAxis: SCNGeometry
    let zAxis: SCNGeometry
    let xAxisNode: SCNNode
    let yAxisNode: SCNNode
    let zAxisNode: SCNNode
    let originGeometry: SCNGeometry
    
    // Axis Arrows
    let xAxisArrow: SCNGeometry
    let yAxisArrow: SCNGeometry
    let zAxisArrow: SCNGeometry
    let xArrowNode: SCNNode
    let yArrowNode: SCNNode
    let zArrowNode: SCNNode
    
    // Planes
    let planeXY: SCNGeometry
    let planeXZ: SCNGeometry
    let planeYZ: SCNGeometry
    let planeXYNode: SCNNode
    let planeXZNode: SCNNode
    let planeYZNode: SCNNode
    
    // Grid
    var gridXY = [SCNGeometry]()
    
    // MARK: - Init
    
    init(config: AxisConfiguration) {
        
        axisHeight = config.axisHeight
        axisRadius = config.axisRadius
        gridlineRadius = config.gridlineRadius
        xAxis = SCNCylinder(radius: axisRadius, height: axisHeight)
        yAxis = SCNCylinder(radius: axisRadius, height: axisHeight)
        zAxis = SCNCylinder(radius: axisRadius, height: axisHeight)
        
        xAxisArrow = SCNCone(topRadius: 0, bottomRadius: config.arrowBottomRadius, height: config.arrowHeight)
        yAxisArrow = SCNCone(topRadius: 0, bottomRadius: config.arrowBottomRadius, height: config.arrowHeight)
        zAxisArrow = SCNCone(topRadius: 0, bottomRadius: config.arrowBottomRadius, height: config.arrowHeight)
        
        xAxisNode = SCNNode(geometry: xAxis)
        yAxisNode = SCNNode(geometry: yAxis)
        zAxisNode = SCNNode(geometry: zAxis)
        
        xArrowNode = SCNNode(geometry: xAxisArrow)
        yArrowNode = SCNNode(geometry: yAxisArrow)
        zArrowNode = SCNNode(geometry: zAxisArrow)
        
        originGeometry = SCNSphere(radius: axisRadius)
                
        let xyGridSpacing = config.xyGridSpacing
        let xzGridSpacing = config.xzGridSpacing
        let yzGridSpacing = config.yzGridSpacing
        
        planeXY = SCNPlane(width: xyGridSpacing, height: xyGridSpacing)
        planeXZ = SCNPlane(width: xzGridSpacing, height: xzGridSpacing)
        planeYZ = SCNPlane(width: yzGridSpacing, height: yzGridSpacing)
        
        planeXYNode = SCNNode(geometry: planeXY)
        planeXZNode = SCNNode(geometry: planeXZ)
        planeYZNode = SCNNode(geometry: planeYZ)
        
        super.init()
        
        setupAxis(axisHeight: axisHeight)
        setupPlanes(gridSpacingXY: xyGridSpacing, gridSpacingXZ: xzGridSpacing, gridSpacingYZ: yzGridSpacing)

        let xyGridColor = config.xyGridColor
        let xzGridColor = config.xzGridColor
        let yzGridColor = config.yzGridColor
        setupGridLines(rootNode: xAxisNode, spacing: xyGridSpacing, direction: SCNVector3(-1, 0, 0), color: xyGridColor)
        setupGridLines(rootNode: yAxisNode, spacing: xyGridSpacing, direction: SCNVector3(1, 0, 0), color: xyGridColor)

        setupGridLines(rootNode: xAxisNode, spacing: xzGridSpacing, direction: SCNVector3(0, 0, 1), color: xzGridColor)
        setupGridLines(rootNode: zAxisNode, spacing: xzGridSpacing, direction: SCNVector3(1, 0, 0), color: xzGridColor)

        setupGridLines(rootNode: yAxisNode, spacing: yzGridSpacing, direction: SCNVector3(0, 0, 1), color: yzGridColor)
        setupGridLines(rootNode: zAxisNode, spacing: yzGridSpacing, direction: SCNVector3(0, 0, -1), color: yzGridColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    func setupAxis(axisHeight: CGFloat) {
        xAxisNode.position = SCNVector3(axisHeight/2, 0, 0)
        xAxisNode.eulerAngles = SCNVector3(0, 0, -Double.pi/2)
        xArrowNode.position = SCNVector3(0, axisHeight/2, 0)
        xAxisNode.addChildNode(xArrowNode)
        addChildNode(xAxisNode)

        yAxisNode.position = SCNVector3(0, axisHeight/2, 0)
        yArrowNode.position = SCNVector3(0, axisHeight/2, 0)
        yAxisNode.addChildNode(yArrowNode)
        addChildNode(yAxisNode)
        
        zAxisNode.position = SCNVector3(0, 0, axisHeight/2)
        zAxisNode.eulerAngles = SCNVector3(Double.pi/2, 0, 0)
        zArrowNode.position = SCNVector3(0, axisHeight/2, 0)
        zAxisNode.addChildNode(zArrowNode)
        addChildNode(zAxisNode)

        originGeometry.materials.first!.diffuse.contents = UIColor.white
        let originNode = SCNNode(geometry: originGeometry)
        originNode.position = SCNVector3(0, 0, 0)
        addChildNode(originNode)
    }
    
    func setupPlanes(gridSpacingXY: CGFloat, gridSpacingXZ: CGFloat, gridSpacingYZ: CGFloat) {
        
        let offsetXY = gridSpacingXY/2
        planeXY.materials.first!.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
        planeXYNode.position = SCNVector3(offsetXY, offsetXY, 0)
        addChildNode(planeXYNode)
        
        let offsetXZ = gridSpacingXZ/2
        planeXZ.materials.first!.diffuse.contents = UIColor.green.withAlphaComponent(0.5)
        planeXZNode.eulerAngles = SCNVector3(-Double.pi/2, 0, 0)
        planeXZNode.position = SCNVector3(offsetXZ, 0, offsetXZ)
        addChildNode(planeXZNode)
        
        let offsetYZ = gridSpacingYZ/2
        planeYZ.materials.first!.diffuse.contents = UIColor.yellow.withAlphaComponent(0.5)
        planeYZNode.eulerAngles = SCNVector3(0, Double.pi/2, 0)
        planeYZNode.position = SCNVector3(0, offsetYZ, offsetYZ)
        addChildNode(planeYZNode)
    }
    
    func setupGridLines(rootNode: SCNNode, spacing: CGFloat, direction: SCNVector3, color: UIColor) {
        let lineCount = Int(axisHeight/spacing)
        for i in 0..<lineCount {
            let gridLine = SCNCylinder(radius: gridlineRadius, height: axisHeight)
            gridLine.materials.first!.diffuse.contents = color
            let gridLineNode = SCNNode(geometry: gridLine)
            let position = spacing * CGFloat(i + 1)
            gridLineNode.position = SCNVector3(position, position, position) * direction
            rootNode.addChildNode(gridLineNode)
        }
    }
    
}
