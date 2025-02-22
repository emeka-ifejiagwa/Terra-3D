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
        self.components[HeightComponent.self] = HeightComponent(
            height: MAP_HEIGHT,
            width: MAP_WIDTH
        )
        self.components[TemperatureComponent.self] = TemperatureComponent(
            height: MAP_HEIGHT,
            width: MAP_WIDTH,
            heightMap: self.components[HeightComponent.self]!.heightMap
        )
        self.components[HumidityComponent.self] = HumidityComponent(
            height: MAP_HEIGHT,
            width: MAP_WIDTH,
            heightMap: self.components[HeightComponent.self]!.heightMap
        )
        self.components[TerrainTextureComponent.self] = TerrainTextureComponent(
            height: MAP_HEIGHT, width: MAP_WIDTH,
            heightMap: self.components[HeightComponent.self]!.heightMap,
            temperatureMap: self.components[TemperatureComponent.self]!.temperatureMap,
            humidityMap: self.components[HumidityComponent.self]!.humidityMap
        )
        
        if let component = self.components[HeightComponent.self] {
            let terrainTextureComponent = self.components[TerrainTextureComponent.self]!
            
            let modelComponent = ModelComponent(mesh: component.terrainMesh, materials: [terrainTextureComponent.material])
            self.model = modelComponent
        }
        
    }
}
