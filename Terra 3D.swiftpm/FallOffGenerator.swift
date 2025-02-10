//
//  FallOffGenerator.swift
//  Terra 3D
//
//  Created by Jiexy on 2/9/25.
//

import CoreGraphics
import simd
import Accelerate

/// A fall off map is used to modify noise values in specific ways. Think of it as a mask.
/// The mask, when applied to a map, modifies the resulting values accordingly. The values of a fall of map range from [0,1]
/// Using this, when there is complete fall off, the mask value would be 0.
/// Therefore applying "the mask" to the noise value at that position returns 0.
/// A similar process occurs for values of fall off maps between 0 and 1
/// In this class, we use "squircle" fall off maps as opposed to rectangular or radial
/// The main purpose is to gradually flatten the edges especially in cases that a mountain is forming at edge wehre half of the mountain is outside the map
class FallOffGenerator {
    let fallOffStart: Float
    let fallOffEnd: Float
    let size: CGSizeInt
    lazy var fallOffMap: Flat2DArray<Float> = {
        var fallOffMap = Flat2DArray<Float>(repeating: 0, height: size.height, width: size.width)
        for row in 0..<size.height {
            for col in 0..<size.width {
                // Normalize the value between [-1,1]
                let x = 2 * Float(col) / Float(size.width) - 1
                let y = 2 * Float(row) / Float(size.height) - 1
                let xPow2 = x * x
                let yPow2 = y * y
                let distance = sqrt(xPow2 * xPow2 + yPow2 * yPow2) // zero at the center
                let normalizedDistance = distance/sqrt(2.0) // because x and y have max values of 1, max distance is sqrt 2
                // compute fall off map
                fallOffMap[row, col] = 1.0 - simd_smoothstep(fallOffStart,
                                                             fallOffEnd,
                                                             normalizedDistance)
                
            }
        }
        return fallOffMap
    }()
    
    
    /// Initializes a fall off map.
    /// - Parameters:
    ///   - height: The height of the map
    ///   - width: The width of the map
    ///   - fallOffStart: A value between [0,1] where the fall off starts
    ///   - fallOffEnd:  A value between [0,1] where the fall off ends
    init( height: Int, width: Int, fallOffStart: Float = 0, fallOffEnd: Float = 1) {
        self.fallOffStart = fallOffStart
        self.fallOffEnd = fallOffEnd
        self.size = CGSizeInt(height: height, width: width)
    }
    
    func applyFallOff(to input: Flat2DArray<Float>) -> Flat2DArray<Float> {
        precondition(input.count == fallOffMap.count, "Input and fall off map must have the same size")
        return Flat2DArray<Float>(with: vDSP.multiply(input.array, fallOffMap.array), height: size.height, width: size.width)
    }
}
