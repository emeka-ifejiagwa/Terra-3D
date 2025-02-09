//
//  TerrainTextureGenerator.swift
//  Terra 3D
//
//  Created by Jiexy on 2/3/25.
//

import CoreGraphics
import SwiftUI
import Accelerate

struct TerrainTextureGenerator {
    
    /// All supplied maps should be direct result of the noise generator and should have values between [-1,1]
    static func generateTextureMap(heightMap: Flat2DArray<Float>,
                                   temperatureMap: Flat2DArray<Float>,
                                   humidityMap: Flat2DArray<Float>,
                                   size: CGSize
    ) -> Flat2DArray<UInt8> {
        guard heightMap.count == Int(size.height * size.width) else {
            return Flat2DArray(repeating: UInt8(0), height: 0, width: 0)
        }
        
        guard heightMap.count == temperatureMap.count && temperatureMap.count == humidityMap.count else {
            precondition(false, "Maps must have the same size")
            return Flat2DArray(repeating:  UInt8(0), height: 0, width: 0)
        }
        
        // add RGBA values side by side
        let numChannels = 4 //RGBA channel
        var colorMap = Flat2DArray<UInt8>(
            repeating:  UInt8(0), height: Int(size.height), width: Int(size.width) * numChannels
        )
        for i in 0..<heightMap.count {
            let index = i * numChannels
            let simdColor = BiomeConfig.getBiomeColor(height: heightMap[i],
                                                      temperature: temperatureMap[i],
                                                      humidity: humidityMap[i]
            )
            colorMap[index] = simdColor.x
            colorMap[index + 1] = simdColor.y
            colorMap[index + 2] = simdColor.z
            colorMap[index + 3] = simdColor.w
        }
        return colorMap
    }
    
    static func generateImage(colorMap: Flat2DArray<UInt8>, size: CGSize, blurRadius: Int = 1) -> UIImage? {
        let sourceBuffer = vImage.PixelBuffer(pixelValues: colorMap.array, size: vImage.Size(exactly: size) ?? vImage.Size(width: Int(size.width), height: Int(size.height)), pixelFormat: vImage.Interleaved8x4.self)
        // to potentially smooth out transitions
        let destinationBuffer = sourceBuffer.tentConvolved(kernelSize: vImage.Size(width: blurRadius, height: blurRadius), edgeMode: .extend)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue) // RGBA not ARGB
        
        guard let cgImage = destinationBuffer.makeCGImage(cgImageFormat: vImage_CGImageFormat(
            bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: colorSpace, bitmapInfo: bitmapInfo
        )!) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    static func generateTexture(heightMap: Flat2DArray<Float>,
                                temperatureMap: Flat2DArray<Float>,
                                humidityMap: Flat2DArray<Float>,
                                size: CGSize,
                                blurRadius: Int = 1
    ) -> UIImage? {
        let colorMap = generateTextureMap(heightMap: heightMap, temperatureMap: temperatureMap, humidityMap: humidityMap, size: size)
        return generateImage(colorMap: colorMap, size: size, blurRadius: blurRadius)
    }
}
