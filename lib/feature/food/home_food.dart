import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/feature/food/image_scan_screen.dart';
import 'package:hackathon/feature/food/product/ui/product_screen.dart';
import 'package:hackathon/feature/logs/ui/meal_log_screen.dart';
import 'package:hackathon/feature/logs/ui/meal_history_screen.dart';

// Use consistent app color scheme
const Color kFoodPrimaryColor = Color(
  0xFF6A1B9A,
); // Deep Purple - consistent with app
const Color kFoodAccentColor = Color(0xFFEC407A); // Pink accent
const Color kFoodBackgroundColor = Color(0xFFF3E5F5); // Light purple background
const Color kFoodCardColor = Colors.white;
const Color kFoodTextColor = Color(0xFF263238); // Blue Grey Dark
const Color kFoodSecondaryTextColor = Color(0xFF546E7A); // Blue Grey
const Color kFoodSuccessColor = Color(0xFF388E3C); // Green
const Color kFoodWarningColor = Color(0xFFF57C00); // Orange

class HomeFood extends StatefulWidget {
  const HomeFood({super.key});

  @override
  State<HomeFood> createState() => _HomeFoodState();
}

class _HomeFoodState extends State<HomeFood> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Food and Nutrition Analyser',
                style: GoogleFonts.lato(
                  fontSize: screenWidth < 350 ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'AI-powered pregnancy safety assessment for your diet',
                style: GoogleFonts.lato(
                  fontSize: screenWidth < 350 ? 10 : 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: screenHeight < 600 ? 60 : 70,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;
            final padding = availableWidth * 0.05; // 5% padding

            return Padding(
              padding: EdgeInsets.all(padding),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: padding * 0.8,
                mainAxisSpacing: padding * 0.8,
                childAspectRatio: availableWidth > 400 ? 1.1 : 1.0,
                children: [
                  _buildFeatureTile(
                    title: 'Scan Meal',
                    icon: Icons.camera_alt_rounded,
                    color: Colors.green,
                    constraints: constraints,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImageScanScreen(),
                          ),
                        ),
                  ),
                  _buildFeatureTile(
                    title: 'Scan Barcode',
                    icon: Icons.qr_code_scanner_rounded,
                    color: Colors.blue,
                    constraints: constraints,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductScreen(),
                          ),
                        ),
                  ),
                  _buildFeatureTile(
                    title: 'Log Meal',
                    icon: Icons.edit_note_rounded,
                    color: Colors.orange,
                    constraints: constraints,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MealLogScreen(),
                          ),
                        ),
                  ),
                  _buildFeatureTile(
                    title: 'Meal History',
                    icon: Icons.history_rounded,
                    color: Colors.purple,
                    constraints: constraints,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MealHistoryScreen(),
                          ),
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required String title,
    required IconData icon,
    required Color color,
    required BoxConstraints constraints,
    required VoidCallback onTap,
  }) {
    final tileWidth =
        (constraints.maxWidth - 60) / 2; // Account for padding and spacing
    final iconSize = tileWidth * 0.2; // 20% of tile width
    final fontSize = tileWidth * 0.1; // 10% of tile width

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: tileWidth,
          padding: EdgeInsets.all(tileWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.all(iconSize * 0.3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: iconSize.clamp(24, 40)),
                ),
              ),
              SizedBox(height: tileWidth * 0.05),
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: fontSize.clamp(12, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
