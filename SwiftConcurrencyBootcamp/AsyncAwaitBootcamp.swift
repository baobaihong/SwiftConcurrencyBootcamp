//
//  AsyncAwaitBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/14.
//

import SwiftUI

// await: wait for the code to finish, and then run the code below. Don't know how long it's gonna wait.
// async func: a special kind of function or method that can be suspended while it’s partway through execution.
// Concurrency is built on top of thread management, which means developers don't need to worry about which thread their code is run on.

@Observable class AsyncAwaitBootcampViewModel {
    var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dataArray.append("Title1: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            let title2 = "Title2: \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title2)
            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1: \(Thread.current)" // author1 is always on the background thread
        self.dataArray.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000) // delay for 2 seconds
        
        let author2 = "Author2: \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(author2)
            
            let author3 = "Author3: \(Thread.current)" // author3 is always on the main thread
            self.dataArray.append("Author3: \(Thread.current)")
        }
        
        await addSomething() // chain the async func
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let something1 = "Something1: \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(something1)
            
            let something2 = "Something2: \(Thread.current)"
            self.dataArray.append(something2)
        }
    }
}

struct AsyncAwaitBootcamp: View {
    @State private var viewModel = AsyncAwaitBootcampViewModel()
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                await viewModel.addAuthor1()
                
                let finalText = "Final Text: \(Thread.current)" // on the main Thread
                viewModel.dataArray.append(finalText)
            }
//            viewModel.addTitle1()
//            viewModel.addTitle2()
        }
    }
}

#Preview {
    AsyncAwaitBootcamp()
}
