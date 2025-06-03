extension StringExtension on String {
  // Capitaliser la première lettre
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  // Capitaliser chaque mot
  String get capitalizeWords {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  // Vérifier si c'est un email valide
  bool get isValidEmail {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(this);
  }

  // Vérifier si c'est un numéro de téléphone valide (format néerlandais)
  bool get isValidPhoneNumber {
    return RegExp(r'^(\+31|0)[6789]\d{8}$').hasMatch(replaceAll(' ', ''));
  }

  // Vérifier si c'est seulement des lettres
  bool get isAlphabetic {
    return RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(this);
  }

  // Vérifier si c'est seulement des chiffres
  bool get isNumeric {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  // Vérifier si c'est alphanumeric
  bool get isAlphaNumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  // Obtenir les initiales
  String get initials {
    if (isEmpty) return '';

    final parts = trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
  }

  // Masquer partiellement l'email
  String get maskedEmail {
    if (!isValidEmail) return this;

    final parts = split('@');
    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length <= 2) {
      return '${localPart[0]}*@$domain';
    } else {
      return '${localPart[0]}${'*' * (localPart.length - 2)}${localPart[localPart.length - 1]}@$domain';
    }
  }

  // Nettoyer les espaces multiples
  String get cleanSpaces {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Tronquer avec des points de suspension
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  // Supprimer les accents
  String get removeAccents {
    return replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  // Convertir en slug
  String get toSlug {
    return toLowerCase()
        .removeAccents
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  // Vérifier si la chaîne est vide ou null
  bool get isNullOrEmpty {
    return isEmpty;
  }

  // Vérifier si la chaîne n'est pas vide
  bool get isNotEmpty {
    return !isEmpty;
  }

  // Extraire les chiffres seulement
  String get numbersOnly {
    return replaceAll(RegExp(r'[^0-9]'), '');
  }

  // Extraire les lettres seulement
  String get lettersOnly {
    return replaceAll(RegExp(r'[^a-zA-ZÀ-ÿ]'), '');
  }

  // Compter les mots
  int get wordCount {
    if (trim().isEmpty) return 0;
    return trim().split(RegExp(r'\s+')).length;
  }

  // Reverse string
  String get reversed {
    return split('').reversed.join('');
  }

  // Premier caractère
  String get firstChar {
    return isEmpty ? '' : this[0];
  }

  // Dernier caractère
  String get lastChar {
    return isEmpty ? '' : this[length - 1];
  }

  // Vérifier si ça commence par une majuscule
  bool get startsWithUpperCase {
    return isNotEmpty && firstChar == firstChar.toUpperCase();
  }
}
