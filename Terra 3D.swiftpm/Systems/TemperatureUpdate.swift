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
                // update all temperatures since global temperature has increased
                let adjustedTempArray = vDSP.add(Float(tempChange), temperature.temperatureMap.array)
                
                temperature.temperatureMap.array = adjustedTempArray
                
                // update temperature component
                entity.components[TemperatureComponent.self] = temperature
            }
    }
}
