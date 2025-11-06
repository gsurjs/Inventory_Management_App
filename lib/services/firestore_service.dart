import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  // Create collection reference for 'items'
  final CollectionReference<Map<String, dynamic>> _itemsCollection =
      FirebaseFirestore.instance.collection('items');

  // Add a new item to Firestore
  Future<void> addItem(Item item) async {
    try {
      await _itemsCollection.add(item.toMap());
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }
  // Get real-time stream of items from Firestore
  Stream<List<Item>> getItemsStream() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
  // Update an existing item by its document ID
  Future<void> updateItem(Item item) async {
    if (item.id == null) {
      throw Exception('Cannot update item without ID');
    }
    try {
      await _itemsCollection.doc(item.id).update(item.toMap());
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }
  // Delete an item by its document ID
  Future<void> deleteItem(String itemId) async {
    try {
      await _itemsCollection.doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }
  // Search items by name for enhanced feature
  Stream<List<Item>> searchItems(String query) {
    if (query.isEmpty) return getItemsStream();
    
    String searchKey = query.toLowerCase();
    return _itemsCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Item.fromMap(doc.id, doc.data()))
          .where((item) => item.name.toLowerCase().contains(searchKey))
          .toList();
    });
  }
  // Get items by category for enhanced feature
  Stream<List<Item>> getItemsByCategory(String category) {
    return _itemsCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
  // Get inventory statistics for enhanced feature
  Future<Map<String, dynamic>> getInventoryStats() async {
    try {
      final snapshot = await _itemsCollection.get();
      final items = snapshot.docs.map((doc) => 
        Item.fromMap(doc.id, doc.data())
      ).toList();

      int totalItems = items.length;
      double totalValue = 0;
      List<Item> outOfStock = [];
      List<Item> lowStock = [];

      for (var item in items) {
        totalValue += item.quantity * item.price;
        if (item.quantity == 0) {
          outOfStock.add(item);
        } else if (item.quantity < 5) {
          lowStock.add(item);
        }
      }

      return {
        'totalItems': totalItems,
        'totalValue': totalValue,
        'outOfStock': outOfStock,
        'lowStock': lowStock,
        'itemCount': items.fold<int>(0, (sum, item) => sum + item.quantity),
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}