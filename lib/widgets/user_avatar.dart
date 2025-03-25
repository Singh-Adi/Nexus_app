import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  
  const UserAvatar({
    Key? key,
    this.imageUrl,
    this.size = 40,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey[200],
      backgroundImage: imageUrl != null
          ? CachedNetworkImageProvider(imageUrl!)
          : null,
      child: imageUrl == null
          ? Icon(
              Icons.person,
              size: size / 2,
              color: Colors.grey[600],
            )
          : null,
    );
  }
}