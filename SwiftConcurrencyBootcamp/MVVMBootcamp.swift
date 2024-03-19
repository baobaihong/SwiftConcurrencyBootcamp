//
//  MVVMBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/19.
//

import SwiftUI

final class MyManagerClass {
    func getData() async throws -> String {
        "Some Data"
    }
}

actor MyManagerActor {
    func getData() async throws -> String {
        "Some Data"
    }
}

@MainActor
final class MVVMBootcampViewModel: ObservableObject {
    let managerClass = MyManagerClass()
    let managerActor = MyManagerActor()
    
    @Published private(set) var myData: String = "Starting text"
    private var tasks: [Task<Void, Never>] = []
    
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    //@MainActor
    func onCallToActionButtonPressed() {
        // to keep the UI sync, put Task {} instead of async
        let task = Task {
            do {
//                myData = try await managerClass.getData()
                // as the whole view model is marked as @MainActor, when you access actor from background thread, it can get the data back to the main thread automatically.
                myData = try await managerActor.getData()
            } catch {
                // handle the error inside do-catch block instead throw it outside the task to make task error type as Never
                print(error)
            }
        }
        tasks.append(task)
    }
}

struct MVVMBootcamp: View {
    @StateObject private var viewModel = MVVMBootcampViewModel()
    
    var body: some View {
        Button(viewModel.myData) {
            viewModel.onCallToActionButtonPressed()
        }
    }
}

#Preview {
    MVVMBootcamp()
}
