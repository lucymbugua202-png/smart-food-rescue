import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.role == UserRole.administrator;
  bool get isDonor => _currentUser?.role == UserRole.donor;
  bool get isRecipient => _currentUser?.role == UserRole.recipient;

  AppAuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    if (rememberMe && _auth.currentUser != null) {
      await getUserData(_auth.currentUser!.uid);
    }
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      await getUserData(user.uid);
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> getUserData(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _currentUser = AppUser.fromJson(data);
          print('User loaded: ${_currentUser?.name}, Role: ${_currentUser?.role}');
        } else {
          print('User document data is null');
        }
        _errorMessage = null;
      } else {
        print('User document does not exist for ID: $userId');
      }
    } catch (e) {
      _errorMessage = 'Error loading user data: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = AppUser(
        id: result.user!.uid,
        name: name,
        email: email.trim(),
        role: UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == role.toLowerCase()
        ),
        phone: phone,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(result.user!.uid).set(user.toJson());
      
      await result.user!.updateDisplayName(name);
      
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithEmail(String email, String password, bool rememberMe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', rememberMe);

      await getUserData(result.user!.uid);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
    await _auth.signOut();
    _currentUser = null;
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name, 
    String? phone, 
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updates = <String, dynamic>{};
      if (name != null) {
        updates['name'] = name;
        await _auth.currentUser?.updateDisplayName(name);
      }
      if (phone != null) updates['phone'] = phone;
      if (profileImageUrl != null) updates['profileImage'] = profileImageUrl;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_currentUser!.id).update(updates);
        
        if (name != null) _currentUser!.name = name;
        if (phone != null) _currentUser!.phone = phone;
        if (profileImageUrl != null) _currentUser!.profileImage = profileImageUrl;
      }
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
