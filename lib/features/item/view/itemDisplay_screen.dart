import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/item/bloc/item_cubit.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/item/data/models/item_model.dart';
import 'package:unifind/features/item/view/itemDetail_screen.dart';
import 'package:unifind/features/item/view/widgets/categoryScroll.dart';
import 'package:unifind/features/profile/bloc/profile_cubit.dart';
import 'package:unifind/features/profile/bloc/profile_state.dart'; // Assuming LostFoundItemCard is here

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                String name = 'Loading...';
                String email = '';
                String? profilePicUrl;

                if (state is ProfileLoaded) {
                  name = state.user.name;
                  email = state.user.email ?? '';
                  profilePicUrl = state.user.photoUrl;
                } else if (state is ProfileError) {
                  name = 'Error';
                  email = '';
                }
                return UserAccountsDrawerHeader(
                  accountName: Text(name),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        profilePicUrl != null
                            ? NetworkImage(profilePicUrl)
                            : const AssetImage('assets/images/profile.jpg')
                                as ImageProvider,
                  ),
                  decoration: BoxDecoration(
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
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                context.read<AuthCubit>().logout();
                Navigator.of(context).pop();
              },
            ),
          ],
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
                                  print(
                                    "the item id: ${item.itemId.toString()}",
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ItemdetailScreen(
                                            item: item,
                                            itemId: item.itemId,
                                          ),
                                    ),
                                  );
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
                                  Navigator.pushNamed(
                                    context,
                                    '/displaydetail',
                                    arguments: item.itemId,
                                  );
                                  print(
                                    "the item id: ${item.itemId.toString()}",
                                  );
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
