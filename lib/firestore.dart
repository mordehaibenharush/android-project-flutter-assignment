import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<List<WordPair>> getSavedWordPairs() async {
    DocumentSnapshot documentSnapshot = await users.doc(userId).get();
      try{
        List savedSuggestions = documentSnapshot["saved_suggestions"];
        return savedSuggestions.map((e) => WordPair(e.split("_")[0], e.split("_")[1])).toList();
      } on StateError catch (_) {
        createUserDoc();
        return [];
      }
  }
}