//
//  ContentView.swift
//  To_Do_list
//
//  Created by Ting Qu on 11/30/20.
//

import SwiftUI

var formatter = DateFormatter()

func initUserData() -> [SingleToDo]{
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    var output: [SingleToDo] = []
    if let dataStored = UserDefaults.standard.object(forKey: "ToDoListData") as? Data {
        let data = try! decoder.decode([SingleToDo].self,from:dataStored)
        for item in data{
            if !item.deleted{
                output.append(SingleToDo(title:item.title, duedate: item.duedate, isChecked: item.isChecked, isFavorite:item.isFavorite, id: output.count))
            }
        }
    }
    return output
}
struct ContentView: View {
    @ObservedObject var UserData: ToDo = ToDo(data: initUserData())
    
    @State var showEditingPage = false
    
    @State var editingMode = false
    
    @State var showLikeOnly = false
 
    @State var selection: [Int] = []

    
    var body: some View {
        ZStack {
            NavigationView{
                ScrollView(.vertical,showsIndicators: true){
                    VStack{
                        ForEach(self.UserData.ToDoList) {item in
                            if !item.deleted{
                                if !self.showLikeOnly || item.isFavorite{
                                    SingleCardView(editingMode: self.$editingMode, selection: self.$selection, index: item.id)
                                        .environmentObject(self.UserData)
                                        .padding(.top)
                                        .padding(.horizontal)
                                        .animation(.spring())
                                        .transition(.slide)
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("To Do List")
                .navigationBarItems(trailing:
                    HStack (spacing: 20){
                        if self.editingMode{
                            deleteButton(selection: self.$selection, editingMode: self.$editingMode)
                                .environmentObject(self.UserData)
                            LikeButton(selection:self.$selection, editingMode: self.$editingMode)
                                .environmentObject(self.UserData)
                            
                        }
                        if !self.editingMode{
                            showLikeButton(showLikeOnly: self.$showLikeOnly)
                        }
                        EditingButton(editingMode:self.$editingMode, selection: self.$selection)
                        
                })
                
            }
            
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Button(action:{
                        self.showEditingPage = true
                    }){
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:50)
                            .foregroundColor(.blue)
                            .padding()
                    }.sheet(isPresented:self.$showEditingPage,content:{
                        EditingPage()
                            .environmentObject(self.UserData)
                    })
                }
            }
            
            
            
        }
    }
}

struct LikeButton:View{
    
    @EnvironmentObject var UserData: ToDo
    
    @Binding var selection: [Int]
    
    @Binding var editingMode: Bool
    
    var body: some View{
        Image(systemName: "star.lefthalf.fill")
            .imageScale(.large)
            .foregroundColor(.yellow)
            .onTapGesture {
                for i in self.selection{
                    self.UserData.ToDoList[i].isFavorite.toggle()
            }
                self.editingMode = false
        }
    }
}

struct  showLikeButton:View{
    @Binding var showLikeOnly: Bool
    
    var body: some View{
        Button(action:{
            self.showLikeOnly.toggle()
        }){
            Image(systemName: self.showLikeOnly ? "star.fill" : "star")
                .imageScale(.large)
                .foregroundColor(.yellow)
        }
    }
}

struct EditingButton:View{
    @Binding var editingMode: Bool
    @Binding var selection:[Int]
    
    var body: some View{
        Button(action:{
            self.editingMode.toggle()
            self.selection.removeAll()
        }){
            Image(systemName:"gear")
                .imageScale(.large)
        }
       
    }
}

struct deleteButton: View{
    @Binding var selection: [Int]
    @EnvironmentObject var UserData: ToDo
    @Binding var editingMode: Bool
    
    var body: some View{
        Button(action:{
            for i in self.selection{
                self.UserData.delete(id: i)
            }
            self.editingMode = false
        }){
            Image(systemName: "trash")
                .imageScale(.large)
        }
    }
}

struct SingleCardView: View{
    @EnvironmentObject var UserData: ToDo
    @Binding var editingMode: Bool
    @State var showEditingPage = false
    @Binding var selection: [Int]
    var index: Int
    
    var body: some View{
        HStack {
            Rectangle()
                .frame(width:6)
                .foregroundColor(Color("Card" + String(self.index % 5)))
            
            if self.editingMode{
                Button(action:{
                    self.UserData.delete(id: self.index)
                    self.editingMode = false
                }){
                    Image(systemName: "trash")
                        .imageScale(.large)
                        .padding()
                }
            }
        
            Button(action:{
                if !self.editingMode{
                    self.showEditingPage = true
                }
                
            }){
                Group {
                    VStack(alignment: .leading, spacing: 8.0){
                        Text(self.UserData.ToDoList[index].title)
                            .font(.headline)
                            .foregroundColor(.black)
                            .fontWeight(.heavy)
                        Text(formatter.string(from:self.UserData.ToDoList[index].duedate))
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                    .padding(.leading)
                    Spacer()// push the other view to the side
                }
                
            }
            .sheet(isPresented: self.$showEditingPage, content: {
                EditingPage(title: self.UserData.ToDoList[self.index].title, duedate: self.UserData.ToDoList[self.index].duedate, isFavorite: self.UserData.ToDoList[self.index].isFavorite, id:self.index)
                    .environmentObject(self.UserData)
            })
            
            if self.UserData.ToDoList[index].isFavorite{
                Image(systemName: "star.fill")
                    .imageScale(.large)
                    .foregroundColor(.yellow)
            }
            
            if !self.editingMode{
                Image(systemName: self.UserData.ToDoList[index].isChecked ? "checkmark.square.fill" : "square")
                    .imageScale(.large)
                    .padding(.trailing)
                    .onTapGesture {
                        self.UserData.check(id: self.index)
                    }
            }
            else{
                Image(systemName: self.selection.firstIndex(where: {$0 == self.index}) == nil ? "circle" : "checkmark.circle.fill")
                    .imageScale(.large)
                    .padding(.trailing)
                    .onTapGesture {
                        if self.selection.firstIndex(where: {
                            $0 == self.index
                        }) == nil{
                            self.selection.append(self.index)
                        }
                        else{
                            self.selection.remove(at: self.selection.firstIndex(where: {
                                $0 == self.index
                            })!)
                        }
                    }
            }
            
            
        }
        .frame(height:80)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10, x:0, y:10)

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(UserData:ToDo(data: [SingleToDo(title: "Do Homework", duedate: Date(), isFavorite: false), SingleToDo(title: "Studying", duedate: Date(), isFavorite: false)]))
    }
}
