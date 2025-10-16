import 'package:cloud_firestore/cloud_firestore.dart';

class PlanService {
  final FirebaseFirestore _db;
  final String officeId;

  PlanService(this._db, {required this.officeId});

  // ✅ Typed collections so queries return Query<Map<String, dynamic>>
  CollectionReference<Map<String, dynamic>> get _plans =>
      _db.collection('offices')
         .doc(officeId)
         .collection('plans')
         .withConverter<Map<String, dynamic>>(
            fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
            toFirestore: (data, _) => data,
         );

  DocumentReference<Map<String, dynamic>> get _counter =>
      _db.collection('offices')
         .doc(officeId)
         .collection('counters')
         .doc('planNumber')
         .withConverter<Map<String, dynamic>>(
            fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
            toFirestore: (data, _) => data,
         );

  /// Create a plan with an auto-incremented unique planNumber (transaction-safe)
  Future<String> createPlan(Map<String, dynamic> planData) async {
    return _db.runTransaction((txn) async {
      final counterSnap = await txn.get(_counter);
      int next = 1;
      if (counterSnap.exists) {
        next = (counterSnap.data()?['next'] as int?) ?? 1;
      }

      // reserve the next number
      txn.set(_counter, {'next': next + 1}, SetOptions(merge: true));

      final docRef = _plans.doc(); // new plan id
      txn.set(docRef, {
        ...planData,
        'planNumber': next,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    });
  }

  Future<void> updatePlan(String planId, Map<String, dynamic> patch) async {
    await _plans.doc(planId).update({
      ...patch,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePlan(String planId) async {
    await _plans.doc(planId).delete();
  }

  /// Listing (paginate by updatedAt desc)
  Query<Map<String, dynamic>> listPlans({int limit = 100}) {
    return _plans.orderBy('updatedAt', descending: true).limit(limit);
  }

  /// Exact plan number match
  Query<Map<String, dynamic>> searchByPlanNumber(int number) {
    return _plans.where('planNumber', isEqualTo: number).limit(50);
  }

  /// Prefix searches (ensure fields are strings & indexed)
  Query<Map<String, dynamic>> searchByJobNumberPrefix(String prefix) {
    final end = '$prefix\uf8ff';
    return _plans.orderBy('jobNumber').startAt([prefix]).endAt([end]).limit(50);
  }

  Query<Map<String, dynamic>> searchByClientNamePrefix(String prefix) {
    final end = '$prefix\uf8ff';
    return _plans.orderBy('clientName').startAt([prefix]).endAt([end]).limit(50);
  }

  Query<Map<String, dynamic>> searchByClientPhonePrefix(String prefix) {
    final end = '$prefix\uf8ff';
    return _plans.orderBy('clientPhone').startAt([prefix]).endAt([end]).limit(50);
  }
}
