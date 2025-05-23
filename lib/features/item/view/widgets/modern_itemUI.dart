import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/core/models/user_model.dart';
import 'package:unifind/features/item/data/models/item_model.dart';
import 'package:unifind/features/profile/bloc/other_profile_cubit.dart';

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
                                        context.read<OtherProfileCubit>().fetchUserById(item.userId);
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
