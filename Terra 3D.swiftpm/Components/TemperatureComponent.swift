//
//  TemperatureComponent.swift
//  Terra 3D
//
//  Created by Jiexy on 2/13/25.
//

import RealityKit
import Foundation
import Accelerate

/**
 This struct contains information about the temperature of the terrain.
 Temperatures are normalized to -10ºC to 40ºC. The actual final temperature may vary slightly from this range because of the latitude falloff map
 
 (1) To emulate earth's temperature change along the latitude, we use a fall off map. \
 (2) Temperature is also gets cooler as the height increases. \
 (3) Additionally, we need to account for the change in temperature around around ocean areas.
    To do this, we obtain the mask for ocean biomes, then reduce the temperature of those areas.
    We proceed to use a kernel blur to simulate the cooling effect on surrounding areas
 */
struct TemperatureComponent: Component {
    static let maxTemp: Float = 40.0
    static let minTemp: Float = -10.0
    
    // regions close to the center would have an increased temperature of 3 degrees
    // regions close to the edges would have a reduced temperature of 2 degrees
    private static let latTempOffsetMax: Float = 10.0
    private static let latTempOffsetMin: Float = -5.0
    
    private static let oceanTemp: Float = 10.0
    private static let peakTemp: Float = -20.0
    private static let lapseRate: Float = 25.0
    
    private static let blurRadius: Int = 32
    var temperatureMap: Flat2DArray<Float>
    private static let temperatureNormalizer: NormalizerFunction = { value in
        let normalizedTemp = NoiseNormalizer.noiseSmoothStepNormalizer(value)
        // map between maxTemp and minTemp
        return TemperatureComponent.minTemp + (TemperatureComponent.maxTemp - TemperatureComponent.minTemp) * normalizedTemp
    }
    
    init(height: Int, width: Int, heightMap: Flat2DArray<Float>){
        precondition(height * width == heightMap.count, "Height map does not match the specified size")
        let tempGenerator = PerlinNoiseGenerator(frequency: 4, octaveCount: 6, lacunarity: 2, seed: Int32.random(in: Int32.min...Int32.max))
        let gkTempMap = tempGenerator.generateNoiseMap()
        let intermediateTempMAp =  NoiseGenerator.fillMap(from: gkTempMap, scaleBy: 1, size: (height: height, width: width), with: TemperatureComponent.temperatureNormalizer)
        
        // emulate earths temperature relative to the latitude
        let latitudeMapGenerator = FallOffGenerator(height: height, width: width) { value in
            // map [0,1] to [latTempOffsetMin, latTempOffsetMax]
            return TemperatureComponent.latTempOffsetMin + (TemperatureComponent.latTempOffsetMax - TemperatureComponent.latTempOffsetMin) * value
        }
        let latTemperatureMap = latitudeMapGenerator.applyFallOff(to: intermediateTempMAp, by: .addition)
        var unDiffusedMap = Flat2DArray(repeating: Float(0), height: height, width: width)
        // account for temperature change due to height
        DispatchQueue.concurrentPerform(iterations: height){ row in
            for col in 0..<width{
                let heightVal = heightMap[row, col]
                let heightBiome = Altitude(heightVal)
                if heightBiome == .deep || heightBiome == .shallow {
                    unDiffusedMap[row, col] = TemperatureComponent.oceanTemp
                } else if heightBiome == .mountain {
                    unDiffusedMap[row, col] = latTemperatureMap[row, col] - (heightVal * TemperatureComponent.lapseRate)
                } else if heightBiome == .peak{
                    // height val is positive and peak temperature is negative
                    unDiffusedMap[row, col] = latTemperatureMap[row, col] + (heightVal * TemperatureComponent.peakTemp)
                } else {
                    unDiffusedMap[row, col] = latTemperatureMap[row, col]
                }
            }
        }
        
        // blur to affect neighbors
        let sourceBuffer = vImage.PixelBuffer(pixelValues: unDiffusedMap.array, size: vImage.Size(width: width, height: height), pixelFormat: vImage.PlanarF.self)
        let destinationBuffer = vImage.PixelBuffer(width: width, height: height, pixelFormat: vImage.PlanarF.self)
        // MARK: Must be odd
        let kernelSize = TemperatureComponent.blurRadius * 2 + 1
        let kernelCount = kernelSize * kernelSize
        // equally weigh each neighboring pixel within the blur size
        let kernel = vImage.ConvolutionKernel2D(
            values: Array(repeating: Float(1.0 / Float(kernelCount)), count: kernelCount),
            width: kernelSize, height: kernelSize
        )
        sourceBuffer.convolve(with: kernel, edgeMode: .fill(backgroundColor: TemperatureComponent.oceanTemp), destination: destinationBuffer)
        self.temperatureMap = Flat2DArray<Float>(with: destinationBuffer.array, height: height, width: width)
    }
}
