//
//  SimManager.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import SwiftUI

@Observable class SimManager {
    //    var pollutionPerPersion: Double = 0
    //    var Urbanization: Double = 0
    var pollutionLevel: PollutionLevel = .none
    var urbanizationLevel: UrbanizationLevel = .none
    var forestationLevel: ForestationLevel = .none
    var currentAppState: AppState = .mainMenu
    
    let menuItems: [MainMenuItem] = [
        .init(title: "Start Simulation", icon: "🚀", destination: .intro),
    ]
    
    let pollutionLevelOptions = PollutionLevel.allCases
    let urbanizationLevelOptions = UrbanizationLevel.allCases
    let forestationLevelOptions = ForestationLevel.allCases
    
    func transitionToAR(){
        switch pollutionLevel {
        case .none:
            HumanParams.basePollutionPerPerson = 0.0
        case .low:
            HumanParams.basePollutionPerPerson = Double.random(in: 0.5...2.0)
        case .medium:
            HumanParams.basePollutionPerPerson = Double.random(in: 3.0...4.5)
        case .high:
            HumanParams.basePollutionPerPerson = Double.random(in: 7.0...10)
        }
        
        switch urbanizationLevel {
        case .none:
            HumanParams.initialUrbanization = 0.0
        case .low:
            HumanParams.initialUrbanization = Double.random(in: 0.0...1)
        case .medium:
            HumanParams.initialUrbanization = Double.random(in: 5...10)
        case .high:
            HumanParams.initialUrbanization = Double.random(in: 15...20)
        }
        
        switch forestationLevel {
        case .none:
            HumanParams.initialForestation = 0.0
        case .deforestation:
            HumanParams.initialForestation = Double.random(in: -20 ..< -10)
        case .afforestation:
            HumanParams.initialForestation = Double.random(in: 45...55)
        }
        
        currentAppState = .simulation
        
        print(HumanParams.basePollutionPerPerson)
    }

}

struct MainMenuItem: Identifiable, Hashable{
    var title: String
    var icon: String
    var id = UUID()
    var destination: AppState
}

enum PollutionLevel: CaseIterable {
    case none, low, medium, high
}

enum UrbanizationLevel: CaseIterable {
    case none, low, medium, high
}

enum ForestationLevel: CaseIterable {
    case none, deforestation, afforestation
}

enum AppState: CaseIterable {
    case mainMenu, intro, userSelection, simulation, results
}
