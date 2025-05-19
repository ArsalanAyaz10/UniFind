import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unifind/core/widgets/custom_drawer.dart';
import 'package:unifind/core/widgets/modern_itemcard.dart';
import 'package:unifind/features/item/bloc/item_cubit.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/item/data/models/item_model.dart';
import 'package:unifind/features/item/view/itemDetail_screen.dart';

class ItemdisplayScreen extends StatefulWidget {
  const ItemdisplayScreen({super.key});

  @override
  State<ItemdisplayScreen> createState() => _ItemdisplayScreenState();
}

class _ItemdisplayScreenState extends State<ItemdisplayScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep the state alive when navigating

  @override
  void initState() {
    super.initState();
    // Fetch items when the screen is first created
    _fetchItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures items are refreshed when returning to this screen
    _fetchItems();
  }

  void _fetchItems() {
    // Always fetch items when this method is called
    context.read<ItemCubit>().fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Lost & Found Items',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(12, 77, 161, 1).withOpacity(0.8),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: ModernDrawer(),
      body: BlocListener<ItemCubit, ItemState>(
        listener: (context, state) {
          if (state is ItemError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: const ItemBuilderUI(),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(12, 77, 161, 1),
              Color.fromRGBO(41, 121, 209, 1),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/report');
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            "Report Item",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ItemBuilderUI extends StatefulWidget {
  const ItemBuilderUI({super.key});

  @override
  State<ItemBuilderUI> createState() => _ItemBuilderUIState();
}

class _ItemBuilderUIState extends State<ItemBuilderUI> {
  @override
  void initState() {
    super.initState();
    // Force fetch items when widget initializes
    context.read<ItemCubit>().fetchItems();
  }

  @override
  void didUpdateWidget(ItemBuilderUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force fetch items when widget updates
    context.read<ItemCubit>().fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: BlocConsumer<ItemCubit, ItemState>(
        listener: (context, state) {
          // If we get an error state, immediately try to fetch items again
          if (state is ItemError) {
            // Add a small delay before retrying
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted) {
                context.read<ItemCubit>().fetchItems();
              }
            });
          }
        },
        builder: (context, state) {
          if (state is ItemLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading items...",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ItemsLoaded) {
            final List<Item> items = state.items;

            final lostItems =
                items
                    .where((item) => item.category.toLowerCase() == 'lost')
                    .toList();
            final foundItems =
                items
                    .where((item) => item.category.toLowerCase() == 'found')
                    .toList();

            if (lostItems.isEmpty && foundItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No items found",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Be the first to report a lost or found item",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/report-item');
                      },
                      icon: Icon(Icons.add),
                      label: Text("Report Item"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color.fromRGBO(12, 77, 161, 1),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
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
                onRefresh: () async {
                  // Refresh items
                  context.read<ItemCubit>().fetchItems();
                },
                color: Color.fromRGBO(12, 77, 161, 1),
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header section
                        Text(
                          "Lost & Found Items",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 600.ms),

                        SizedBox(height: 8),

                        Text(
                          "Browse through items that have been reported",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

                        SizedBox(height: 24),

                        // Lost items section
                        if (lostItems.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(Icons.search, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Lost Items',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                          SizedBox(height: 12),

                          Container(
                            height: 320,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: BouncingScrollPhysics(),
                              itemCount: lostItems.length,
                              itemBuilder: (context, index) {
                                final item = lostItems[index];
                                return ModernItemCard(
                                      imageUrl: item.imageUrl,
                                      specificLocation: item.specificLocation,
                                      name: item.name,
                                      campus: item.campus,
                                      category: item.category,
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
                                          // Force reload items when returning from details
                                          if (mounted) {
                                            context
                                                .read<ItemCubit>()
                                                .fetchItems();
                                          }
                                        });
                                      },
                                    )
                                    .animate(
                                      delay: Duration(
                                        milliseconds: 400 + (index * 100),
                                      ),
                                    )
                                    .fadeIn(duration: 600.ms)
                                    .slideX(
                                      begin: 0.2,
                                      end: 0,
                                      duration: 600.ms,
                                    );
                              },
                            ),
                          ),
                        ],

                        SizedBox(height: 24),

                        // Found items section
                        if (foundItems.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Found Items',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

                          SizedBox(height: 12),

                          Container(
                            height: 320,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: BouncingScrollPhysics(),
                              itemCount: foundItems.length,
                              itemBuilder: (context, index) {
                                final item = foundItems[index];
                                return ModernItemCard(
                                      imageUrl: item.imageUrl,
                                      specificLocation: item.specificLocation,
                                      name: item.name,
                                      campus: item.campus,
                                      category: item.category,
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
                                          // Force reload items when returning from details
                                          if (mounted) {
                                            context
                                                .read<ItemCubit>()
                                                .fetchItems();
                                          }
                                        });
                                      },
                                    )
                                    .animate(
                                      delay: Duration(
                                        milliseconds: 600 + (index * 100),
                                      ),
                                    )
                                    .fadeIn(duration: 600.ms)
                                    .slideX(
                                      begin: 0.2,
                                      end: 0,
                                      duration: 600.ms,
                                    );
                              },
                            ),
                          ),
                        ],

                        SizedBox(height: 80), // Extra space for FAB
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            // Error state or initial state - immediately trigger a fetch
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<ItemCubit>().fetchItems();
              }
            });

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading items...",
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
        },
      ),
    );
  }
}
