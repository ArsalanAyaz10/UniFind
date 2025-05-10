import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:unifind/core/models/user_model.dart';


class DataRepository {

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseStorage _firebaseStorage;

  DataRepository(this.firebaseAuth, this.firestore, this._firebaseStorage);

  
}