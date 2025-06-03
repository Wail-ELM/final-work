class DateHelpers {
  // Formatage de date pour l'affichage
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Vandaag';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return 'Gisteren';
    } else if (dateToCheck.isAfter(today.subtract(const Duration(days: 7)))) {
      return _getDayName(date.weekday);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Formatage de l'heure
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Formatage date et heure combinés
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} om ${formatTime(dateTime)}';
  }

  // Vérifier si c'est aujourd'hui
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Vérifier si c'est cette semaine
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // Obtenir le début de la semaine
  static DateTime getStartOfWeek([DateTime? date]) {
    date ??= DateTime.now();
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Obtenir la fin de la semaine
  static DateTime getEndOfWeek([DateTime? date]) {
    date ??= DateTime.now();
    return getStartOfWeek(date).add(const Duration(days: 6));
  }

  // Obtenir le nom du jour
  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Maandag';
      case 2:
        return 'Dinsdag';
      case 3:
        return 'Woensdag';
      case 4:
        return 'Donderdag';
      case 5:
        return 'Vrijdag';
      case 6:
        return 'Zaterdag';
      case 7:
        return 'Zondag';
      default:
        return '';
    }
  }

  // Obtenir le nom du mois
  static String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'januari';
      case 2:
        return 'februari';
      case 3:
        return 'maart';
      case 4:
        return 'april';
      case 5:
        return 'mei';
      case 6:
        return 'juni';
      case 7:
        return 'juli';
      case 8:
        return 'augustus';
      case 9:
        return 'september';
      case 10:
        return 'oktober';
      case 11:
        return 'november';
      case 12:
        return 'december';
      default:
        return '';
    }
  }

  // Calculer la différence en jours
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}
