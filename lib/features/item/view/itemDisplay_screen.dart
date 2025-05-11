import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:unifind/core/widgets/auth_button.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/item/bloc/item_cubit.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/item/view/widgets/categoryScroll.dart';
import 'package:unifind/features/profile/bloc/profile_cubit.dart';
import 'package:unifind/features/profile/bloc/profile_state.dart';
import 'package:unifind/features/item/data/models/item_model.dart';

class ItemdisplayScreen extends StatefulWidget {
  const ItemdisplayScreen({super.key});

  @override
  State<ItemdisplayScreen> createState() => _ItemdisplayScreenState();
}

class _ItemdisplayScreenState extends State<ItemdisplayScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ItemCubit>().fetchItems(); // Trigger fetch
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
                    backgroundImage: profilePicUrl != null
                        ? NetworkImage(profilePicUrl)
                        : const AssetImage('assets/images/profile.jpg')
                            as ImageProvider,
                  ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<ItemCubit, ItemState>(
          builder: (context, state) {
            if (state is ItemLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ItemsLoaded) {
              final List<Item> items = state.items;
              if (items.isEmpty) {
                return const Center(child: Text("No items found."));
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return LostFoundItemCard(
                    imageUrl: item.imageUrl,
                    name: item.name,
                    description: item.description,
                    campus: item.campus,
                    specificLocation: item.specificLocation,
                    category: item.category,
                    date:
                        '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}',
                    time:
                        '${item.time.hourOfPeriod}:${item.time.minute.toString().padLeft(2, '0')} ${item.time.period.name.toUpperCase()}',
                    onTap: () {
                      // Navigate to detail page or show dialog
                    },
                  );
                },
              );
            } else {
              return const Center(child: Text("Something went wrong."));
            }
          },
        ),
      ),
    );
  }
}
