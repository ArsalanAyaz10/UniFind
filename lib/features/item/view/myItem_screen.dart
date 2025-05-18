import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unifind/core/widgets/custom_drawer.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/item/bloc/item_cubit.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/item/data/models/item_model.dart';
import 'package:unifind/features/item/view/itemDetail_screen.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  List<Item> _userItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _fetchUserItems();
  }

  Future<void> _fetchUserItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user ID
      final userId = context.read<AuthCubit>().getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Fetch all items
      await context.read<ItemCubit>().fetchItems();

      // Wait for the state to update
      await Future.delayed(Duration.zero);

      // Get the current state
      final state = context.read<ItemCubit>().state;

      if (state is ItemsLoaded) {
        // Filter items by user ID
        setState(() {
          _userItems =
              state.items.where((item) => item.userId == userId).toList();
          _isLoading = false;
        });
      } else if (state is ItemError) {
        setState(() {
          _errorMessage = state.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateItemStatus(String itemId, String newStatus) async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      // Use ItemCubit instead of directly calling repository
      await context.read<ItemCubit>().updateItemStatus(itemId, newStatus);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Item status updated to $newStatus',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh the items
      await _fetchUserItems();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update status: ${e.toString()}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'My Items',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(12, 77, 161, 1).withOpacity(0.8),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchUserItems,
          ),
        ],
      ),
      drawer: ModernDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(12, 77, 161, 1),
              Color.fromRGBO(28, 93, 177, 1),
              Color.fromRGBO(41, 121, 209, 1),
              Color.fromRGBO(64, 144, 227, 1),
            ],
          ),
        ),
        child: _buildContent(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/report-item').then((_) {
            // Refresh items when returning from report screen
            _fetchUserItems();
          });
        },
        backgroundColor: Colors.white,
        foregroundColor: Color.fromRGBO(12, 77, 161, 1),
        icon: Icon(Icons.add),
        label: Text("Report New Item"),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Loading your items...",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            SizedBox(height: 16),
            Text(
              "Error loading your items",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchUserItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color.fromRGBO(12, 77, 161, 1),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_userItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            SizedBox(height: 16),
            Text(
              "You haven't posted any items yet",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Items you report will appear here",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/report-item').then((_) {
                  _fetchUserItems();
                });
              },
              icon: Icon(Icons.add),
              label: Text("Report Item"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color.fromRGBO(12, 77, 161, 1),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchUserItems,
        color: Color.fromRGBO(12, 77, 161, 1),
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              "My Reported Items",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 600.ms),

            SizedBox(height: 8),

            Text(
              "Manage and update the status of your reported items",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

            SizedBox(height: 24),

            ..._userItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return MyItemCard(
                    item: item,
                    isUpdatingStatus: _isUpdatingStatus,
                    onStatusUpdate: (newStatus) {
                      _updateItemStatus(item.itemId, newStatus);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ItemdetailScreen(
                                item: item,
                                itemId: item.itemId,
                              ),
                        ),
                      ).then((_) {
                        if (mounted) {
                          _fetchUserItems();
                        }
                      });
                    },
                  )
                  .animate(delay: Duration(milliseconds: 300 + (index * 100)))
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, duration: 600.ms);
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class MyItemCard extends StatelessWidget {
  final Item item;
  final Function(String) onStatusUpdate;
  final VoidCallback onTap;
  final bool isUpdatingStatus;

  const MyItemCard({
    Key? key,
    required this.item,
    required this.onStatusUpdate,
    required this.onTap,
    this.isUpdatingStatus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item image and category badge
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey.shade300,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          item.category.toLowerCase() == 'lost'
                              ? Colors.red.withOpacity(0.8)
                              : Colors.green.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.status),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Item details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${item.campus} - ${item.specificLocation}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _formatDate(item.date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onTap,
                        icon: Icon(Icons.visibility),
                        label: Text("View Details"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color.fromRGBO(12, 77, 161, 1),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          isUpdatingStatus
                              ? Container(
                                width: 48,
                                height: 48,
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromRGBO(12, 77, 161, 1),
                                  ),
                                ),
                              )
                              : PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Color.fromRGBO(12, 77, 161, 1),
                                ),
                                tooltip: 'Change status',
                                onSelected: onStatusUpdate,
                                itemBuilder:
                                    (context) => [
                                      PopupMenuItem(
                                        value: 'active',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Active'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'dormant',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.pause_circle_filled,
                                              color: Colors.orange,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Dormant'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'returned',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.assignment_turned_in,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Returned to Owner'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'claimed',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.person_search,
                                              color: Colors.purple,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Claimed'),
                                          ],
                                        ),
                                      ),
                                    ],
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.withOpacity(0.8);
      case 'dormant':
        return Colors.orange.withOpacity(0.8);
      case 'returned':
        return Colors.blue.withOpacity(0.8);
      case 'claimed':
        return Colors.purple.withOpacity(0.8);
      default:
        return Colors.grey.withOpacity(0.8);
    }
  }
}
