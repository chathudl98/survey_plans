import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserGuard {
  static final _db = FirebaseFirestore.instance;

  static Future<bool> isAllowed() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return false;
    final doc = await _db.doc('users/${u.uid}').get();
    if (!doc.exists) return false;
    final data = doc.data()!;
    return (data['active'] == true);
  }
}
