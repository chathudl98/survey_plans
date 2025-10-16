import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlanService {
  static CollectionReference<Map<String, dynamic>> _col() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users/$uid/plans');
  }

  static Future<void> addOrUpdatePlan(Map<String, dynamic> data) async {
    final id = data['planNo'] as String;
    await _col().doc(id).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> deletePlan(String id) => _col().doc(id).delete();

  static Stream<List<Map<String, dynamic>>> streamPlans() => _col()
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => {'planNo': d.id, ...d.data()}).toList());
}
