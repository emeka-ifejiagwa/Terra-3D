//
//  NoiseMap.swift
//  My App
//
//  Created by Jiexy on 1/25/25.
//

import GameplayKit

// NOTE: It seems that when obtaining values from the noise map, either the x-coordinate or the y-coordinate have to be less than 99
let maxPerlinIndex = 90

class PerlinNoiseGenerator {
    
    var noise: GKNoise
    
    init(frequency: Double = 2, octaveCount: Int = 6, persistence: Double = 0.5, lacunarity: Double = 2, seed: Int32 = 0){
        let noiseSource = GKPerlinNoiseSource(frequency: frequency,
                                              octaveCount: octaveCount,
                                              persistence: persistence,
                                              lacunarity: lacunarity,
                                              seed: seed)
        noise = GKNoise(noiseSource)
    }
    
    /// Generate the noise map object from which we can obtain perlin noise values
    func generate() -> GKNoiseMap{
        return GKNoiseMap(noise)
    }
    
    
    /// Generates a noise map using perlin noise. Each value of the noise map is normalized using the given normalization function
    /// - Parameters:
    ///   - size: The  height and width of the terrain that the noise map is intended for
    ///   - scaleFactor: The level of zoom.
    ///   - noiseMap: The noise map used to get perlin values for the final map. If not provided, the default one for the class is used
    ///   - normalizationFunc: The function used to normalize all values in the final result. If not provided, no normalization is applied
    /// - Returns: Returns a final perlin based noise array after  normalization
    func generateMap<N: Numeric>(size: (height: Int, width: Int),
                     scaleBy scaleFactor: Float = 1.0,
                     from noiseMap: GKNoiseMap? = nil,
                     withNormalization normalizationFunc: @escaping (Float) -> N = PerlinNormalizer.unNormalized
    ) -> Flat2DArray<N> {
        
        let adjustedScaleFactor = Float(size.height / maxPerlinIndex)
        // avoid divide by 0 error by setting to a very small value
        let scale: Float = (scaleFactor == 0 ? 1e-5 : scaleFactor) * adjustedScaleFactor
        // default normalized function is unnormalized
        let noiseMap = noiseMap ?? generate()
        
        var resMap = Flat2DArray<N>(repeating: 0, height: size.height, width: size.width)
        
        for x in 0..<size.height {
            for y in 0..<size.width {
                let scaledX = Float(x) / scale
                let scaledY = Float(y) / scale
                resMap[x,y] = normalizationFunc(noiseMap.interpolatedValue(at: vector_float2(scaledX, scaledY)))
            }
        }
        return resMap
    }
}
