import 'package:firebase_database/firebase_database.dart';
import 'package:adentweets_admin/services/firebase_service.dart';

class DatabaseService {
  DatabaseService._();

  static final _db = FirebaseService.db;

  static Future<DataSnapshot> get(String path) {
    return _db.child(path).get();
  }

  static Future<void> set(String path, dynamic value) {
    return _db.child(path).set(value);
  }

  static Future<void> update(String path, Map<String, dynamic> value) {
    return _db.child(path).update(value);
  }

  static Future<void> remove(String path) {
    return _db.child(path).remove();
  }

  static Future<String> push(String path, Map<String, dynamic> value) async {
    final ref = _db.child(path).push();
    await ref.set(value);
    return ref.key!;
  }

  static Query query(String path, {int? limitToFirst, String? orderBy, String? startAt, String? endAt}) {
    var query = _db.child(path);
    if (orderBy != null) {
      query = query.orderByChild(orderBy);
    }
    if (startAt != null) {
      query = query.startAt(startAt);
    }
    if (endAt != null) {
      query = query.endAt(endAt);
    }
    if (limitToFirst != null) {
      query = query.limitToFirst(limitToFirst);
    }
    return query;
  }

  static Stream<DatabaseEvent> onValue(String path) {
    return _db.child(path).onValue;
  }

  static Stream<DatabaseEvent> onChildAdded(String path, {int? limitToFirst}) {
    var query = _db.child(path).orderByChild('createdAt');
    if (limitToFirst != null) {
      query = query.limitToLast(limitToFirst);
    }
    return query.onChildAdded;
  }

  static Future<int> getCount(String path) async {
    final snapshot = await _db.child(path).get();
    if (snapshot.exists && snapshot.value != null) {
      return (snapshot.value as Map).length;
    }
    return 0;
  }

  static Future<List<Map<String, dynamic>>> getList(String path, {int limit = 20, String? orderBy, bool descending = true}) async {
    var query = _db.child(path);
    if (orderBy != null) {
      query = query.orderByChild(orderBy);
    }
    query = query.limitToLast(limit);

    final snapshot = await query.get();
    final List<Map<String, dynamic>> items = [];

    if (snapshot.exists && snapshot.value != null) {
      final map = snapshot.value as Map;
      for (final entry in map.entries) {
        final item = Map<String, dynamic>.from(entry.value as Map);
        item['id'] = entry.key;
        items.add(item);
      }
      if (descending) {
        items.sort((a, b) {
          final aTime = (a['createdAt'] as int?) ?? 0;
          final bTime = (b['createdAt'] as int?) ?? 0;
          return bTime.compareTo(aTime);
        });
      }
    }
    return items;
  }
}