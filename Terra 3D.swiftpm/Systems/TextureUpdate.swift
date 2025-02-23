//
//  TextureUpdate.swift
//  Terra 3D
//
//  Created by Jiexy on 2/22/25.
//

import RealityKit

class TextureUpdate: System {
    private var timeSinceTextureUpdate = 0.0
    private var updateInterval = 0.5
    private static let query = EntityQuery(where: .has(HeightComponent.self)
                                           && .has(TemperatureComponent.self)
                                           && .has(HumidityComponent.self)
                                           && .has(TerrainTextureComponent.self)
    )
    required init(scene: Scene) {    }
    
    func update(context: SceneUpdateContext) {
        timeSinceTextureUpdate += context.deltaTime
        guard timeSinceTextureUpdate >= updateInterval else {return}
        timeSinceTextureUpdate = 0
        let entities = context.entities(matching: TextureUpdate.query, updatingSystemWhen: .rendering)
        entities.forEach { entity in
            entity.components[TerrainTextureComponent.self] = TerrainTextureComponent(
                height: MAP_HEIGHT, width: MAP_WIDTH,
                heightMap: entity.components[HeightComponent.self]!.heightMap,
                temperatureMap: entity.components[TemperatureComponent.self]!.temperatureMap, humidityMap: entity.components[HumidityComponent.self]!.humidityMap)
        }
    }
}
