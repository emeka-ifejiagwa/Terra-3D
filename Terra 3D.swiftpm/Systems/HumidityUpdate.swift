//
//  HumidityUpdate.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import RealityKit
import Accelerate

class HumidityUpdate: System {
    private var timeSinceTextureUpdate = 0.0
    private var updateInterval = SimulationConfig.updateInterval
    private static let query = EntityQuery(where: .has(HumidityComponent.self)
                                           && .has(TemperatureComponent.self))
    static var dependencies: [SystemDependency] = [
        .after(TemperatureUpdate.self)
    ]
    
    required init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        // update after every set milliseconds
        timeSinceTextureUpdate += context.deltaTime
        guard timeSinceTextureUpdate >= updateInterval else {return}
        timeSinceTextureUpdate = 0
        
        context.entities(matching: HumidityUpdate.query, updatingSystemWhen: .rendering)
            .forEach { entity in
                var humidity = entity.components[HumidityComponent.self]!
                let temperature = entity.components[TemperatureComponent.self]!
                
                let variation = Double.random(in: HumidityParams.humidityReductionProbability...1)
                let tempChangeSinceInitial = temperature.globalTemperatureChange
                
                // Higher temperature leads to lower humidity, hence negative
                let globalHumidity = -HumidityParams.rainfallTempCouplingConstant * tempChangeSinceInitial

                // variation is on a per cell basis
                var adjustedHumidity = vDSP.add(Float(globalHumidity * variation), humidity.humidityMap.array)
                adjustedHumidity = vDSP.clip(adjustedHumidity, to: (HumidityParams.minHumidity)...HumidityParams.maxHumidity)
                humidity.humidityMap.array = adjustedHumidity
//                print(humidity.humidityMap[10_000])
                // update humidity component
                entity.components[HumidityComponent.self] = humidity
            }
    }
}
