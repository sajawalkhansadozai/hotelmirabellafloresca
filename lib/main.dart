import 'package:flutter/material.dart';
import 'package:mirabellafh/pages/admin_login.dart';

// Pages
import 'pages/home.dart';
import 'pages/about.dart';
import 'pages/rooms.dart';
import 'pages/gallery.dart';
import 'pages/contact.dart';

// Admin pages
import 'pages/admin_panel.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Google Analytics (Firebase)
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MirabellaFlorescaApp());
}

class MirabellaFlorescaApp extends StatelessWidget {
  const MirabellaFlorescaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brandGold = Color(0xFFD4AF37);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandGold,
        brightness: Brightness.light,
      ),
      fontFamily: 'Georgia',
    );

    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    final FirebaseAnalyticsObserver analyticsObserver =
        FirebaseAnalyticsObserver(analytics: analytics);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Mirabella Floresca',
      theme: base.copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        textTheme: base.textTheme.apply(
          bodyColor: const Color(0xFF333333),
          displayColor: const Color(0xFF333333),
        ),
      ),
      navigatorObservers: [analyticsObserver],
      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) => const HomePage(),
        Routes.about: (_) => const AboutPage(),
        Routes.rooms: (_) => const RoomsPage(),
        Routes.gallery: (_) => const GalleryPage(),
        Routes.contact: (_) => const ContactPage(),

        // Admin routes
        Routes.adminLogin: (_) => const AdminLoginPage(),
        Routes.admin: (_) => const AdminPanelPage(),
      },
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }
}

abstract class Routes {
  static const home = '/';
  static const about = '/about';
  static const rooms = '/rooms';
  static const gallery = '/gallery';
  static const dining = '/dining';
  static const services = '/services';
  static const events = '/events';
  static const contact = '/contact';

  // Admin routes
  static const adminLogin = '/admin-login';
  static const admin = '/admin';
}
