//
//  PollutionComponent.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import RealityKit

struct PollutionComponent: Component {
    var industrialEmission = PollutionParams.baseIndustrialEmission// more global
    var landUseEmission = PollutionParams.baseLandUseEmission // per individual basis
}
