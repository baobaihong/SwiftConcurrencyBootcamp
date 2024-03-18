//
//  GlobalActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/18.
//

import SwiftUI

// MARK: Data Manager
@globalActor
final class MyFirstGlobalActor {
    static var shared = MyNewDataManager()
}

actor MyNewDataManager {
    func getDataFromDatabase() -> [String] {
        return["one", "two", "three", "four", "five"]
    }
}
// MARK: View Model
class GlobalActorBootcampViewModel: ObservableObject {
    // Use @MainActor when you want to isolate the property/method to the main thread.
    @MainActor @Published var dataArray: [String] = []
    let manager = MyFirstGlobalActor.shared
    
    @MyFirstGlobalActor 
    func getData() async {
        // Heavy complex methods...
        let data = await manager.getDataFromDatabase()
        await MainActor.run {
            self.dataArray = data
        }
    }
}
// MARK: View
struct GlobalActorBootcamp: View {
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

#Preview {
    GlobalActorBootcamp()
}
