//
//  MeshHeightComponent.swift
//  Terra 3D
//
//  Created by Jiexy on 2/8/25.
//

import CoreGraphics
import RealityKit


/// This struct contains the height map used to update the terrain.
/// RealityKit coordinate system is really important in understanding and debugging this code
/// z if towards the user, x in to the users' right, y is parallel to gravity
/// Therefore the row represent Z-coordinates and the columns represent X-coordinates
struct HeightComponent: Component {
    var heightMap: Flat2DArray<Float>
    var descriptor: MeshDescriptor
    var terrainMesh: MeshResource
    var terrainSize: CGSizeInt
    let fallOffGenerator: FallOffGenerator
    
    private static let heightNormalizer: NormalizerFunction = { value in
        return NoiseNormalizer.noiseSmoothStepNormalizer(value)
    }
    
    init(height: Int, width: Int){
        // TODO: Remove if unnecessary
        self.terrainSize = CGSizeInt(height: height, width: width)
        
        let heightGenerator = BillowNoiseGenerator(frequency: 2,
                                                   persistence: 0.25,
                                                   lacunarity: 4,
                                                   seed: Int32.random(in: Int32.min...Int32.max))
        //        let heightGenerator = PerlinNoiseGenerator(seed: 0)
        let gkHeightMap = heightGenerator.generateNoiseMap()
        let interMediateHeightMap =  NoiseGenerator.fillMap(from: gkHeightMap, scaleBy: 0.5, size: (height: height, width: width), with: HeightComponent.heightNormalizer)
        // apply fall off map to ease the edges
        self.fallOffGenerator = FallOffGenerator(height: height, width: width, fallOffStart: 0, fallOffEnd: 0.75)
        self.heightMap = fallOffGenerator.applyFallOff(to: interMediateHeightMap)
        var descriptor = MeshDescriptor(name: "Height Mesh")
        
        // add vertices and indices
        let numVertices = height * width
        let numTriangles = (height - 1) * (width - 1) * 6
        var vertices = Array(repeating: SIMD3<Float>.zero, count: numVertices)
        var indices: [UInt32] = Array(repeating: 0, count: numTriangles)
        var triangleIndex = 0
        var vertexIndex = 0 // helps us simplify the index to add the current vertex
        
        // because x and z start at 0 and move in the positive direction, the final mesh is not centered
        let xOffset: Float = -Float(width/2)
        let zOffSet: Float = -Float(height/2)
        
        /// The x and z components correspond to the indices of the terrain height map. Therefore, if the height map is of size 256 x 256,
        /// the AR terrain would be 256 meters by 256 meters which is too large. This is why the scale vector is needed
        /// The y coordinate spans 0 to 1 meters (normalized) or -1 to 1 meters unnormalized
        let scaleVector = SIMD3<Float>(x: 1/Float(width) , y: 0.7, z: 1/Float(height))
        
        // for UV mapping
        var uvMap = Array(repeating: SIMD2<Float>.zero, count: numVertices)
        
        // used to control the height rate depending on the biome
        let adjustedHeightVal: (Float) -> Float = { heightVal in
            pow(heightVal, 2.8)
        }
        
        for row in 0..<height {
            for col in 0..<width {
                // calculate indices
                let topLeftIndex = UInt32(vertexIndex)
                let topRight = topLeftIndex + 1
                let bottomLeft = UInt32(vertexIndex + width)
                let bottomRight = bottomLeft + 1
                // add the vertices with reality kit coordinates xzy where y is axis of gravity
                vertices[vertexIndex] = SIMD3<Float>(Float(col) + xOffset,  adjustedHeightVal(heightMap[row, col]), Float(row) + zOffSet) * scaleVector
                // calculate uv map position
                uvMap[vertexIndex] = SIMD2<Float>(Float(row)/Float(height), Float(col)/Float(width))
                // The commented out code is for voxel representation
                // See https://www.redblobgames.com/maps/terrain-from-noise/#terraces
                // vertices[vertexIndex] = SIMD3<Float>(Float(col) + xOffset, Float(Int(heightMap[row, col] * 100)/5)/10, Float(row) + zOffSet) * scaleVector
                
                // add triangle indices
                if row < height - 1 && col < width - 1 {
                    indices[triangleIndex] = topLeftIndex
                    indices[triangleIndex + 1] = bottomLeft
                    indices[triangleIndex + 2] = topRight
                    
                    indices[triangleIndex + 3] = topRight
                    indices[triangleIndex + 4] = bottomLeft
                    indices[triangleIndex + 5] = bottomRight
                    triangleIndex += 6
                }
                vertexIndex += 1
            }
        }
        descriptor.positions = MeshBuffers.Positions(vertices)
        descriptor.primitives = .triangles(indices)
        descriptor.textureCoordinates = MeshBuffers.TextureCoordinates(uvMap)
        self.descriptor = descriptor
        self.terrainMesh = try! MeshResource.generate(from: [descriptor])
    }
    
}
