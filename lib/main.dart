import 'package:flutter/material.dart';
import 'package:hackathon/core/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hackathon/feature/splash/splash_screen.dart';
import 'package:hackathon/feature/logs/cubit/meal_log_cubit.dart';
import 'package:hackathon/feature/food/product/logic/cubit/product_cubit.dart';
import 'package:hackathon/feature/logs/data/repositories/meal_log_repository.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OpenFoodFacts
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'Garbh',
    version: '1.0.0',
    system: 'Android',
  );

  await SharedPreferences.getInstance();
  await setupInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MealLogRepository>(create: (_) => getIt<MealLogRepository>()),
        BlocProvider(create: (_) => getIt<ProductCubit>()),
        BlocProvider(create: (_) => getIt<MealLogCubit>()..loadLogs()),
      ],
      child: MaterialApp(
        title: 'Garbh',
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          textTheme: GoogleFonts.robotoTextTheme(),
          useMaterial3: true,
        ),
      ),
    );
  }
}
