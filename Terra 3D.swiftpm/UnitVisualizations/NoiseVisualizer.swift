//
//  PerlinNoiseVisualizer.swift
//  Terra 3D
//
//  Created by Jiexy on 1/26/25.
//
//  Primarily for visual feedback. Should not be reachable from any other view
// Code content could be improved but it is not a primary concern

import SwiftUI
import CoreGraphics

fileprivate let testSize = (height: 512, width: 512)

struct NoiseVisualizer: View {
    @State var frequency = 2.0
    @State var persistence = 0.5
    @State var lacunarity = 2.0
    @State var seed: Int32 = 0
    @State var scale: Float = 1
    @State var noiseHeight: Double = 1.0
    @State var noiseWidth: Double = 1.0
    @State var seamless = true
    // Double for the slider. Ideally ints
    @State var octaveCount = 6.0
    @State var sampleCountX = 100.0
    @State var sampleCountY = 100.0
    var noiseGenerator: NoiseGenerator {
        return PerlinNoiseGenerator(
            frequency: frequency,
            octaveCount: Int(octaveCount),
            persistence: persistence,
            lacunarity: lacunarity,
            seed: seed
        )
    }
    
    var body: some View {
        VStack(spacing: 25){
            Image(uiImage: generatePerlinNoiseImage() ?? UIImage())
                .resizable()
                .frame(width: 500, height: 500)
                .aspectRatio(contentMode: .fill)
            Button {
                reset()
                seed = Int32.random(in: 0..<Int32.max)
            } label: {
                Text("Generate New Perlin Noise Image")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(width: 500, height: 50)
            }
            .buttonStyle(.bordered)
            .tint(.pink)
            .buttonBorderShape(.roundedRectangle)
            VStack{
                LabeledSlider(label: "Frequency", value: $frequency, min: 0, max: 64, step: 0.01)
                LabeledSlider(label: "Octave", value: $octaveCount, min: 0, max: 30, step: 1)
                LabeledSlider(label: "Persistence", value: $persistence, min: 0, max: 1.5, step: 0.01)
                LabeledSlider(label: "Lacunarity", value: $lacunarity, min: 0, max: 5, step: 0.01)
                LabeledSlider(label: "Scale", value: $scale, min: 1, max: 10, step: 0.01)
                LabeledSlider(label: "Noise Height", value: $noiseHeight, min: 0.01, max: 5, step: 0.01)
                LabeledSlider(label: "Noise Width", value: $noiseWidth, min: 0.01, max: 5, step: 0.01)
                LabeledSlider(label: "Sample Count X", value: $sampleCountX, min: 1, max: Double(testSize.height), step: 1)
                LabeledSlider(label: "Sample Count Y", value: $sampleCountY, min: 1, max: Double(testSize.width), step: 1)
                Toggle(isOn: $seamless) {
                    Text("Seamless")
                }.frame(width: 200)
            }
            .frame(width: 600)
        }
    }
    
    func generatePerlinNoiseImage() -> UIImage? {
        // from the data source array, we only read one value to create an output pixel
        // this is because for grayscale pixels, the RGB values are the same
        let grayScaleUnitDataSize = 1
        let bitsPerComponent = 8 // recommended in docs as default
        let bitsPerPixel = bitsPerComponent * grayScaleUnitDataSize
        let width = testSize.width
        let height = testSize.height
        let bytesPerRow = width * grayScaleUnitDataSize
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        // generate the map used for the image
        let noiseMap = noiseGenerator.generateNoiseMap(
            noiseHeight: noiseHeight, noiseWidth: noiseWidth,
            sampleCount: (x: Int(sampleCountX), y: Int(sampleCountY)),
            seamless: seamless
        )
        let imageMap = NoiseGenerator.fillMap(from: noiseMap, scaleBy: scale, size: testSize, with: NoiseNormalizer.colorNormalizer)
        // we need the colors to be integers
        let grayColorMap = imageMap.map { value in
            UInt8(value)
        }
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let provider = CGDataProvider(data: Data(grayColorMap) as CFData) else {
            return nil
        }
        
        guard let cgImage = CGImage(width: width,
                                    height: height,
                                    bitsPerComponent: bitsPerComponent,
                                    bitsPerPixel: bitsPerPixel,
                                    bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo,
                                    provider: provider,
                                    decode: nil,
                                    shouldInterpolate: true,
                                    intent: .defaultIntent)
        else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    
    /// This is used to reset all the values of the sliders. It is used when a new image is generated. Ideally, we want this to reset the slider values when a new image is generated
    private func reset() {
        frequency = 2.0
        octaveCount = 6
        persistence = 0.5
        lacunarity = 2.0
        seed = 0
        scale = 1
        noiseWidth = 1.0
        noiseHeight = 1.0
        seamless = true
        sampleCountX = 100.0
        sampleCountY = 100.0
    }
    
    private func LabeledSlider<N>(
        label: String,
        value: Binding<N>,
        min: N,
        max: N,
        step: N.Stride
    ) -> some View where N: BinaryFloatingPoint, N.Stride:  BinaryFloatingPoint {
        return HStack(spacing: 50) {
            Text(label)
                .font(.headline)
                .frame(width: 150)
            Slider(value: value, in: min...max, step: step)
            Text(String(format: "%.2f", value.wrappedValue as! CVarArg))
                .font(.headline)
                .frame(width: 75)
        }
    }
}

#Preview {
    NoiseVisualizer()
}
