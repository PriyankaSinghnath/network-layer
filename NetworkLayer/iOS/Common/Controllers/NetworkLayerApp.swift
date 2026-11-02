//
//  NetworkLayerApp.swift
//  NetworkLayer
//
//  Created by Shipra on 02/11/26.
//

import SwiftUI

@main
struct NetworkLayerApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(api: APIManager(networkManager: NetworkManager()))
        }
    }
}
