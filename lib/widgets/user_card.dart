import 'package:flutter/material.dart';
import 'package:nexus_mobile/models/user.dart';
import 'package:nexus_mobile/widgets/user_avatar.dart';

class UserCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;
  
  const UserCard({
    Key? key,
    required this.profile,
    required this.onTap,
    required this.onFollowTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: profile.profileImageUrl,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.user?.username ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${profile.user?.username ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.bio!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onFollowTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: profile.isFollowing ? Colors.black : Colors.blue,
                  side: BorderSide(
                    color: profile.isFollowing ? Colors.grey : Colors.blue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(profile.isFollowing ? 'Unfollow' : 'Follow'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}