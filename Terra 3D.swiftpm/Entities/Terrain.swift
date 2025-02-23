//
//  Terrain.swift
//  Terra 3D
//
//  Created by Jiexy on 2/8/25.
//
import RealityKit

class Terrain: Entity, HasModel {
    required init() {
        super.init()
        let terrainMesh = TerrainMesh()
        // min change should be 0.075
        terrainMesh.position.y = Ocean.waterLevel - 0.0755// submerge level
        let ocean = Ocean()
        ocean.position = .zero
        self.addChild(ocean)
        self.addChild(terrainMesh)
    }
}
