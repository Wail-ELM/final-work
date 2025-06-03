class Validators {
  // Validation email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Voer je e-mailadres in';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Voer een geldig e-mailadres in';
    }

    return null;
  }

  // Validation mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Voer een wachtwoord in';
    }

    if (value.length < 6) {
      return 'Wachtwoord moet minimaal 6 tekens bevatten';
    }

    return null;
  }

  // Validation nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Voer je naam in';
    }

    if (value.length > 50) {
      return 'Naam mag maximaal 50 tekens bevatten';
    }

    return null;
  }

  // Validation confirmation mot de passe
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Bevestig je wachtwoord';
    }

    if (value != password) {
      return 'Wachtwoorden komen niet overeen';
    }

    return null;
  }

  // Validation note/description
  static String? validateNote(String? value) {
    if (value != null && value.length > 500) {
      return 'Notitie mag maximaal 500 tekens bevatten';
    }

    return null;
  }

  // Validation mood value
  static String? validateMoodValue(int? value) {
    if (value == null) {
      return 'Selecteer een stemming';
    }

    if (value < 1 || value > 5) {
      return 'Stemming moet tussen 1 en 5 zijn';
    }

    return null;
  }
}
