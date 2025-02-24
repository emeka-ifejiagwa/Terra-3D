//
//  HumanInteractions.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import RealityKit

class HumanInteractions: System {
    private var timeSinceTextureUpdate = 0.0
    private var updateInterval = SimulationConfig.updateInterval
    private static let query = EntityQuery(where: .has(HumanComponent.self)
                                           && .has(PollutionComponent.self)
                                           && .has(TemperatureComponent.self)
                                           && .has(VegetationComponent.self))
    required init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        // update after every set milliseconds
        timeSinceTextureUpdate += context.deltaTime
        guard timeSinceTextureUpdate >= updateInterval else {return}
        timeSinceTextureUpdate = 0
        
        let entities = context.entities(matching: HumanInteractions.query, updatingSystemWhen: .rendering)
        entities.forEach { entity in
            var humanComponent = entity.components[HumanComponent.self]!
            let pollution = entity.components[PollutionComponent.self]!
            let temperature = entity.components[TemperatureComponent.self]!
            let vegetation = entity.components[VegetationComponent.self]!
            
            // update population
            let population = humanComponent.population
            let decline =  -HumanParams.pollutionFactor * (pollution.landUseEmission + pollution.industrialEmission) - (population * HumanParams.deathRate)
            - (HumanParams.tempFactor * temperature.globalTemperatureChange
)            + (HumanParams.vegFactor * vegetation.vegetativeCover)
            let populationChange = HumanParams.growthRate * population * (1 - population/HumanParams.carryingCapacity) + decline
            
            humanComponent.population = max(HumanParams.minPopulation, population + populationChange)
            print(decline)
            entity.components[HumanComponent.self] = humanComponent
        }
    }
}
