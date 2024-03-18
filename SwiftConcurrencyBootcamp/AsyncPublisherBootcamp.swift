//
//  AsyncPublisherBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/18.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
    }
}
class AsyncPublisherBootcampViewModel: ObservableObject {
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    var cancellable = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        Task {
            await MainActor.run {
                self.dataArray = ["ONE"]
            }
            // subscriber will never stop waiting the publishers, break the for-in loop manually
            for await value in manager.$myData.values {
                await MainActor.run {
                    self.dataArray = value
                }
                break
            }
            await MainActor.run {
                self.dataArray = ["TWO"]
            }
        }
//        manager.$myData
//            .receive(on: DispatchQueue.main)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellable)
    }
    
    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisherBootcamp: View {
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
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
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherBootcamp()
}
