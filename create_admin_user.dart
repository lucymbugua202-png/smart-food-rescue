import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  
  try {
    // Create admin user
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: 'admin@smartfoodrescue.com',
      password: 'Admin123!',
    );
    
    // Save admin data to Firestore
    await firestore.collection('users').doc(userCredential.user!.uid).set({
      'userId': userCredential.user!.uid,
      'name': 'System Administrator',
      'email': 'admin@smartfoodrescue.com',
      'role': 'administrator',
      'phone': '+1234567890',
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
    
    print('Admin user created successfully!');
    print('Email: admin@smartfoodrescue.com');
    print('Password: Admin123!');
  } catch (e) {
    print('Error: \');
    print('User might already exist. Try logging in instead.');
  }
}
