//
//  Params.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

/// This is used to store equation constants and hyper parameter for easy tuning
/// This helps us avoid going into files to make changes
/// The properties labelled var are game params
struct GHGParams {
    static let baselineConcentration = 420.0
    static let baseGlobalEmission = 2.5
}

struct SequestrationParams {
    static let baseSequestrationAmount = 1.5
    static let seqPerVegetation = 1.5
    static let ghgSinkFactor = 0.25
}

struct TempParams {
    static let baseGlobalTempChange = 0.0
    static let climateSensitivity = 0.1
    static let tempReductionProbability = 0.1e-1
}

struct HumidityParams {
    static let baseGlobalHumidityChange = 0
    static let rainfallTempCouplingConstant = 30.0 // mm/ºC
    
    static let minHumidity: Float = 0.0
    static let maxHumidity: Float = 500.0
    
    static let humidityReductionProbability = 2.5e-1
}

struct HumanParams {
    static let basePopulation = 8.0 // billions
    static let minPopulation = 1e-5
    static let growthRate = 2.5e-1
    static let carryingCapacity = 10.5
    
    static let deathRate = 0.5e-3
    static var initialForestation = 0.0
    static var initialUrbanization = 0.0
    static var basePollutionPerPerson = 4.0
    
    static let pollutionFactor = 5e-4
    static let tempFactor = 5.5e-2
    static let vegFactor = 0.01
    
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
