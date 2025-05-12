import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


  void _incrementCounter() {
  final user = {
    "firstname": "usman",
    "lastname": "baig",
    
  };

  db.collection("users").add(user).then((DocumentReference doc) =>
    print("User added with ID: ${doc.id}")
  );
}