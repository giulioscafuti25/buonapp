// notification_service.dart - Servizio per la gestione delle notifiche locali
// Schedula e cancella le notifiche di scadenza dei buoni

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_dati;
import '../models/buono_sconto.dart';

//Eccezione personalizzata per gli errori nelle notifiche
class EccezioneNotifiche implements Exception {
  //Messaggio di errore
  final String messaggio;
  const EccezioneNotifiche(this.messaggio);
  @override
  String toString() => 'EccezioneNotifiche: $messaggio';
}

// Callback per le notifiche ricevute in background
// Deve essere una funzione top-level (fuori dalla classe)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse risposta) {}

class ServizioNotifiche{
  //Istanza del plugin notifiche passata dal main.dart
  static late FlutterLocalNotificationsPlugin _pluginNotifiche;

  //Inizializza il servizio notifiche all'avvio dell'app
  static Future<void> inizializza(
    FlutterLocalNotificationsPlugin pluginNotifiche) async{
      try{
    _pluginNotifiche = pluginNotifiche;

    //Inizializza i fusi orari
    tz_dati.initializeTimeZones();

    //impostazioni di inizializzazione per Android
    const impostazioniAndroid = 
      AndroidInitializationSettings('@mipmap/ic_launcher');

    //Impostazioni di inizializzazione per iOS
    const impostazioniIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    //Impostazioni combinate per tutte le piattaforme
    const impostazioniGenerali = InitializationSettings(
      android: impostazioniAndroid,
      iOS: impostazioniIOS,
    );

    await _pluginNotifiche.initialize(
      settings: impostazioniGenerali,
      onDidReceiveNotificationResponse: (NotificationResponse risposta) {},
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      } catch (errore){
        throw EccezioneNotifiche('Errore durante l\'inizializzazione: $errore');
      }
    }

    //Schedula una notifica per un buono in scadenza
    //giorniAnticipo: quanti giorni prima della scadenza inviare la notifica
    //orarioNotifica: orario del giorno in cui inviare la notifica (es. 9:00)
    static Future<void> schedulaNotifica({
      required BuonoSconto buono,
      required int giorniAnticipo,
      required int orarioNotifica,
    }) async {
      try{
      //Calcola la data in cui inviare la notifica
      final dataNotifica = buono.dataScadenza.subtract(
        Duration(days: giorniAnticipo),
      );

      //Se la data di notifica è già passata, non schedulare nulla
      if (dataNotifica.isBefore(DateTime.now())) return;

      //Data e ora esatti in cui inviare la notifica
      final dataOraNotifica = tz.TZDateTime(
        tz.local,
        dataNotifica.year,
        dataNotifica.month,
        dataNotifica.day,
        orarioNotifica, // ora impostata dall'utente
        0, // minuti
      );

      //Dettagli della notifica per Android
      const dettagliAndroid = AndroidNotificationDetails(
        'canale_scadenza', //id canale
        'Scadenze buoni', //nome canale
        channelDescription: 'Notifiche per buoni in scadenza',
        importance: Importance.high,
        priority: Priority.high,
      );

      //Dettagli della notifica per iOS
      const dettagliIOS = DarwinNotificationDetails();

      //Dettagli combinati per tutte le piattaforme
      const dettagliGenerali = NotificationDetails(
        android: dettagliAndroid,
        iOS: dettagliIOS,
      );

      //Schedula la notifica
      await _pluginNotifiche.zonedSchedule(
        id: buono.id ?? 0, //id della notifica (usa id del buono o 0 se null)
        title: '⏰ Buono in scadenza!', //titolo della notifica
        body:  '${buono.nomeNegozio} scade tra $giorniAnticipo giorni', //corpo della notifica
        scheduledDate: dataOraNotifica, //quando inviarla
        notificationDetails: dettagliGenerali, //dettagli della notifica
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: buono.id.toString(), //payload con id del buono per eventuali azioni future
      );
      } catch (errore){
        throw EccezioneNotifiche('Errore durante la schedulazione: $errore');
      }
    }

    //Cancella la notifica associata a un buono (es. quando viene eliminato o modificato)
    static Future<void> cancellaNotifica(int idBuono) async {
      try{
      await _pluginNotifiche.cancel(id: idBuono);
    } catch (errore){
        throw EccezioneNotifiche('Errore durante la cancellazione: $errore');
      }
  }

    //Cancella tutte le notifiche schedulate
    static Future<void> cancellaTutteNotifiche() async {
      try{
      await _pluginNotifiche.cancelAll();
    } catch (errore){
        throw EccezioneNotifiche('Errore durante la cancellazione: $errore');
    }
  }
}