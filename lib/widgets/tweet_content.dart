import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nexus_mobile/models/tweet.dart';
import 'package:nexus_mobile/screens/tweet/media_view_screen.dart';

class TweetContent extends StatelessWidget {
  final Tweet tweet;
  
  const TweetContent({
    Key? key,
    required this.tweet,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tweet text
        Text(
          tweet.content,
          style: const TextStyle(fontSize: 16),
        ),
        
        // Media content (if any)
        if (tweet.mediaUrl != null || tweet.mediaFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaViewScreen(
                      mediaUrl: tweet.mediaUrl ?? tweet.mediaFile!,
                      isVideo: _isVideoMedia(tweet.mediaUrl ?? tweet.mediaFile!),
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildMediaContent(tweet.mediaUrl ?? tweet.mediaFile!),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildMediaContent(String mediaUrl) {
    if (_isVideoMedia(mediaUrl)) {
      // For video, show a thumbnail with a play icon
      return Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: CachedNetworkImage(
                imageUrl: mediaUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.black45,
            radius: 24,
            child: Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      );
    } else {
      // For images
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: mediaUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    }
  }
  
  bool _isVideoMedia(String mediaUrl) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.flv', '.wmv', '.webm'];
    return videoExtensions.any((ext) => mediaUrl.toLowerCase().endsWith(ext));
  }
}