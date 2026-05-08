import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  CollectionReference get _taskCollection {
    if (uid == null) throw Exception("User not logged in");
    return _db.collection('users').doc(uid).collection('tasks');
  }

  Stream<List<TaskModel>> getTasks() {
    if (uid == null) return const Stream.empty();
    return _taskCollection.orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addTask(TaskModel task) async {
    await _taskCollection.add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskCollection.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _taskCollection.doc(id).delete();
  }

  Future<void> markCompleted(String id, bool status) async {
    await _taskCollection.doc(id).update({'status': status ? 'completed' : 'pending'});
  }
}
