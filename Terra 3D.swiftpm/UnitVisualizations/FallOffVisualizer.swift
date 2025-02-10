//
//  FallOffVisualizer.swift
//  Terra 3D
//
//  Created by Jiexy on 2/9/25.
//
// Code content could be improved but it is not a primary concern
// Intended for visual feedback with preview

import SwiftUI

fileprivate let testSize = CGSizeInt(height: 512, width: 512)

private struct FallOffVisualizer: View {
    @State var fallOffStart: Float = 0
    @State var fallOffEnd: Float = 1
    let noiseGenerator: NoiseGenerator = ConstantNoiseGenerator(value: 1)
    var fallOffGenerator: FallOffGenerator {
        return FallOffGenerator(height: testSize.height, width: testSize.width, fallOffStart: fallOffStart, fallOffEnd: fallOffEnd)
    }
    
    var body: some View {
        VStack{
            Image(uiImage: generateFallOffMapImage() ?? UIImage())
                .resizable()
                .frame(width: 512, height: 512)
            HStack{
                Text("Fall off start")
                    .font(.subheadline)
                Slider(value: $fallOffStart, in: 0...1)
                Text("\(fallOffStart)")
            }
            HStack{
                Text("Fall off end")
                    .font(.subheadline)
                Slider(value: $fallOffEnd, in: 0...1)
                Text("\(fallOffEnd)")
            }
        }
        .frame(width: 512)
        .ignoresSafeArea(.all)
    }
    
    func generateFallOffMapImage() -> UIImage? {
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
        let noiseMap = noiseGenerator.generateNoiseMap()
        let imageMap = NoiseGenerator.fillMap(from: noiseMap, size: testSize, with: NoiseNormalizer.colorNormalizer)
        // we need the colors to be integers
        let grayColorMap = fallOffGenerator.applyFallOff(to: imageMap).map { value in
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
}

#Preview {
    FallOffVisualizer()
        .preferredColorScheme(.light)
}
