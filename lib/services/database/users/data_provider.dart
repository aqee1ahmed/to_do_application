import 'package:flutter/material.dart';
import 'package:to_do_application/static/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class taskProvider {
  static final _firestore = FirebaseFirestore.instance;
  static const taskCollection = AppConstants.taskCollection;

  static Future<List<Map<String, dynamic>>> getData() async {
    try {
      final tasks = await _firestore.collection(taskCollection).get();
      return tasks.docs.map((task) => task.data()).toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchTask() {
    try {
      return _firestore
          .collection(taskCollection)
          .snapshots()
          .asBroadcastStream();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<void> createTask(
      String title, String details, bool taskStatus) async {
    try {
      final payload = {
        'title': title,
        'details': details,
        'taskStatus': taskStatus,
      };

      await _firestore
          .collection(taskCollection)
          .doc(DateTime.now().microsecondsSinceEpoch.toString())
          .set(payload);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateTask(String documentId, bool taskStatus) async {
    try {
      final upload = {
        'taskStatus': taskStatus,
      };

      await _firestore
          .collection(taskCollection)
          .doc(documentId)
          .update(upload);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateTaskDetails(
    String documentId,
    String newTitle,
    String newSubtitle,
  ) async {
    try {
      final upload = {
        'title': newTitle,
        'details': newSubtitle,
      };

      await _firestore
          .collection(taskCollection)
          .doc(documentId)
          .update(upload);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteTask(String documentId) async {
    try {
      await _firestore.collection(taskCollection).doc(documentId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
