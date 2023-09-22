//
//  FUserListener.swift
//  ChitChat
//
//  Created by S M Hasibur Rahman on 22/9/23.
//

import Foundation
import FirebaseAuth

class FUserListener {
    static let shared = FUserListener()
    private init() {}

    //MARK: Login


    //MARK: Register
    func registerUser(email: String, password: String, completion: @escaping ( (Error?) -> Void) ) {
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            completion(error)

            if error == nil {
                //send verification mail
                authDataResult!.user.sendEmailVerification() { error in
                    print("auth email sent with error \(error?.localizedDescription)")
                }

                //create user with all info now and save to local storage and firebase
                let user = User(id: authDataResult!.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "Busy")
                saveUserLocally(user: user)
                self.saveUserToFirestore(user: user)
            }
        }
    }

    func saveUserToFirestore(user: User) {
        if let jsonData = try? JSONEncoder().encode(user) {
            do {
                let dict = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
                firebaseReference(collectionReference: .user).document(user.id).setData(dict)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
