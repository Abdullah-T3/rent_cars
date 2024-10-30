import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../services/cloudinary_service.dart';

class PhotoViewModel with ChangeNotifier {
  File? _selectedImage;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Getter to expose the selected image
  File? get selectedImage => _selectedImage;

  // Function to pick an image from the gallery
  Future<void> pickImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _selectedImage = File(image.path);
      notifyListeners(); // Notify listeners about the change
    }
  }

  // Function to upload the photo and return its URL
  Future<String?> uploadPhoto() async {
    if (_selectedImage == null) {
      print('No image selected for upload.');
      return null; // Return null if no image is selected
    }

    try {
      final imageUrl = await _cloudinaryService.uploadImage(_selectedImage!.path);
      return imageUrl; // Return the URL of the uploaded image
    } catch (e) {
      print('Image upload failed: $e');
      return null; // Return null in case of failure
    }
  }

  // Clear the selected image
  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners(); // Notify listeners about the change
  }
}