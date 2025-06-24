import 'package:flutter/material.dart';
import 'package:hackathon/feature/functions/exercise_perform.dart'; // Import ExercisePerform
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- Modern Medical Therapy Color Palette ---
const Color kExercisePrimaryColor = Color(
  0xFF6A1B9A,
); // Deep Purple - Medical Authority
const Color kExerciseAccentColor = Color(
  0xFFEC407A,
); // Vibrant Pink - Therapeutic Energy
const Color kExerciseBackgroundColor = Color(
  0xFFF3E5F5,
); // Light Lavender - Healing Environment
const Color kExerciseCardColor = Colors.white;
const Color kExerciseTextColor = Color(
  0xFF372841,
); // Dark Purple-Gray - Professional
const Color kExerciseSecondaryTextColor = Color(
  0xFF7B6B8C,
); // Muted Purple-Gray - Supportive Text
const Color kExerciseSuccessColor = Color(
  0xFF2E7D32,
); // Dark Green - Recovery Success
const Color kExerciseWarningColor = Color(0xFFEF6C00); // Orange - Risk Alerts
// --- End Modern Medical Therapy Color Palette ---

class Exercise extends StatefulWidget {
  const Exercise({super.key});

  @override
  State<Exercise> createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {
  int? _pregnancyWeek;
  double? _weight;
  String? _name;
  String?
  _selectedExerciseInternalKey; // Stores the internal key like "bicep_curl"
  int _setsToPerform = 1;

  // Maps internal keys to therapeutic exercise names and medical icons
  final Map<String, Map<String, dynamic>> _exerciseDetails = {
    "bicep_curl": {
      "name": "Upper Limb Strengthening",
      "icon": Icons.fitness_center,
    },
    "squat": {"name": "Pelvic Floor Therapy", "icon": Icons.accessibility_new},
    "lateral_raise": {"name": "Postural Correction", "icon": Icons.straighten},
    "overhead_press": {
      "name": "Core Stabilization",
      "icon": Icons.arrow_upward,
    },
    "torso_twist": {
      "name": "Spinal Mobility Therapy",
      "icon": Icons.rotate_right,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pregnancyWeek = prefs.getInt('pregnancyWeek');
      _weight = prefs.getDouble('weight');
      _name = prefs.getString('name');
      if (_exerciseDetails.isNotEmpty) {
        _selectedExerciseInternalKey =
            _exerciseDetails.keys.first; // Default selection
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kExerciseBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Physical Therapy',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: kExercisePrimaryColor,
          ),
        ),
        backgroundColor: kExerciseCardColor,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: kExercisePrimaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildGreetingHeader(),
            const SizedBox(height: 20),
            _buildUserInfoCard(),
            const SizedBox(height: 28),
            _buildSectionTitle('Choose Your Therapeutic Exercise'),
            const SizedBox(height: 16),
            _buildExerciseGrid(),
            const SizedBox(height: 28),
            _buildSectionTitle('Set Treatment Intensity'),
            const SizedBox(height: 16),
            _buildSetsSelectorCard(),
            const SizedBox(height: 32),
            _buildStartWorkoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    if (_name == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        'Hello, ${_name!}!',
        style: GoogleFonts.lato(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: kExercisePrimaryColor,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: kExerciseTextColor,
      ),
    );
  }

  Widget _buildUserInfoCard() {
    if (_pregnancyWeek == null || _weight == null) {
      return const Center(
        child: CircularProgressIndicator(color: kExercisePrimaryColor),
      );
    }
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: kExerciseCardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildStatItem(
              'Gestational Week',
              '$_pregnancyWeek',
              Icons.calendar_today_outlined,
              kExerciseAccentColor,
            ),
            Container(height: 50, width: 1, color: Colors.grey.shade300),
            _buildStatItem(
              'Current Weight',
              '${_weight!.toStringAsFixed(1)} kg',
              Icons.monitor_weight_outlined,
              kExercisePrimaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 32, color: iconColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kExerciseTextColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 13,
            color: kExerciseSecondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseGrid() {
    if (_exerciseDetails.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Or 3 for smaller tiles
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.2, // Adjust for desired tile shape
      ),
      itemCount: _exerciseDetails.length,
      itemBuilder: (context, index) {
        final internalKey = _exerciseDetails.keys.elementAt(index);
        final details = _exerciseDetails[internalKey]!;
        final bool isSelected = _selectedExerciseInternalKey == internalKey;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedExerciseInternalKey = internalKey;
            });
          },
          child: Card(
            elevation: isSelected ? 4.0 : 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: isSelected ? kExerciseAccentColor : Colors.grey.shade300,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            color: isSelected ? kExerciseAccentColor : kExerciseCardColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  details["icon"] as IconData,
                  size: 40,
                  color:
                      isSelected ? kExerciseCardColor : kExercisePrimaryColor,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    details["name"] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color:
                          isSelected ? kExerciseCardColor : kExerciseTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSetsSelectorCard() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: kExerciseCardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Therapeutic Sets: $_setsToPerform',
              style: GoogleFonts.lato(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: kExerciseTextColor,
              ),
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: kExercisePrimaryColor,
                inactiveTrackColor: kExercisePrimaryColor.withOpacity(0.3),
                trackShape: const RoundedRectSliderTrackShape(),
                trackHeight: 6.0,
                thumbColor: kExerciseAccentColor,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 12.0,
                ),
                overlayColor: kExerciseAccentColor.withAlpha(
                  (0.32 * 255).round(),
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 24.0,
                ),
                tickMarkShape: const RoundSliderTickMarkShape(),
                activeTickMarkColor: kExerciseAccentColor,
                inactiveTickMarkColor: kExercisePrimaryColor.withOpacity(0.5),
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                valueIndicatorColor: kExerciseAccentColor,
                valueIndicatorTextStyle: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Slider(
                value: _setsToPerform.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _setsToPerform.toString(),
                onChanged: (double value) {
                  setState(() {
                    _setsToPerform = value.round();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartWorkoutButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.play_arrow_rounded, size: 28),
        label: Text(
          'Begin Therapy Session',
          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          if (_selectedExerciseInternalKey != null) {
            final String exerciseInternalKey = _selectedExerciseInternalKey!;

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ExercisePerform(
                      targetReps: _setsToPerform,
                      initialExerciseType: exerciseInternalKey,
                    ),
              ),
            );

            if (result != null && result is Map && mounted) {
              int achievedReps = result['reps'] ?? 0;
              bool completed = result['completed'] ?? false;
              _showWorkoutCompletionSnackbar(completed, achievedReps);

              if (completed) {
                _fetchAndShowFeedback(exerciseInternalKey, achievedReps);
              }
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please select a therapeutic exercise first.',
                  style: GoogleFonts.lato(color: Colors.white),
                ),
                backgroundColor: kExerciseWarningColor,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kExercisePrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 4.0,
          shadowColor: kExercisePrimaryColor.withOpacity(0.5),
        ),
      ),
    );
  }

  void _showWorkoutCompletionSnackbar(bool completed, int achievedReps) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Therapy session ${completed ? "completed" : "ended"}. Sets: $achievedReps/$_setsToPerform',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor:
            completed ? kExerciseSuccessColor : kExerciseWarningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Future<void> _fetchAndShowFeedback(
    String exerciseName, // This is already the internal key
    int completedSets,
  ) async {
    if (!mounted) return;

    // Show loading bottom sheet first
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false, // Prevent back button dismiss
            child: Container(
              decoration: const BoxDecoration(
                color: kExerciseCardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Generating Therapeutic Feedback...',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kExercisePrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing your performance to provide personalized therapeutic recommendations.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: kExerciseSecondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: kExerciseAccentColor),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final String url = 'http://192.168.158.156:5001/feedback';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'exercise_name': exerciseName,
          'completed_sets': completedSets,
          'target_sets': _setsToPerform,
          'pregnancy_week': _pregnancyWeek ?? 0,
          'weight': _weight ?? 0.0,
        }),
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading sheet

      if (response.statusCode == 200) {
        final Map<String, dynamic> feedbackData = jsonDecode(response.body);
        _showTherapeuticFeedbackSheet(feedbackData);
      } else {
        _showErrorFeedback('Failed to generate feedback. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading sheet
      _showErrorFeedback('Error: ${e.toString()}');
    }
  }

  void _showTherapeuticFeedbackSheet(Map<String, dynamic> feedbackData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: kExerciseCardColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Therapeutic Assessment',
                          style: GoogleFonts.lato(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kExercisePrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Personalized therapeutic recommendations based on your performance',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: kExerciseSecondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (feedbackData.containsKey('feedback'))
                          _buildFeedbackSection(feedbackData['feedback']),
                        if (feedbackData.containsKey('recommendations'))
                          _buildRecommendationsSection(
                            feedbackData['recommendations'],
                          ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kExercisePrimaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Continue Therapy',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildFeedbackSection(String feedback) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kExerciseSuccessColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kExerciseSuccessColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.feedback_rounded, color: kExerciseSuccessColor),
              const SizedBox(width: 8),
              Text(
                'Performance Feedback',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kExerciseTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: kExerciseTextColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(List<dynamic> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(Icons.lightbulb_rounded, color: kExerciseAccentColor),
            const SizedBox(width: 8),
            Text(
              'Therapeutic Recommendations',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kExerciseTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recommendations
            .map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: kExerciseAccentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec.toString(),
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: kExerciseTextColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  void _showErrorFeedback(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error, style: GoogleFonts.lato(color: Colors.white)),
        backgroundColor: kExerciseWarningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}
