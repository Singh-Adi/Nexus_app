import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_mobile/providers/user_provider.dart';
import 'package:nexus_mobile/screens/profile/profile_screen.dart';
import 'package:nexus_mobile/widgets/user_card.dart';
import 'package:nexus_mobile/widgets/loading_indicator.dart';

class FollowersScreen extends StatefulWidget {
  final String username;
  
  const FollowersScreen({
    Key? key,
    required this.username,
  }) : super(key: key);
  
  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load followers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFollowers();
    });
  }
  
  Future<void> _loadFollowers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadFollowers(widget.username);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username}\'s Followers'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading && userProvider.followers.isEmpty) {
            return const LoadingIndicator();
          }
          
          if (userProvider.followers.isEmpty) {
            return const Center(
              child: Text('No followers yet.'),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: userProvider.followers.length,
            itemBuilder: (context, index) {
              final follower = userProvider.followers[index];
              return UserCard(
                profile: follower,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        username: follower.user!.username,
                      ),
                    ),
                  );
                },
                onFollowTap: () async {
                  if (follower.isFollowing) {
                    await userProvider.unfollowUser(follower.user!.username);
                  } else {
                    await userProvider.followUser(follower.user!.username);
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