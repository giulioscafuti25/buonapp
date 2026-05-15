// posizione_provider.dart - Provider per la gestione della posizione GPS
// Gestisce il recupero e lo stato della posizione corrente dell'utente

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';

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
  Future<Position?> build() async{
    //All'avvio non recupera automaticamente la posizione
    // per non chiedere subito i permessi GPS
    return null;
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
      throw EccezionePosizione('Errore nel recupero della posizione: $errore');
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

//Provider che restituisce l'indirizzo testuale della posizione corrente
// Effettua una chiamata REST API a Nominatim per il geocoding inverso
final providerIndirizzo = FutureProvider.autoDispose.family<String?, Position?>(
  (ref, posizione) async{
    // Se la posizione è null, restituisce null
    if (posizione == null) return null;

    try{
      //Chiama il servizio di geocoding per ottenere l'indirizzo
      final indirizzo = await ServizioGeocoding.coordinateAdIndirizzo(
        latitudine: posizione.latitude,
        longitudine: posizione.longitude,
      );
      return indirizzo;
    } catch (errore){
      throw EccezionePosizione('Errore nel recupero dell\'indirizzo: $errore');
    }
  },
);