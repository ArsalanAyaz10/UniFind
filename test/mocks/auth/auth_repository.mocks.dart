import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unifind/features/auth/data/auth_repository.dart'; // <-- Add this import

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  UserCredential,
  DocumentReference,
  DocumentSnapshot,
  CollectionReference,
  QuerySnapshot,
  AuthRepository, // <-- Add this line!
])
void main() {}