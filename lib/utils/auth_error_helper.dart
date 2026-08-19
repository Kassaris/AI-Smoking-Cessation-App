String parseFirebaseAuthError(String errorMessage) {
  // Remove the [firebase_auth/...] prefix
  final regex = RegExp(r'^\[[^\]]+\]\s*');
  final cleanMessage = errorMessage.replaceAll(regex, '');

  // Customize specific messages if needed
  if (errorMessage.contains('[firebase_auth/invalid-email]')) {
    return 'Please enter a valid email address';
  } else if (errorMessage.contains('[firebase_auth/weak-password]')) {
    return 'Password should be at least 6 characters';
  } else if (errorMessage.contains('[firebase_auth/email-already-in-use]')) {
    return 'This email is already registered';
  }

  // Capitalize first letter and add period if missing
  return cleanMessage.trim().isEmpty
      ? 'An unknown error occurred'
      : cleanMessage[0].toUpperCase() +
          cleanMessage.substring(1).replaceAll(RegExp(r'\.$'), '') +
          '.';
}
