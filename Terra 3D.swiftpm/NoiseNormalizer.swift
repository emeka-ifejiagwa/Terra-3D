//
//  PerlinNormalizer.swift
//  Terra 3D
//
//  Created by Jiexy on 1/26/25.
//

// FIXME: Change implementation details
/*
 The zero normalizer does not work for composition of normalizers
 Example: performing the following composition colorNormalizer(absNormalizer(value))
 This does not work because abs already clamps the value between the min and the max (0 to 1 in the case of noise)
 After this clamping, colorNormalizer is applied which calls zeroToOneNormalizer which performs an additional clamping /interpolation using min and max which have been altered by absNormalizer
 */

fileprivate let maxPerlinValue: Float = 1.0
fileprivate let minPerlinValue: Float = -1.0
fileprivate let maxColorVal: Float = 255.0

typealias NormalizerFunction = (Float) -> Float

/// Normalizers are simply functions that take a float and returns a float allowing us to manipulate values however
/// Noise normalizer has an input range of [-1, 1].
/// This implies that the normalizer functions return 0 for values lower than the min and 1 for values greater than the min
struct NoiseNormalizer {
    /// returns the value unnormalized
    static let identityNormalizer: NormalizerFunction = { $0 }
    
    /// Normalizes a given value from 0 to 1
    /// - Parameter value: value to normalize
    /// - Returns: A real number between 0 and 1
    static func zeroToOneNormalizer(normalize value: Float) -> Float {
        if value <= minPerlinValue { return 0 }
        if value >= maxPerlinValue { return 1 }
        return (value - minPerlinValue) / (maxPerlinValue - minPerlinValue)
    }
    
    static func createZeroToValueNormalizer(_ maxVal: Float) -> NormalizerFunction {
        return { x in
            return zeroToOneNormalizer(normalize: x) * maxVal
        }
    }
    
    // MARK: User defined normalizers go here
    static let colorNormalizer: NormalizerFunction = createZeroToValueNormalizer(maxColorVal)
    
    static let absNormalizer: NormalizerFunction = { value in
        return abs(value)
    }
    
    static let absColorNormalizer: NormalizerFunction = {value in
        return abs(value) * maxColorVal
    }
}
