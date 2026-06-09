import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  
  final user = auth.currentUser;
  if (user != null) {
    print('Current user: ${user.email}');
    final doc = await firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final role = doc.data()?['role'];
      print('Current role: $role');
      
      if (role != 'administrator') {
        await firestore.collection('users').doc(user.uid).update({'role': 'administrator'});
        print('Role updated to administrator!');
      } else {
        print('Role is already administrator.');
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
      print('Admin user created!');
    }
  } else {
    print('Please login first in the main app');
  }
}
