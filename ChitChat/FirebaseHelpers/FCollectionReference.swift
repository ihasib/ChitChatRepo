//
//  FCollectionReference.swift
//  ChitChat
//
//  Created by S M Hasibur Rahman on 22/9/23.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case user, recent
}

func firebaseReference(collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
