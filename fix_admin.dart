import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with web config
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyD6i8VIpGAHo0q2To0XyMkP2_vxHJJ0Jtk',
      appId: '1:51644822800:web:cfa1e4fd149a2974142195',
      messagingSenderId: '51644822800',
      projectId: 'smart-food-rescue-fa0a9',
      authDomain: 'smart-food-rescue-fa0a9.firebaseapp.com',
      storageBucket: 'smart-food-rescue-fa0a9.firebasestorage.app',
    ),
  );
  
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  
  final user = auth.currentUser;
  if (user != null) {
    print('Current user: ${user.email}');
    final doc = await firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final role = doc.data()?['role'];
      print('Current role in Firestore: $role');
      
      if (role != 'administrator') {
        await firestore.collection('users').doc(user.uid).update({'role': 'administrator'});
        print('✓ Role updated to administrator!');
        print('Please restart the app.');
      } else {
        print('✓ Role is already administrator.');
      }
    } else {
      await firestore.collection('users').doc(user.uid).set({
        'userId': user.uid,
        'name': user.email?.split('@')[0] ?? 'Admin',
        'email': user.email,
        'role': 'administrator',
        'phone': '',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      print('✓ Admin user created!');
    }
  } else {
    print('❌ No user logged in.');
    print('Please login in the main app first, then run this script again.');
  }
}
