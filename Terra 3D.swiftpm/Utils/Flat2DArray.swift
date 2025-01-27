//
//  Flat2DMap.swift
//  Terra 3D
//
//  Created by Jiexy on 1/25/25.
//
import CoreGraphics

struct Flat2DArray<Element> {
    // ideally private but we need this for the accelerate package
    var array: [Element]
    let size: CGSize
    let length: Int
    
    init(repeating value: Element, height: Int, width: Int) {
        self.array = Array(repeating: value, count: height * width)
        self.size = CGSize(width: width, height: height)
        self.length = Int(size.width * size.height)
    }
    
    init(with array: [Element], height: Int, width: Int) {
        precondition(array.count == height * width, "Input array count must match the product of the height and width")
        self.array = array
        self.size = CGSize(width: width, height: height)
        self.length = array.count
    }
    
    subscript(row: Int, col: Int) -> Element {
        get {
            return array[row * Int(size.width) + col]
        }
        set {
            array[row * Int(size.width) + col] = newValue
        }
    }
}

extension Flat2DArray: Collection {
    var startIndex: Int { return array.startIndex }
    var endIndex: Int { return array.endIndex }
    
    subscript(position: Int) -> Element {
        get {
            return array[position]
        }
        set {
            array[position] = newValue
        }
    }
    
    func index(after i: Int) -> Int {
        return array.index(after: i)
    }
}
