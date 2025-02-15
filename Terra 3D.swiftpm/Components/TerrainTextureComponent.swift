//
//  TerrainTextureComponent.swift
//  Terra 3D
//
//  Created by Jiexy on 2/15/25.
//

import RealityKit
import CoreGraphics

struct TerrainTextureComponent: Component {
    var cgTexture: CGImage?
    var texture: TextureResource?
    
    init(height: Int, width: Int,
         heightMap: Flat2DArray<Float>,
         temperatureMap: Flat2DArray<Float>,
         humidityMap: Flat2DArray<Float>
    ){
        self.cgTexture = TerrainTextureGenerator.generateCGTextureImage(heightMap: heightMap, temperatureMap: temperatureMap, humidityMap: humidityMap, size: CGSize(width: width, height: height), blurRadius: 6)
        self.texture = try? TextureResource(image: self.cgTexture!, withName: "TerrainMeshTexture", options: TextureResource.CreateOptions(semantic: .hdrColor, compression: .default, mipmapsMode: .allocateAndGenerateAll))
    }
}
