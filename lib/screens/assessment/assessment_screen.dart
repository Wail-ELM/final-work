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
      'text': 'Hoeveel uur per dag gebruik je gemiddeld je smartphone?',
      'options': [
        'Minder dan 1 uur',
        '1-2 uur',
        '3-4 uur',
        '5-6 uur',
        'Meer dan 6 uur'
      ],
      'category': 'screenTime',
    },
    {
      'id': 'Q2',
      'text':
          'Hoe vaak controleer je bewust de tijd die je op je apparaten doorbrengt?',
      'options': ['Nooit', 'Zelden', 'Soms', 'Vaak', 'Zeer regelmatig'],
      'category': 'mindfulness',
    },
    {
      'id': 'Q3',
      'text': 'Voel je je angstig als je je telefoon niet kunt controleren?',
      'options': [
        'Extreem angstig',
        'Zeer angstig',
        'Matig angstig',
        'Licht angstig',
        'Helemaal niet angstig'
      ],
      'category': 'wellBeing',
    },
    {
      'id': 'Q4',
      'text': 'Hoe vaak onderbreken meldingen je werk of studie?',
      'options': [
        'Voortdurend',
        'Heel vaak',
        'Regelmatig',
        'Af en toe',
        'Zelden of nooit'
      ],
      'category': 'productivity',
    },
    {
      'id': 'Q5',
      'text': 'Gebruik je je telefoon in bed voordat je gaat slapen?',
      'options': ['Altijd', 'Bijna altijd', 'Soms', 'Zelden', 'Nooit'],
      'category': 'screenTime',
    },
    {
      'id': 'Q6',
      'text': 'Hoe vaak neem je bewust een pauze van technologie?',
      'options': ['Nooit', 'Zelden', 'Soms', 'Vaak', 'Dagelijks'],
      'category': 'mindfulness',
    },
    {
      'id': 'Q7',
      'text': 'Hoe zou je de impact van sociale media op je humeur beoordelen?',
      'options': [
        'Zeer negatief',
        'Vrij negatief',
        'Neutraal',
        'Vrij positief',
        'Zeer positief'
      ],
      'category': 'wellBeing',
    },
    {
      'id': 'Q8',
      'text': 'Hoe vaak per dag voel je je afgeleid door je telefoon?',
      'options': [
        'Meer dan 20 keer',
        '15-20 keer',
        '10-14 keer',
        '5-9 keer',
        'Minder dan 5 keer'
      ],
      'category': 'productivity',
    },
    {
      'id': 'Q9',
      'text': 'Hoeveel applicaties gebruik je dagelijks?',
      'options': ['Meer dan 15', '11-15', '7-10', '4-6', '1-3'],
      'category': 'screenTime',
    },
    {
      'id': 'Q10',
      'text': 'Hoe vaak doe je activiteiten zonder technologie?',
      'options': ['Nooit', 'Zelden', 'Soms', 'Vaak', 'Dagelijks'],
      'category': 'mindfulness',
    },
    {
      'id': 'Q11',
      'text': 'Hoe beoordeel je de kwaliteit van je slaap?',
      'options': ['Zeer slecht', 'Slecht', 'Gemiddeld', 'Goed', 'Uitstekend'],
      'category': 'wellBeing',
    },
    {
      'id': 'Q12',
      'text':
          'Kun je je concentreren op een taak zonder je telefoon te controleren?',
      'options': [
        'Helemaal niet',
        'Moeilijk',
        'Matig',
        'Redelijk goed',
        'Zeer gemakkelijk'
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
          content: Text('Beantwoord alstublieft alle vragen.'),
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
          content: Text('Er is een fout opgetreden: $e'),
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
        title: const Text('Gepersonaliseerde Beoordeling'),
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
                'Vraag ${_currentPage + 1} van de ${_questions.length}',
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
                AlwaysStoppedAnimation<Color>(AppDesignSystem.primaryGreen),
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
              ? AppDesignSystem.primaryGreen.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          border: Border.all(
            color: isSelected
                ? AppDesignSystem.primaryGreen
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppDesignSystem.primaryGreen.withOpacity(0.1),
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
                    ? AppDesignSystem.primaryGreen
                    : Colors.grey.shade200,
                border: Border.all(
                  color: isSelected
                      ? AppDesignSystem.primaryGreen
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
                      ? AppDesignSystem.primaryGreen
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
                  Text('Vorige'),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.primaryGreen,
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
                            ? 'Voltooien'
                            : 'Volgende',
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
