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
    var material: PhysicallyBasedMaterial
    
    init(height: Int, width: Int,
         heightMap: Flat2DArray<Float>,
         temperatureMap: Flat2DArray<Float>,
         humidityMap: Flat2DArray<Float>
    ){
        self.cgTexture = TerrainTextureGenerator.generateCGTextureImage(heightMap: heightMap, temperatureMap: temperatureMap, humidityMap: humidityMap, size: CGSize(width: width, height: height), blurRadius: 1)
        self.texture = try? TextureResource(image: self.cgTexture!, withName: "TerrainMeshTexture", options: TextureResource.CreateOptions(semantic: .hdrColor, compression: .default, mipmapsMode: .allocateAndGenerateAll))
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(texture: MaterialParameters.Texture(self.texture!))
        material.roughness = 0.8
        material.metallic = 0.8
        material.textureCoordinateTransform.rotation = Float(90) * .pi / 180
        self.material = material
    }
}
