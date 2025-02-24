//
//  HomeView.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import SwiftUI

struct HomeView: View {
    private var simManager: SimManager
    
    init(simManager: SimManager) {
        self.simManager = simManager
    }
    
    
    public var body: some View {
        ZStack {
            Image("HomeImage")
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea(.all)
                .offset(CGSize(width: 24, height: 0))
            VStack {
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .circular)
                        .frame(width: 640, height: 100)
                        .foregroundStyle(.ultraThinMaterial)
                    HStack(spacing: 50){
                        ForEach(self.simManager.menuItems, id: \.self) { menuItem in
                            Button {
                                simManager.currentAppState = menuItem.destination
                            } label: {
                                HStack(alignment: .top){
                                    Text(menuItem.icon)
                                        .frame(width: 32)
                                    Text(menuItem.title)
                                }
                                .frame(width: 250, height: 32)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.roundedRectangle)
                            .frame(width: 250, alignment: .center)
                            .tint(.green)
                        }
                    }
                }
            }.padding(24)
        }
    }
}

#Preview {
    HomeView(simManager: SimManager())
}
