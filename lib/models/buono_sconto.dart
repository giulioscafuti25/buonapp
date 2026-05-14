// buono_sconto.dart - Modello principale del buono sconto
//Contiene la struttura dati del buono e i metodi di conversione per il database

class BuonoSconto{
  //Identificatore univoco del buono (null se non ancora salvato nel database)
  final int? id;

  //Nome del supermercato dove è stato ricevuto il buono
  final String nomeNegozio;

  //Destizione o nota aggiuntiva sul buono
  final String descrizione;

  //Data di scadenza del buono
  final DateTime dataScadenza;

  //Percorso locale della foto del buono salvata sul dispositivo
  final String? percorsoFoto;

  //Latitutinde della posizione del negozio
  final double? latitudine;

  //Longitudine della posizione del negozio
  final double? longitudine;

  //Indirizzo testuale del negozio (ottenuto tramite geocoding inverso)
  final String? indirizzo;

  //Data in cui il buono è stato aggiunto
  final DateTime dataAggiunta;

  //Costruttore principale del buono sconto
  const BuonoSconto({
    this.id,
    required this.nomeNegozio,
    required this.descrizione,
    required this.dataScadenza,
    this.percorsoFoto,
    this.latitudine,
    this.longitudine,
    this.indirizzo,
    required this.dataAggiunta,
  });

  //Restituisce true se il buono è già scaduto
  bool get eScaduto => DateTime.now().isAfter(dataScadenza);

  //Restituisce il numero di giorni rimanenti alla scadenza (negativo se già scaduto)
  int get giorniAllaScadenza =>
    dataScadenza.difference(DateTime.now()).inDays;

  //Restituisce true se il buono scade entro i prossimi 7 giorni
  bool get staPerScadere =>
    !eScaduto && giorniAllaScadenza <= 7;

  //Converte il buono in una Map per salvarlo nel dabatase SqLite
  Map<String,dynamic> aDatabase(){
    return{
      'id': id,
      'nomeNegozio': nomeNegozio,
      'descrizione': descrizione,
      'dataScadenza': dataScadenza.toIso8601String(),
      'percorsoFoto': percorsoFoto,
      'latitudine': latitudine,
      'longitudine': longitudine,
      'indirizzo': indirizzo,
      'dataAggiunta': dataAggiunta.toIso8601String(),
    };
  }

  //Crea un buono sconto da una Map proveniente dal database SqLite
  factory BuonoSconto.dalDatabase(Map<String, dynamic> mappa) {
    return BuonoSconto(
      id: mappa['id'] as int?,
      nomeNegozio: mappa['nomeNegozio'] as String,
      descrizione: mappa['descrizione'] as String,
      dataScadenza: DateTime.parse(mappa['dataScadenza'] as String),
      percorsoFoto: mappa['percorsoFoto'] as String?,
      latitudine: mappa['latitudine'] as double?,
      longitudine: mappa['longitudine'] as double?,
      indirizzo: mappa['indirizzo'] as String?,
      dataAggiunta: DateTime.parse(mappa['dataAggiunta'] as String),
    );
  }

  //Crea una copia del buono con alcuni campi modificati
  BuonoSconto copiaCon({
    int? id,
    String? nomeNegozio,
    String? descrizione,
    DateTime? dataScadenza,
    String? percorsoFoto,
    double? latitudine,
    double? longitudine,
    String? indirizzo,
    DateTime? dataAggiunta,
    }) {
      return BuonoSconto(
        id: id ?? this.id,
        nomeNegozio: nomeNegozio ?? this.nomeNegozio,
        descrizione: descrizione ?? this.descrizione,
        dataScadenza: dataScadenza ?? this.dataScadenza,
        percorsoFoto: percorsoFoto ?? this.percorsoFoto,
        latitudine: latitudine ?? this.latitudine,
        longitudine: longitudine ?? this.longitudine,
        indirizzo: indirizzo ?? this.indirizzo,
        dataAggiunta: dataAggiunta ?? this.dataAggiunta,
      );
  }
}