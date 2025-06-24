# 🤱 Garbh - Comprehensive Pregnancy Wellness App

**Garbh** is an AI-powered Flutter application designed to support expecting mothers throughout their pregnancy journey. The app combines cutting-edge technology with healthcare expertise to provide personalized nutrition tracking, exercise guidance, meal analysis, and interactive wellness features.

## 🌟 Key Features

### 🍎 **Smart Food & Nutrition Tracking**
- **AI-Powered Food Scanning**: Use your camera to instantly identify and analyze food items
- **OpenFoodFacts Integration**: Get detailed nutritional information for thousands of products
- **Barcode Scanner**: Quick product identification via barcode scanning
- **Meal Logging**: Track breakfast, lunch, dinner, and snacks with detailed analytics
- **Nutritional Analysis**: AI-generated insights on nutritional balance, caloric intake, and meal suggestions

### 🏃‍♀️ **Interactive Exercise System**
- **Real-time Pose Detection**: Advanced computer vision for exercise form analysis
- **Socket-based Exercise Tracking**: Live feedback during workouts
- **Pregnancy-Safe Workouts**: Tailored exercise routines for different pregnancy stages
- **Rep Counting**: Automated repetition counting for various exercises

### 🤖 **AI Health Assistant**
- **Voice-Enabled Chatbot**: Ask questions using voice or text input
- **Text-to-Speech**: Natural female voice responses
- **Pregnancy Week Tracking**: Personalized advice based on current pregnancy stage
- **24/7 Health Support**: Instant answers to pregnancy-related questions

### 📊 **Comprehensive Analytics**
- **Meal History & Trends**: Track nutritional patterns over time
- **Health Reports**: Detailed analytics on nutrition and exercise
- **Progress Tracking**: Monitor wellness goals and achievements
- **Custom Analysis Types**: Choose from nutritional balance, caloric intake, meal timing, and more

### 🎯 **3D Visualization**
- **Interactive 3D Models**: Visualize fetal development by trimester
- **Immersive Experience**: Full-screen 3D models with auto-rotation and camera controls
- **Educational Content**: Learn about pregnancy stages through interactive visualizations

### 📱 **User Experience**
- **Modern Material Design**: Clean, intuitive interface with Google Fonts
- **Dark/Light Theme Support**: Comfortable viewing in any lighting
- **Responsive Design**: Optimized for various screen sizes
- **Offline Capabilities**: Core features work without internet connection

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: `>=3.7.2`
- **Dart SDK**: Latest stable version
- **Android Studio** or **VS Code** with Flutter extensions
- **Physical device or emulator** (Camera features require physical device)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/adarshnagrikar14/garbh.git
   cd garbh
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure permissions**
   
   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   ```

   **iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>This app needs camera access to scan food items</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>This app needs microphone access for voice commands</string>
   ```

4. **Add assets**
   
   Ensure the following assets are in the `assets/` directory:
   - `baby.jpg` - Pregnancy-related imagery
   - `one.glb` - First trimester 3D model
   - `two.glb` - Second trimester 3D model
   - `wn1.m4a` - Audio files for wellness content

5. **Run the application**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   
   # Specific device
   flutter run -d <device_id>
   ```

### Development Setup

1. **Check Flutter environment**
   ```bash
   flutter doctor
   ```

2. **Run tests**
   ```bash
   flutter test
   ```

3. **Build for production**
   ```bash
   # Android APK
   flutter build apk --release
   
   # Android App Bundle
   flutter build appbundle --release
   
   # iOS
   flutter build ios --release
   ```

## 🏗️ Project Architecture

### **Clean Architecture Pattern**
- **Core Layer**: Dependency injection and shared utilities
- **Data Layer**: Models, repositories, and external API integrations
- **Logic Layer**: BLoC/Cubit state management
- **UI Layer**: Screens and widgets

### **Key Dependencies**
- **State Management**: `flutter_bloc`, `provider`
- **HTTP Requests**: `http` package
- **Food Database**: `openfoodfacts` API integration
- **Camera & Scanning**: `camera`, `mobile_scanner`, `image_picker`
- **3D Models**: `model_viewer_plus`
- **Voice Features**: `speech_to_text`, `flutter_tts`
- **Real-time Communication**: `socket_io_client`
- **UI Components**: `google_fonts`, `percent_indicator`

### **Directory Structure**
```
lib/
├── core/                 # Dependency injection & utilities
├── feature/
│   ├── chat/            # AI chatbot functionality
│   ├── food/            # Food scanning & nutrition
│   ├── functions/       # Exercise pose detection
│   ├── home/            # Dashboard & navigation
│   ├── logs/            # Meal logging & history
│   ├── prescription/    # Health prescriptions
│   ├── reports/         # Analytics & reports
│   └── splash/          # App initialization
└── main.dart           # Application entry point
```

## 🔧 Configuration

### **API Configuration**
Update the OpenFoodFacts user agent in `main.dart`:
```dart
OpenFoodAPIConfiguration.userAgent = UserAgent(
  name: 'Garbh',
  version: '1.0.0',
  system: 'Android', // or 'iOS'
);
```

### **Socket Configuration**
Configure the exercise pose detection server endpoint in the exercise module.

## 🎯 Features Deep Dive

### **Food Intelligence**
- Supports 1M+ food products via OpenFoodFacts database
- Real-time nutritional analysis using AI
- Pregnancy-specific dietary recommendations
- Allergen and safety warnings for expecting mothers

### **Exercise Safety**
- Computer vision-based form correction
- Pregnancy-appropriate exercise modifications
- Real-time safety monitoring
- Progressive difficulty based on pregnancy stage

### **Health Insights**
- Personalized recommendations based on pregnancy week
- Integration with health guidelines for expecting mothers
- Trend analysis for nutritional intake
- Goal setting and achievement tracking

## 🛠️ Troubleshooting

### **Common Issues**

1. **Camera Permission Denied**
   - Ensure permissions are properly configured in platform-specific files
   - Check device settings for app permissions

2. **3D Models Not Loading**
   - Verify `.glb` files are in the `assets/` directory
   - Check `pubspec.yaml` asset declarations

3. **Voice Features Not Working**
   - Test on physical device (emulator may not support microphone)
   - Verify microphone permissions

4. **Socket Connection Issues**
   - Ensure exercise pose detection server is running
   - Check network connectivity and firewall settings

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenFoodFacts** for comprehensive food database
- **MediaPipe** for pose detection capabilities
- **Flutter Team** for the amazing framework
- **Healthcare professionals** who provided pregnancy wellness guidelines

---

**Made with ❤️ for expecting mothers everywhere**

*Garbh - Nurturing wellness throughout your pregnancy journey*
