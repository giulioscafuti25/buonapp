// location_service.dart - Servizio per la gestione del GPS
// Gestisce i permessi e il recupero della posizione corrente dell'utente

import 'package:geolocator/geolocator.dart';

class ServizioPosizione{
  //Richiede i permessi GPS e restituisce la posizione corrente dell'utente
  //Lancia un'eccezione se i permessi vengono negati
  static Future<Position> ottieniPosizione() async{
    //Controlla se il GPS è abilitato sul dispotivio
    final gpsAbilitato = await Geolocator.isLocationServiceEnabled();
    if (!gpsAbilitato) {
      throw Exception('Il GPS non è abilitato. Attivalo nelle impostazioni');
    }

    //Controlla lo stato attuale dei permessi
    LocationPermission permesso = await Geolocator.checkPermission();

    //Se i permessi non sono stati ancora concessi, li richiede
    if (permesso == LocationPermission.denied) {
      permesso = await Geolocator.requestPermission();

      //Se l'utente nega i permessi lancia un'eccezione
      if (permesso == LocationPermission.denied) {
        throw Exception('Permessi GPS negati. Non posso recuperare la posizione');
      }
    }

    //Se i permessi sono stati negati permanenentemente, lancia un'eccezione
    if (permesso == LocationPermission.deniedForever) {
      throw Exception(
        'Permessi GPS negati permanentemente. '
        'Abilitati nelle impostazioni dell\'app',
      );
  }

  //Ottieni la posizione corrente con alta precisione
  return await Geolocator.getCurrentPosition(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );
  }

  //Restituisce true se i permessi GPS sono stati concessi
  static Future<bool> haiPermessiGPS() async {
  final permesso = await Geolocator.checkPermission();
  return permesso == LocationPermission.always ||
      permesso == LocationPermission.whileInUse;
  }
}