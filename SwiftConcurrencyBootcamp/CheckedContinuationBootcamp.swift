//
//  CheckedContinuationBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/15.
//

import SwiftUI
class CheckedContinuationBootcampDataManager {
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }
    
    // turn a escaping closure into a concurrency func
    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            // resume must be called exactly one time
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if error != nil {
                    continuation.resume(throwing: URLError(.badServerResponse))
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartImageFromDatabase() async -> UIImage {
        return await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
    
}
@Observable class CheckedContinuationBootcampViewModel {
    var image: UIImage? = nil
    let dataManager = CheckedContinuationBootcampDataManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        
        do {
            let data = try await dataManager.getData2(url: url)
            self.image = UIImage(data: data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getHeartImage() async {
        self.image = await dataManager.getHeartImageFromDatabase()
    }
}

struct CheckedContinuationBootcamp: View {
    @State private var viewModel = CheckedContinuationBootcampViewModel()
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.getHeartImage()
        }
    }
}

#Preview {
    CheckedContinuationBootcamp()
}
