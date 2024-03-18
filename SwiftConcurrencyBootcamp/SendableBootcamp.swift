//
//  SendableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Jason on 2024/3/18.
//

import SwiftUI

actor CurrentUserManager {
    func updateDatabase(userInfo: MyClassUserInfo) {
        
    }
}

struct MyUserInfo: Sendable {
    let name: String
}

// to make a unthread-safe class Sendable, you need to mark the class 'final'
// @unchecked, like force unwrapping, is not a safe action to do, telling compiler that developer will be responsible for checking
// to actually write safe code, use the custom DispatchQueue method to make the class thread-safe
final class MyClassUserInfo: @unchecked Sendable {
    private var name: String
    let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        queue.async {
            self.name = name
        }
    }
}

class SendableBootcampViewModel: ObservableObject {
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        let info = MyClassUserInfo(name: "info")
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableBootcamp: View {
    @StateObject private var viewModel = SendableBootcampViewModel()
    var body: some View {
        Text("Hello, World!")
            .task {
                
            }
    }
}

#Preview {
    SendableBootcamp()
}
