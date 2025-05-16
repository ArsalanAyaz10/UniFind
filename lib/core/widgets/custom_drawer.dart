import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/profile/bloc/profile_cubit.dart';
import 'package:unifind/features/profile/bloc/profile_state.dart';

class ModernDrawer extends StatelessWidget {
  const ModernDrawer(BuildContext context, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
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
                  email = state.user.email;
                  profilePicUrl = state.user.photoUrl;
                } else if (state is ProfileError) {
                  name = 'Error';
                  email = '';
                }

                return DrawerHeader(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage:
                            profilePicUrl != null
                                ? NetworkImage(profilePicUrl)
                                : const AssetImage('assets/images/profile.jpg')
                                    as ImageProvider,
                      ),
                      SizedBox(height: 10),
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.home, color: Color.fromRGBO(12, 77, 161, 1)),
              title: Text(
                'Home',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.search,
                color: Color.fromRGBO(12, 77, 161, 1),
              ),
              title: Text(
                'Browse Items',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/display');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.add_circle_outline,
                color: Color.fromRGBO(12, 77, 161, 1),
              ),
              title: Text(
                'Report Item',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/report');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.person,
                color: Color.fromRGBO(12, 77, 161, 1),
              ),
              title: Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Color.fromRGBO(12, 77, 161, 1),
              ),
              title: Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                context.read<AuthCubit>().logout();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
