//
//  StructClassActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/15.
//

import SwiftUI

/*
 VALUE TYPES:
 - Struct, Enum, String, Int, etc.
 - Stored in the Stack
 - Faster
 - Thread safe!
 - When you assign or pass value type a new copy of data is created
 
 REFERENCE TYPES:
 - Class, Function, Actor
 - Store in the Heap
 - Slower, but synchronized
 - Not Thread safe
 - When you assign or pass value type a new reference to original instance is created (pointer)
 
 STACK:
 - Stored Value types
 - Variables allocated on the stack are stored directly to the memory, and access to this memory is very fast
 - Each thread has it's own stack
 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
 HEAP:
 - Stores reference types
 - Shared across threads
 
 STRUCT:
 - Based on VALUES
 - Can be mutated
 - Stored in the Stack
 
 CLASS:
 - Based on REFERENCES (INSTANCES)
 - Stored in the Heap
 - Inherit from other classes
 
 ACTOR:
 - Same as Class, but thread safe!
 
 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
 Structs: Data Models, Views
 Classes: View Models
 Actors: 
 
 */


struct MyStruct {
    var title: String
}

//Immutable struct, preferred by developers
struct CustomStruct {
    let title: String
    
    func updateTitle(newTitle: String) -> CustomStruct {
        CustomStruct(title: newTitle)
    }
}

struct MutatingStruct {
    private(set) var title: String // <- (set): the value can only set privately, but can be get in public
    
    init(title: String) {
        self.title = title
    }
    
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

// class may run into situations where two threads accessing the instance at the same time, and it will crash your app
// actor is basically the same as class, with one major difference: actor is thread-safe
// when actor run into the awkward situation as mentioned, actor will wait in order
actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

// MARK: View
struct StructClassActorBootcamp: View {
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                runTest()
            }
    }
}

extension StructClassActorBootcamp {
    private func runTest() {
        print("Test started")
        structTest1()
        printDividers()
        ClassTest1()
        printDividers()
        ActorTest1()
//        structTest2()
//        printDividers()
//        classTest2()
    }
    
    private func printDividers() {
        print("""
        
        - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
        """)
    }
    
    private func structTest1() {
        print("structTest1:")
        let objectA = MyStruct(title: "Starting Title")
        print("ObjectA: \(objectA.title)")
        
        print("--Pass the VALUES of objectA to objectB--")
        var objectB = objectA // create a new struct with the value of objectA
        print("ObjectB: \(objectB.title)")
        
        objectB.title = "Second title" // changing the property of a struct will result in a recreating of the whole struct
        print("--ObjectB title changed.--")
        
        print("ObjectA: \(objectA.title)")
        print("ObjectB: \(objectB.title)")
    }
    
    private func ClassTest1() {
        print("ClassTest1:")
        let objectA = MyClass(title: "Starting title")
        print("ObjectA: \(objectA.title)")
        
        print("--Pass the REFERENCE of objectA to objectB--")
        let objectB = objectA
        print("ObjectB: \(objectB.title)")
        
        objectB.title = "Second title" // only change the property, leave the class instance untouched
        print("--ObjectB title changed--")
        
        print("ObjectA: \(objectA.title)")
        print("ObjectB: \(objectB.title)")
    }
    
    private func ActorTest1() {
        Task {
            print("actorTest:")
            let objectA = MyActor(title: "Starting title")
            await print("ObjectA: \(objectA.title)")
            
            print("--Pass the REFERENCE of objectA to objectB--")
            let objectB = objectA
            await print("ObjectB: \(objectB.title)")
            
            await objectB.updateTitle(newTitle: "Title 2")
            print("--ObjectB title changed--")
            
            await print("ObjectA: \(objectA.title)")
            await print("ObjectB: \(objectB.title)")
        }
    }
}

extension StructClassActorBootcamp {
    private func structTest2() {
        print("structTest2")
        
        var struct1 = MyStruct(title: "Title1")
        print("Struct1: \(struct1.title)")
        struct1.title = "Title2"
        print("Struct1: \(struct1.title)")
        
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2: \(struct2.title)")
        struct2 = CustomStruct(title: "Title2")
        print("Struct2: \(struct2.title)")
        
        var struct3 = CustomStruct(title: "Title1")
        print("Struct3: \(struct3.title)")
        struct3 = struct3.updateTitle(newTitle: "Title2")
        print("Struct3: \(struct3.title)")
        
        var struct4 = MutatingStruct(title: "Title1")
        print("Struct4: \(struct4.title)")
        struct4.updateTitle(newTitle: "Title2")
        print("Struct4: \(struct4.title)")
    }
}


extension StructClassActorBootcamp {
    private func classTest2() {
        print("Class Test2:")
        
        let class1 = MyClass(title: "Title1")
        print("Class1: ", class1.title)
        class1.title = "Title2"
        print("Class1: ", class1.title)
        
        let class2 = MyClass(title: "Title1")
        print("Class2: ", class2.title)
        class2.updateTitle(newTitle: "Title2")
        print("Class2: ", class2.title)
    }
}
