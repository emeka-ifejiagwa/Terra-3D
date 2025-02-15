//
//  HumidityComponent.swift
//  Terra 3D
//
//  Created by Jiexy on 2/14/25.
//

import RealityKit
import Foundation
import Accelerate

/// This struct stores information about the humidity of the terrain
/// Note that areas around oceans are more humid than other areas.
/// To simulate this, use a blur kernel to diffuse the values to its neighbors.
/// Humidity values range from 0 to 400
struct HumidityComponent: Component {
    var humidityMap: Flat2DArray<Float>
    
    private static let minHumidity: Float = 0
    private static let maxHumidity: Float = 400
    
    private static let deepOceanHumidity: Float = 400
    private static let shallowOceanHumidity: Float = 250
    
    private static let blurRadius: Int = 64
    
    private static let humidityNormalizer: NormalizerFunction = { value in
        return NoiseNormalizer.noiseSmoothStepNormalizer(value) * (HumidityComponent.maxHumidity - HumidityComponent.minHumidity) + HumidityComponent.minHumidity
    }
    
    init(height: Int, width: Int, heightMap: Flat2DArray<Float>){
        let humidityGenerator: NoiseGenerator = PerlinNoiseGenerator(seed: Int32.random(in: Int32.min...Int32.max))
        let gkHumidityMap = humidityGenerator.generateNoiseMap()
        let intermediateHumidityMap = NoiseGenerator.fillMap(from: gkHumidityMap, scaleBy: 1, size: CGSizeInt(height: height, width: width), with: HumidityComponent.humidityNormalizer)
        var unDiffusedMap = Flat2DArray(repeating: Float(0), height: height, width: width)
        
        // to reduce overhead, parallelize the work done on each row
        DispatchQueue.concurrentPerform(iterations: height) { row in
            for col in 0..<width {
                let height = Altitude(heightMap[row, col])
                if height == .deep {
                    unDiffusedMap[row, col] = HumidityComponent.deepOceanHumidity
                } else if height == .shallow {
                    unDiffusedMap[row, col] = HumidityComponent.shallowOceanHumidity
                } else {
                    unDiffusedMap[row, col] = intermediateHumidityMap[row, col]
                }
            }
        }
        
        // blur to affect neighbors
        let sourceBuffer = vImage.PixelBuffer(pixelValues: unDiffusedMap.array, size: vImage.Size(width: width, height: height), pixelFormat: vImage.PlanarF.self)
        let destinationBuffer = vImage.PixelBuffer(width: width, height: height, pixelFormat: vImage.PlanarF.self)
        // MARK: Must be odd
        let kernelSize = HumidityComponent.blurRadius * 2 + 1
        let kernelCount = kernelSize * kernelSize
        // equally weigh each neighboring pixel within the blur size
        let kernel = vImage.ConvolutionKernel2D(
            values: Array(repeating: Float(1.0 / Float(kernelCount)), count: kernelCount),
            width: kernelSize, height: kernelSize
        )
        sourceBuffer.convolve(with: kernel, edgeMode: .fill(backgroundColor: HumidityComponent.shallowOceanHumidity), destination: destinationBuffer)
        self.humidityMap = Flat2DArray<Float>(with: destinationBuffer.array, height: height, width: width)
    }
}
