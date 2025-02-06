//
//  SwiftUIView.swift
//  Terra 3D
//
//  Created by Jiexy on 2/5/25.
//

import SwiftUI

fileprivate let testSize = (height: 512, width: 512)

struct TerrainTextureVisualizer: View {
    @State private var seed: Int32 = Int32.random(in: Int32.min...Int32.max)

    var heightMap: Flat2DArray<Float> {
        let heightGenerator: NoiseGenerator = PerlinNoiseGenerator(seed: seed)
        let gkHeightMap = heightGenerator.generateNoiseMap()
        return NoiseGenerator.fillMap(from: gkHeightMap, size: testSize)
    }
    var tempMap: Flat2DArray<Float> {
        let tempGenerator: NoiseGenerator = BillowNoiseGenerator(seed: seed)
        let gkTempMap = tempGenerator.generateNoiseMap()
        return NoiseGenerator.fillMap(from: gkTempMap, scaleBy: 1, size: testSize)
    }
    var humidityMap: Flat2DArray<Float> {
        let humidityGenerator: NoiseGenerator = PerlinNoiseGenerator(seed: seed)
        let gkHumidityMap = humidityGenerator.generateNoiseMap()
        return NoiseGenerator.fillMap(from: gkHumidityMap, size: testSize)
    }
    
    var body: some View {
        VStack(spacing: 50){
            Image(uiImage: TerrainTextureGenerator.generateTexture(
                heightMap: heightMap,
                temperatureMap: tempMap,
                humidityMap: humidityMap,
                size: CGSize(width: testSize.width, height: testSize.height))!)
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
