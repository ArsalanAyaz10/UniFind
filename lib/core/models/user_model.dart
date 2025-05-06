class AppUser {
  late String uid;
  final String name;
  final String? program;
  final int? studentId;
  final String email;
  final String? photoUrl;

  AppUser({
    required this.name,
    this.program,
    this.studentId,
    required this.email,
    this.photoUrl,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      name: data['name'] ?? '',
      program: data['program'],
      studentId: data['studentId'],
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],  // new
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'program': program,
      'studentId': studentId,
      'email': email,
      'photoUrl': photoUrl,  // new
    };
  }
}
