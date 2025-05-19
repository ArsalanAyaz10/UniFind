import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unifind/core/widgets/action_card.dart';
import 'package:unifind/core/widgets/custom_drawer.dart';
import 'package:unifind/core/widgets/stat_card.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/auth/bloc/auth_state.dart';
import 'package:unifind/features/profile/bloc/current_profile_cubit.dart';
import 'package:unifind/features/profile/bloc/profile_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CurrentProfileCubit>().fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'ZabFind',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Color.fromRGBO(12, 77, 161, 1).withOpacity(0.8),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notifications will be implemented here'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      drawer: ModernDrawer(),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          } else if (state is AuthError) {
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
        child: ModernHomeUI(),
      ),
    );
  }
}

class ModernHomeUI extends StatelessWidget {
  const ModernHomeUI({super.key});

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
      child: SafeArea(
        child: Column(
          children: [
            // Welcome section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<CurrentProfileCubit, ProfileState>(
                    builder: (context, state) {
                      String name = 'there';
                      if (state is ProfileLoaded) {
                        name = state.user.name.split(' ')[0]; // Get first name
                      }
                      return Text(
                        "Hello, $name!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 600.ms);
                    },
                  ),
                  SizedBox(height: 8),
                  Text(
                    "What would you like to do today?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Report Item Card
                      ActionCard(
                            title: "Report Item",
                            description:
                                "Lost or found something? Report it here.",
                            icon: Icons.add_circle_outline,
                            onTap: () {
                              Navigator.pushNamed(context, '/report');
                            },
                          )
                          .animate(delay: 400.ms)
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: 0.2, end: 0, duration: 800.ms),

                      SizedBox(height: 20),

                      // Browse Items Card
                      ActionCard(
                            title: "Browse Items",
                            description: "View lost and found items on campus.",
                            icon: Icons.search,
                            onTap: () {
                              Navigator.pushNamed(context, '/display');
                            },
                          )
                          .animate(delay: 600.ms)
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: 0.2, end: 0, duration: 800.ms),

                      SizedBox(height: 20),

                      // My Items Card
                      ActionCard(
                            title: "My Items",
                            description:
                                "View items you've reported or claimed.",
                            icon: Icons.inventory_2_outlined,
                            onTap: () {
                              Navigator.pushNamed(context, '/my-items');
                            },
                          )
                          .animate(delay: 800.ms)
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: 0.2, end: 0, duration: 800.ms),
                    ],
                  ),
                ),
              ),
            ),

            // Quick stats section
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Stats",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),

                  SizedBox(height: 16),

                  Row(
                    children: [
                      StatCard(
                        title: "Lost Items",
                        value: "24",
                        icon: Icons.search,
                        color: Colors.red.withOpacity(0.8),
                      ),
                      SizedBox(width: 16),
                      StatCard(
                        title: "Found Items",
                        value: "18",
                        icon: Icons.check_circle_outline,
                        color: Colors.green.withOpacity(0.8),
                      ),
                      SizedBox(width: 16),
                      StatCard(
                        title: "Claimed",
                        value: "12",
                        icon: Icons.handshake_outlined,
                        color: Colors.amber.withOpacity(0.8),
                      ),
                    ],
                  ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
