// buoni_provider.dart - Provider per la gestione dello stato dei buoni sconto
// Gestisce la lista dei buoni e le operazioni CRUD tramite Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/buono_sconto.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../providers/preferenze_provider.dart';

// Eccezione personalizzata per gli errori del provider buoni
class EccezioneBuoni implements Exception {
  // Messaggio di errore
  final String messaggio;

  const EccezioneBuoni(this.messaggio);

  @override
  String toString() => 'EccezioneBuoni: $messaggio';
}

// Provider globale del ServizioStorage, accessibile da tutta l'app
final providerStorage = Provider<ServizioStorage>((ref) {
  return ServizioStorage();
});

// Filtro per la lista dei buoni
enum FiltroBuoni {
  tutti, // mostra tutti i buoni
  inScadenza, // mostra solo i buoni in scadenza entro 7 giorni
  scaduti, // mostra solo i buoni scaduti
}

// Notifier che gestisce il filtro attivo nella schermata lista
class GestoreFiltro extends Notifier<FiltroBuoni> {
  @override
  FiltroBuoni build() => FiltroBuoni.tutti;

  // Cambia il filtro attivo
  void cambiaFiltro(FiltroBuoni nuovoFiltro) {
    state = nuovoFiltro;
  }
}

// Provider del filtro attivo nella schermata lista
final providerFiltro = NotifierProvider<GestoreFiltro, FiltroBuoni>(() {
  return GestoreFiltro();
});

// AsyncNotifier che gestisce la lista dei buoni e le operazioni CRUD
class GestoreBuoni extends AsyncNotifier<List<BuonoSconto>> {
  // Riferimento al servizio di storage
  late final ServizioStorage _storage;

  @override
  Future<List<BuonoSconto>> build() async {
    // Inizializza il servizio di storage
    _storage = ref.read(providerStorage);
    // Carica i buoni dal database all'avvio
    return await _caricaBuoni();
  }

  // Carica tutti i buoni dal database
  Future<List<BuonoSconto>> _caricaBuoni() async {
    try {
      return await _storage.caricaTuttiBuoni();
    } catch (errore) {
      throw EccezioneBuoni(
          'Errore durante il caricamento dei buoni: $errore');
    }
  }

  // Aggiunge un nuovo buono al database e schedula la notifica
  Future<void> aggiungiBuono(BuonoSconto buono) async {
    try {
      // Salva il buono nel database e ottieni l'id assegnato
      final idAssegnato = await _storage.inserisciBuono(buono);

      // Crea il buono con l'id assegnato dal database
      final buonoConId = buono.copiaCon(id: idAssegnato);

      // Leggi le preferenze notifiche per schedulare la notifica
      final preferenze = ref.read(providerPreferenze).value ??
           PreferenzeNotifiche();
      if (preferenze.notificheAttive) {
        await ServizioNotifiche.schedulaNotifica(
          buono: buonoConId,
          giorniAnticipo: preferenze.giorniAnticipo,
          orarioNotifica: preferenze.orarioNotifica,
          minutiNotifica: preferenze.minutiNotifica,
        );
      }

      // Aggiorna lo stato aggiungendo il nuovo buono e riordinando per data
      // (mantiene l'ordine coerente con quello restituito dal database)
      final listaAggiornata = [...state.value ?? [], buonoConId]
        ..sort((a, b) => a.dataScadenza.compareTo(b.dataScadenza));
        state = AsyncValue.data(List<BuonoSconto>.from(listaAggiornata));
    } catch (errore) {
      throw EccezioneBuoni(
          'Errore durante l\'aggiunta del buono: $errore');
    }
  }

  // Aggiorna un buono esistente nel database
  Future<void> aggiornaBuono(BuonoSconto buono) async {
    try {
      await _storage.aggiornaBuono(buono);

      // Cancella la vecchia notifica e schedula quella aggiornata
      await ServizioNotifiche.cancellaNotifica(buono.id!);
      final preferenze = ref.read(providerPreferenze).value ??
           PreferenzeNotifiche();
      if (preferenze.notificheAttive) {
        await ServizioNotifiche.schedulaNotifica(
          buono: buono,
          giorniAnticipo: preferenze.giorniAnticipo,
          orarioNotifica: preferenze.orarioNotifica,
          minutiNotifica: preferenze.minutiNotifica,
        );
      }

      // Aggiorna lo stato sostituendo il buono modificato e riordinando per data
      // (la data di scadenza potrebbe essere cambiata, l'ordine va ricalcolato)
      final listaAggiornata = (state.value ?? [])
          .map((b) => b.id == buono.id ? buono : b)
          .toList()
          ..sort((a, b) => a.dataScadenza.compareTo(b.dataScadenza));
      state = AsyncValue.data(listaAggiornata);
    } catch (errore) {
      throw EccezioneBuoni(
          'Errore durante l\'aggiornamento del buono: $errore');
    }
  }

  // Elimina un buono dal database e cancella la sua notifica
  Future<void> eliminaBuono(int id) async {
    try {
      await _storage.eliminaBuono(id);

      // Cancella la notifica associata al buono eliminato
      await ServizioNotifiche.cancellaNotifica(id);

      // Aggiorna lo stato rimuovendo il buono dalla lista
      state = AsyncValue.data(
        (state.value ?? []).where((b) => b.id != id).toList(),
      );
    } catch (errore) {
      throw EccezioneBuoni(
          'Errore durante l\'eliminazione del buono: $errore');
    }
  }
}

// NotifierProvider che espone la lista dei buoni e le operazioni su di essa
final providerBuoni =
    AsyncNotifierProvider<GestoreBuoni, List<BuonoSconto>>(() {
  return GestoreBuoni();
});

// Provider che restituisce la lista filtrata dei buoni
final providerBuoniFiltrati = Provider<AsyncValue<List<BuonoSconto>>>((ref) {
  // Osserva la lista completa dei buoni
  final tuttiBuoni = ref.watch(providerBuoni);
  // Osserva il filtro attivo
  final filtroAttivo = ref.watch(providerFiltro);

  return tuttiBuoni.when(
    // Se i dati sono disponibili applica il filtro
    data: (listaBuoni) {
      switch (filtroAttivo) {
        case FiltroBuoni.tutti:
          return AsyncValue.data(listaBuoni);
        case FiltroBuoni.inScadenza:
          return AsyncValue.data(
            listaBuoni.where((buono) => buono.staPerScadere).toList(),
          );
        case FiltroBuoni.scaduti:
          return AsyncValue.data(
            listaBuoni.where((buono) => buono.eScaduto).toList(),
          );
      }
    },
    // Se sta caricando restituisce loading
    loading: () => const AsyncValue.loading(),
    // Se c'è un errore lo propaga
    error: (errore, stack) => AsyncValue.error(errore, stack),
  );
});