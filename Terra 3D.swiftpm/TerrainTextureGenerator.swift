//
//  TerrainTextureGenerator.swift
//  Terra 3D
//
//  Created by Jiexy on 2/3/25.
//

import CoreGraphics
import SwiftUI

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
    
    static func generateImage(colorMap: Flat2DArray<UInt8>, size: CGSize) -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue) // RGBA not ARGB
        guard let provider = CGDataProvider(data: Data(colorMap) as CFData) else {
            return nil
        }
        let width = Int(size.width)
        let height = Int(size.height)
        guard let cgImage = CGImage(width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bitsPerPixel: 32,
                                    bytesPerRow: width * 4,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo,
                                    provider: provider,
                                    decode: nil,
                                    shouldInterpolate: true,
                                    intent: .defaultIntent)
        else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    static func generateTexture(heightMap: Flat2DArray<Float>,
                                temperatureMap: Flat2DArray<Float>,
                                humidityMap: Flat2DArray<Float>,
                                size: CGSize
    ) -> UIImage? {
        let colorMap = generateTextureMap(heightMap: heightMap, temperatureMap: temperatureMap, humidityMap: humidityMap, size: size)
        return generateImage(colorMap: colorMap, size: size)
    }
}
