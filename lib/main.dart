import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';
import 'app/app.locator.dart';
import 'app/app.router.dart';
import 'app/app.dialogs.dart';
import 'app/app.bottomsheets.dart';
import 'firebase_options.dart';
import 'ui/common/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed (placeholder config): $e');
  }

  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  runApp(const MachineMarketplaceApp());
}

class MachineMarketplaceApp extends StatelessWidget {
  const MachineMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '537 Machines',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: AppColors.primary,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.titilliumWebTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.dark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorObservers: [StackedService.routeObserver],
    );
  }
}
