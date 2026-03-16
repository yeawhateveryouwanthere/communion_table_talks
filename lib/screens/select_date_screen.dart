import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/presentation.dart';
import '../theme/app_theme.dart';
import 'browse_presentations_screen.dart';

class SelectDateScreen extends StatefulWidget {
  const SelectDateScreen({super.key});

  @override
  State<SelectDateScreen> createState() => _SelectDateScreenState();
}

class _SelectDateScreenState extends State<SelectDateScreen> {
  DateTime? _selectedDate;
  PresentationLength? _selectedLength;
  final TextEditingController _passageController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  @override
  void dispose() {
    _passageController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: 'When will you be presenting?',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.primaryColor,
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectPresentation() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a date first'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrowsePresentationsScreen(
          scheduledDate: _selectedDate,
          filterLength: _selectedLength,
          filterPassage: _passageController.text.trim(),
          filterTopic: _topicController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image header
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppTheme.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Plan a Presentation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Color(0x88000000),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/header_date.jpeg',
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Intro text
                  Text(
                    'When will you be leading the Lord\'s Supper?',
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                  ),
                  const SizedBox(height: 24),

                  // Date picker card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Material(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: _selectedDate != null
                                ? Border.all(
                                    color: AppTheme.primaryColor
                                        .withOpacity(0.3),
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _selectedDate != null
                                      ? AppTheme.primaryColor.withOpacity(0.1)
                                      : AppTheme.textSecondary
                                          .withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: _selectedDate != null
                                      ? AppTheme.primaryColor
                                      : AppTheme.textSecondary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedDate != null
                                          ? DateFormat.EEEE()
                                              .format(_selectedDate!)
                                          : 'Select a date',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _selectedDate != null
                                            ? AppTheme.textPrimary
                                            : AppTheme.textSecondary,
                                        fontWeight: _selectedDate != null
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                    if (_selectedDate != null)
                                      Text(
                                        DateFormat.yMMMd()
                                            .format(_selectedDate!),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color:
                                    AppTheme.textSecondary.withOpacity(0.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Optional filters section
                  Row(
                    children: [
                      Icon(Icons.tune,
                          size: 18,
                          color: AppTheme.textSecondary.withOpacity(0.6)),
                      const SizedBox(width: 8),
                      Text(
                        'Narrow your search',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(optional)',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose any combination of filters, or leave them blank to see everything.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 22),

                  // Length selector
                  Text(
                    'Presentation Length',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildLengthOption(
                          'Brief', PresentationLength.brief),
                      const SizedBox(width: 10),
                      _buildLengthOption(
                          'Medium', PresentationLength.medium),
                      const SizedBox(width: 10),
                      _buildLengthOption(
                          'Substantive', PresentationLength.substantive),
                    ],
                  ),
                  if (_selectedLength != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _selectedLength = null),
                      child: Text(
                        'Clear length filter',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Passage search
                  Text(
                    'Scripture Passage',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passageController,
                    hint: 'e.g., 1 Corinthians 11, John 6, Luke 22',
                    icon: Icons.menu_book,
                  ),

                  const SizedBox(height: 24),

                  // Topic search
                  Text(
                    'Topic or Theme',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _topicController,
                    hint: 'e.g., grace, sacrifice, remembrance, hope',
                    icon: Icons.label_outline,
                  ),

                  const SizedBox(height: 40),

                  // Find presentations button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _selectPresentation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text('Find Presentations'),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppTheme.textSecondary.withOpacity(0.4),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon,
              color: AppTheme.primaryColor.withOpacity(0.4)),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppTheme.primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  String _timeForLabel(String label) {
    switch (label) {
      case 'Brief':
        return '2–3 min';
      case 'Medium':
        return '4–6 min';
      case 'Substantive':
        return '7–10 min';
      default:
        return '';
    }
  }

  Widget _buildLengthOption(String label, PresentationLength length) {
    final isSelected = _selectedLength == length;
    final color = AppTheme.lengthColor(label);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedLength = isSelected ? null : length;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.4) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: isSelected ? [] : AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              Icon(
                AppTheme.lengthIcon(label),
                size: 20,
                color: isSelected ? color : AppTheme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppTheme.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _timeForLabel(label),
                style: TextStyle(
                  color: isSelected
                      ? color.withOpacity(0.7)
                      : AppTheme.textSecondary.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
