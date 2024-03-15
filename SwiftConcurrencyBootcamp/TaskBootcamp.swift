//
//  TaskBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/15.
//

import SwiftUI

@Observable class TaskBootcampViewModel {
    var image: UIImage? = nil
    var image2: UIImage? = nil
    
    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        /*
         in a long-task(e.g. includes for-in loop), you might need to check for cancellation at several points, and handle cancellation differently at each point.
         for x in array {
            //work...
            try Task.checkCancellation()
         }
         */
        
        
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            self.image = UIImage(data: data)
            print("image returned successfully")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            self.image2 = UIImage(data: data)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskBootcampHomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationLink("CLICK ME") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    @State private var viewModel = TaskBootcampViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40.0) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        // use .task directly instead of .onAppear / .onDismiss, SwiftUI will automatically run and cancel the tasks
        .task {
            await viewModel.fetchImage()
        }
//        .onDisappear {
            // manually cancel the task if user dismiss the view
//            fetchImageTask?.cancel()
//        }
//        .onAppear {
            // sync code, two task starts simultaneously
//            self.fetchImageTask = Task {
                // async code
                //print(Thread.current) // on the main thread
                //print(Task.currentPriority) // high priority
//                await viewModel.fetchImage()
//            }
//            Task {
//                // async code
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage2()
//            }
            // High priority does not mean it will finish first
            // T1:HIGH
//            Task(priority: .high) {
//                await Task.yield() // Suspends the current task and allows other tasks to execute.
//                print("high: \(Thread.current); \(Task.currentPriority)")
//            }
//            Task(priority: .userInitiated) {
//                print("userInitiated: \(Thread.current); \(Task.currentPriority)")
//            }
//            // T2: MEDIUM
//            Task(priority: .medium) {
//                print("medium: \(Thread.current); \(Task.currentPriority)")
//            }
//            // T3: LOW
//            Task(priority: .utility) {
//                print("utility: \(Thread.current); \(Task.currentPriority)")
//            }
//            Task(priority: .low) {
//                print("low: \(Thread.current); \(Task.currentPriority)")
//            }
//            // T4: BACKGROUND
//            Task(priority: .background) {
//                print("Background: \(Thread.current); \(Task.currentPriority)")
//            }
//            Task(priority: .low) {
//                print("userInitiated: \(Thread.current); \(Task.currentPriority)")
//                // sub-task will inherit the priority from parent
//                // detach the sub-task to reset its own priority
//                Task.detached {
//                    print("userInitiated: \(Thread.current); \(Task.currentPriority)")
//                }
//            }
            
//        }
    }
}

#Preview {
    TaskBootcampHomeView()
}
