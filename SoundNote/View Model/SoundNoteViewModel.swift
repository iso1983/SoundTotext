//
//  SoundNoteViewModel.swift
//  SoundNote
//
//  Created by iso karo on 23.03.2022.
//

import Foundation
////Use Combine if you need to do API calls or notifications
//import Combine
import CoreData


class SoundNoteViewModel:ObservableObject{
    
//    This is a Published prop observer ,so in other files this notTitle will be observed using the @ObservedObject like this:  @ObservedObject var noteTitle:SoundNoteViewModel
    @Published var noteTitle=""
    
    func createNote(context:NSManagedObjectContext,text:String){
        let note = Note(context:context)
        note.id=UUID()
        note.text=text
        note.created=Date()
     
        save(context: context)
    }

    func save(context:NSManagedObjectContext){
        do{
            try context.save()
        }catch{
            print(error)
        }
    }
    
    //To use this function from a view ,add this:  @ObservedObject var note:Note  to that view and then call the delete : SoundViewModel.delete(note:note,viewContext)
    func delete(note:Note,context:NSManagedObjectContext){
        context.delete(note)
        save(context:context)
    }

}
