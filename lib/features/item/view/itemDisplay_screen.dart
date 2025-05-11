import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/features/item/bloc/item_cubit.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/item/data/models/item_model.dart';
import 'package:unifind/features/item/view/widgets/categoryScroll.dart'; // Assuming LostFoundItemCard is here

class ItemdisplayScreen extends StatefulWidget {
  const ItemdisplayScreen({super.key});

  @override
  State<ItemdisplayScreen> createState() => _ItemdisplayScreenState();
}

class _ItemdisplayScreenState extends State<ItemdisplayScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ItemCubit>().fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Item'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE96443),
                Color(0xFFED6B47),
                Color(0xFFF0724B),
                Color(0xFFF37A4F),
                Color(0xFFF68152),
                Color(0xFFF99856),
                Color(0xFFF9B456),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: BlocListener<ItemCubit, ItemState>(
        listener: (context, state) {
          if (state is ItemError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: const ItemBuilderUI(),
      ),
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
  Widget build(BuildContext context) {
    return BlocBuilder<ItemCubit, ItemState>(
      builder: (context, state) {
        if (state is ItemLoading) {
          return const Center(child: CircularProgressIndicator());
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
            return const Center(child: Text("No items found."));
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (lostItems.isNotEmpty) ...[
                      const Text(
                        'Lost',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: lostItems.length,
                          itemBuilder: (context, index) {
                            final item = lostItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: LostFoundItemCard(
                                imageUrl: item.imageUrl,
                                specificLocation: item.specificLocation,
                                name: item.name,
                                campus: item.campus,
                                category: item.category,
                                onTap: () {
                                  // Handle item tap
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (foundItems.isNotEmpty) ...[
                      const Text(
                        'Found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: foundItems.length,
                          itemBuilder: (context, index) {
                            final item = foundItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: LostFoundItemCard(
                                imageUrl: item.imageUrl,
                                specificLocation: item.specificLocation,
                                name: item.name,
                                campus: item.campus,
                                category: item.category,
                                onTap: () {
                                  // Handle item tap
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(child: Text("Something went wrong."));
        }
      },
    );
  }
}
