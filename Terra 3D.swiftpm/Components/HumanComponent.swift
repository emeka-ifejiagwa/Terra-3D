//
//  HumanComponent.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import RealityKit

struct HumanComponent: Component {
    var population = HumanParams.basePopulation // unit is billion
    var forestation = HumanParams.initialForestation
    var urbanization = HumanParams.initialUrbanization
    var pollutionPerPerson = HumanParams.basePollutionPerPerson
}
