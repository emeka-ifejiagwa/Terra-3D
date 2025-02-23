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
 Temperatures are normalized to a certain range eg -15ºC to 40ºC. The actual final temperature may vary slightly from this range because of the latitude falloff map \
 
 (1) To emulate earth's temperature change along the latitude, we use a fall off map. \
 (2) Temperature is also gets cooler as the height increases. \
 (3) Additionally, we need to account for the change in temperature around around ocean areas.
    To do this, we obtain the mask for ocean biomes, then reduce the temperature of those areas. \
 Blurring is done before accounting for temperature change due to elevation
 */
struct TemperatureComponent: Component {
    static let maxTemp: Float = 40.0
    static let minTemp: Float = -15.0
    
    // regions close to the center (equator) would have an latTempOffsetMax
    // regions close to the edges (poles) would have a reduced temperature of latTempOffsetMin
    private static let latTempOffsetMax: Float = 10.0
    private static let latTempOffsetMin: Float = -25.0
    
    private static let oceanTemp: Float = 10.0
    private static let lapseRate: Float = 20.0 // highest peaks would be about -lapseRateºC
    
    private static let blurRadius: Int = 50
    
    // simulation parameters
    var globalTemperatureChange = TempParams.baseGlobalTempChange
    
    var temperatureMap: Flat2DArray<Float>
    private static let temperatureNormalizer: NormalizerFunction = { value in
        let normalizedTemp = NoiseNormalizer.noiseSmoothStepNormalizer(value)
        // map between maxTemp and minTemp
        return TemperatureComponent.minTemp + (TemperatureComponent.maxTemp - TemperatureComponent.minTemp) * normalizedTemp
    }
    
    init(height: Int, width: Int, heightMap: Flat2DArray<Float>){
        precondition(height * width == heightMap.count, "Height map does not match the specified size")
        let tempGenerator = PerlinNoiseGenerator(frequency: 2, octaveCount: 6, lacunarity: 3, seed: Int32.random(in: Int32.min...Int32.max))
        let gkTempMap = tempGenerator.generateNoiseMap()
        let intermediateTempMAp =  NoiseGenerator.fillMap(from: gkTempMap, scaleBy: 0.5, size: (height: height, width: width), with: TemperatureComponent.temperatureNormalizer)
        
        // emulate earths temperature relative to the latitude
        let latitudeMapGenerator = FallOffGenerator(height: height, width: width, fallOffEnd: 0.85) { value in
            // map [0,1] to [latTempOffsetMin, latTempOffsetMax]
            return TemperatureComponent.latTempOffsetMin + (TemperatureComponent.latTempOffsetMax - TemperatureComponent.latTempOffsetMin) * value
        }
        let latTemperatureMap = latitudeMapGenerator.applyFallOff(to: intermediateTempMAp, by: .addition)
        
        // simulate cooling effect of ocean on land by applying ocean temperature and blurring
        var oceanAccountedTempMap = Flat2DArray<Float>(repeating: 0.0, height: height, width: width)
        DispatchQueue.concurrentPerform(iterations: height) { row in
            for col in 0..<width{
                let heightVal = heightMap[row, col]
                let heightBiome = Altitude(heightVal)
                if heightBiome == .deep || heightBiome == .shallow {
                    oceanAccountedTempMap[row, col] = TemperatureComponent.oceanTemp
                } else {
                    oceanAccountedTempMap[row, col] = latTemperatureMap[row, col]
                }
            }
        }
        
        let sourceBuffer = vImage.PixelBuffer(pixelValues: latTemperatureMap.array, size: vImage.Size(width: width, height: height), pixelFormat: vImage.PlanarF.self)
        let destinationBuffer = vImage.PixelBuffer(width: width, height: height, pixelFormat: vImage.PlanarF.self)
        // MARK: Must be odd
        let kernelSize = TemperatureComponent.blurRadius * 2 + 1
        let kernelCount = kernelSize * kernelSize
        let kernel = vImage.ConvolutionKernel2D(
            values: Array(repeating: Float(1.0 / Float(kernelCount)), count: kernelCount),
            width: kernelSize, height: kernelSize
        )
        sourceBuffer.convolve(with: kernel, edgeMode: .fill(backgroundColor: TemperatureComponent.oceanTemp), destination: destinationBuffer)
        let diffusedMap = Flat2DArray(with: destinationBuffer.array, height: height, width: width)
        
        self.temperatureMap = Flat2DArray(repeating: Float(0.0), height: height, width:  width)
        // account for temperature change due to height
        DispatchQueue.concurrentPerform(iterations: height){ row in
            for col in 0..<width{
                let heightVal = heightMap[row, col]
                let heightBiome = Altitude(heightVal)
                if heightBiome == .mountain || heightBiome == .peak{
                    self.temperatureMap[row, col] = diffusedMap[row, col] - heightVal * TemperatureComponent.lapseRate
                } else {
                    self.temperatureMap[row, col] = diffusedMap[row, col]
                }
            }
        }
    }
}
