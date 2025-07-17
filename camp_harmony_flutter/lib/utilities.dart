class Utilities {
  static String? phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter a phone number';
    final pat = r'^(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$';
    if (!RegExp(pat).hasMatch(v)) return 'Invalid US phone number';
    return null;
  }

  static String? nameValidator(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Cannot be empty';
    } else if (v.trim().length >= 50) {
      return 'Must be at most 50 characters';
    } else {
      return null;
    }
  }
}
