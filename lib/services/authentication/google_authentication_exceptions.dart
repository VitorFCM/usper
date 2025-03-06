class GoogleAuthException implements Exception {
  String errorMessage;

  GoogleAuthException({required this.errorMessage});

  @override
  String toString() {
    return errorMessage;
  }
}

class NotAUniversityEmail extends GoogleAuthException {
  NotAUniversityEmail()
      : super(errorMessage: "The selected email is not from the university");
}
