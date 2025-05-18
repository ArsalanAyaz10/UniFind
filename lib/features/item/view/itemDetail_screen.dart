import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unifind/core/models/user_model.dart';
import 'package:unifind/features/item/data/models/item_model.dart';
import 'package:unifind/features/item/bloc/item_cubit.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/item/view/widgets/chat_button.dart';
import 'package:unifind/features/item/view/widgets/modern_itemUI.dart';
import 'package:unifind/features/profile/bloc/other_profile_cubit.dart'; // <-- Use this!
import 'package:unifind/features/profile/bloc/profile_state.dart';

class ItemdetailScreen extends StatefulWidget {
  final String itemId;
  final Item item;

  const ItemdetailScreen({super.key, required this.itemId, required this.item});

  @override
  State<ItemdetailScreen> createState() => _ItemdetailScreenState();
}

class _ItemdetailScreenState extends State<ItemdetailScreen> {
  @override
  void initState() {
    super.initState();
    _fetchItemDetails();
    _fetchUserData();
  }

  void _fetchItemDetails() {
    final state = context.read<ItemCubit>().state;
    if (state is! ItemLoaded || (state.item.itemId != widget.itemId)) {
      context.read<ItemCubit>().fetchItemById(widget.itemId);
    }
  }

  void _fetchUserData() {
    // <-- Use OtherProfileCubit here!
    context.read<OtherProfileCubit>().fetchUserById(widget.item.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Item Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(12, 77, 161, 1).withOpacity(0.8),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Share functionality will be implemented here'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ItemCubit, ItemState>(
        builder: (context, state) {
          if (state is ItemLoading) {
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Loading item details...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ItemLoaded) {
            final item = state.item;

            return Stack(
              children: [
                BlocConsumer<OtherProfileCubit, ProfileState>(
                  listener: (context, profileState) {
                    if (profileState is ProfileError) {
                      Future.delayed(Duration(seconds: 1), () {
                        if (mounted) {
                          context.read<OtherProfileCubit>().fetchUserById(
                            item.userId,
                          );
                        }
                      });
                    }
                  },
                  builder: (context, profileState) {
                    AppUser? user;
                    bool isLoading = profileState is ProfileLoading;

                    if (profileState is ProfileLoaded) {
                      user = profileState.user;
                    }

                    return ModernItemUI(
                      item: item,
                      user: user,
                      isUserLoading: isLoading,
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ChatButton(userId: item.userId),
                ),
              ],
            );
          } else if (state is ItemError) {
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
              child: Center(
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
                      "Error loading item details",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _fetchItemDetails();
                        _fetchUserData();
                      },
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
                      child: Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<OtherProfileCubit>().fetchUserById(
                  widget.item.userId,
                );
              }
            });

            return Stack(
              children: [
                BlocBuilder<OtherProfileCubit, ProfileState>(
                  builder: (context, profileState) {
                    AppUser? user;
                    bool isLoading = profileState is ProfileLoading;

                    if (profileState is ProfileLoaded) {
                      user = profileState.user;
                    }

                    return ModernItemUI(
                      item: widget.item,
                      user: user,
                      isUserLoading: isLoading,
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ChatButton(userId: widget.item.userId),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
