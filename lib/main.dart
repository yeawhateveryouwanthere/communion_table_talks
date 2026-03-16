import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell_screen.dart';
import 'data/seed_firestore.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'providers/subscription_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Launch the app immediately — don't block on Firestore seeding
  runApp(const CommunionTableTalksApp());

  // Run seeding in the background (non-blocking) with a timeout
  try {
    await seedFirestore().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('Firestore seeding timed out — will retry next launch.');
      },
    );
  } catch (e) {
    print('Firestore seeding error (non-fatal): $e');
  }
}

class CommunionTableTalksApp extends StatelessWidget {
  const CommunionTableTalksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: _AppWithAuthListener(),
    );
  }
}

/// Listens to auth changes and connects the SubscriptionProvider
/// to the current user. Also initializes in-app purchases.
class _AppWithAuthListener extends StatefulWidget {
  @override
  State<_AppWithAuthListener> createState() => _AppWithAuthListenerState();
}

class _AppWithAuthListenerState extends State<_AppWithAuthListener> {
  bool _purchasesInitialized = false;

  @override
  Widget build(BuildContext context) {
    // Watch auth state and sync subscription listener
    final authProvider = context.watch<app_auth.AuthProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();

    // Initialize in-app purchases once
    if (!_purchasesInitialized) {
      _purchasesInitialized = true;
      subscriptionProvider.initializePurchases();
    }

    if (authProvider.isSignedIn) {
      subscriptionProvider.listenToUser(authProvider.user!.uid);
    } else {
      subscriptionProvider.clearUser();
    }

    return MaterialApp(
      title: 'Communion Table Talks',
      theme: AppTheme.lightTheme,
      home: const MainShellScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
