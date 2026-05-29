// notification_service.dart - Servizio per la gestione delle notifiche locali
// Schedula e cancella le notifiche di scadenza dei buoni

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_dati;

import '../models/buono_sconto.dart';

// Eccezione personalizzata per gli errori delle notifiche
class EccezioneNotifica implements Exception {
  // Messaggio di errore
  final String messaggio;

  const EccezioneNotifica(this.messaggio);

  @override
  String toString() => 'EccezioneNotifica: $messaggio';
}

// Callback per le notifiche ricevute in background
// Deve essere una funzione top-level (fuori dalla classe)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse risposta) {}

class ServizioNotifiche {
  // Istanza del plugin notifiche passata dal main.dart
  static late FlutterLocalNotificationsPlugin _pluginNotifiche;

  // Inizializza il servizio notifiche all'avvio dell'app
  static Future<void> inizializza(
      FlutterLocalNotificationsPlugin pluginNotifiche) async {
    try {
      _pluginNotifiche = pluginNotifiche;

      // Inizializza i fusi orari
      tz_dati.initializeTimeZones();

      // Imposta il fuso orario locale italiano
      tz.setLocalLocation(tz.getLocation('Europe/Rome'));

      // Impostazioni di inizializzazione per Android
      const impostazioniAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Impostazioni di inizializzazione per iOS
      const impostazioniIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Impostazioni combinate per tutte le piattaforme
      const impostazioniGenerali = InitializationSettings(
        android: impostazioniAndroid,
        iOS: impostazioniIOS,
      );

      // Inizializza il plugin con le impostazioni
      await _pluginNotifiche.initialize(
        settings: impostazioniGenerali,
        onDidReceiveNotificationResponse: (NotificationResponse risposta) {},
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
    } catch (errore) {
      throw EccezioneNotifica(
          'Errore durante l\'inizializzazione delle notifiche: $errore');
    }
  }

  // Schedula una notifica per un buono in scadenza
  // giorniAnticipo: quanti giorni prima della scadenza inviare la notifica
  // orarioNotifica: ora del giorno in cui inviare la notifica
  // minutiNotifica: minuti dell'orario della notifica
  static Future<void> schedulaNotifica({
    required BuonoSconto buono,
    required int giorniAnticipo,
    required int orarioNotifica,
    required int minutiNotifica,
  }) async {
    try {
      // Calcola la data in cui inviare la notifica
      final dataNotifica = buono.dataScadenza.subtract(
        Duration(days: giorniAnticipo),
      );

      // Data e ora esatta della notifica nel fuso orario locale
      final dataOraNotifica = tz.TZDateTime(
        tz.local,
        dataNotifica.year,
        dataNotifica.month,
        dataNotifica.day,
        orarioNotifica,
        minutiNotifica,
      );

      // Se la data e ora della notifica è già passata non la schedula
      if (dataOraNotifica.isBefore(tz.TZDateTime.now(tz.local))) return;

      // Dettagli della notifica per Android
      const dettagliAndroid = AndroidNotificationDetails(
        'canale_scadenza',
        'Scadenze buoni',
        channelDescription: 'Notifiche per i buoni in scadenza',
        importance: Importance.high,
        priority: Priority.high,
      );

      // Dettagli della notifica per iOS
      const dettagliIOS = DarwinNotificationDetails();

      // Dettagli combinati
      const dettagliGenerali = NotificationDetails(
        android: dettagliAndroid,
        iOS: dettagliIOS,
      );

      // Schedula la notifica con zonedSchedule
      await _pluginNotifiche.zonedSchedule(
        id: buono.id ?? 0,
        title: '⏰ Buono in scadenza!',
        body: '${buono.nomeNegozio} scade tra $giorniAnticipo ${giorniAnticipo == 1 ? 'giorno' : 'giorni'}',
        scheduledDate: dataOraNotifica,
        notificationDetails: dettagliGenerali,
        androidScheduleMode: AndroidScheduleMode.inexact,
        payload: buono.id.toString(),
      );
    } catch (errore) {
      throw EccezioneNotifica(
          'Errore durante la schedulazione della notifica: $errore');
    }
  }

  // Cancella la notifica associata a un buono (es. quando viene eliminato)
  static Future<void> cancellaNotifica(int idBuono) async {
    try {
      await _pluginNotifiche.cancel(id: idBuono);
    } catch (errore) {
      throw EccezioneNotifica(
          'Errore durante la cancellazione della notifica: $errore');
    }
  }

  // Cancella tutte le notifiche schedulate
  static Future<void> cancellaTutteNotifiche() async {
    try {
      await _pluginNotifiche.cancelAll();
    } catch (errore) {
      throw EccezioneNotifica(
          'Errore durante la cancellazione di tutte le notifiche: $errore');
    }
  }
}