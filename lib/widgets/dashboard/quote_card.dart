import 'package:flutter/material.dart';
import '../../core/design_system.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quote = _getRandomQuote();
    
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.space8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
                ),
                child: Icon(
                  Icons.format_quote,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDesignSystem.space12),
              Text(
                'Inspiratie voor vandaag',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space16),
          Text(
            '"${quote.text}"',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: AppDesignSystem.space8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '- ${quote.author}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Quote _getRandomQuote() {
    final quotes = [
      Quote(
        text: 'De kunst van rusten is een deel van de kunst van werken.',
        author: 'John Steinbeck',
      ),
      Quote(
        text: 'Technologie is een geweldige dienaar, maar een verschrikkelijke meester.',
        author: 'Gretchen Rubin',
      ),
      Quote(
        text: 'Soms is de belangrijkste les die je kunt leren, dat een pauze nemen geen tijdverspilling is.',
        author: 'Maryileene Crespo',
      ),
      Quote(
        text: 'De eenvoudigste dingen brengen vaak de meeste vreugde.',
        author: 'Eckhart Tolle',
      ),
      Quote(
        text: 'Vergelijk je niet met anderen. Vergelijk jezelf met de persoon die je gisteren was.',
        author: 'Jordan Peterson',
      ),
      Quote(
        text: 'Je hoeft niet altijd bereikbaar te zijn. Dat is je eigen keuze.',
        author: 'Byron Katie',
      ),
      Quote(
        text: 'Geluk is wanneer wat je denkt, wat je zegt en wat je doet in harmonie zijn.',
        author: 'Mahatma Gandhi',
      ),
    ];

    // Renvoyer une citation pseudo-aléatoire basée sur le jour du mois
    final dayOfMonth = DateTime.now().day;
    final index = dayOfMonth % quotes.length;
    return quotes[index];
  }
}

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});
} 