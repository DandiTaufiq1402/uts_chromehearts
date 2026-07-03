import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import file-file penting
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/biometric_lock_provider.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/widgets/biometric_lock_screen.dart';
import 'core/services/payment_deeplink_service.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyD1Jri3Km4_5xo7EkQEtxZ4hIDu-mcUoxw',
        appId: '1:296039717564:android:9070dafa959c842f614eb9',
        messagingSenderId: '296039717564',
        projectId: 'chrome-hearts-uts',
      ),
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  await PaymentDeeplinkService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BiometricLockProvider()..initialize(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Chrome Hearts',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      builder: (context, child) => BiometricLockScreen(child: child!),
    );
  }
}