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
    
    static let absColorNormalizer: NormalizerFunction = { value in
        return abs(value) * maxColorVal
    }
    
    /// This function applies the smooth step function for values in the range [0,1]
    /// For values less than 0 or greater than 1, it returns 0 and 1 respectively
    /// See [Smooth Step Function in Wikipedia](https://en.wikipedia.org/wiki/Smoothstep)
    // MARK: Consider replacing with [SIMD method](https://developer.apple.com/documentation/simd/simd_smoothstep(_:_:_:)-5839l)
    static let smoothStepNormalizer: NormalizerFunction = { value in
        if value <= 0 { return 0 }
        if value >= 1 { return 1 }
        return (value * value * (3 - 2 * value))
    }
    
    /// This function applies the smooth step function for values in the range [-1,1]
    /// For values less than 0 or greater than 1, it returns 0 and 1 respectively
    /// See [Smooth Step Function in Wikipedia](https://en.wikipedia.org/wiki/Smoothstep)
    /// See graph [on Desmos](https://www.desmos.com/calculator/i5qwuxlh2w)
    ///
    /// 3(0.5(x + 1))^2 - 2(0.5(x + 1))^3 => 0.75(x + 1)^2 - 0.25(x + 1)^3
    static let noiseSmoothStepNormalizer: NormalizerFunction = { value in
        if value <= -1 { return 0 }
        if value >= 1 { return 1 }
        let valuePlus1 = value + 1
        return valuePlus1 * valuePlus1 * (0.75 - 0.25 * valuePlus1)
    }
}
