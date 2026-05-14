// geocoding_service.dart - Servizio per la conversione coordinata-indirizzo
//Effettua chiamate REST API a Nominatim (OpenStreetMap) per il geocoding inverso

import 'dart:convert';
import 'package:http/http.dart' as http;

//Eccezione personalizzata per errori di geocoding
class EccezioneGeocoding implements Exception {
  //Messaggio di errore
  final String messaggio;
  const EccezioneGeocoding(this.messaggio);
  @override
  String toString() => 'EccezioneGeocoding: $messaggio';
}

class ServizioGeocoding{
  //URL base dell'API Nominatim di OpenStreetMap
  static const String _urlBase = 'https://nominatim.openstreetmap.org';

  //Header richiesto da Nominatim per identificare l'applicazione
  static const Map<String, String> _intestazioni  = {
    'User-Agent': 'BuonAPP/1.0',
    'Accept-Language': 'it', //risposta in italiano
  };

  //Converte coordinate GPS in un indirizzo testuale (geocoding inverso)
  //Restituisce l'indirizzo completo o null se non trovato
  static Future<String?> coordinateAdIndirizzo({
    required double latitudine,
    required double longitudine,
  }) async {
    try{
      //Costruisce l'URL della richiesta con i parametri necessari
      final url = Uri.parse(
        '$_urlBase/reverse?format=json&lat=$latitudine&lon=$longitudine'
      );

      //Effettua la chiamata REST GET a Nominatim
      final risposta = await http.get(url, headers: _intestazioni);

      //controlla che la risposta sia andata a buon fine (codice 200)
      if(risposta.statusCode != 200){
        throw EccezioneGeocoding(
          'Errore dal server: codice  ${risposta.statusCode}'
        );
      }

      //Decodifica il JSON della risposta
      final datiJson = jsonDecode(risposta.body) as Map<String, dynamic>;

      //Estrae l'indirizzo completo dal campo 'display_name' della risposta
      final indirizzo = datiJson['display_name'] as String?;

      return indirizzo;
    } on EccezioneGeocoding{
      //Rilancia l'eccezione di geocoding
      rethrow;
    } catch (errore){
      //Converte qualisasi altro errore in EccezioneGeocoding
      throw EccezioneGeocoding('Errore di rete: $errore');
    }
  }

  //Converte un indirizzo testuale in coordinate GPS (geocoding diretto)
  //Lancia EccezioneGeocoding in caso di errore
  static Future<Map<String, double>?> indirizzoACoordinate(
    String indirizzo) async {
    try{
      //Costruisce l'URL con l'indirizzo codificato per la URLindirizzo
      final uri = Uri.parse(
        '$_urlBase/search?format=json&q=${Uri.encodeComponent(indirizzo)}&limit=1'
      );

      //Effettua la chiamata REST GET a Nominatim
      final risposta = await http.get(uri, headers: _intestazioni);

      //Se la risposta non è 200, lancia un'eccezione
      if(risposta.statusCode != 200){
        throw EccezioneGeocoding(
          'Errore dal server: codice ${risposta.statusCode}'
        );
      }

      //Decodifica il JSON della risposta
      final datiJson = jsonDecode(risposta.body) as List<dynamic>;

      //Se non ci sono risultati restituisce null
      if(datiJson.isEmpty) return null;

      //Estrae il primo risultato
      final primoRisultato = datiJson[0] as Map<String, dynamic>;

      //Restituisce le coordinate come Map
      return{
        'latitudine': double.parse(primoRisultato['lat'] as String),
        'longitudine': double.parse(primoRisultato['lon'] as String),
      };
    } on EccezioneGeocoding{
      //Rilancia l'eccezione di geocoding
      rethrow;
    } catch (errore){
      //Converte qualisasi altro errore in EccezioneGeocoding
      throw EccezioneGeocoding('Errore di rete: $errore');
    }
  }
}