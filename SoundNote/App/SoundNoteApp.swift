//
//  SoundNoteApp.swift
//  SoundNote
//
//  Created by iso karo on 19.03.2022.
//

import SwiftUI

@main
struct SoundNoteApp: App {
    let persistenceController = PersistenceController.shared
    // created the instance of the SoundNoteViewModel() here and pass it as an EnvironmentObject
    @StateObject var sondNoteVM=SoundNoteViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
            //This below passes our view context directly into ContentView as environment data which means we can add an @Environment property to ContentView to read the managed object context
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(sondNoteVM)
        }
    }
}
