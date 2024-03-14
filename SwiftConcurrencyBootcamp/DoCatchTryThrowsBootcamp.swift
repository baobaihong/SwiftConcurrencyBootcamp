//
//  DoCatchTryThrowsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/14.
//

import SwiftUI

// do-catch
// try
// throws

class DoCatchTryThrowsBootcampDataManager {
    let isActive: Bool = true
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("new text", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    // the code above is not efficient because only one of the value in tuple is being used at one time
    // to improve the code above, return a generic type Result<SuceesResultType, FailureErrorType>
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("new text")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    
    // a even simpler way of writing this functionality is mark the functions as 'throws' and return a normal string
    func getTitle3() throws -> String {
//        if isActive {
//            return "new text"
//        } else {
            throw URLError(.badServerResponse)
//        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "final text"
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
}

class DoCatchTryThrowsBootcampViewModel: ObservableObject {
    @Published var text: String = "Starting text."
    let manager = DoCatchTryThrowsBootcampDataManager()
    
    func fetchTitle() {
        let returnedValue = manager.getTitle()
        
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedDescription
        }
    }
    
    func fetchTitle2() {
        let result = manager.getTitle2()
        switch result {
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let error):
            self.text = error.localizedDescription
        }
    }
    
    func fetchTitle3() {
        do {
            let newTitle = try manager.getTitle3()
            self.text = newTitle
        } catch {
            self.text = error.localizedDescription
        }
    }
    
    func fetchTitle4() {
        do {
            // NOTE⚠️: with one of the try fails, the rest of the do block will not be executed and the error will be thrown.
            //let newTitle = try manager.getTitle3()
            // ⬇️ you can make try OPTIONAL and unwrap it to solve the problem
            let newTitle = try? manager.getTitle3()
            if let newTitle = newTitle {
                self.text = newTitle
            }
            
            let finalTitle = try manager.getTitle4()
            self.text = finalTitle
        } catch {
            self.text = error.localizedDescription
        }
    }
}

struct DoCatchTryThrowsBootcamp: View {
    @StateObject private var viewModel = DoCatchTryThrowsBootcampViewModel()
    
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(.blue)
            .onTapGesture {
                viewModel.fetchTitle4()
            }
    }
}

#Preview {
    DoCatchTryThrowsBootcamp()
}
