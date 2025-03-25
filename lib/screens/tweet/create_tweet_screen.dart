import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:nexus_mobile/providers/auth_provider.dart';
import 'package:nexus_mobile/providers/tweet_provider.dart';
import 'package:nexus_mobile/utils/validators.dart';
import 'package:nexus_mobile/widgets/user_avatar.dart';

class CreateTweetScreen extends StatefulWidget {
  final int? replyToTweetId;
  
  const CreateTweetScreen({
    Key? key,
    this.replyToTweetId,
  }) : super(key: key);
  
  @override
  _CreateTweetScreenState createState() => _CreateTweetScreenState();
}

class _CreateTweetScreenState extends State<CreateTweetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isSubmitting = false;
  
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _selectImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  
  Future<void> _takePicture() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }
  
  Future<void> _postTweet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
        
        if (widget.replyToTweetId != null) {
          // Posting a reply/comment
          await tweetProvider.postComment(
            widget.replyToTweetId!,
            _contentController.text.trim(),
          );
        } else {
          // Posting a new tweet
          await tweetProvider.postTweet(
            content: _contentController.text.trim(),
            mediaFile: _selectedImage,
          );
        }
        
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to post: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final remainingChars = 280 - _contentController.text.length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.replyToTweetId != null ? 'Reply' : 'New Tweet'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _postTweet,
            child: Text(
              widget.replyToTweetId != null ? 'Reply' : 'Tweet',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User avatar
                  UserAvatar(
                    imageUrl: user?.profile?.profileImageUrl,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  
                  // Tweet content field
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            hintText: "What's happening?",
                            border: InputBorder.none,
                          ),
                          maxLines: 5,
                          maxLength: 280,
                          validator: Validators.validateTweetContent,
                          onChanged: (_) => setState(() {}), // Refresh for character count
                        ),
                        
                        // Selected image preview
                        if (_selectedImage != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Character counter
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$remainingChars',
                  style: TextStyle(
                    color: remainingChars < 0 
                        ? Colors.red 
                        : remainingChars < 20 
                            ? Colors.orange 
                            : Colors.grey,
                  ),
                ),
              ),
              
              const Divider(),
              
              // Media buttons
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: _isSubmitting ? null : _selectImage,
                    tooltip: 'Add photo from gallery',
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _isSubmitting ? null : _takePicture,
                    tooltip: 'Take a picture',
                  ),
                  const Spacer(),
                  
                  // If submitting, show a loading indicator
                  if (_isSubmitting)
                    const CircularProgressIndicator(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}