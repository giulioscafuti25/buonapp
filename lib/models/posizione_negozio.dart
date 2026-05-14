//posizione negozio.dart - Modello per la posizione di un negozio
//Contiene le coordinate GPS e l'indirizzo testuale del negozio

class PosizioneNegozio {
  //Latitudine della posizione del negozio
  final double latitudine;

  //Longitudine della posizione del negozio;
  final double longitudine;

  //Indirizzo testuale del negozio (ottenuto tramite geocoding)
  final String? indirizzo;

  //Nome del negozio
  final String nomeNegozio;

  const PosizioneNegozio({
    required this.latitudine,
    required this.longitudine,
    required this.nomeNegozio,
    this.indirizzo,
  });

  //Restituisce una stringa con le coordinate nel formato "lat, lon"
  String get coordinateFormattate =>
  '${latitudine.toStringAsFixed(6)}, ${longitudine.toStringAsFixed(6)}';

  //Restituisce l'indirizzo se disponibile, altrimenti le coordinate
  String get indirizzoOCoordinate => indirizzo ?? coordinateFormattate;

  //Crea una copia della posizione con alcuni campi modificati
  PosizioneNegozio copiaCon({
    double? latitudine,
    double? longitudine,
    String? nomeNegozio,
    String? indirizzo,
  }) {
    return PosizioneNegozio(
      latitudine: latitudine ?? this.latitudine,
      longitudine: longitudine ?? this.longitudine,
      nomeNegozio: nomeNegozio ?? this.nomeNegozio,
      indirizzo: indirizzo ?? this.indirizzo,
    );
  }
}