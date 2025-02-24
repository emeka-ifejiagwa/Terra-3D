//
//  SimulationOptionsView.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import SwiftUI

struct SimulationOptionsView: View {
    @Bindable var simManager: SimManager
    
    init(simManager: SimManager) {
        self.simManager = simManager
    }
    
    var body: some View {
        ZStack{
            Image("HomeImage")
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea(.all)
            HStack(alignment: .top) {
            Spacer()
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(.ultraThinMaterial)
                .frame(width: 450)
                .frame(maxHeight: .infinity)
                .overlay {
                    VStack (alignment: .leading) {
                        Text("Simulation Options")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                        Text("Explore different scenarios for your simulation.")
                            .font(.footnote)
                            .fontWeight(.light)
                            .padding(.bottom, 20)
                        VStack(alignment: .leading) {
                            Text("Pollution Level")
                                .font(.headline)
                            Picker(selection: $simManager.pollutionLevel) {
                                Text("None").tag(PollutionLevel.none)
                                Text("Low").tag(PollutionLevel.low)
                                Text("Medium").tag(PollutionLevel.medium)
                                Text("High").tag(PollutionLevel.high)
                            } label: {
                                Text("Pollution Level")
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: .infinity)
                            Text("The pollution level you choose is individual-based. The general effect of pollution is based on the population")
                                .font(.footnote)
                                .fontWeight(.thin)
                        }
                        .padding(.bottom, 20)
                        
                        VStack(alignment: .leading) {
                            Text("Urbanization Level")
                                .font(.headline)
                            Picker(selection: $simManager.urbanizationLevel) {
                                Text("None").tag(UrbanizationLevel.none)
                                Text("Low").tag(UrbanizationLevel.low)
                                Text("Medium").tag(UrbanizationLevel.medium)
                                Text("High").tag(UrbanizationLevel.high)
                            } label: {
                                Text("Urbanization Level")
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: .infinity)
                            Text("This determines the level technological advancements. Higher levels of urbanization can lead to increased industrial pollution.")
                                .font(.footnote)
                                .fontWeight(.thin)
                        }
                        .padding(.bottom, 28)
                        
                        VStack(alignment: .leading) {
                            Text("Forestation")
                                .font(.headline)
                            Picker(selection: $simManager.forestationLevel) {
                                Text("Deforestation").tag(ForestationLevel.deforestation)
                                Text("None").tag(ForestationLevel.none)
                                Text("Afforestation").tag(ForestationLevel.afforestation)
                            } label: {
                                Text("Forestation Level")
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: .infinity)
                            Text("Afforestation, which involves the planting of trees, can reduce carbon concentration in the atmosphere by increasing the number of trees.")
                                .font(.footnote)
                                .fontWeight(.thin)
                        }
                        .padding(.bottom, 28)
                        
                        Spacer()
                        Text("Find a flat surface, preferably an open space, and watch the simulation unfold before your eyes.")
                        Button {
                            self.simManager.transitionToAR()
                        } label: {
                            Label("Run Simulation", systemImage: "play.fill")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .frame(height: 32)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                        .frame(maxWidth: .infinity)
                        
                        
                    }
                    .padding(32)
                }
        }
        .padding(.horizontal, 32)
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    SimulationOptionsView(simManager: SimManager())
}
