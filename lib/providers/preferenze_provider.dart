// preferenze_provider.dart - Provider per la gestione delle preferenze notifiche
// Gestisce le impostazioni delle notifiche di scadenza tramite Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Chiavi per il salvataggio delle preferenze in SharedPreferences
const String _chiaveNotificheAttive = 'notifiche_attive';
const String _chiaveGiorniAnticipo = 'giorni_anticipo';
const String _chiaveOrarioNotifica = 'orario_notifica';
const String _chiaveMinutiNotifica = 'minuti_notifica';

// Eccezione personalizzata per gli errori delle preferenze
class EccezionePreferenze implements Exception {
  // Messaggio di errore
  final String messaggio;

  const EccezionePreferenze(this.messaggio);

  @override
  String toString() => 'EccezionePreferenze: $messaggio';
}

// Modello che contiene tutte le preferenze delle notifiche
class PreferenzeNotifiche {
  // Indica se le notifiche sono attive
  final bool notificheAttive;

  // Quanti giorni prima della scadenza inviare la notifica
  final int giorniAnticipo;

  // Ora del giorno in cui inviare la notifica
  final int orarioNotifica;

  // Minuti dell'orario della notifica
  final int minutiNotifica;

  const PreferenzeNotifiche({
    this.notificheAttive = false,
    this.giorniAnticipo = 3,
    this.orarioNotifica = 9,
    this.minutiNotifica = 0,
  });

  // Crea una copia delle preferenze con alcuni campi modificati
  PreferenzeNotifiche copiaCon({
    bool? notificheAttive,
    int? giorniAnticipo,
    int? orarioNotifica,
    int? minutiNotifica,
  }) {
    return PreferenzeNotifiche(
      notificheAttive: notificheAttive ?? this.notificheAttive,
      giorniAnticipo: giorniAnticipo ?? this.giorniAnticipo,
      orarioNotifica: orarioNotifica ?? this.orarioNotifica,
      minutiNotifica: minutiNotifica ?? this.minutiNotifica,
    );
  }
}

// AsyncNotifier che gestisce le preferenze delle notifiche
class GestorePreferenze extends AsyncNotifier<PreferenzeNotifiche> {
  @override
  Future<PreferenzeNotifiche> build() async {
    return await _caricaPreferenze();
  }

  // Carica le preferenze da SharedPreferences
  Future<PreferenzeNotifiche> _caricaPreferenze() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return PreferenzeNotifiche(
        notificheAttive: prefs.getBool(_chiaveNotificheAttive) ?? false,
        giorniAnticipo: prefs.getInt(_chiaveGiorniAnticipo) ?? 3,
        orarioNotifica: prefs.getInt(_chiaveOrarioNotifica) ?? 9,
        minutiNotifica: prefs.getInt(_chiaveMinutiNotifica) ?? 0,
      );
    } catch (errore) {
      throw EccezionePreferenze(
          'Errore durante il caricamento delle preferenze: $errore');
    }
  }

  // Salva le preferenze aggiornate in SharedPreferences
  Future<void> _salvaPreferenze(PreferenzeNotifiche preferenze) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_chiaveNotificheAttive, preferenze.notificheAttive);
      await prefs.setInt(_chiaveGiorniAnticipo, preferenze.giorniAnticipo);
      await prefs.setInt(_chiaveOrarioNotifica, preferenze.orarioNotifica);
      await prefs.setInt(_chiaveMinutiNotifica, preferenze.minutiNotifica);
    } catch (errore) {
      throw EccezionePreferenze(
          'Errore durante il salvataggio delle preferenze: $errore');
    }
  }

  // Attiva o disattiva le notifiche
  Future<void> impostaNotificheAttive(bool valore) async {
    try {
      final preferenzeAttuali = state.value ?? const PreferenzeNotifiche();
      final nuovePreferenze = preferenzeAttuali.copiaCon(
        notificheAttive: valore,
      );
      await _salvaPreferenze(nuovePreferenze);
      state = AsyncValue.data(nuovePreferenze);
    } catch (errore) {
      throw EccezionePreferenze(
          'Errore durante l\'aggiornamento delle notifiche: $errore');
    }
  }

  // Imposta i giorni di anticipo della notifica
  Future<void> impostaGiorniAnticipo(int giorni) async {
    try {
      final preferenzeAttuali = state.value ?? const PreferenzeNotifiche();
      final nuovePreferenze = preferenzeAttuali.copiaCon(
        giorniAnticipo: giorni,
      );
      await _salvaPreferenze(nuovePreferenze);
      state = AsyncValue.data(nuovePreferenze);
    } catch (errore) {
      throw EccezionePreferenze(
          'Errore durante l\'aggiornamento dei giorni di anticipo: $errore');
    }
  }

  // Imposta l'orario e i minuti della notifica
  Future<void> impostaOrarioNotifica(int ora, int minuti) async {
    try {
      final preferenzeAttuali = state.value ?? const PreferenzeNotifiche();
      final nuovePreferenze = preferenzeAttuali.copiaCon(
        orarioNotifica: ora,
        minutiNotifica: minuti,
      );
      await _salvaPreferenze(nuovePreferenze);
      state = AsyncValue.data(nuovePreferenze);
    } catch (errore) {
      throw EccezionePreferenze(
          'Errore durante l\'aggiornamento dell\'orario: $errore');
    }
  }
}

// Provider globale delle preferenze notifiche
final providerPreferenze =
    AsyncNotifierProvider<GestorePreferenze, PreferenzeNotifiche>(() {
  return GestorePreferenze();
});