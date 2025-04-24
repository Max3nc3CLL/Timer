//
//  SimpleTimerMacApp.swift
//  SimpleTimerMac
//
//  Created by Maxence Cailleau on 22/04/2025.
//

import SwiftUI
import Combine // Ajouter Combine pour utiliser .onReceive

@main
struct SimpleTimerMacApp: App {
    // Instancier TimerManager comme un StateObject pour le partager
    @StateObject private var timerManager = TimerManager()
    // Ajouter un NSStatusItem pour la barre de menu
    @State private var statusItem: NSStatusItem?

    var body: some Scene {
        // Remplacer WindowGroup par MenuBarExtra pour l'intégration dans la barre de menus
        MenuBarExtra {
            // Le contenu qui apparaît lorsque l'on clique sur l'icône de la barre de menus
            ContentView(timerManager: timerManager)
                // Définir une taille pour la vue popover
                .frame(width: 300)
                // Laisser la hauteur s'adapter au contenu
                .frame(minHeight: 200)
        } label: {
            // L'étiquette affichée dans la barre de menus, mise à jour dynamiquement
            // Utiliser une police monospaced pour un affichage stable
            Text(timerManager.timeString)
                .font(.system(.body, design: .monospaced))
                .onAppear(perform: setupMenuBar)
        }
        // Appliquer un style pour que ça ressemble plus à un popover standard
        .menuBarExtraStyle(.window)
    }
    
    // Fonction pour configurer la barre de menus si plus de personnalisation est nécessaire
    // (Actuellement, l'étiquette Text se met à jour automatiquement grâce à @StateObject)
    private func setupMenuBar() {
        // Configuration future si nécessaire
    }
}
