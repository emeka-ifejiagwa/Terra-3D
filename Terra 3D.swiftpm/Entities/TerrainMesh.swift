//
//  TerrainMesh.swift
//  Terra 3D
//
//  Created by Jiexy on 2/8/25.
//

import RealityKit

let MAP_WIDTH = 512
let MAP_HEIGHT = 512

class TerrainMesh: Entity, HasModel {
    
    
    required init() {
        super.init()
        self.components[TerrainMapComponent.self] = TerrainMapComponent(height: MAP_HEIGHT,
                                                                              width: MAP_WIDTH)
        if let component = self.components[TerrainMapComponent.self] {
            let modelComponent = ModelComponent(mesh: component.terrainMesh, materials: [component.waterMaterial])
            self.model = modelComponent
        }

    }
}
