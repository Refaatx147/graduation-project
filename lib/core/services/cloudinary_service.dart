// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  CloudinaryPublic? _cloudinary;
  bool _isInitialized = false;

  // Default values in case .env file is not available
  static const String _defaultCloudName = 'dkylre9yq';
  static const String _defaultUploadPreset = 'chat_upload';

  factory CloudinaryService() {
    return _instance;
  }

  CloudinaryService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Try to load .env file, but don't fail if it doesn't exist
      try {
        await dotenv.load();
      } catch (e) {
        print('Warning: Could not load .env file, using default values');
      }

      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? _defaultCloudName;
      final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? _defaultUploadPreset;

      _cloudinary = CloudinaryPublic(
        cloudName,
        uploadPreset,
        cache: false,
      );
      _isInitialized = true;
    } catch (e) {
      print('Error initializing Cloudinary: $e');
      // Try to initialize with default values if normal initialization fails
      try {
        _cloudinary = CloudinaryPublic(
          _defaultCloudName,
          _defaultUploadPreset,
          cache: false,
        );
        _isInitialized = true;
      } catch (e) {
        print('Error initializing Cloudinary with default values: $e');
        rethrow;
      }
    }
  }

  Future<String> uploadAudio(File audioFile, String userId) async {
    try {
      if (!_isInitialized || _cloudinary == null) {
        await initialize();
      }

      if (_cloudinary == null) {
        throw Exception('Failed to initialize Cloudinary');
      }

      final response = await _cloudinary!.uploadFile(
        CloudinaryFile.fromFile(
          audioFile.path,
          resourceType: CloudinaryResourceType.Video,
          folder: 'chat_audio/$userId',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Error uploading audio: $e');
      rethrow;
    }
  }
} 
