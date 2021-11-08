import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:english_words/english_words.dart';

class FirestoreRepository {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String? userId;

  FirestoreRepository({this.userId});

  void createUserDoc() {
    users.doc(userId).set({"saved_suggestions": FieldValue.arrayUnion([])});
  }

  void putSavedWordPair(WordPair pair) {
    users.doc(userId).update({"saved_suggestions": FieldValue.arrayUnion(["${pair.first}_${pair.second}"])});
  }

  Future removeSavedWordPair(WordPair pair) {
    return users.doc(userId).update({"saved_suggestions": FieldValue.arrayRemove(["${pair.first}_${pair.second}"])});
  }

  Future putSavedWordPairs(Set<WordPair> set) {
    return users.doc(userId).update({"saved_suggestions": FieldValue.arrayUnion(set.map((pair) => "${pair.first}_${pair.second}").toList())});
  }

  List? getSavedWordPairs() {
    users.doc(userId).get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
        data['saved_suggestions'].map((pair) {
          return WordPair(pair.split('_')[0], pair.split('_')[1]);
        }).toList();
      }
    });
    return null;
  }


}