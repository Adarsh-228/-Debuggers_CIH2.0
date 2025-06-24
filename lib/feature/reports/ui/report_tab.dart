import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

// Define a professional color palette for medical reports
const Color kReportPrimaryColor = Color(0xFF6A1B9A); // Deep Purple
const Color kReportAccentColor = Color(0xFFFF6F00); // Orange
const Color kReportBackgroundColor = Color(0xFFF3E5F5); // Light Purple
const Color kReportCardColor = Colors.white;
const Color kReportTextColor = Color(0xFF263238); // Blue Grey Dark
const Color kReportSecondaryTextColor = Color(0xFF546E7A); // Blue Grey
const Color kReportErrorColor = Color(0xFFD32F2F); // Red
const Color kReportSuccessColor = Color(0xFF388E3C); // Green
const Color kReportWarningColor = Color(0xFFF57C00); // Orange
const Color kReportMaternalColor = Color(0xFF8E24AA); // Purple
const Color kReportPretermColor = Color(0xFF1976D2); // Blue

enum PredictionType { maternal, preterm }

class ReportTab extends StatefulWidget {
  const ReportTab({super.key});

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> with TickerProviderStateMixin {
  late TabController _tabController;

  // Maternal Risk state
  File? _maternalImageFile;
  bool _isMaternalLoading = false;
  Map<String, dynamic>? _maternalPredictionData;
  String? _maternalErrorMessage;

  // Preterm Birth state
  File? _pretermImageFile;
  bool _isPretermLoading = false;
  Map<String, dynamic>? _pretermPredictionData;
  String? _pretermErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final photosStatus = await Permission.photos.status;

    if (cameraStatus.isDenied || photosStatus.isDenied) {
      dev.log("Permissions initially denied. Will request on action.");
    }
  }

  Future<bool> _handlePermissions(ImageSource source) async {
    Permission permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;
    PermissionStatus status = await permission.status;

    if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Permission Required',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    color: kReportPrimaryColor,
                  ),
                ),
                content: Text(
                  'Please enable ${source == ImageSource.camera ? 'camera' : 'photos'} access in app settings to use this feature.',
                  style: GoogleFonts.lato(color: kReportSecondaryTextColor),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.lato(color: kReportSecondaryTextColor),
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      openAppSettings();
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: kReportPrimaryColor,
                    ),
                    child: Text('Open Settings', style: GoogleFonts.lato()),
                  ),
                ],
              ),
        );
      }
      return false;
    }

    if (status.isDenied) {
      status = await permission.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> _pickImage(PredictionType type) async {
    final ImagePicker picker = ImagePicker();
    final String title =
        type == PredictionType.maternal
            ? 'Select Maternal Health Report'
            : 'Select Preterm Birth Report';

    final XFile? image = await showModalBottomSheet<XFile>(
      context: context,
      backgroundColor: kReportCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          type == PredictionType.maternal
                              ? kReportMaternalColor
                              : kReportPretermColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(
                      Icons.camera_alt_rounded,
                      color:
                          type == PredictionType.maternal
                              ? kReportMaternalColor
                              : kReportPretermColor,
                    ),
                    title: Text(
                      'Take a Photo',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: kReportTextColor,
                      ),
                    ),
                    onTap: () async {
                      if (await _handlePermissions(ImageSource.camera)) {
                        final XFile? pickedImage = await picker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (mounted) Navigator.pop(context, pickedImage);
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.photo_library_rounded,
                      color:
                          type == PredictionType.maternal
                              ? kReportMaternalColor
                              : kReportPretermColor,
                    ),
                    title: Text(
                      'Choose from Gallery',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: kReportTextColor,
                      ),
                    ),
                    onTap: () async {
                      if (await _handlePermissions(ImageSource.gallery)) {
                        final XFile? pickedImage = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (mounted) Navigator.pop(context, pickedImage);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
    );

    if (image != null) {
      setState(() {
        if (type == PredictionType.maternal) {
          _maternalImageFile = File(image.path);
          _maternalPredictionData = null;
          _maternalErrorMessage = null;
        } else {
          _pretermImageFile = File(image.path);
          _pretermPredictionData = null;
          _pretermErrorMessage = null;
        }
      });
      await _analyzeReport(type);
    }
  }

  Future<void> _analyzeReport(PredictionType type) async {
    final File? imageFile =
        type == PredictionType.maternal
            ? _maternalImageFile
            : _pretermImageFile;
    if (imageFile == null) return;

    setState(() {
      if (type == PredictionType.maternal) {
        _isMaternalLoading = true;
        _maternalErrorMessage = null;
        _maternalPredictionData = null;
      } else {
        _isPretermLoading = true;
        _pretermErrorMessage = null;
        _pretermPredictionData = null;
      }
    });

    try {
      final String url =
          type == PredictionType.maternal
              ? 'http://192.168.158.156:5000/api/predict/maternal/image'
              : 'http://192.168.158.156:5000/api/predict/preterm/image';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      dev.log('Sending request to $url');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      dev.log('Response status: ${response.statusCode}');
      dev.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          if (type == PredictionType.maternal) {
            _maternalPredictionData = data;
          } else {
            _pretermPredictionData = data;
          }
        });
      } else {
        dev.log('API Error Response: ${response.body}');
        String errorMsg =
            'Failed to analyze ${type == PredictionType.maternal ? 'maternal risk' : 'preterm birth risk'}. Status: ${response.statusCode}.';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          if (errorData.containsKey('detail')) {
            errorMsg += ' ${errorData['detail']}';
          }
        } catch (_) {
          errorMsg += ' Could not parse error detail.';
        }
        throw Exception(errorMsg);
      }
    } catch (e, s) {
      dev.log('Error analyzing ${type.name} risk:', error: e, stackTrace: s);
      setState(() {
        if (type == PredictionType.maternal) {
          _maternalErrorMessage = e.toString().replaceFirst('Exception: ', '');
        } else {
          _pretermErrorMessage = e.toString().replaceFirst('Exception: ', '');
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          if (type == PredictionType.maternal) {
            _isMaternalLoading = false;
          } else {
            _isPretermLoading = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kReportPrimaryColor,
                  kReportPrimaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Title Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.analytics_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medical Reports',
                                style: GoogleFonts.lato(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'AI-Powered Risk Analysis',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Custom Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: kReportPrimaryColor,
                      unselectedLabelColor: Colors.white,
                      labelStyle: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: GoogleFonts.lato(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.pregnant_woman_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text('Maternal'),
                            ],
                          ),
                        ),
                        Tab(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.child_care_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text('Preterm'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildMaternalRiskTab(), _buildPretermBirthTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaternalRiskTab() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModernInfoCard(
              'Maternal Health Risk Assessment',
              'Upload medical reports to analyze maternal health risks during pregnancy. Our AI analyzes vital signs and health indicators.',
              Icons.favorite_rounded,
              kReportMaternalColor,
            ),
            const SizedBox(height: 24),
            _buildModernImagePicker(PredictionType.maternal),
            const SizedBox(height: 24),
            if (_isMaternalLoading)
              _buildModernLoadingCard(
                'Analyzing Maternal Risk...',
                kReportMaternalColor,
              )
            else if (_maternalErrorMessage != null)
              _buildModernErrorCard(
                _maternalErrorMessage!,
                () => _analyzeReport(PredictionType.maternal),
              )
            else if (_maternalPredictionData != null)
              _buildMaternalPredictionResults(_maternalPredictionData!)
            else
              _buildModernPromptCard(
                'Ready to Analyze',
                'Upload a maternal health report to begin risk assessment.',
                Icons.cloud_upload_rounded,
                kReportMaternalColor,
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPretermBirthTab() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModernInfoCard(
              'Preterm Birth Risk Assessment',
              'Upload medical reports to predict preterm birth risk. Our AI analyzes multiple clinical factors and biomarkers.',
              Icons.baby_changing_station_rounded,
              kReportPretermColor,
            ),
            const SizedBox(height: 24),
            _buildModernImagePicker(PredictionType.preterm),
            const SizedBox(height: 24),
            if (_isPretermLoading)
              _buildModernLoadingCard(
                'Analyzing Preterm Birth Risk...',
                kReportPretermColor,
              )
            else if (_pretermErrorMessage != null)
              _buildModernErrorCard(
                _pretermErrorMessage!,
                () => _analyzeReport(PredictionType.preterm),
              )
            else if (_pretermPredictionData != null)
              _buildPretermPredictionResults(_pretermPredictionData!)
            else
              _buildModernPromptCard(
                'Ready to Analyze',
                'Upload a preterm birth assessment report to analyze delivery timing risks.',
                Icons.schedule_rounded,
                kReportPretermColor,
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kReportTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: kReportSecondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kReportTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: kReportSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernImagePicker(PredictionType type) {
    final File? imageFile =
        type == PredictionType.maternal
            ? _maternalImageFile
            : _pretermImageFile;
    final Color primaryColor =
        type == PredictionType.maternal
            ? kReportMaternalColor
            : kReportPretermColor;
    final String title =
        type == PredictionType.maternal
            ? 'Upload Maternal Report'
            : 'Upload Preterm Report';
    final IconData icon =
        type == PredictionType.maternal
            ? Icons.pregnant_woman_rounded
            : Icons.child_care_rounded;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => _pickImage(type),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: imageFile != null ? null : Colors.white,
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child:
                  imageFile != null
                      ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.file(imageFile, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () => _pickImage(type),
                                icon: Icon(
                                  Icons.edit_rounded,
                                  color: primaryColor,
                                  size: 20,
                                ),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                        ],
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(icon, size: 48, color: primaryColor),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to use camera or gallery',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: kReportSecondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Camera',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.photo_library_rounded,
                                  size: 16,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Gallery',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageDisplayAndPicker(PredictionType type) {
    final File? imageFile =
        type == PredictionType.maternal
            ? _maternalImageFile
            : _pretermImageFile;
    final Color primaryColor =
        type == PredictionType.maternal
            ? kReportMaternalColor
            : kReportPretermColor;
    final String title =
        type == PredictionType.maternal
            ? 'Upload Maternal Report'
            : 'Upload Preterm Report';
    final IconData icon =
        type == PredictionType.maternal
            ? Icons.pregnant_woman_rounded
            : Icons.child_care_rounded;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _pickImage(type),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: primaryColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              imageFile != null
                  ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(imageFile, fit: BoxFit.cover),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: FloatingActionButton.small(
                          onPressed: () => _pickImage(type),
                          backgroundColor: kReportAccentColor,
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                          ),
                          heroTag: '${type.name}PickImageFab',
                        ),
                      ),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 60,
                        color: primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        'Use camera or gallery',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: kReportSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildModernLoadingCard(String message, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(color),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kReportTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we analyze your report...',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: kReportSecondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernErrorCard(String message, VoidCallback onRetry) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: kReportErrorColor.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: kReportErrorColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kReportErrorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: kReportErrorColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Analysis Failed',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kReportErrorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: kReportSecondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    kReportErrorColor,
                    kReportErrorColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernPromptCard(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 64, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kReportTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: kReportSecondaryTextColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(String message, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(color),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: kReportSecondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message, VoidCallback onRetry) {
    return Card(
      color: kReportErrorColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: kReportErrorColor, size: 40),
            const SizedBox(height: 8),
            Text(
              'Analysis Failed',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kReportErrorColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: kReportErrorColor.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: kReportErrorColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialPrompt(String message, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 60,
              color: kReportSecondaryTextColor.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: kReportSecondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaternalPredictionResults(Map<String, dynamic> data) {
    final inputFeatures = data['input_features'] as Map<String, dynamic>?;
    final predictions = data['predictions'] as Map<String, dynamic>?;
    final recommendedModel = data['recommended_model'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (inputFeatures != null)
          _buildMaternalInputFeaturesCard(inputFeatures),
        if (predictions != null)
          _buildMaternalPredictionsCard(predictions, recommendedModel),
      ],
    );
  }

  Widget _buildPretermPredictionResults(Map<String, dynamic> data) {
    final inputData = data['input_data'] as Map<String, dynamic>?;
    final predictions = data['predictions'] as Map<String, dynamic>?;
    final recommendedModel = data['recommended_model'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (inputData != null) _buildPretermInputDataCard(inputData),
        if (predictions != null)
          _buildPretermPredictionsCard(predictions, recommendedModel),
      ],
    );
  }

  Widget _buildMaternalInputFeaturesCard(Map<String, dynamic> features) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.list_alt_rounded,
                  color: kReportMaternalColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Extracted Maternal Health Features',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kReportMaternalColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...features.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatMaternalFeatureName(entry.key),
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.w600,
                        color: kReportTextColor,
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: GoogleFonts.lato(color: kReportSecondaryTextColor),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPretermInputDataCard(Map<String, dynamic> inputData) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.data_exploration_rounded,
                  color: kReportPretermColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Extracted Clinical Data',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kReportPretermColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...inputData.entries.take(8).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatPretermFeatureName(entry.key),
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w600,
                          color: kReportTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: GoogleFonts.lato(
                        color: kReportSecondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (inputData.length > 8)
              ExpansionTile(
                title: Text(
                  'View All ${inputData.length - 8} More Parameters',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: kReportPretermColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children:
                    inputData.entries.skip(8).map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8.0,
                          left: 16,
                          right: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                _formatPretermFeatureName(entry.key),
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w600,
                                  color: kReportTextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              entry.value.toString(),
                              style: GoogleFonts.lato(
                                color: kReportSecondaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaternalPredictionsCard(
    Map<String, dynamic> predictions,
    String? recommendedModel,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.psychology_rounded,
                  color: kReportMaternalColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Maternal Risk Predictions',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kReportMaternalColor,
                  ),
                ),
              ],
            ),
            if (recommendedModel != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kReportMaternalColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Recommended: $recommendedModel',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: kReportMaternalColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const Divider(height: 20),
            ...predictions.entries.map((entry) {
              final modelName = entry.key;
              final prediction = entry.value as Map<String, dynamic>;
              final riskLevel = prediction['prediction'] as String;
              final probability =
                  prediction['probability'] as Map<String, dynamic>?;

              return _buildMaternalModelPredictionItem(
                modelName,
                riskLevel,
                probability,
                modelName == recommendedModel,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPretermPredictionsCard(
    Map<String, dynamic> predictions,
    String? recommendedModel,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.timeline_rounded,
                  color: kReportPretermColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Preterm Birth Predictions',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kReportPretermColor,
                  ),
                ),
              ],
            ),
            if (recommendedModel != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kReportPretermColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Recommended: $recommendedModel',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: kReportPretermColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const Divider(height: 20),
            ...predictions.entries.map((entry) {
              final modelName = entry.key;
              final prediction = entry.value as Map<String, dynamic>;
              final predictionResult = prediction['prediction'] as String;
              final probability = prediction['probability'] as double?;
              final riskScore = prediction['risk_score'] as int?;

              return _buildPretermModelPredictionItem(
                modelName,
                predictionResult,
                probability,
                riskScore,
                modelName == recommendedModel,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaternalModelPredictionItem(
    String modelName,
    String riskLevel,
    Map<String, dynamic>? probability,
    bool isRecommended,
  ) {
    final riskColor = _getRiskColor(riskLevel);
    final riskIcon = _getRiskIcon(riskLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isRecommended ? kReportMaternalColor : Colors.grey.shade300,
          width: isRecommended ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isRecommended ? kReportMaternalColor.withOpacity(0.05) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                modelName,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kReportTextColor,
                ),
              ),
              if (isRecommended) ...[
                const SizedBox(width: 8),
                Icon(Icons.star_rounded, color: kReportMaternalColor, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(riskIcon, color: riskColor, size: 20),
              const SizedBox(width: 8),
              Text(
                riskLevel.toUpperCase(),
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),
            ],
          ),
          if (probability != null) ...[
            const SizedBox(height: 8),
            ...probability.entries.map((entry) {
              final prob = ((entry.value as double) * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: kReportSecondaryTextColor,
                      ),
                    ),
                    Text(
                      '$prob%',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getRiskColor(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildPretermModelPredictionItem(
    String modelName,
    String prediction,
    double? probability,
    int? riskScore,
    bool isRecommended,
  ) {
    final Color predictionColor =
        prediction == 'Preterm Birth' ? kReportErrorColor : kReportSuccessColor;
    final IconData predictionIcon =
        prediction == 'Preterm Birth' ? Icons.warning : Icons.check_circle;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isRecommended ? kReportPretermColor : Colors.grey.shade300,
          width: isRecommended ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isRecommended ? kReportPretermColor.withOpacity(0.05) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                modelName,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kReportTextColor,
                ),
              ),
              if (isRecommended) ...[
                const SizedBox(width: 8),
                Icon(Icons.star_rounded, color: kReportPretermColor, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(predictionIcon, color: predictionColor, size: 20),
              const SizedBox(width: 8),
              Text(
                prediction.toUpperCase(),
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: predictionColor,
                ),
              ),
            ],
          ),
          if (probability != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Confidence',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: kReportSecondaryTextColor,
                  ),
                ),
                Text(
                  '${(probability * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: predictionColor,
                  ),
                ),
              ],
            ),
          ],
          if (riskScore != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Risk Score',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: kReportSecondaryTextColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: predictionColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    riskScore.toString(),
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: predictionColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low risk':
        return kReportSuccessColor;
      case 'mid risk':
        return kReportWarningColor;
      case 'high risk':
        return kReportErrorColor;
      default:
        return kReportSecondaryTextColor;
    }
  }

  IconData _getRiskIcon(String risk) {
    switch (risk.toLowerCase()) {
      case 'low risk':
        return Icons.check_circle_outline;
      case 'mid risk':
        return Icons.warning_outlined;
      case 'high risk':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _formatMaternalFeatureName(String key) {
    final Map<String, String> featureNames = {
      'Age': 'Age (years)',
      'BS': 'Blood Sugar (mmol/L)',
      'BodyTemp': 'Body Temperature (°F)',
      'DiastolicBP': 'Diastolic BP (mmHg)',
      'HeartRate': 'Heart Rate (bpm)',
      'SystolicBP': 'Systolic BP (mmHg)',
    };
    return featureNames[key] ?? key;
  }

  String _formatPretermFeatureName(String key) {
    final Map<String, String> featureNames = {
      'Age': 'Age',
      'BMI': 'BMI',
      'CRP': 'CRP (mg/L)',
      'Education [0-primary. 1-vocational. 2-higher]': 'Education Level',
      'Gestational diabetes mellitus [0-no. 1-type 1. 2-type 2]':
          'Gestational Diabetes',
      'Gestational hypothyroidism [0-no.-1yes]': 'Hypothyroidism',
      'HCT [%]': 'Hematocrit (%)',
      'Hb [g/dl]': 'Hemoglobin (g/dl)',
      'Height': 'Height (cm)',
      'History of caesarean section [0-no.1-yes]': 'Previous C-Section',
      'History of preterm labour [0-no.1-yes]': 'Previous Preterm',
      'History of surgical delivery [0-no.1-yes]': 'Surgical Delivery History',
      'Marital status [0-single. 1-married]': 'Marital Status',
      'No. of deliveries': 'Deliveries',
      'No. of pregnancy': 'Pregnancies',
      'PLT [G/l]': 'Platelets (G/l)',
      'Smoking [0-no.1-yes]': 'Smoking',
      'Type of delivery [0-vaginal.1-c-section]': 'Delivery Type',
      'WBC [G/l]': 'WBC (G/l)',
      'Week of delivery': 'Delivery Week',
      'Week of sample collection': 'Sample Week',
      'Weight': 'Weight (kg)',
    };
    return featureNames[key] ?? key.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }
}
