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

    //MARK: Login
    func loginUser(email: String, password: String, completion: @escaping (Error?, Bool) -> Void?) {
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error == nil && authDataResult!.user.isEmailVerified {
                print("Login successful")
                FUserListener.shared.getUserFromFirebase(userId: authDataResult!.user.uid)
                completion(error,true)
                return
            }
            print("Login Failed")
            completion(error, false)
        }
    }

    //MARK: - Resend mail & Pass
    func resendVerificationMail(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().currentUser?.reload { error in
            Auth.auth().currentUser?.sendEmailVerification { error in
                completion(error)
            }
        }
    }

    func resetPassword(email: String, completion: @escaping (Error?)->Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
           completion(error)
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

    func getUserFromFirebase(userId: String, email: String? = nil) {
        let users = firebaseReference(collectionReference: .user).document(userId).getDocument() { docSnapshot, error in
            guard let docSnapshot = docSnapshot else {
                print("no user found")
                return
            }

            let result = Result {
                try? docSnapshot.data()
            }

            switch result {
                case .success(let userObject):
                    print("user = \(userObject)")
                    if let user = userObject {
                        if let userData = try? JSONSerialization.data(withJSONObject: user) {
                            if let userDic = try? JSONDecoder().decode(User.self, from: userData) {
                                print("user = \(userDic)")
                                saveUserLocally(user: userDic)
                            }
                        }
                    }
                case .failure(let error):
                    print("user data fetch failed \(error.localizedDescription)")
            }
        }
    }

    func requestEmailVerification(withEmail email: String) {
        Auth.auth().currentUser
    }
}
