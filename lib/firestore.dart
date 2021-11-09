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

  void updateSavedSuggestions(String? userID, List<WordPair> saved){
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    if(userID != null){
      users.doc(userID).update({"saved_suggestions": FieldValue.arrayUnion(saved.map((e) => "${e.first}_${e.second}").toList())});
    }
  }


  void removeSavedSuggestions(String? userID, WordPair pair){
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    if(userID != null){
      users.doc(userID).update({"saved_suggestions": FieldValue.arrayRemove(["${pair.first}_${pair.second}"])});
    }
  }


  void syncSavedSuggestions(String? userID, List<WordPair> suggestions, Set<WordPair> saved) async{
    DocumentSnapshot snapshot = await users.doc(userID).get();
    List savedSuggestions;
    if(snapshot.data != null){
      try{
        savedSuggestions = snapshot["saved_suggestions"];
        List<WordPair> savedList = savedSuggestions.map((e) => WordPair(e.split("_")[0], e.split("_")[1])).toList();
        saved.addAll(savedList);
        savedList.forEach((element) {
          if(!suggestions.contains(element)){
            suggestions.insert(0, element);
          }
        });
      }
      on StateError catch (_) {
        users.doc(userID).set({"saved_suggestions": FieldValue.arrayUnion([])});
      }
    }
    updateSavedSuggestions(userID, saved.toList());
  }

  Future<List<WordPair>> getSavedSuggestions(String? userID) async {
    DocumentSnapshot snapshot = await users.doc(userID).get();
      try{
        List savedSuggestions = snapshot["saved_suggestions"];
        return savedSuggestions.map((e) => WordPair(e.split("_")[0], e.split("_")[1])).toList();
      } on StateError catch (_) {
        users.doc(userID).set({"saved_suggestions": FieldValue.arrayUnion([])});
        return [];
      }
  }


  Future<List<WordPair>> pullSavedSuggestions(String? userID) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    DocumentSnapshot doc = await users.doc(userID).get();
    List savedSuggestions = doc.get("saved_suggestions");
    List<WordPair> savedList = savedSuggestions.map((e) => WordPair(e.split("_")[0], e.split("_")[1])).toList();
    return savedList;
  }
}