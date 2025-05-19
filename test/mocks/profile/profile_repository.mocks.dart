import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unifind/core/models/user_model.dart';
import 'package:unifind/features/profile/data/profile_repository.dart';

@GenerateMocks([
  ProfileRepository,
  FirebaseAuth,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  Query,
  User,
])
void main() {}
