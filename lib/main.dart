import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tamales_screen.dart';
import 'screens/beverages_screen.dart';
import 'screens/inventory_list_screen.dart';
import 'screens/new_sale_screen.dart';
import 'screens/sale_list_screen.dart';
import 'screens/branch_list_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/users_screen.dart';
import 'screens/combos_screen.dart';
import 'services/notification_service.dart';
import 'theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await NotificationService.initialize();
  final themeNotifier = await ThemeNotifier.init();
  runApp(
    ChangeNotifierProvider<ThemeNotifier>.value(
      value: themeNotifier,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, notifier, _) {
        return MaterialApp(
          title: 'Cazuela Chapina',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
            cardTheme: const CardThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: notifier.themeMode,
          initialRoute: '/',
          routes: {
            '/': (_) => const SplashScreen(),
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/dashboard': (_) => const DashboardScreen(),
            '/tamales': (_) => const TamalesScreen(),
            '/beverages': (_) => const BeveragesScreen(),
            '/inventory': (_) => const InventoryListScreen(),
            '/sales/new': (_) => const NewSaleScreen(),
            '/sales': (_) => const SaleListScreen(),
            '/branches': (_) => const BranchListScreen(),
            '/chat': (_) => const ChatScreen(),
            '/users': (_) => const UsersScreen(),
            '/combos': (_) => const CombosScreen(),
          },
          onUnknownRoute: (_) => MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Ruta no encontrada')),
            ),
          ),
        );
      },
    );
  }
}
