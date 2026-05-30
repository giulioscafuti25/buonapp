// main.dart - Entry point dell'applicazione BuonApp
// Inizializza Riverpod, le notifiche locali e avvia l'app

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';
import 'services/notification_service.dart';

// Istanza globale del plugin notifiche, accessibile anche dal servizio
final FlutterLocalNotificationsPlugin pluginNotifiche =
    FlutterLocalNotificationsPlugin();

void main() async {
  // Assicura che i binding Flutter siano inizializzati prima di chiamare
  // codice nativo (notifiche, database, ecc.)
  WidgetsFlutterBinding.ensureInitialized();

  // Abilita la modalita' edge-to-edge: l'app si estende dietro
  // la navigation bar e la status bar di Android
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Richiede il permesso per le notifiche (necessario su Android 13+)
  await Permission.notification.request();

  // Inizializza il servizio notifiche all'avvio
  await ServizioNotifiche.inizializza(pluginNotifiche);

  // ProviderScope e' il widget radice obbligatorio per Riverpod:
  // rende tutti i provider accessibili all'albero dei widget
  runApp(
    const ProviderScope(
      child: BuonApp(),
    ),
  );
}