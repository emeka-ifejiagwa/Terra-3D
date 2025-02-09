//
//  TerrainMesh.swift
//  Terra 3D
//
//  Created by Jiexy on 2/8/25.
//

import RealityKit

class TerrainMesh: Entity, HasModel {
    
    
    required init() {
        super.init()
        self.components[TerrainHeightComponent.self] = TerrainHeightComponent()
        if let component = self.components[TerrainHeightComponent.self] {
            let modelComponent = ModelComponent(mesh: component.waterMesh, materials: [component.waterMaterial])
            self.model = modelComponent
        }

    }
}
