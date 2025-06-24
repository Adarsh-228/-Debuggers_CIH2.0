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
      final hour = DateTime.now().hour;
      String timeOfDay = "afternoon";
      if (hour < 12) {
        timeOfDay = "morning";
      } else if (hour >= 18) {
        timeOfDay = "evening";
      }

      final requestBody = {
        "week_pregnancy": _pregnancyWeek,
        "n_sets": completedSets,
        "time": timeOfDay,
        "name": exerciseName, // Use the direct internal key
      };

      final response = await http.post(
        Uri.parse('http://192.168.158.156:8000/feedback_gemini'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Close loading sheet safely
      if (mounted && Navigator.canPop(context)) {
        try {
          Navigator.pop(context);
        } catch (e) {
          debugPrint('Error closing loading sheet: $e');
        }
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Try to parse as structured JSON first
        Map<String, dynamic>? structuredFeedback;
        try {
          if (responseData['feedback'] is String) {
            // Try to parse the feedback string as JSON
            final feedbackString = responseData['feedback'] as String;
            final finalAnswerStart = feedbackString.indexOf('FINAL ANSWER:');
            String cleanFeedback = feedbackString;
            if (finalAnswerStart != -1) {
              cleanFeedback =
                  feedbackString
                      .substring(finalAnswerStart + 'FINAL ANSWER:'.length)
                      .replaceAll('```json', '')
                      .replaceAll('```', '')
                      .trim();
            }
            structuredFeedback = jsonDecode(cleanFeedback);
          } else if (responseData['feedback'] is Map<String, dynamic>) {
            // Feedback is already a structured object
            structuredFeedback =
                responseData['feedback'] as Map<String, dynamic>;
          } else if (responseData.containsKey('exercise_analysis') ||
              responseData.containsKey('technical_details') ||
              responseData.containsKey('safety_guidelines') ||
              responseData.containsKey('recommendations') ||
              responseData.containsKey('benefits_and_progression') ||
              responseData.containsKey('summary')) {
            // The response data itself IS the structured feedback (no 'feedback' wrapper)
            structuredFeedback = responseData;
          } else {
            structuredFeedback = null; // Will fall back to simple text display
          }
        } catch (e) {
          // If JSON parsing fails, fall back to plain text
          structuredFeedback = null;
          debugPrint('JSON parsing error: $e');
        }

        // Small delay to ensure smooth transition
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          try {
            if (structuredFeedback != null) {
              _showDetailedFeedbackModal(structuredFeedback);
            } else {
              // Fallback to simple text display
              final feedback =
                  _getSafeString(responseData['feedback']) ??
                  'No feedback available';
              _showFeedbackModal(feedback);
            }
          } catch (e) {
            debugPrint('Error showing feedback modal: $e');
            _showErrorSnackbar('Failed to display feedback');
          }
        }
      } else {
        if (mounted) {
          _showErrorSnackbar(
            'Failed to get feedback. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Close loading sheet if open
        if (Navigator.canPop(context)) {
          try {
            Navigator.pop(context);
          } catch (navError) {
            debugPrint('Error closing loading sheet in catch: $navError');
          }
        }
        _showErrorSnackbar('Error fetching feedback: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.lato(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint('Error showing snackbar: $e');
    }
  }

  // Helper method to safely convert any value to string, handling nulls
  String? _getSafeString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return value.isEmpty ? null : value;
    }
    final stringValue = value.toString();
    return stringValue == 'null' || stringValue.isEmpty ? null : stringValue;
  }

  // Helper method to safely get list from dynamic value
  List<dynamic>? _getSafeList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value;
    return null;
  }

  void _showDetailedFeedbackModal(Map<String, dynamic> feedbackData) {
    if (!mounted) return;

    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder:
            (context) => Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: kExerciseBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.insights,
                          color: kExercisePrimaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Therapeutic Analysis',
                          style: GoogleFonts.lato(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kExercisePrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [..._buildSafeSections(feedbackData)],
                      ),
                    ),
                  ),
                  // Bottom button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: ElevatedButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          try {
                            Navigator.pop(context);
                          } catch (e) {
                            debugPrint('Error closing feedback modal: $e');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kExerciseAccentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        minimumSize: const Size(200, 50),
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
      );
    } catch (e) {
      debugPrint('Error showing detailed feedback modal: $e');
      _showErrorSnackbar('Failed to display therapeutic analysis');
    }
  }

  // Helper method to safely build sections with individual error handling
  List<Widget> _buildSafeSections(Map<String, dynamic> feedbackData) {
    List<Widget> sections = [];

    try {
      // Exercise Analysis Section
      if (feedbackData['exercise_analysis'] != null &&
          feedbackData['exercise_analysis'] is Map<String, dynamic>) {
        sections.add(
          _buildAnalysisSection(
            feedbackData['exercise_analysis'] as Map<String, dynamic>,
          ),
        );
        sections.add(const SizedBox(height: 16));
      }
    } catch (e) {
      debugPrint('Error in analysis section: $e');
      sections.add(_buildErrorCard('Performance Analysis'));
      sections.add(const SizedBox(height: 16));
    }

    try {
      // Technical Details Section
      if (feedbackData['technical_details'] != null &&
          feedbackData['technical_details'] is Map<String, dynamic>) {
        sections.add(
          _buildTechnicalDetailsSection(
            feedbackData['technical_details'] as Map<String, dynamic>,
          ),
        );
        sections.add(const SizedBox(height: 16));
      }
    } catch (e) {
      debugPrint('Error in technical details section: $e');
      sections.add(_buildErrorCard('Exercise Details'));
      sections.add(const SizedBox(height: 16));
    }

    try {
      // Safety Guidelines Section
      if (feedbackData['safety_guidelines'] != null &&
          feedbackData['safety_guidelines'] is Map<String, dynamic>) {
        sections.add(
          _buildSafetySection(
            feedbackData['safety_guidelines'] as Map<String, dynamic>,
          ),
        );
        sections.add(const SizedBox(height: 16));
      }
    } catch (e) {
      debugPrint('Error in safety section: $e');
      sections.add(_buildErrorCard('Safety Guidelines'));
      sections.add(const SizedBox(height: 16));
    }

    try {
      // Recommendations Section
      if (feedbackData['recommendations'] != null) {
        if (feedbackData['recommendations'] is Map<String, dynamic>) {
          sections.add(
            _buildRecommendationsSection(
              feedbackData['recommendations'] as Map<String, dynamic>,
            ),
          );
        } else if (feedbackData['recommendations'] is List) {
          sections.add(
            _buildRecommendationsListSection(
              feedbackData['recommendations'] as List<dynamic>,
            ),
          );
        }
        sections.add(const SizedBox(height: 16));
      }
    } catch (e) {
      debugPrint('Error in recommendations section: $e');
      sections.add(_buildErrorCard('Recommendations'));
      sections.add(const SizedBox(height: 16));
    }

    try {
      // Benefits Section
      if (feedbackData['benefits_and_progression'] != null &&
          feedbackData['benefits_and_progression'] is Map<String, dynamic>) {
        sections.add(
          _buildBenefitsSection(
            feedbackData['benefits_and_progression'] as Map<String, dynamic>,
          ),
        );
        sections.add(const SizedBox(height: 16));
      }
    } catch (e) {
      debugPrint('Error in benefits section: $e');
      sections.add(_buildErrorCard('Benefits & Progression'));
      sections.add(const SizedBox(height: 16));
    }

    try {
      // Summary Section
      if (feedbackData['summary'] != null &&
          feedbackData['summary'] is Map<String, dynamic>) {
        sections.add(
          _buildSummarySection(feedbackData['summary'] as Map<String, dynamic>),
        );
        sections.add(const SizedBox(height: 16));
      }
    } catch (e) {
      debugPrint('Error in summary section: $e');
      sections.add(_buildErrorCard('Summary'));
      sections.add(const SizedBox(height: 16));
    }

    // Show a message if no valid sections were built
    if (sections.isEmpty) {
      sections.add(_buildFallbackCard());
    }

    sections.add(const SizedBox(height: 32));
    return sections;
  }

  Widget _buildErrorCard(String sectionName) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: kExerciseCardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: kExerciseWarningColor),
            const SizedBox(width: 8),
            Text(
              'Error loading $sectionName',
              style: GoogleFonts.lato(
                fontSize: 16,
                color: kExerciseSecondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: kExerciseCardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: kExerciseSecondaryTextColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Therapy session completed successfully!',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kExerciseTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analysis data is being processed. Please try again later for detailed insights.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: kExerciseSecondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackModal(String feedbackContent) {
    if (!mounted) return;

    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder:
            (context) => Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: const BoxDecoration(
                color: kExerciseCardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    'Therapeutic Insights ✨',
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kExercisePrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        feedbackContent,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: kExerciseTextColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          try {
                            Navigator.pop(context);
                          } catch (e) {
                            debugPrint('Error closing feedback modal: $e');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kExerciseAccentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
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
      );
    } catch (e) {
      debugPrint('Error showing feedback modal: $e');
      _showErrorSnackbar('Failed to display therapeutic insights');
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget content,
    Color? iconColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: kExerciseCardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor ?? kExercisePrimaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kExerciseTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(Map<String, dynamic> analysis) {
    try {
      return _buildSectionCard(
        title: 'Performance Analysis',
        icon: Icons.analytics,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'Exercise',
              _getSafeString(analysis['exercise_name']) ?? 'N/A',
            ),
            _buildInfoRow(
              'Sets Performed',
              _getSafeString(analysis['user_performed_sets']) ?? 'N/A',
            ),
            _buildInfoRow(
              'Recommended Sets',
              _getSafeString(analysis['recommended_sets']) ?? 'N/A',
            ),
            if (_getSafeString(analysis['sets_comparison']) != null) ...[
              const SizedBox(height: 8),
              Text(
                'Performance Notes:',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kExerciseTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getSafeString(analysis['sets_comparison']) ?? '',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: kExerciseSecondaryTextColor,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error building analysis section: $e');
      return _buildErrorCard('Performance Analysis');
    }
  }

  Widget _buildTechnicalDetailsSection(Map<String, dynamic> technical) {
    try {
      return _buildSectionCard(
        title: 'Exercise Details',
        icon: Icons.fitness_center,
        content: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDetailChip(
                    'Intensity',
                    _getSafeString(technical['intensity_level']) ?? 'N/A',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDetailChip(
                    'Level',
                    _getSafeString(technical['fitness_level_required']) ??
                        'N/A',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDetailChip(
                    'Muscles',
                    _getSafeString(technical['primary_muscles']) ?? 'N/A',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDetailChip(
                    'Trimester',
                    _getSafeString(technical['trimester']) ?? 'N/A',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error building technical details section: $e');
      return _buildErrorCard('Exercise Details');
    }
  }

  Widget _buildSafetySection(Map<String, dynamic> safety) {
    try {
      return _buildSectionCard(
        title: 'Safety Guidelines',
        icon: Icons.security,
        iconColor: kExerciseWarningColor,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_getSafeString(safety['safety_tips']) != null) ...[
              _buildSafetyItem(
                Icons.tips_and_updates,
                'Safety Tips',
                _getSafeString(safety['safety_tips']) ?? '',
                kExerciseSuccessColor,
              ),
              const SizedBox(height: 12),
            ],
            if (_getSafeString(safety['contraindications']) != null) ...[
              _buildSafetyItem(
                Icons.warning,
                'Contraindications',
                _getSafeString(safety['contraindications']) ?? '',
                kExerciseWarningColor,
              ),
            ],
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error building safety section: $e');
      return _buildErrorCard('Safety Guidelines');
    }
  }

  Widget _buildRecommendationsSection(Map<String, dynamic> recommendations) {
    try {
      return _buildSectionCard(
        title: 'Recommendations',
        icon: Icons.lightbulb,
        iconColor: kExerciseAccentColor,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_getSafeString(recommendations['next_week_adjustments']) !=
                null) ...[
              _buildRecommendationItem(
                Icons.trending_up,
                'Next Week',
                _getSafeString(recommendations['next_week_adjustments']) ?? '',
              ),
              const SizedBox(height: 12),
            ],
            if (_getSafeString(recommendations['suggested_modifications']) !=
                null) ...[
              _buildRecommendationItem(
                Icons.build,
                'Modifications',
                _getSafeString(recommendations['suggested_modifications']) ??
                    '',
              ),
            ],
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error building recommendations section: $e');
      return _buildErrorCard('Recommendations');
    }
  }

  Widget _buildRecommendationsListSection(List<dynamic> recommendations) {
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

  Widget _buildBenefitsSection(Map<String, dynamic> benefits) {
    try {
      return _buildSectionCard(
        title: 'Benefits & Progression',
        icon: Icons.trending_up,
        iconColor: kExerciseSuccessColor,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_getSafeString(benefits['exercise_benefits']) != null) ...[
              _buildBenefitItem(
                'Exercise Benefits',
                _getSafeString(benefits['exercise_benefits']) ?? '',
              ),
              const SizedBox(height: 8),
            ],
            if (_getSafeString(benefits['postpartum_relevance']) != null) ...[
              _buildBenefitItem(
                'Postpartum Benefits',
                _getSafeString(benefits['postpartum_relevance']) ?? '',
              ),
            ],
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error building benefits section: $e');
      return _buildErrorCard('Benefits & Progression');
    }
  }

  Widget _buildSummarySection(Map<String, dynamic> summary) {
    try {
      return _buildSectionCard(
        title: 'Summary',
        icon: Icons.summarize,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_getSafeString(summary['overall_assessment']) != null) ...[
              Text(
                _getSafeString(summary['overall_assessment']) ?? '',
                style: GoogleFonts.lato(
                  fontSize: 15,
                  color: kExerciseTextColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_getSafeList(summary['key_points']) != null) ...[
              Text(
                'Key Points:',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kExerciseTextColor,
                ),
              ),
              const SizedBox(height: 8),
              ...(_getSafeList(summary['key_points']) ?? []).map((point) {
                final pointText = _getSafeString(point);
                if (pointText == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: kExerciseSuccessColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pointText,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: kExerciseSecondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error building summary section: $e');
      return _buildErrorCard('Summary');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kExerciseTextColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: kExerciseSecondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kExerciseBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kExercisePrimaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kExerciseSecondaryTextColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: kExerciseTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyItem(
    IconData icon,
    String title,
    String content,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kExerciseTextColor,
                ),
              ),
              Text(
                content,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: kExerciseSecondaryTextColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(IconData icon, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kExerciseAccentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kExerciseAccentColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: kExerciseAccentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kExerciseTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: kExerciseSecondaryTextColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.star, size: 16, color: kExerciseSuccessColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kExerciseTextColor,
                ),
              ),
              Text(
                content,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: kExerciseSecondaryTextColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
