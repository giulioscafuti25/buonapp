// posizione_provider.dart - Provider per la gestione della posizione GPS
// Gestisce il recupero e lo stato della posizione corrente dell'utente

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

//Eccezione personalizzata per gli errori di posizione
class EccezionePosizione implements Exception{
  //Messaggio di errore
  final String messaggio;
  const EccezionePosizione(this.messaggio);
  @override
  String toString() => 'EccezionePosizione: $messaggio';
}

//AsyncNotifier che gestisce la posizione corrente dell'utente
class GestorePosizione extends AsyncNotifier<Position?>{
  @override
  Future<Position?> build() async {
    // Recupera automaticamente la posizione all'avvio
    try {
      return await ServizioPosizione.ottieniPosizione();
    } catch (errore) {
      // Se non riesce (GPS disabilitato o permessi negati) restituisce null
      return null;
    }
  }

  Future <void> recuperaPosizione() async{
    try {
      //Imposta lo stato a loading mentre recupera la posizione
      state = const AsyncValue.loading();

      //Ottieni la posizione tramite il servizio GPS
      final posizione = await ServizioPosizione.ottieniPosizione();

      //Aggiorna lo stato con la posizione ottenuta
      state = AsyncValue.data(posizione);
    } catch (errore){
      // In caso di errore (GPS negato/disabilitato) imposta lo stato a null
      // così la UI esce dallo stato loading e mostra il messaggio appropriato
      state = const AsyncValue.data(null);
    }
  }

  //Resetta la posizione a null
  void resettaPosizione(){
    state = const AsyncValue.data(null);
  }
}

//Provider globale della posizione corrente dell'utente
final providerPosizione =
    AsyncNotifierProvider<GestorePosizione, Position?>((){
  return GestorePosizione();
});

