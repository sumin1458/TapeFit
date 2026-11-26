import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/guide_repository.dart';

/// users/{uid}/favorites/{symptomId} (익명 로그인 UID 기준)
class FirestoreFavoriteRepository implements FavoriteRepository {
  FirestoreFavoriteRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Future<CollectionReference<Map<String, dynamic>>> _col() async {
    var user = _auth.currentUser;
    user ??= (await _auth.signInAnonymously()).user;
    return _db.collection('users').doc(user!.uid).collection('favorites');
  }

  @override
  Future<Set<String>> loadFavorites() async {
    final snap = await (await _col()).get();
    return snap.docs.map((d) => d.id).toSet();
  }

  @override
  Future<void> setFavorite(String symptomId, bool value) async {
    final doc = (await _col()).doc(symptomId);
    if (value) {
      await doc.set({'createdAt': FieldValue.serverTimestamp()});
    } else {
      await doc.delete();
    }
  }
}

/// Firebase를 쓸 수 없을 때 메모리에만 보관한다 (테스트·기본값용).
class LocalFavoriteRepository implements FavoriteRepository {
  final Set<String> _ids = {};

  @override
  Future<Set<String>> loadFavorites() async => {..._ids};

  @override
  Future<void> setFavorite(String symptomId, bool value) async {
    value ? _ids.add(symptomId) : _ids.remove(symptomId);
  }
}

/// Firebase를 쓸 수 없을 때 기기(SharedPreferences)에 저장해 앱을 다시 켜도 유지한다.
class PersistentFavoriteRepository implements FavoriteRepository {
  static const storageKey = 'favorite_symptom_ids';

  @override
  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(storageKey) ?? const <String>[]).toSet();
  }

  @override
  Future<void> setFavorite(String symptomId, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(storageKey) ?? const <String>[]).toSet();
    value ? ids.add(symptomId) : ids.remove(symptomId);
    await prefs.setStringList(storageKey, ids.toList());
  }
}
