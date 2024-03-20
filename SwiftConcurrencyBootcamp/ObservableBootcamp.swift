//
//  ObservableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/20.
//

import SwiftUI

actor TitleDatabase {
    func getNewTitle() -> String {
        "Some new title"
    }
}

// @Observable macro disable the main thread purple warning
@Observable
class ObservableViewModel {
    @ObservationIgnored let database = TitleDatabase()
    @MainActor var title: String = "Starting title" // Mark the title property as mainactor
    
    //Approach 1: Mark the whole function as main actor
    //@MainActor
    func updateTitle() async {
        //let title = await database.getNewTitle()
        // Approach2: Mark the essential part of the function as mainactor
//        await MainActor.run {
//            self.title = title
//            print(Thread.current) // on background thread
//        }
        // Approach3: Mark the task as mainactor
        Task { @MainActor in
            title = await database.getNewTitle()
            print(Thread.current)
        }
        
    }
}

struct ObservableBootcamp: View {
    @State private var viewModel = ObservableViewModel()
    var body: some View {
        Text(viewModel.title)
            .task {
                await viewModel.updateTitle()
            }
    }
}

#Preview {
    ObservableBootcamp()
}
