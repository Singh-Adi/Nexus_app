import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:nexus_mobile/models/user.dart';
import 'package:nexus_mobile/providers/auth_provider.dart';
import 'package:nexus_mobile/providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _profileImage;
  File? _coverPhoto;
  bool _isLoading = false;
  UserProfile? _currentProfile;

  @override
  void initState() {
    super.initState();

    // Initialize form fields with current profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFields();
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentProfile = userProvider.currentProfile;

    if (currentProfile != null) {
      setState(() {
        _currentProfile = currentProfile;
        _bioController.text = currentProfile.bio ?? '';
      });
    }
  }

  Future<void> _selectProfileImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectCoverPhoto() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _coverPhoto = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final success = await userProvider.updateProfile(
          bio: _bioController.text.trim(),
          profileImage: _profileImage,
          coverPhoto: _coverPhoto,
        );

        if (success && mounted) {
          // Refresh the auth provider to update the user profile
          await authProvider.refreshUser();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: const Text('Save'),
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
              // Cover Photo
              Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                      image: _coverPhoto != null
                          ? DecorationImage(
                              image: FileImage(_coverPhoto!),
                              fit: BoxFit.cover,
                            )
                          : _currentProfile?.coverPhotoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                      _currentProfile!.coverPhotoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: FloatingActionButton.small(
                      heroTag: 'cover_photo',
                      onPressed: _selectCoverPhoto,
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Profile Image
              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!) as ImageProvider<Object>?
                          : _currentProfile?.profileImageUrl != null
                              ? NetworkImage(_currentProfile!.profileImageUrl!)
                                  as ImageProvider<Object>?
                              : null,
                      child: _profileImage == null &&
                              _currentProfile?.profileImageUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton.small(
                        heroTag: 'profile_image',
                        onPressed: _selectProfileImage,
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bio Field
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  hintText: 'Tell us about yourself',
                ),
                maxLength: 160,
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Loading indicator
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
