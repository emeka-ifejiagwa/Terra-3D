//
//  MeshHeightComponent.swift
//  Terra 3D
//
//  Created by Jiexy on 2/8/25.
//

import RealityKit

struct TerrainHeightComponent: Component {
    let waterMesh = MeshResource.generateBox(size: 0.2)
    let waterMaterial = SimpleMaterial(color: .red, roughness: 1, isMetallic: true)
}
