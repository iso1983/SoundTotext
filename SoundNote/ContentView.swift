//
//  ContentView.swift
//  SoundNote
//
//  Created by iso karo on 19.03.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    // this passes our view context directly into ContentView as environment data.The persistent container gives us a property called viewContext , which is a managed object context: an environment where we can manipulate Core Data objects entirely in RAM. Note in the SoundNoteApp.swift file we added an environment data that is the viewContext and to get it we just add the line right below
    @Environment(\.managedObjectContext) private var viewContext

    //If you want to sort your data, provide your sort descriptors as an array of keypaths, like below,also note that @FetchRequest allows us to fetch the data in core data so below the "notes" property can be used in the ForEach loop to fetch data in core data and we did that.:
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Note.created, ascending: true)],animation:.default) private var notes:FetchedResults<Note>
    
//    SoundNoteViewModel is a class and conforms to ObservableObject,it has the CRUD functionality for core data so we use it here as EnvironmentObject,Think of @EnvironmentObject as a massive convenience for times when you need to pass lots of data around your app. Because all views point to the same model, if one view changes the model all views immediately update – there’s no risk of getting different parts of your app out of sync.So If you want to use the SoundNoteViewModle in another file we need to add this line right below
    @EnvironmentObject var soundNoteVM:SoundNoteViewModel
    @State private var recording=false
    private var speechManager=SpeechManager()
    
        var body: some View {
            NavigationView {
                ZStack(alignment: .bottomTrailing){
                    List {
                        //notes below is coming from the @FetchRequest core data property wrapper
                        ForEach(notes) { item in
                                HStack {
                                        Text(item.text!)
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                   .onTapGesture(count: 1) {
                                      //UIPasteboard class is used to copy something to the clipboard
                                       UIPasteboard.general.setValue(item.text!, forPasteboardType: "public.plain-text")
                                       
//                                     share(text: "hello")
                                   }
                       
                        }
                        .onDelete(perform: deleteItems)
                        
                    }//List
                   
                    
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.7))
                    .opacity(recording ? 1 : 0)
// put this at the end because remember we are still in ZStack and if i put this above then it is on top of the filling
                    VStack{
                           recordButton()
                    }
            }//:ZStack
                .navigationTitle("Sound Note")
                .toolbar {
                    Button("Help") {
                        print("Help tapped!")
                        }
                    }
            .onAppear {
                speechManager.checkPermissions()
            }
            
        }//:NavigationView
    //This line makes the app show in full in screen on ipad.
            .navigationViewStyle(StackNavigationViewStyle())
    }
        

    
    private func recordButton()->some View{
        Button(action:addItem){
            Image(systemName:recording ? "stop.fill" :  "mic.fill")
                .resizable()
                    .frame(width: 45.0, height: 50.0)
                .font(.system(size:40))
                .padding()
                .cornerRadius(10)
        }
        .foregroundColor(.red)
    }
    
    private func addItem(){
        if speechManager.isRecording{
            self.recording=false
            speechManager.stopRecording()
            
        }else{
            self.recording=true
            //speechManager.start is important ,check it 
            speechManager.start { speechText in
             
            guard let text=speechText, !text.isEmpty else{
               
                self.recording = false
                return
            }
                
            DispatchQueue.main.async {
                withAnimation {
                    soundNoteVM.createNote(context:viewContext,text:text)
                }
            }
            

            }
        }
        speechManager.isRecording.toggle()
    }
    
    private func deleteItems(offsets:IndexSet){
        withAnimation{
            offsets.map{notes[$0]}.forEach(viewContext.delete)
            do{
                try viewContext.save()
            }catch{
               print(error)
            }
        }
    }
    
}
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Note>
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//            Text("Select an item")
//        }
//    }

//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
