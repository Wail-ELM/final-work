import 'package:social_balans/models/challenge_category_adapter.dart';

class ChallengeTemplate {
  final String id;
  final String title;
  final String description;
  final int xp;
  final ChallengeCategory category;
  final int durationInDays;

  const ChallengeTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.xp,
    required this.category,
    required this.durationInDays,
  });
}

const challengeTemplates = <ChallengeTemplate>[
  ChallengeTemplate(
    id: 'st_free_hour',
    title: 'Een uur zonder scherm',
    description: 'Geen smartphone, tablet of computer gedurende 1 uur.',
    xp: 50,
    category: ChallengeCategory.screenTime,
    durationInDays: 1,
  ),
  ChallengeTemplate(
    id: 'focus_25_5',
    title: 'Pomodoro 25/5',
    description: '25 minuten geconcentreerd werken, daarna 5 minuten pauze.',
    xp: 30,
    category: ChallengeCategory.focus,
    durationInDays: 1,
  ),
  ChallengeTemplate(
    id: 'no_notifs_evening',
    title: 'Geen meldingen in de avond',
    description: 'Schakel alle meldingen uit na 20:00 uur.',
    xp: 40,
    category: ChallengeCategory.notifications,
    durationInDays: 7,
  ),
];
