//
//  IntroView.swift
//  Terra 3D
//
//  Created by Jiexy on 2/24/25.
//

import SwiftUI

struct IntroView: View {
    var simManager: SimManager
    
    var attributionString = "<a href=\"https://www.vecteezy.com/free-png/3d\">3d PNGs by Vecteezy</a>'"
    
    var introText = """
    A sudden ripple passes through Terra—something unseen yet undeniably present. Scientists, workers, and citizens alike pause mid-step, struck by a tingle of looming significance. Then an echoing pulse resonates, almost as if time itself shifts under them.

    Moments later, a curious entity emerges, claiming to hail from a future world—one that has collapsed into ruin, rendered uninhabitable by catastrophic forces. The being’s voice crackles with urgency and regret:
    
    “They told me my planet was doomed—its skies tainted red, forests turned to ash, oceans shrinking beneath toxic storms. My people believed escape was futile, but I refused to surrender. So I volunteered for a desperate mission, setting course for a distant world we call Earth—a place rumored to teeter on the same brink we once did, yet still clinging to hope for revival”
    """
    
    var body: some View {
        ZStack{
            Image("HomeImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                
            Color.black
                .opacity(0.7)
            VStack {
                Text(introText)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(width: 600)
                    .foregroundStyle(.white)
                Button {
                    simManager.currentAppState = .userSelection
                } label: {
                    Label("Next", image: "forward.fill")
                        .font(.headline)
                }
                .buttonStyle(.bordered)
                .tint(.white)
                .frame(maxWidth: .infinity)
                Text("Attribution for image: \(attributionString)")
                    .font(.footnote)
            }
            .padding(30)
            
        }.ignoresSafeArea(.all)
    }
}

#Preview {
    IntroView(simManager: SimManager())
}
