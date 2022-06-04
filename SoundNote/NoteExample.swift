//
//  NoteExample.swift
//  SoundNote
//
//  Created by iso karo on 21.03.2022.
//

import Foundation


class NoteExample:Identifiable{
    
    let uuid=UUID()
    let timeStamp=Date()
    
    init()
    {
        let context=PersistenceController.shared.container.viewContext
        let request=Note.fetchRequest()
        
    }
}
