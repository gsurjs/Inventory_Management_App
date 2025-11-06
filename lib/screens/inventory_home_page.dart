import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import 'add_edit_item_screen.dart';
import 'dashboard_screen.dart';

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}
class _InventoryHomePageState extends State<InventoryHomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _showLowStockOnly = false;
  Stream<List<Item>>? _itemsStream;

  @override
  void initState() {
    super.initState();
    _itemsStream = _firestoreService.getItemsStream();
  }

  void _filterItems() {
    setState(() {
      if (_searchController.text.isNotEmpty) {
        _itemsStream = _firestoreService.searchItems(_searchController.text);
      } else if (_selectedCategory != 'All') {
        _itemsStream = _firestoreService.getItemsByCategory(_selectedCategory);
      } else {
        _itemsStream = _firestoreService.getItemsStream();
      }
    });
  }
}