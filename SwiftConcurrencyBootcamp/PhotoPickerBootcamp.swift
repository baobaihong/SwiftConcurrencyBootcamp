//
//  PhotoPickerBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/20.
//

import SwiftUI
import PhotosUI

@MainActor
final class PhotoPickerViewModel: ObservableObject {
    // single image version
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    return
                }
            }
        }
    }
    
    // multiple images version
    @Published private(set) var selectedImages: [UIImage] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            setImages(from: imageSelections)
        }
    }
    
    private func setImages(from selections: [PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            
            for selection in selections {
                if let data = try? await selection.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        images.append(uiImage)
                    }
                }
            }
            selectedImages = images
        }
    }
}

struct PhotoPickerBootcamp: View {
    @StateObject private var viewModel = PhotoPickerViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Hello, World!")
            
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                Text("Open the photo picker")
                    .foregroundStyle(.red)
            }
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                        }
                    }
                }
            }
            PhotosPicker(selection: $viewModel.imageSelections, matching: .images) {
                Text("Open the photo picker")
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    PhotoPickerBootcamp()
}
