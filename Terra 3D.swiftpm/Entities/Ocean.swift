//
//  Ocean.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import RealityKit

class Ocean: Entity, HasModel {
    static let waterLevel: Float = 0.15 // Remember 1 = 1 meter in reality kit
    
    
    required init() {
        super.init()
        let oceanMesh = MeshResource.generateBox(size: .init(x: 0.8, y: Float(Ocean.waterLevel), z: 0.8))
        let oceanMaterial = SimpleMaterial(color: .cyan, roughness: 0.5, isMetallic: true)
        self.components[OpacityComponent.self] = .init(opacity: 0.8)
        self.model = .init(mesh: oceanMesh, materials: [oceanMaterial])
    }
}
