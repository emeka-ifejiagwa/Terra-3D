//
//  SwiftUIView.swift
//  Terra 3D
//
//  Created by Jiexy on 2/5/25.
//

// Code content could be improved but it is not a primary concern
// Intended for visual feedback with preview

import SwiftUI

fileprivate let testSize = (height: 256, width: 256)

private struct TerrainTextureVisualizer: View {
    @State private var seed: Int32 = Int32.random(in: Int32.min..<Int32.max - 1)

    var heightMap: Flat2DArray<Float> {
        let heightGenerator: NoiseGenerator = PerlinNoiseGenerator(seed: seed)
        let gkHeightMap = heightGenerator.generateNoiseMap()
        return NoiseGenerator.fillMap(from: gkHeightMap, size: testSize, with: NoiseNormalizer.absNormalizer)
    }
    var tempMap: Flat2DArray<Float> {
        let tempGenerator: NoiseGenerator = RidgedNoiseGenerator(frequency: 2, octaveCount: 6, lacunarity: 2, seed: seed + 1)
        let gkTempMap = tempGenerator.generateNoiseMap()
        return NoiseGenerator.fillMap(from: gkTempMap, scaleBy: 2, size: testSize, with: NoiseNormalizer.zeroToOneNormalizer)
    }
    var humidityMap: Flat2DArray<Float> {
        let humidityGenerator: NoiseGenerator = BillowNoiseGenerator(seed: seed + 2)
        let gkHumidityMap = humidityGenerator.generateNoiseMap()
        return NoiseGenerator.fillMap(from: gkHumidityMap, scaleBy: 4, size: testSize, with: NoiseNormalizer.zeroToOneNormalizer(normalize:))
    }
    
    var body: some View {
        VStack(spacing: 50){
            Image(uiImage: TerrainTextureGenerator.generateTexture(
                heightMap: heightMap,
                temperatureMap: tempMap,
                humidityMap: humidityMap,
                size: CGSize(width: testSize.width, height: testSize.height),
                blurRadius: 4)!)
                .resizable()
                .frame(width: 600, height: 600)
            Button {
                seed = Int32.random(in: Int32.min...Int32.max)
            } label: {
                Text("Generate New Texture")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(width: 600, height: 50)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .buttonBorderShape(.roundedRectangle)
        }
        }
}

#Preview {
    TerrainTextureVisualizer()
}
