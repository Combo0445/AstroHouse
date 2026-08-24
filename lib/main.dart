import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'pages/menu_book_page.dart';
import 'services/cart_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E2723),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: const _AppStartupGate(),
    );
  }
}

/// Briefly holds the loading screen before revealing [MenuBookPage].
///
/// On web, the very first frame after the engine boots can have a short
/// window where taps land before the graphics pipeline (WebGL/CanvasKit
/// shader compilation, GPU context warm-up) is actually ready to respond,
/// making early taps feel like they do nothing. Showing a plain loading
/// screen for a moment keeps users from tapping into that window.
class _AppStartupGate extends StatefulWidget {
  const _AppStartupGate();

  @override
  State<_AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends State<_AppStartupGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const MenuBookPage();
    return const Scaffold(
      backgroundColor: Color(0xFF3E2723),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4AF37),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
