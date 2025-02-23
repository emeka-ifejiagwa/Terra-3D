//
//  VegetationUpdate.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import RealityKit

class VegetationUpdate: System {
    private var timeSinceTextureUpdate = 0.0
    private var updateInterval = SimulationConfig.updateInterval
    private static let query = EntityQuery(where: .has(HeightComponent.self)
                                           && .has(TemperatureComponent.self)
                                           && .has(HumidityComponent.self))
    static var dependencies: [SystemDependency] = [
        .after(HumidityUpdate.self),
        .after(TemperatureUpdate.self)
    ]
    required init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        // update after every set milliseconds
        timeSinceTextureUpdate += context.deltaTime
        guard timeSinceTextureUpdate >= updateInterval else {return}
        timeSinceTextureUpdate = 0
        
        context.entities(matching: VegetationUpdate.query, updatingSystemWhen: .rendering)
            .forEach { entity in
                let height = entity.components[HeightComponent.self]!
                let temperature = entity.components[TemperatureComponent.self]!
                let humidity = entity.components[HumidityComponent.self]!
                
                var vegetativeCover = 0.0
                for i in 0..<height.heightMap.count {
                    let heightVal = height.heightMap[i]
                    let tempVal = temperature.temperatureMap[i]
                    let humidityVal = humidity.humidityMap[i]
                    
                    if BiomeConfig.isVegetationBiome(height: heightVal, temperature: tempVal, humidity: humidityVal) {
                        vegetativeCover += 1.0
                    }
                }
                vegetativeCover /= Double(height.heightMap.count)
                entity.components[VegetationComponent.self]?.vegetativeCover = vegetativeCover
            }
    }
}
