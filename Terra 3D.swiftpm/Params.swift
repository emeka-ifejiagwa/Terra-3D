//
//  Params.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

/// This is used to store equation constants and hyper parameter for easy tuning
/// This helps us avoid going into files to make changes

struct GHGParams {
    static let baselineConcentration = 420.0
    static let baseGlobalEmission = 2.5
}

struct SequestrationParams {
    static let baseSequestrationAmount = 1.5
    static let seqPerVegetation = 0.5
    static let ghgSinkFactor = 0.25
}

struct TempParams {
    static let baseGlobalTempChange = 0.0
    static let climateSensitivity = 2.5
}

struct HumidityParams {
    static let localNoiseRange = 0.85...1.1
    static let baseGlobalHumidityChange = 0
    static let rainfallTempCouplingConstant = 50.0 // mm/ºC
    
    static let minHumidity: Float = 0.0
    static let maxHumidity: Float = 500.0
}

struct HumanParams {
    static let basePopulation = 8.0 // billions
    static let minPopulation = 1e-5
    static let growthRate = 0.012
    static let carryingCapacity = 10.5
    
    static let initialDeathRate = 0.0
    static let initialForestation = 0.0
    static let initialUrbanization = 0.0
    static let basePollutionPerPerson = 4.0
    
    static let pollutionFactor = 5e-6
    static let tempFactor = 5e-6
    static let vegFactor = 0.25
    
}

struct VegetationParams {
    static let baseVegetationAmount = 0.5
}

struct PollutionParams {
    static let baseIndustrialEmission = 0.75 // more global
    static let baseLandUseEmission = 0.3 // per individual basis
    static let pollutionDecay = 0.25
}

struct SimulationConfig {
    static let updateInterval: Double = 1
    static let updateTextureInterval = 0.5
}
