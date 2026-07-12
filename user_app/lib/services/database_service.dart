import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/services/firebase_service.dart';

class DatabaseService {
  DatabaseReference get _db => FirebaseService.ref;

  Future<Map<String, dynamic>?> getData(String path) async {
    try {
      final snapshot = await _db.child(path).get();
      if (snapshot.exists && snapshot.value != null) {
        return _mapFromSnapshot(snapshot);
      }
      return null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> setData(String path, Map<String, dynamic> data) async {
    try {
      await _db.child(path).set(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateData(String path, Map<String, dynamic> data) async {
    try {
      await _db.child(path).update(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteData(String path) async {
    try {
      await _db.child(path).remove();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Stream<DatabaseEvent> listenToPath(String path) {
    return _db.child(path).onValue;
  }

  Stream<DatabaseEvent> listenToChildAdded(String path) {
    return _db.child(path).orderByKey().limitToLast(1).onChildAdded;
  }

  Stream<DatabaseEvent> listenToChildChanged(String path) {
    return _db.child(path).onChildChanged;
  }

  Future<List<Map<String, dynamic>>> getList(String path, {int limit = 20}) async {
    try {
      final snapshot = await _db
          .child(path)
          .orderByKey()
          .limitToLast(limit)
          .get();

      if (!snapshot.exists || snapshot.value == null) return [];

      final data = _mapFromSnapshot(snapshot);
      if (data == null) return [];

      return data.entries
          .map((e) => {'_key': e.key, ...e.value as Map<String, dynamic>})
          .toList()
          .reversed
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getListAfter(
    String path, {
    required String startAfterKey,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _db
          .child(path)
          .orderByKey()
          .startAfter(startAfterKey)
          .limitToLast(limit)
          .get();

      if (!snapshot.exists || snapshot.value == null) return [];

      final data = _mapFromSnapshot(snapshot);
      if (data == null) return [];

      return data.entries
          .map((e) => {'_key': e.key, ...e.value as Map<String, dynamic>})
          .toList()
          .reversed
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getListOrdered(
    String path, {
    required String orderBy,
    int limit = 20,
    bool descending = true,
  }) async {
    try {
      var query = _db.child(path).orderByChild(orderBy);
      query = query.limitToLast(limit);

      final snapshot = await query.get();
      if (!snapshot.exists || snapshot.value == null) return [];

      final data = _mapFromSnapshot(snapshot);
      if (data == null) return [];

      var results = data.entries
          .map((e) => {'_key': e.key, ...e.value as Map<String, dynamic>})
          .toList();

      if (descending) results = results.reversed.toList();
      return results;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>?> getSingleChild(String path, String childKey) async {
    try {
      final snapshot = await _db.child('$path/$childKey').get();
      if (snapshot.exists && snapshot.value != null) {
        return _mapFromSnapshot(snapshot);
      }
      return null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> exists(String path) async {
    try {
      final snapshot = await _db.child(path).get();
      return snapshot.exists;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<int> getCount(String path) async {
    try {
      final snapshot = await _db.child(path).get();
      if (!snapshot.exists || snapshot.value == null) return 0;
      final data = _mapFromSnapshot(snapshot);
      return data?.length ?? 0;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> incrementValue(String path, String field, {int amount = 1}) async {
    try {
      final ref = _db.child(path).child(field);
      final snapshot = await ref.get();
      final current = (snapshot.value as int?) ?? 0;
      await ref.set(current + amount);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic>? _mapFromSnapshot(DataSnapshot snapshot) {
    if (snapshot.value == null) return null;
    if (snapshot.value is Map) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return {'value': snapshot.value};
  }

  Exception _handleError(dynamic e) {
    return Exception('خطأ في قاعدة البيانات: $e');
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});