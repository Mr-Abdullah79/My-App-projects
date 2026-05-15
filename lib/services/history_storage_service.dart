import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryStorageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to get the current user's history collection reference
  static CollectionReference<Map<String, dynamic>>? _getUserHistoryCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('history');
  }

  // Get history for the current user, ordered by timestamp descending
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final collection = _getUserHistoryCollection();
    if (collection == null) return [];

    try {
      final querySnapshot = await collection.orderBy('timestamp', descending: true).get();
      
      final parsed = <Map<String, dynamic>>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id; // Store document ID for deletion later
        parsed.add(data);
      }
      return parsed;
    } catch (e) {
      debugPrint('Error fetching history: $e');
      return [];
    }
  }

  // Save a new entry to the user's history
  static Future<void> saveEntry(Map<String, dynamic> entry) async {
    final collection = _getUserHistoryCollection();
    if (collection == null) return;

    try {
      // Add a server timestamp so we can order them
      entry['timestamp'] = FieldValue.serverTimestamp();
      await collection.add(entry);
    } catch (e) {
      debugPrint('Error saving entry: $e');
    }
  }

  // Delete a specific entry by its document ID
  static Future<void> deleteById(String documentId) async {
    final collection = _getUserHistoryCollection();
    if (collection == null) return;

    try {
      await collection.doc(documentId).delete();
    } catch (e) {
      debugPrint('Error deleting entry: $e');
    }
  }

  // Clear all history for the current user
  static Future<void> clearAll() async {
    final collection = _getUserHistoryCollection();
    if (collection == null) return;

    try {
      final querySnapshot = await collection.get();
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
}
