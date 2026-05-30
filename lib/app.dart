// app.dart - Widget radice dell'applicazione
// Definisce il tema Material Design e la navigazione principale

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/list_screen.dart';

class BuonApp extends ConsumerWidget {
  const BuonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Imposta la navigation bar e status bar trasparenti
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    return MaterialApp(
      // Nome dell'app mostrato nel task manager del telefono
      title: 'BuonApp',

      // Nasconde il banner "debug" nell'angolo in alto a destra
      debugShowCheckedModeBanner: false,

      // Localizzazione italiana per date picker e altri widget
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('it', 'IT'),
        Locale('en', 'US'),
      ],
      locale: const Locale('it', 'IT'),

      // Tema Material Design con colore verde come colore principale
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),

      // Schermata iniziale: lista dei buoni
      home: const ListScreen(),
    );
  }
}