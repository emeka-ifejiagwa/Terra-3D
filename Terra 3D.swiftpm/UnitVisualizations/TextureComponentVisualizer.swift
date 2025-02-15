//
//  TextureComponentVisualizer.swift
//  Terra 3D
//
//  Created by Jiexy on 2/15/25.
//

// Code content could be improved but it is not a primary concern
// Intended for visual feedback with preview

import SwiftUI

fileprivate let testSize = (height: 512, width: 512)

private struct TerrainTextureVisualizer: View {

    @State var heightMap: Flat2DArray<Float> = TerrainMapComponent(height: testSize.height, width: testSize.width).heightMap
    var tempMap: Flat2DArray<Float> {
        TemperatureComponent(height: testSize.height, width: testSize.width, heightMap: self.heightMap).temperatureMap
    }
    var humidityMap: Flat2DArray<Float> {
        HumidityComponent(height: testSize.height, width: testSize.width, heightMap: self.heightMap).humidityMap
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
                self.heightMap = TerrainMapComponent(height: testSize.height, width: testSize.width).heightMap
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
