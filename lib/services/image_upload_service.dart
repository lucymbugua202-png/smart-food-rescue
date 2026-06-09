import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndUploadImage() async {
    try {
      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image == null) return null;
      
      // Upload to Firebase Storage
      return await uploadImage(File(image.path));
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<String?> takePhoto() async {
    try {
      // Take photo with camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image == null) return null;
      
      // Upload to Firebase Storage
      return await uploadImage(File(image.path));
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      // Generate unique filename
      String fileName = 'donations/${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}.jpg';
      
      // Reference to storage
      Reference ref = _storage.ref().child(fileName);
      
      // Upload file
      await ref.putFile(imageFile);
      
      // Get download URL
      String downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }
}
