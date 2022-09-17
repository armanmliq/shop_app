class FirebaseException implements Exception {
  final String message;
  FirebaseException(this.message);

  @override
  String toString() {
    return message;
  }
}
