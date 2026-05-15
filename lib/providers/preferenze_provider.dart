//preferenze_provider.dart - Provider per la gestione delle preferenze notifiche
//Gestisce le impostazioni delle notifiche di scadenza tramite Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Chiavi per il salvataggio delle preferenze in SharedPreferences
const String _chiaveNotificheAttive = 'notifiche_attive';
const String _chiaveGiornoAnticipo = 'giorni_anticipo';
const String _chiaveOrarioNotifica = 'orario_notifica';


//Eccezione personalizzata per errori nella gestione delle preferenze
class EccezionePreferenze implements Exception {
  final String messaggio;
  const EccezionePreferenze(this.messaggio);
  @override
  String toString() => 'EccezionePreferenze: $messaggio';
}

//Modello che contiene tutte le preferenze delle notifiche
class PreferenzeNotifiche {
  //Indica se le notifiche sono attive
  final bool notificheAttive;

  //Quanti giorni prima della scadenza inviare la notifica
  final int giorniAnticipo;

  //Ora del giorno a cui inviare la notifica (es 9 = 9:00)
  final int orarioNotifica;

  //Indica se avisare anche per i buoni già scaduti
  final bool avvisaBuoniScaduti;

  const PreferenzeNotifiche({
    this.notificheAttive = true,
    this.giorniAnticipo = 3,
    this.orarioNotifica = 9,
    this.avvisaBuoniScaduti = false,
  });

  //Crea una copia delle preferenze con alcuni campi modificati
  PreferenzeNotifiche copiaCon({
    bool? notificheAttive,
    int? giorniAnticipo,
    int? orarioNotifica,
    bool? avvisaBuoniScaduti,
  }) {
    return PreferenzeNotifiche(
      notificheAttive: notificheAttive ?? this.notificheAttive,
      giorniAnticipo: giorniAnticipo ?? this.giorniAnticipo,
      orarioNotifica: orarioNotifica ?? this.orarioNotifica,
      avvisaBuoniScaduti: avvisaBuoniScaduti ?? this.avvisaBuoniScaduti,
    );
  }
}

//AsyncNotifier che gestisce le preferenze delle notifiche
class GestorePreferenze extends AsyncNotifier<PreferenzeNotifiche> {
  @override
  Future<PreferenzeNotifiche> build() async{
    //Carica le preferenze salvate al primo avvio
    return await _caricaPreferenze();
  }

  //Carica le preferenze da SharedPreferences
  Future<PreferenzeNotifiche> _caricaPreferenze() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return PreferenzeNotifiche(
        notificheAttive: prefs.getBool(_chiaveNotificheAttive) ?? true,
        giorniAnticipo: prefs.getInt(_chiaveGiornoAnticipo) ?? 3,
        orarioNotifica: prefs.getInt(_chiaveOrarioNotifica) ?? 9,
        avvisaBuoniScaduti: prefs.getBool('avvisa_buoni_scaduti') ?? false,
      );
    }
    catch (errore) {
      throw EccezionePreferenze('Errore nel caricamento delle preferenze: $errore');
    }
  }

  //Salva le preferenze aggiornate in SharedPreferences
  Future<void> _salvaPreferenze(PreferenzeNotifiche preferenze) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_chiaveNotificheAttive, preferenze.notificheAttive);
      await prefs.setInt(_chiaveGiornoAnticipo, preferenze.giorniAnticipo);
      await prefs.setInt(_chiaveOrarioNotifica, preferenze.orarioNotifica);
      await prefs.setBool('avvisa_buoni_scaduti', preferenze.avvisaBuoniScaduti);
    }
    catch (errore) {
      throw EccezionePreferenze('Errore nel salvataggio delle preferenze: $errore');
    }
  }

  //Attiva o disattiva le notifiche
  Future<void> impostaNotificheAttive(bool valore) async {
    try{
      final preferenzeAttuali = state.value ?? const PreferenzeNotifiche();
      final nuovePreferenze = preferenzeAttuali.copiaCon(
        notificheAttive: valore,
        );
      await _salvaPreferenze(nuovePreferenze);
      state = AsyncValue.data(nuovePreferenze);
    } catch (errore) {
      throw EccezionePreferenze('Errore durante l\'aggiornamento delle notifiche: $errore');
    }
  }

  //Imposta i giorni di anticipo della notifica
  Future<void> impostaGiorniAnticipo(int giorni) async {
    try{
      final preferenzeAttuali = state.value ?? const PreferenzeNotifiche();
      final nuovePreferenze = preferenzeAttuali.copiaCon(
        giorniAnticipo: giorni,
        );
      await _salvaPreferenze(nuovePreferenze);
      state = AsyncValue.data(nuovePreferenze);
    } catch (errore) {
      throw EccezionePreferenze('Errore durante l\'aggiornamento dei giorni di anticipo: $errore');
    }
  }

  //Imposta l'orario della notifica
  Future<void> impostaOrarioNotifica(int ora) async {
    try{
      final preferenzeAttuali = state.value ?? const PreferenzeNotifiche();
      final nuovePreferenze = preferenzeAttuali.copiaCon(
        orarioNotifica: ora,
        );
      await _salvaPreferenze(nuovePreferenze);
      state = AsyncValue.data(nuovePreferenze);
    } catch (errore) {
      throw EccezionePreferenze('Errore durante l\'aggiornamento dell\'orario della notifica: $errore');
    }
  }

  //Attiva o disattiva gli avvisi per i buoni già scaduti
  Future<void> impostaAvvisoBuoniScaduti(bool valore) async {
    try{
      final preferenzeAttuali = state.value ?? const PreferenzeNotifiche();
      final nuovePreferenze = preferenzeAttuali.copiaCon(
        avvisaBuoniScaduti: valore,
        );
      await _salvaPreferenze(nuovePreferenze);
      state = AsyncValue.data(nuovePreferenze);
    } catch (errore) {
      throw EccezionePreferenze('Errore durante l\'aggiornamento dell\'avviso per i buoni scaduti: $errore');
    }
  }
}

//Provider globale delle preferenze notifiche
final providerPreferenze = 
    AsyncNotifierProvider<GestorePreferenze, PreferenzeNotifiche>(() {
  return GestorePreferenze();
});