//
//  BiomeConfig.swift
//  Terra 3D
//
//  Created by Jiexy on 2/4/25.
//

typealias SIMD_RGBA = SIMD4<UInt8>

enum Biome: Equatable {
    case tundra
    case desert
    case savanna
    case tropicalForest
    case temperateForest
    case borealForest
    case woodland
    case coldBeach
    case beach
    case deepOcean
    case shallowOcean
    case regularMountain
    case iceMountain
    case snowCappedPeak
    case grassLand
}

let BiomeColorMap : [Biome : SIMD_RGBA] = [
    .snowCappedPeak : SIMD_RGBA(x: 220, y: 220, z: 220, w: 255),
    .tundra : SIMD_RGBA(x: 149, y: 174, z: 210, w: 255),
    .coldBeach : SIMD_RGBA(x: 249, y: 231, z: 199, w: 255),
    .beach : SIMD_RGBA(x: 249, y: 231, z: 199, w: 255),
    .iceMountain : SIMD_RGBA(x: 178, y: 178, z: 178, w: 255),
    .regularMountain : SIMD_RGBA(x: 96, y: 96, z: 96, w: 255),
    .desert : SIMD_RGBA(x: 214, y: 169, z: 114, w: 255),
    .savanna : SIMD_RGBA(x: 155, y: 149, z: 14, w: 255),
    .deepOcean : SIMD_RGBA(x: 0, y: 0, z: 112, w: 255),
    .shallowOcean : SIMD_RGBA(x: 48, y: 48, z: 175, w: 255),
    .temperateForest : SIMD_RGBA(x: 98, y: 139, z: 23, w: 255),
//    .temperateForest : SIMD_RGBA(x: 48, y: 116, z: 68, w: 255),
    .tropicalForest : SIMD_RGBA(x: 6, y: 104, z: 6, w: 255),
//    .tropicalForest : SIMD_RGBA(x: 5, y: 102, z: 33, w: 255),
    .borealForest : SIMD_RGBA(x: 0, y: 87, z: 78, w: 255),
//    .borealForest : SIMD_RGBA(x: 11, y: 102, z: 89, w: 255),
//    .grassLand : SIMD_RGBA(x: 98, y: 139, z: 23, w: 255),
    .grassLand : SIMD_RGBA(x: 193, y: 189, z: 62, w: 255),
]

enum Temperature: CaseIterable, Equatable {
    case freezing, cold, moderate, warm, hot
    
    private enum TempBoundary {
        static let freezingStart = Float(-10) // Not used in init but here as a good reference for ideal start
        static let coldStart = Float(-3)
        static let moderateStart = Float(10)
        static let warmStart = Float(20)
        static let hotStart = Float(32)
    }
    
    init(_ value: Float) {
        switch value {
        case _ where value < TempBoundary.coldStart:
            self = .freezing
        case TempBoundary.coldStart..<TempBoundary.moderateStart:
            self = .cold
        case TempBoundary.moderateStart..<TempBoundary.warmStart:
            self = .moderate
        case TempBoundary.warmStart..<TempBoundary.hotStart:
            self = .warm
        default:
            self = .hot // every value at or after hotStart
        }
    }
}

enum Altitude: CaseIterable, Equatable {
    case deep, shallow, beach, land, mountain, peak
    /**
     Observation: Using PerlinNoiseGenerator and absNormalizer causes much more oceans than
     the start for all oceans may represent
     */
    // TODO: Adjust using scale because RealityKit is in meters
    private enum AltBoundary {
        static let deepStart = Float(0) // Not used in init but here as a good reference for ideal start
        static let shallowStart = Float(0.025)
        static let beachStart = Float(0.05)
        static let landStart = Float(0.075)
        static let mountainStart = Float(0.7)
        static let peakStart = Float(0.9)
    }
    
    init(_ value: Float) {
        switch value {
        case _ where value < AltBoundary.shallowStart:
            self = .deep
        case AltBoundary.shallowStart..<AltBoundary.beachStart:
            self = .shallow
        case AltBoundary.beachStart..<AltBoundary.landStart:
            self = .beach
        case AltBoundary.landStart..<AltBoundary.mountainStart:
            self = .land
        case AltBoundary.mountainStart..<AltBoundary.peakStart:
            self = .mountain
        default:
            self = .peak // every value at or after peakStart
        }
    }
}

enum Humidity: CaseIterable, Equatable {
    case low, normal, high, veryHigh
    
    private enum HConstant {
        static let lowStart = Float(0) // Not used in init but here as a good reference for ideal start
        static let normalStart = Float(60)
        static let highStart = Float(200)
        static let veryHighStart = Float(350)
    }
    
    init(_ value: Float) {
        switch value {
        case _ where value < HConstant.normalStart:
            self = .low
        case HConstant.normalStart..<HConstant.highStart:
            self = .normal
        case HConstant.highStart..<HConstant.veryHighStart:
            self = .high
        default:
            self = .veryHigh
        }
    }
}

struct BiomeConfig {
    static func getBiomeType(height heightVal: Float,
                             temperature temperatureVal: Float,
                             humidity humidityVal: Float
    ) -> Biome {
        let height = Altitude(heightVal)
        let temperature = Temperature(temperatureVal)
        let humidity = Humidity(humidityVal)
        
        func getLandBiome(temperature: Temperature, humidity: Humidity) -> Biome {
            switch temperature {
            case .freezing:
                return .tundra
            case .cold:
                return .borealForest
            case .moderate:
                if humidity == .low {
                    return .grassLand
                } else{
                    return .temperateForest
                }
            case .warm:
                return .temperateForest
            case .hot:
                if humidity == .low {
                    return .desert
                } else if humidity == .normal || humidity == .high {
                    return .savanna
                } else {
                    return .tropicalForest
                }
            }
        }
        
        // map combinations to biomes
        switch height {
        case .deep: // independent
            return .deepOcean
        case .shallow: // independent
            return .shallowOcean
        case .beach: // independent of humidity
            if temperature == .freezing ||  temperature == .cold {
                return .coldBeach
            }
            return .beach
        case .land:
            return getLandBiome(temperature: temperature, humidity: humidity)
        case .mountain: // independent of humidity
            if temperature == .freezing{
                return .iceMountain
            }
            return .regularMountain
        case .peak: // independent of humidity
            if temperature == .freezing || temperature == .cold{
                return .snowCappedPeak
            }
            return .iceMountain
        }
    }
    
    
    static func getBiomeColor(biome: Biome) -> SIMD_RGBA {
        return BiomeColorMap[biome]! // MARK: consider changing ! to be safe
    }
    
    static func getBiomeColor(height: Float,
                              temperature: Float,
                              humidity: Float
    ) -> SIMD_RGBA {
        let biome = getBiomeType(height: height, temperature: temperature, humidity: humidity)
        return getBiomeColor(biome: biome)
    }
    
    static func isVegetationBiome(height: Float, temperature: Float, humidity: Float) -> Bool {
        let biome = getBiomeType(height: height, temperature: temperature, humidity: humidity)
        return biome == .borealForest || biome == .grassLand || biome == .savanna || biome == .tropicalForest || biome == .temperateForest
    }
}
