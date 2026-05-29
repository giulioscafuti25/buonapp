// geocoding_service.dart - Servizio per la conversione coordinate -> indirizzo
// Effettua chiamate REST API a Nominatim (OpenStreetMap) per il geocoding inverso

import 'dart:convert';
import 'package:http/http.dart' as http;

// Eccezione personalizzata per gli errori di geocoding
class EccezioneGeocoding implements Exception {
  // Messaggio di errore
  final String messaggio;

  const EccezioneGeocoding(this.messaggio);

  @override
  String toString() => 'EccezioneGeocoding: $messaggio';
}

class ServizioGeocoding {
  // URL base delle API Nominatim di OpenStreetMap
  static const String _urlBase = 'https://nominatim.openstreetmap.org';

  // Header richiesto da Nominatim per identificare l'applicazione
  static const Map<String, String> _intestazioni = {
    'User-Agent': 'BuonApp/1.0',
    'Accept-Language': 'it', // risposte in italiano
  };

  // Converte coordinate GPS in un indirizzo testuale (geocoding inverso)
  // Lancia EccezioneGeocoding in caso di errore
  static Future<String?> coordinateAdIndirizzo({
    required double latitudine,
    required double longitudine,
  }) async {
    try {
      // Costruisce l'URL della richiesta con i parametri necessari
      final uri = Uri.parse(
        '$_urlBase/reverse?format=json&lat=$latitudine&lon=$longitudine',
      );

      // Effettua la chiamata REST GET a Nominatim
      final risposta = await http.get(uri, headers: _intestazioni)
          .timeout(const Duration(seconds: 10));

      // Se la risposta non è 200 lancia un'eccezione con il codice di errore
      if (risposta.statusCode != 200) {
        throw EccezioneGeocoding(
          'Errore dal server: codice ${risposta.statusCode}',
        );
      }

      // Decodifica il JSON della risposta
      final datiJson = jsonDecode(risposta.body) as Map<String, dynamic>;

      // Estrae l'indirizzo dal campo 'display_name' della risposta
      final indirizzo = datiJson['display_name'] as String?;

      return indirizzo;
    } on EccezioneGeocoding {
      rethrow;
    } catch (errore) {
      throw EccezioneGeocoding('Errore di rete: $errore');
    }
  }

  // Converte un indirizzo testuale in coordinate GPS (geocoding diretto)
  // Lancia EccezioneGeocoding in caso di errore
  static Future<Map<String, double>?> indirizzoACoordinate(
      String indirizzo) async {
    try {
      // Costruisce l'URL con l'indirizzo codificato per la URL
      final uri = Uri.parse(
        '$_urlBase/search?format=json&q=${Uri.encodeComponent(indirizzo)}&limit=1',
      );

      // Effettua la chiamata REST GET a Nominatim
      final risposta = await http.get(uri, headers: _intestazioni)
          .timeout(const Duration(seconds: 10));

      // Se la risposta non è 200 lancia un'eccezione con il codice di errore
      if (risposta.statusCode != 200) {
        throw EccezioneGeocoding(
          'Errore dal server: codice ${risposta.statusCode}',
        );
      }

      // Decodifica il JSON della risposta
      final datiJson = jsonDecode(risposta.body) as List<dynamic>;

      // Se non ci sono risultati restituisce null
      if (datiJson.isEmpty) return null;

      // Estrae il primo risultato
      final primoRisultato = datiJson[0] as Map<String, dynamic>;

      // Restituisce le coordinate come Map
      return {
        'latitudine': double.parse(primoRisultato['lat'] as String),
        'longitudine': double.parse(primoRisultato['lon'] as String),
      };
    } on EccezioneGeocoding {
      rethrow;
    } catch (errore) {
      throw EccezioneGeocoding('Errore di rete: $errore');
    }
  }
}