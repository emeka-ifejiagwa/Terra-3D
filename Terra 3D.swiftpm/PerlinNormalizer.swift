//
//  PerlinNormalizer.swift
//  Terra 3D
//
//  Created by Jiexy on 1/26/25.
//

fileprivate let maxPerlinValue: Float = 1.0
fileprivate let minPerlinValue: Float = -1.0
fileprivate let maxColorVal: Float = 255.0

struct PerlinNormalizer {
    
    static let colorNormalization: (Float) -> Float = createZeroToValueNormalization(maxColorVal)
    
    static let unNormalized: (Float) -> Float = { $0 }
    
    /// Normalizes a given value from 0 to 1
    /// - Parameter value: value to normalize
    /// - Returns: A real number between 0 and 1
    static func zeroToOneNormalization(normalize value: Float) -> Float {
        return (value - minPerlinValue) / (maxPerlinValue - minPerlinValue)
    }
    
    static func createZeroToValueNormalization(_ maxVal: Float) -> (Float) -> Float {
        return { x in
            return zeroToOneNormalization(normalize: x) * maxVal
        }
    }
}
