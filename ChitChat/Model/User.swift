//
//  User.swift
//  ChitChat
//
//  Created by S M Hasibur Rahman on 22/9/23.
//

import Foundation
import FirebaseAuth

let kCurrentUser = "kCurrentUser"

struct User: Codable {
    var id = ""
    var username: String
    var email: String
    var pushId = ""
    var avatarLink = ""
    var status: String

    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }

    static var currentUser: User? {
        if let curUser = Auth.auth().currentUser {
            if let jsonDic = UserDefaults.standard.data(forKey: kCurrentUser) {
                let decoder = JSONDecoder()
                do {
                    let user = try decoder.decode(User.self, from: jsonDic)
                    return user
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        return nil
    }

    static func == (lhs: User, rhs: User) {
        lhs.id == rhs.id
    }
}


func saveUserLocally(user: User) {
    let encoder = JSONEncoder()
    do {
        let jsonUser = try encoder.encode(user)
        UserDefaults.standard.set(jsonUser, forKey: kCurrentUser)
    } catch {
        print(error.localizedDescription)
    }
}
