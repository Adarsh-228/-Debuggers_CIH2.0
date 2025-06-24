import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/models/meal_log_model.dart';
import '../cubit/meal_log_cubit.dart';

// Use consistent app color scheme
const Color kMealHistoryPrimaryColor = Color(0xFF6A1B9A); // Deep Purple
const Color kMealHistoryAccentColor = Color(0xFFEC407A); // Pink accent
const Color kMealHistoryBackgroundColor = Color(0xFFF3E5F5); // Light purple
const Color kMealHistoryCardColor = Colors.white;
const Color kMealHistoryTextColor = Color(0xFF263238); // Blue Grey Dark
const Color kMealHistorySecondaryTextColor = Color(0xFF546E7A); // Blue Grey

class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  List<MealLogModel> _allMealLogs = [];
  Map<String, List<MealLogModel>> _groupedMealLogs = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMealHistory();
  }

  Future<void> _loadMealHistory() async {
    setState(() => _isLoading = true);

    try {
      final cubit = context.read<MealLogCubit>();
      final logs = await cubit.getMealLogs();
      setState(() {
        _allMealLogs = logs;
        _groupedMealLogs = _groupMealLogsByDate(logs);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading meal history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, List<MealLogModel>> _groupMealLogsByDate(
    List<MealLogModel> logs,
  ) {
    final grouped = <String, List<MealLogModel>>{};

    for (final log in logs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(log.timestamp);
      grouped.putIfAbsent(dateKey, () => []).add(log);
    }

    // Sort logs within each date by meal type order
    for (final dateKey in grouped.keys) {
      grouped[dateKey]!.sort((a, b) {
        const order = [
          MealType.breakfast,
          MealType.lunch,
          MealType.snacks,
          MealType.dinner,
        ];
        return order.indexOf(a.type).compareTo(order.indexOf(b.type));
      });
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Meal History',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: kMealHistoryTextColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: kMealHistoryPrimaryColor),
        actions: [
          if (_allMealLogs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: _showClearHistoryDialog,
              tooltip: 'Clear All History',
            ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : _allMealLogs.isEmpty
              ? _buildEmptyState()
              : _buildMealHistoryList(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(kMealHistoryPrimaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading meal history...',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: kMealHistorySecondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kMealHistoryPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 64,
                color: kMealHistoryPrimaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Meal History Yet',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kMealHistoryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start logging your meals to see your history here!',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: kMealHistorySecondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Log Your First Meal',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: kMealHistoryPrimaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealHistoryList() {
    final sortedDates =
        _groupedMealLogs.keys.toList()
          ..sort((a, b) => b.compareTo(a)); // Most recent first

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final mealsForDate = _groupedMealLogs[date]!;

        return _buildDateGroup(date, mealsForDate);
      },
    );
  }

  Widget _buildDateGroup(String date, List<MealLogModel> meals) {
    final parsedDate = DateTime.parse(date);
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == date;
    final isYesterday =
        DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now().subtract(const Duration(days: 1))) ==
        date;

    String displayDate;
    if (isToday) {
      displayDate = 'Today';
    } else if (isYesterday) {
      displayDate = 'Yesterday';
    } else {
      displayDate = DateFormat('EEEE, MMM d').format(parsedDate);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kMealHistoryPrimaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: kMealHistoryPrimaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  displayDate,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kMealHistoryPrimaryColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kMealHistoryPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${meals.length} meal${meals.length != 1 ? 's' : ''}',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...meals.map((meal) => _buildMealLogItem(meal)).toList(),
        ],
      ),
    );
  }

  Widget _buildMealLogItem(MealLogModel meal) {
    final colorMap = {
      MealType.breakfast: Colors.amber.shade700,
      MealType.lunch: Colors.green.shade600,
      MealType.snacks: Colors.purple.shade400,
      MealType.dinner: Colors.indigo.shade600,
    };

    final iconMap = {
      MealType.breakfast: Icons.breakfast_dining_rounded,
      MealType.lunch: Icons.lunch_dining_rounded,
      MealType.snacks: Icons.cookie_rounded,
      MealType.dinner: Icons.dinner_dining_rounded,
    };

    final color = colorMap[meal.type]!;
    final icon = iconMap[meal.type]!;
    final timeFormatted = DateFormat('h:mm a').format(meal.timestamp);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  meal.type.name.capitalize(),
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  timeFormatted,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: kMealHistorySecondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  meal.items
                      .map(
                        (item) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.quantity != null
                                ? '${item.name} (${item.quantity})'
                                : item.name,
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: kMealHistoryTextColor,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Clear Meal History',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                color: kMealHistoryTextColor,
              ),
            ),
            content: Text(
              'Are you sure you want to delete all meal history? This action cannot be undone.',
              style: GoogleFonts.lato(color: kMealHistorySecondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.lato(
                    color: kMealHistorySecondaryTextColor,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _clearAllHistory();
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Clear All',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _clearAllHistory() async {
    try {
      final cubit = context.read<MealLogCubit>();
      await cubit.clearLogs();
      await _loadMealHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Meal history cleared successfully',
              style: GoogleFonts.lato(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
