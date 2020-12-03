//
//  EditingPage.swift
//  To_Do_list
//
//  Created by Ting Qu on 12/2/20.
//

import SwiftUI

struct EditingPage: View {
    @EnvironmentObject var UserData: ToDo
    @State var title: String = ""
    @State var duedate: Date = Date()
    @State var isFavorite = false
    
    var id: Int? = nil
    
    @Environment(\.presentationMode) var presentation
    var body: some View {
        NavigationView{
            Form{
                Section(header:Text("To Do")){
                    TextField("Things to Do", text: self.$title)
                    DatePicker(selection: self.$duedate, label: { Text("DeadLine") })
                }
                
                Section{
                    Toggle(isOn: self.$isFavorite) {
                        Text("Favorite")
                    }
                }
                
                Section{
                    Button(action:{
                        if self.id == nil {
                            self.UserData.add(data: SingleToDo(title: self.title, duedate: self.duedate, isFavorite:self.isFavorite))
                        }
                        else{
                            self.UserData.edit(id: self.id!, data: SingleToDo(title: self.title, duedate: self.duedate, isFavorite: self.isFavorite))

                        }
        
                        self.presentation.wrappedValue.dismiss()
                    }){
                        Text("Confirm")
                    }
                    Button(action:{
                        self.presentation.wrappedValue.dismiss()
                    }){
                    Text("Cancel")
                    }
                }
            }
            .navigationBarTitle("Adding To Do")
        }
    }
}

struct EditingPage_Previews: PreviewProvider {
    static var previews: some View {
        EditingPage()
    }
}
