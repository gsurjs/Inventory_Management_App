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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
            tooltip: 'View Dashboard',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterItems();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => _filterItems(),
                ),
                const SizedBox(height: 10),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Low Stock'),
                        selected: _showLowStockOnly,
                        onSelected: (selected) {
                          setState(() {
                            _showLowStockOnly = selected;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip('All'),
                      _buildCategoryChip('Electronics'),
                      _buildCategoryChip('Clothing'),
                      _buildCategoryChip('Food'),
                      _buildCategoryChip('Tools'),
                      _buildCategoryChip('Other'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Items List
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: _itemsStream,
              builder: (context, snapshot) {
                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Handle error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                // Handle empty state
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items in inventory',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the + button to add items',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Filter for low stock if needed
                List<Item> items = snapshot.data!;
                if (_showLowStockOnly) {
                  items = items.where((item) => item.quantity < 5).toList();
                }

                // Build ListView with item data
                return ListView.builder(
                  itemCount: items.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Dismissible(
                      key: Key(item.id ?? ''),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Item'),
                            content: Text('Are you sure you want to delete "${item.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        _firestoreService.deleteItem(item.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                // Re-add the item
                                _firestoreService.addItem(item);
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStockColor(item.quantity),
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category: ${item.category}'),
                              Text(
                                'Price: \$${item.price.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.green[700]),
                              ),
                              if (item.quantity < 5)
                                Text(
                                  item.quantity == 0 ? 'OUT OF STOCK' : 'LOW STOCK',
                                  style: TextStyle(
                                    color: item.quantity == 0 ? Colors.red : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '\$${(item.quantity * item.price).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'Total Value',
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditItemScreen(item: item),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditItemScreen()),
          );
        },
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category),
        selected: _selectedCategory == category,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : 'All';
            _filterItems();
          });
        },
      ),
    );
  }

  Color _getStockColor(int quantity) {
    if (quantity == 0) return Colors.red;
    if (quantity < 5) return Colors.orange;
    return Colors.green;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}