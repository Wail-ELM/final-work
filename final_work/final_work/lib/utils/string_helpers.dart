class StringHelpers {
  // Capitaliser la première lettre
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Capitaliser chaque mot
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // Tronquer le texte avec des points de suspension
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Vérifier si l'email est valide
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Extraire les initiales d'un nom
  static String getInitials(String name) {
    if (name.isEmpty) return '';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
  }

  // Masquer partiellement l'email
  static String maskEmail(String email) {
    if (!isValidEmail(email)) return email;

    final parts = email.split('@');
    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length <= 2) {
      return '${localPart[0]}*@$domain';
    } else {
      return '${localPart[0]}${'*' * (localPart.length - 2)}${localPart[localPart.length - 1]}@$domain';
    }
  }

  // Nettoyer les espaces supplémentaires
  static String cleanSpaces(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Vérifier si le texte contient seulement des lettres
  static bool isAlphabetic(String text) {
    return RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(text);
  }

  // Vérifier si le texte contient seulement des chiffres
  static bool isNumeric(String text) {
    return RegExp(r'^[0-9]+$').hasMatch(text);
  }

  // Convertir une durée en texte lisible
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}u ${minutes}m';
      } else {
        return '${hours}u';
      }
    } else {
      return '${minutes}m';
    }
  }

  // Générer un slug à partir d'un texte
  static String toSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }
}
