/// Represents an authenticated user in the app.
/// Works uniformly with Firebase Auth users and local demo users.
class AppUser {
  final String uid;
  final String email;
  final String? displayName;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
  });

  /// Display name or formatted fallback from email
  String get nameToShow {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!;
    }
    if (email.contains('@')) {
      final namePart = email.split('@').first;
      return namePart[0].toUpperCase() + namePart.substring(1);
    }
    return 'User';
  }
}
