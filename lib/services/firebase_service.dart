import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;
  
  // Collections
  static CollectionReference get users => firestore.collection('users');
  static CollectionReference get donations => firestore.collection('donations');
  static CollectionReference get requests => firestore.collection('requests');
  static CollectionReference get notifications => firestore.collection('notifications');
}
