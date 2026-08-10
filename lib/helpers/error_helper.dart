class ErrorHelper {
  String cleanUpMessage(String? error) {
    String message = error ?? '';
    if (message.contains('firebase_auth/user-not-found') ||
        message.contains('firebase_auth/wrong-password')) {
      int index = message.indexOf(']');
      if (index >= 0) {
        message = message.substring(index + 1);
      }
    }
    return message;
  }
}
