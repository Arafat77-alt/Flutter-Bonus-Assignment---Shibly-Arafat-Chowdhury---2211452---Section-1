import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/coffee_records_model.dart';

class CoffeeStateManagement extends ChangeNotifier {
  final CollectionReference _coffeeCollection =
      FirebaseFirestore.instance.collection('coffee_records');

  Stream<List<CoffeeRecordsModel>> get coffeeStream {
    return _coffeeCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CoffeeRecordsModel.fromJson(
          doc.data() as Map<String, dynamic>,
          docId: doc.id,
        );
      }).toList();
    });
  }

  Future<void> addCoffeeRecord(CoffeeRecordsModel record) async {
    try {
      await _coffeeCollection.add(record.toJson());
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error adding: $e");
    }
  }

  Future<void> updateCoffeeRecord(String id, CoffeeRecordsModel record) async {
    try {
      await _coffeeCollection.doc(id).update(record.toJson());
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error updating: $e");
    }
  }

  Future<void> deleteCoffeeRecord(String id) async {
    try {
      await _coffeeCollection.doc(id).delete();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error deleting: $e");
    }
  }
}