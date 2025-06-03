extension DateTimeExtension on DateTime {
  // Vérifier si c'est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  // Vérifier si c'est hier
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  // Vérifier si c'est demain
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  // Obtenir le début de la journée (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  // Obtenir la fin de la journée (23:59:59)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  // Obtenir le début du mois
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  // Obtenir la fin du mois
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  // Obtenir le début de la semaine (lundi)
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  // Obtenir la fin de la semaine (dimanche)
  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday)).endOfDay;
  }

  // Obtenir l'âge en années
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  // Vérifier si c'est un week-end
  bool get isWeekend {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  // Vérifier si c'est un jour de semaine
  bool get isWeekday {
    return !isWeekend;
  }

  // Obtenir le nombre de jours dans le mois
  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  // Vérifier si c'est une année bissextile
  bool get isLeapYear {
    return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
  }

  // Obtenir le nom du jour en néerlandais
  String get dayNameNL {
    switch (weekday) {
      case DateTime.monday:
        return 'Maandag';
      case DateTime.tuesday:
        return 'Dinsdag';
      case DateTime.wednesday:
        return 'Woensdag';
      case DateTime.thursday:
        return 'Donderdag';
      case DateTime.friday:
        return 'Vrijdag';
      case DateTime.saturday:
        return 'Zaterdag';
      case DateTime.sunday:
        return 'Zondag';
      default:
        return '';
    }
  }

  // Obtenir le nom du mois en néerlandais
  String get monthNameNL {
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

  // Formatage personnalisé
  String get friendlyFormat {
    if (isToday) return 'Vandaag';
    if (isYesterday) return 'Gisteren';
    if (isTomorrow) return 'Morgen';

    final now = DateTime.now();
    final difference = now.difference(this).inDays;

    if (difference < 7 && difference > 0) {
      return dayNameNL;
    }

    return '$day $monthNameNL $year';
  }
}
