//
//  ActorsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/18.
//

import SwiftUI

// 1. What is the problem that Actors are solving?
// 2. How was this problem solved prior to Actors?
// 3. Actors can solve the problem

// PROBLEM recur: multiple threads accessing the same class causing swift data race
class MyDataManager {
    static let instance = MyDataManager()
    private init() { }
    
    var data: [String] = []
    
    // before concurrency, to make a class thread safe, create a custom DispatchQueue, making the code stand in line
    private let queue = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    func getRandomData(completionHandle: @escaping (_ title: String?) -> ()) {
        queue.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandle(self.data.randomElement())
        }
        //        self.data.append(UUID().uuidString)
        //        print(Thread.current)
        //        return data.randomElement()
    }
}

// the code inside Actor is isolated, accessing the property need to be in a async context
actor MyActorDataManager {
    static let instance = MyActorDataManager()
    private init() { }
    
    var data: [String] = []
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    // to make method/property not isolated in the async context, mark as nonisolated
    nonisolated
    func getSavedData() -> String {
        return "new data"
    }
}

struct HomeView: View {
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer, perform: { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//                
//            }
        })
    }
}

struct BrowseView: View {
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer, perform: { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
        })
    }
}

struct ActorsBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorsBootcamp()
}
