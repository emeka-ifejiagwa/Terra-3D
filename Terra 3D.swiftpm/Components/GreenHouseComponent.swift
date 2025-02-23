//
//  GreenHouseComponent.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import RealityKit

/// Stores the global green house gas concentration
/// Units in ppm
/// GHGs first, because that global level modifies the temperature in the next step.
//Global Temperature next, because it’s needed for rainfall/climate updates.
//Local Rainfall: updated after we know the new temperature that might shift rainfall distribution.
//Water Flow depends on how much new rainfall arrived.
//Erosion depends on water flow.
//Vegetation depends on final climate, water availability, and terrain changes.
//Pollution last, because it might also be transported via water flow or wind. If you incorporate advanced logic that wind depends on temperature changes, you might do a mini feedback loop, but the typical approach is to place it after the climate and flow steps to incorporate new conditions.
struct GreenHouseComponent: Component {
    var totalGHGConcentration: Double = GHGParams.baselineConcentration
    var globalEmissions: Double = GHGParams.baseGlobalEmission
}
