//
//  TaskGroupBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/15.
//

import SwiftUI
class TaskGroupBootcampDataManager {
    let url = "https://picsum.photos/300"
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let image1 = fetchImage(urlString: url)
        async let image2 = fetchImage(urlString: url)
        async let image3 = fetchImage(urlString: url)
        async let image4 = fetchImage(urlString: url)
        let (fetchedImage1, fetchedImage2, fetchedImage3, fetchedImage4) = await (try image1, try image2, try image3, try image4)
        return [fetchedImage1, fetchedImage2, fetchedImage3, fetchedImage4]
        
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        let urlStrings: [String] = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300"]
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count) // tell the complier in advance how many items will be in this array, sightly improve performance
            
            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            // wait for all the result come back and then start looping
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
    
}

@Observable class TaskGroupBootcampViewModel {
    var images: [UIImage] = []
    let manager = TaskGroupBootcampDataManager()
    
    func getImages() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images = images
        }
    }
    
}

struct TaskGroupBootcamp: View {
    @State private var viewModel = TaskGroupBootcampViewModel()
    let column = [GridItem(.flexible()), GridItem(.flexible())]
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: column) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task Group")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

#Preview {
    TaskGroupBootcamp()
}
