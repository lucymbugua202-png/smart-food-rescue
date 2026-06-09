import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
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
        print('Updating role to administrator...');
        await firestore.collection('users').doc(user.uid).update({
          'role': 'administrator'
        });
        print('Role updated! Please restart the app.');
      } else {
        print('Role is already administrator.');
      }
    } else {
      print('User document not found. Creating...');
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
    print('No user logged in. Please login first.');
  }
}
