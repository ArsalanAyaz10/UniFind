import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unifind/core/models/user_model.dart';
import 'package:unifind/features/chat/view/chat_screen.dart';
import 'package:unifind/features/item/bloc/item_cubit.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/item/data/models/item_model.dart';
import 'package:unifind/features/profile/bloc/profile_cubit.dart';
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
    // Fetch the item details
    _fetchItemDetails();
    // Fetch user data immediately
    _fetchUserData();
  }

  void _fetchItemDetails() {
    // Only fetch if not already loaded
    final state = context.read<ItemCubit>().state;
    if (state is! ItemLoaded || (state.item.itemId != widget.itemId)) {
      context.read<ItemCubit>().fetchItemById(widget.itemId);
    }
  }

  void _fetchUserData() {
    // Always fetch user data when entering this screen
    context.read<ProfileCubit>().fetchUserById(widget.item.userId);
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
            // This ensures we don't lose state when going back
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
                BlocConsumer<ProfileCubit, ProfileState>(
                  listener: (context, profileState) {
                    // If there's an error loading the profile, try again
                    if (profileState is ProfileError) {
                      Future.delayed(Duration(seconds: 1), () {
                        if (mounted) {
                          context.read<ProfileCubit>().fetchUserById(
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
            // Use the item passed in the constructor as fallback
            // Also fetch user data here
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<ProfileCubit>().fetchUserById(widget.item.userId);
              }
            });

            return Stack(
              children: [
                BlocBuilder<ProfileCubit, ProfileState>(
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

class ModernItemUI extends StatefulWidget {
  final Item item;
  final AppUser? user;
  final bool isUserLoading;

  const ModernItemUI({
    super.key,
    required this.item,
    required this.user,
    this.isUserLoading = false,
  });

  @override
  State<ModernItemUI> createState() => _ModernItemUIState();
}

class _ModernItemUIState extends State<ModernItemUI> {
  bool _isFavorite = false;

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white),
        const SizedBox(width: 10),
        Text(
          "$title: ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Expanded(child: Text(value, style: TextStyle(color: Colors.white))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final AppUser? user = widget.user;
    final bool isUserLoading = widget.isUserLoading;

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
      child: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Container(
                    height: 300,
                    width: double.infinity,
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade700,
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade300,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromRGBO(12, 77, 161, 1),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  item.category.toLowerCase() == "lost"
                                      ? Colors.red.withOpacity(0.8)
                                      : Colors.green.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                              },
                            ),
                          ),
                        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.2, end: 0, duration: 800.ms),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                    const SizedBox(height: 24),

                    // Description Section
                    _buildSectionHeader(
                      "Description",
                      Icons.description,
                    ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                    const SizedBox(height: 8),
                    _buildContentCard(
                      child: Text(
                        item.description ?? 'No description provided.',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

                    const SizedBox(height: 20),

                    // Location Section
                    _buildSectionHeader(
                      "Location Information",
                      Icons.location_on,
                    ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
                    const SizedBox(height: 8),
                    _buildContentCard(
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.location_city,
                            "Campus",
                            item.campus ?? "Not specified",
                          ),
                          const Divider(height: 20, color: Colors.white24),
                          _buildInfoRow(
                            Icons.place,
                            "Specific Location",
                            item.specificLocation ?? "Not specified",
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

                    const SizedBox(height: 20),

                    // Time Section
                    _buildSectionHeader(
                      "Time Information",
                      Icons.access_time,
                    ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
                    const SizedBox(height: 8),
                    _buildContentCard(
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.calendar_today,
                            "Date",
                            _formatDate(item.date),
                          ),
                          const Divider(height: 20, color: Colors.white24),
                          _buildInfoRow(
                            Icons.access_time,
                            "Time",
                            _formatTimeOfDay(item.time),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),

                    const SizedBox(height: 20),

                    // Category Section
                    _buildSectionHeader(
                      "Category",
                      Icons.category,
                    ).animate().fadeIn(delay: 1100.ms, duration: 600.ms),
                    const SizedBox(height: 8),
                    _buildContentCard(
                      child: _buildInfoRow(
                        Icons.category,
                        "Category",
                        item.category,
                      ),
                    ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),

                    const SizedBox(height: 20),

                    // User Section
                    _buildSectionHeader(
                      "Posted By",
                      Icons.person,
                    ).animate().fadeIn(delay: 1300.ms, duration: 600.ms),
                    const SizedBox(height: 8),
                    _buildContentCard(
                      child:
                          isUserLoading
                              ? Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Loading user information...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : user == null
                              ? Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "User information not available",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<ProfileCubit>()
                                            .fetchUserById(item.userId);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Color.fromRGBO(
                                          12,
                                          77,
                                          161,
                                          1,
                                        ),
                                      ),
                                      child: Text("Retry"),
                                    ),
                                  ],
                                ),
                              )
                              : Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.2,
                                    ),
                                    backgroundImage:
                                        user.photoUrl != null &&
                                                user.photoUrl!.isNotEmpty
                                            ? NetworkImage(user.photoUrl!)
                                            : null,
                                    child:
                                        user.photoUrl == null ||
                                                user.photoUrl!.isEmpty
                                            ? const Icon(
                                              Icons.person,
                                              size: 30,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (user.email != null)
                                        Text(
                                          user.email!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                    ).animate().fadeIn(delay: 1400.ms, duration: 600.ms),

                    // Reduced the gap from 40 to 16 to bring the chat button closer
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: child,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Not specified";
    return "${date.day}/${date.month}/${date.year}";
  }

  // Fixed method to handle TimeOfDay instead of DateTime
  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return "Not specified";

    // Format hour and minute with leading zeros if needed
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return "$hour:$minute";
  }
}

class ChatButton extends StatelessWidget {
  final String userId;

  const ChatButton({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(12, 77, 161, 1),
                Color.fromRGBO(41, 121, 209, 1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(12, 77, 161, 1).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(otherUserId: userId),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(28),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Chat with User',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 1500.ms, duration: 800.ms)
        .slideY(begin: 0.5, end: 0, duration: 800.ms);
  }
}
