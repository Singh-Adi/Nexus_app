import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_mobile/providers/user_provider.dart';
import 'package:nexus_mobile/screens/profile/profile_screen.dart';
import 'package:nexus_mobile/widgets/user_card.dart';
import 'package:nexus_mobile/widgets/loading_indicator.dart';

class FollowingScreen extends StatefulWidget {
  final String username;
  
  const FollowingScreen({
    Key? key,
    required this.username,
  }) : super(key: key);
  
  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load following
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFollowing();
    });
  }
  
  Future<void> _loadFollowing() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadFollowing(widget.username);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username} is Following'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading && userProvider.following.isEmpty) {
            return const LoadingIndicator();
          }
          
          if (userProvider.following.isEmpty) {
            return const Center(
              child: Text('Not following anyone yet.'),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: userProvider.following.length,
            itemBuilder: (context, index) {
              final followedUser = userProvider.following[index];
              return UserCard(
                profile: followedUser,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        username: followedUser.user!.username,
                      ),
                    ),
                  );
                },
                onFollowTap: () async {
                  if (followedUser.isFollowing) {
                    await userProvider.unfollowUser(followedUser.user!.username);
                  } else {
                    await userProvider.followUser(followedUser.user!.username);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}