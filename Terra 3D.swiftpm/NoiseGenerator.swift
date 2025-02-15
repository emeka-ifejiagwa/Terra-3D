//
//  NoiseMap.swift
//  Terra 3D
//
//  Created by Jiexy on 1/25/25.
//

import GameplayKit
import Foundation

typealias CGSizeInt = (height: Int, width: Int)

/// This class will be inherited by other noise generators that provide their own noise sources
class NoiseGenerator {
    let noise: GKNoise
    // default from documentation
    private var sampleCount: vector_int2 = vector_int2(x: 100, y: 100)
    
    init(noiseSource: GKNoiseSource) {
        self.noise = GKNoise(noiseSource)
    }
    
    init(noise: GKNoise) {
        self.noise = noise
    }
    
    /// This function generates the actual noise map
    /// Parameters follow Apple Documentation
    func generateNoiseMap(noiseHeight: Double =  1.0, noiseWidth: Double = 1.0, origin: CGPoint = CGPoint(x: 0, y: 0), sampleCount: (x: Int, y: Int)? = nil, seamless: Bool = true) -> GKNoiseMap {
        if sampleCount != nil {
            self.sampleCount = vector_int2(x: Int32(sampleCount!.x), y: Int32(sampleCount!.y ))
        }
        let size = vector_double2(x: noiseHeight, y: noiseWidth)
        let originVector = vector_double2(x: origin.x, y: origin.y)
        return GKNoiseMap(self.noise, size: size, origin: originVector, sampleCount: self.sampleCount, seamless: seamless)
    }
    
    /// Generates a noise map using perlin noise. Each value of the noise map is normalized using the given normalization function
    /// - Parameters:
    ///   - noiseMap: The noise map used to get perlin values for the final map. If not provided, the default one for the class is used
    ///   - scaleFactor: The level of zoom.
    ///   - size: The  height and width of the terrain that the noise map is intended for
    ///   - normalizationFunc: The function used to normalize all values in the final result. If not provided, no normalization is applied
    /// - Returns: Returns a final perlin based noise array after  normalization
    static func fillMap<N: Numeric>(
        from noiseMap: GKNoiseMap,
        scaleBy scaleFactor: Float = 1.0,
        size: CGSizeInt,
        with normalizationFunc: (Float) -> N = NoiseNormalizer.identityNormalizer
    ) -> Flat2DArray<N> {
        // the adjustedScaleFactor is to accommodate scales that cause issues
        // because the map size is smaller than the generated perlin map
        // Assumption: the x-count = y-count
        // changing both to doubles ensures that we do not lose any info
        // as a result of integer division
        let adjustedScaleFactor = Float(Double(size.height) / Double(noiseMap.sampleCount.x))
        // scale should not be smaller than 1
        let scale: Float = (scaleFactor < 1 ? 1 : scaleFactor) * adjustedScaleFactor
        var resMap = Flat2DArray<N>(repeating: 0, height: size.height, width: size.width)
        DispatchQueue.concurrentPerform(iterations: size.height) { x in
            DispatchQueue.concurrentPerform(iterations:size.width) { y in
                let scaledX = Float(x) / scale
                let scaledY = Float(y) / scale
                resMap[x,y] = normalizationFunc(noiseMap.interpolatedValue(at: vector_float2(scaledX, scaledY)))
            }
        }
        return resMap
    }
    
}

class PerlinNoiseGenerator: NoiseGenerator {
    init(frequency: Double = 2, octaveCount: Int = 6, persistence: Double = 0.5, lacunarity: Double = 2, seed: Int32 = 0){
        let noiseSource = GKPerlinNoiseSource(frequency: frequency,
                                              octaveCount: octaveCount,
                                              persistence: persistence,
                                              lacunarity: lacunarity,
                                              seed: seed)
        super.init(noiseSource: noiseSource)
    }
}

class RidgedNoiseGenerator: NoiseGenerator {
    init(frequency: Double = 2, octaveCount: Int = 6, lacunarity: Double = 2, seed: Int32 = 0){
        let noiseSource = GKRidgedNoiseSource(frequency: frequency,
                                              octaveCount: octaveCount,
                                              lacunarity: lacunarity,
                                              seed: seed)
        super.init(noiseSource: noiseSource)
    }
}

class BillowNoiseGenerator: NoiseGenerator {
    init(frequency: Double = 2, octaveCount: Int = 6, persistence: Double = 0.5, lacunarity: Double = 2, seed: Int32 = 0){
        let noiseSource = GKBillowNoiseSource(frequency: frequency,
                                              octaveCount: octaveCount,
                                              persistence: persistence,
                                              lacunarity: lacunarity,
                                              seed: seed)
        super.init(noiseSource: noiseSource)
    }
}

class ConstantNoiseGenerator: NoiseGenerator {
    init(value: Double){
        let noiseSource = GKConstantNoiseSource(value: value)
        super.init(noiseSource: noiseSource)
    }
}
