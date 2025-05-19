import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unifind/features/chat/data/chat_repository.dart';
import 'package:unifind/features/chat/data/model/chat_model.dart';
import 'package:unifind/features/chat/data/model/chat_tread_model.dart';

@GenerateMocks([
  ChatRepository,
  FirebaseFirestore,
  FirebaseAuth,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  Query,
  User,
])
void main() {}
