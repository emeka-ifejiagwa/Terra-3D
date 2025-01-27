//
//  HelperMethods.swift
//  Terra 3D
//
//  Created by Jiexy on 1/25/25.
//

/// Given a 2 dimensional index, the function returns a 
func getFlatIndex(x: Int, y: Int, width: Int) -> Int {
    return x * width + y
}

// TODO: implement method
func get2DIndex(flatIndex: Int, width: Int){
    
}

struct Pixel {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
}
