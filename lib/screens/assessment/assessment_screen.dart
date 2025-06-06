import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system.dart';
import '../../models/assessment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/assessment_provider.dart';
import './assessment_result_screen.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  final PageController _pageController = PageController();
  final Map<String, int> _responses = {};
  int _currentPage = 0;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'Q1',
      'text':
          'Combien d\'heures par jour utilisez-vous votre smartphone en moyenne?',
      'options': [
        'Moins d\'1 heure',
        '1-2 heures',
        '3-4 heures',
        '5-6 heures',
        'Plus de 6 heures'
      ],
      'category': 'screenTime',
    },
    {
      'id': 'Q2',
      'text':
          'À quelle fréquence vérifiez-vous consciemment le temps que vous passez sur vos appareils?',
      'options': [
        'Jamais',
        'Rarement',
        'Parfois',
        'Souvent',
        'Très régulièrement'
      ],
      'category': 'mindfulness',
    },
    {
      'id': 'Q3',
      'text':
          'Vous sentez-vous anxieux(se) lorsque vous ne pouvez pas vérifier votre téléphone?',
      'options': [
        'Extrêmement anxieux(se)',
        'Très anxieux(se)',
        'Modérément anxieux(se)',
        'Légèrement anxieux(se)',
        'Pas du tout anxieux(se)'
      ],
      'category': 'wellBeing',
    },
    {
      'id': 'Q4',
      'text':
          'À quelle fréquence les notifications interrompent-elles votre travail ou vos études?',
      'options': [
        'Constamment',
        'Très souvent',
        'Régulièrement',
        'Occasionnellement',
        'Rarement ou jamais'
      ],
      'category': 'productivity',
    },
    {
      'id': 'Q5',
      'text': 'Utilisez-vous votre téléphone au lit avant de vous endormir?',
      'options': [
        'Toujours',
        'Presque toujours',
        'Parfois',
        'Rarement',
        'Jamais'
      ],
      'category': 'screenTime',
    },
    {
      'id': 'Q6',
      'text':
          'À quelle fréquence prenez-vous des pauses délibérées de la technologie?',
      'options': [
        'Jamais',
        'Rarement',
        'Parfois',
        'Souvent',
        'Quotidiennement'
      ],
      'category': 'mindfulness',
    },
    {
      'id': 'Q7',
      'text':
          'Comment évalueriez-vous l\'impact des réseaux sociaux sur votre humeur?',
      'options': [
        'Très négatif',
        'Plutôt négatif',
        'Neutre',
        'Plutôt positif',
        'Très positif'
      ],
      'category': 'wellBeing',
    },
    {
      'id': 'Q8',
      'text':
          'Combien de fois par jour vous sentez-vous distrait(e) par votre téléphone?',
      'options': [
        'Plus de 20 fois',
        '15-20 fois',
        '10-14 fois',
        '5-9 fois',
        'Moins de 5 fois'
      ],
      'category': 'productivity',
    },
    {
      'id': 'Q9',
      'text': 'Combien d\'applications utilisez-vous quotidiennement?',
      'options': ['Plus de 15', '11-15', '7-10', '4-6', '1-3'],
      'category': 'screenTime',
    },
    {
      'id': 'Q10',
      'text':
          'À quelle fréquence pratiquez-vous des activités sans technologie?',
      'options': [
        'Jamais',
        'Rarement',
        'Parfois',
        'Souvent',
        'Quotidiennement'
      ],
      'category': 'mindfulness',
    },
    {
      'id': 'Q11',
      'text': 'Comment évaluez-vous la qualité de votre sommeil?',
      'options': [
        'Très mauvaise',
        'Mauvaise',
        'Moyenne',
        'Bonne',
        'Excellente'
      ],
      'category': 'wellBeing',
    },
    {
      'id': 'Q12',
      'text':
          'Pouvez-vous vous concentrer sur une tâche sans vérifier votre téléphone?',
      'options': [
        'Pas du tout',
        'Difficilement',
        'Modérément',
        'Assez bien',
        'Très facilement'
      ],
      'category': 'productivity',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    } else {
      _submitAssessment();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  void _selectOption(String questionId, int value) {
    setState(() {
      _responses[questionId] = value;
    });
  }

  Future<void> _submitAssessment() async {
    if (_responses.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez répondre à toutes les questions.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = ref.read(authStateProvider).value?.user.id ?? 'unknown';
      final assessment = UserAssessment.fromResponses(_responses, userId);

      // Sauvegarder l'évaluation
      await ref.read(assessmentProvider.notifier).saveAssessment(assessment);

      if (!mounted) return;

      // Naviguer vers l'écran de résultats
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AssessmentResultScreen(assessment: assessment),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur est survenue: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Évaluation Personnalisée'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final question = _questions[index];
                return _buildQuestionCard(question);
              },
            ),
          ),
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignSystem.space24,
        vertical: AppDesignSystem.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentPage + 1} sur ${_questions.length}',
                style: AppDesignSystem.body2,
              ),
              Text(
                '${((_currentPage + 1) / _questions.length * 100).round()}%',
                style: AppDesignSystem.body2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space8),
          LinearProgressIndicator(
            value: (_currentPage + 1) / _questions.length,
            backgroundColor: Colors.grey.shade200,
            valueColor:
                AlwaysStoppedAnimation<Color>(AppDesignSystem.primaryBlue),
            minHeight: 6,
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    final questionId = question['id'] as String;
    final options = question['options'] as List<dynamic>;
    final selectedValue = _responses[questionId];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesignSystem.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['text'] as String,
            style: AppDesignSystem.heading3,
          ),
          const SizedBox(height: AppDesignSystem.space24),
          ...List.generate(options.length, (index) {
            final isSelected = selectedValue == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDesignSystem.space16),
              child: _buildOptionCard(
                options[index] as String,
                index,
                isSelected,
                () => _selectOption(questionId, index),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    String option,
    int value,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDesignSystem.space16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppDesignSystem.primaryBlue.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          border: Border.all(
            color:
                isSelected ? AppDesignSystem.primaryBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppDesignSystem.primaryBlue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppDesignSystem.primaryBlue
                    : Colors.grey.shade200,
                border: Border.all(
                  color: isSelected
                      ? AppDesignSystem.primaryBlue
                      : Colors.grey.shade400,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: AppDesignSystem.space16),
            Expanded(
              child: Text(
                option,
                style: AppDesignSystem.body1.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppDesignSystem.primaryBlue
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            OutlinedButton(
              onPressed: _previousPage,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.space20,
                  vertical: AppDesignSystem.space12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.radiusMedium),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, size: 16),
                  SizedBox(width: AppDesignSystem.space8),
                  Text('Précédent'),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignSystem.space20,
                vertical: AppDesignSystem.space12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDesignSystem.radiusMedium),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                : Row(
                    children: [
                      Text(
                        _currentPage == _questions.length - 1
                            ? 'Terminer'
                            : 'Suivant',
                      ),
                      const SizedBox(width: AppDesignSystem.space8),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
