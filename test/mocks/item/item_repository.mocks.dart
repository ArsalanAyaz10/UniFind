import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unifind/features/item/data/item_repository.dart';
import 'package:unifind/features/item/data/models/item_model.dart';

@GenerateMocks([
  ItemRepository,
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