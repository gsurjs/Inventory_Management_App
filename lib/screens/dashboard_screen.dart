import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _firestoreService.getInventoryStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading statistics: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadStatistics();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(
                  child: Text('Failed to load statistics'),
                )
              : RefreshIndicator(
                  onRefresh: _loadStatistics,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: [
                            _buildStatCard(
                              title: 'Total Items',
                              value: _stats!['totalItems'].toString(),
                              icon: Icons.inventory,
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              title: 'Total Value',
                              value: '\$${_stats!['totalValue'].toStringAsFixed(2)}',
                              icon: Icons.attach_money,
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              title: 'Item Count',
                              value: _stats!['itemCount'].toString(),
                              icon: Icons.numbers,
                              color: Colors.purple,
                            ),
                            _buildStatCard(
                              title: 'Out of Stock',
                              value: (_stats!['outOfStock'] as List).length.toString(),
                              icon: Icons.warning,
                              color: Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Low Stock Alert Section
                        if ((_stats!['lowStock'] as List).isNotEmpty) ...[
                          Card(
                            color: Colors.orange.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber,
                                        color: Colors.orange.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Low Stock Alert',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...(_stats!['lowStock'] as List<Item>).map((item) {
                                    return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.orange,
                                        child: Text(
                                          item.quantity.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      title: Text(item.name),
                                      subtitle: Text(item.category),
                                      trailing: Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Out of Stock Section
                        if ((_stats!['outOfStock'] as List).isNotEmpty) ...[
                          Card(
                            color: Colors.red.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.error,
                                        color: Colors.red.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Out of Stock Items',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...(_stats!['outOfStock'] as List<Item>).map((item) {
                                    return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: const CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          '0',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        item.name,
                                        style: const TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                      subtitle: Text(item.category),
                                      trailing: Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Inventory Health Score
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Inventory Health Score',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(
                                  value: _calculateHealthScore(),
                                  minHeight: 20,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getHealthColor(_calculateHealthScore()),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    '${(_calculateHealthScore() * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: _getHealthColor(_calculateHealthScore()),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    _getHealthMessage(_calculateHealthScore()),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateHealthScore() {
    if (_stats == null) return 0;
    
    int totalItems = _stats!['totalItems'];
    if (totalItems == 0) return 1.0;
    
    int outOfStock = (_stats!['outOfStock'] as List).length;
    int lowStock = (_stats!['lowStock'] as List).length;
    
    double score = 1.0;
    score -= (outOfStock * 0.2); // Each out of stock item reduces 20%
    score -= (lowStock * 0.1);   // Each low stock item reduces 10%
    
    return score.clamp(0.0, 1.0);
  }

  Color _getHealthColor(double score) {
    if (score > 0.8) return Colors.green;
    if (score > 0.5) return Colors.orange;
    return Colors.red;
  }

  String _getHealthMessage(double score) {
    if (score > 0.8) return 'Excellent inventory management!';
    if (score > 0.5) return 'Some items need attention';
    return 'Critical: Immediate restocking needed';
  }
}