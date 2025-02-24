//
//  TemperatureUpdate.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import RealityKit
import Accelerate

class TemperatureUpdate: System {
    private var timeSinceTextureUpdate = 0.0
    private var updateInterval = SimulationConfig.updateInterval
    private static let query = EntityQuery(where: .has(TemperatureComponent.self)
                                           && .has(GreenHouseComponent.self))
    static var dependencies: [SystemDependency] = [
        .after(GreenHouseEmissions.self)
    ]
    
    required init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        // update after every set milliseconds
        timeSinceTextureUpdate += context.deltaTime
        guard timeSinceTextureUpdate >= updateInterval else {return}
        timeSinceTextureUpdate = 0
        
        context.entities(matching: TemperatureUpdate.query, updatingSystemWhen: .rendering)
            .forEach { entity in
                var temperature = entity.components[TemperatureComponent.self]!
                let ghgComponent = entity.components[GreenHouseComponent.self]!
                
                let tempChange = TempParams.climateSensitivity * log(ghgComponent.totalGHGConcentration/GHGParams.baseGlobalEmission)
                temperature.globalTemperatureChange += tempChange
                let variation = Double.random(in: -TempParams.tempReductionProbability...1)
                // update all temperatures since global temperature has increased
                // the randomNess adds some variation to the general temperature change.
                // without this, the desert looks like a pool spreading to neighbors evenly
                // variation should be on a per cell basis
                let adjustedTempArray = vDSP.add(Float(tempChange * variation), temperature.temperatureMap.array)
                
                temperature.temperatureMap.array = adjustedTempArray
//                print(temperature.globalTemperatureChange)
                // update temperature component
                entity.components[TemperatureComponent.self] = temperature
            }
    }
}
