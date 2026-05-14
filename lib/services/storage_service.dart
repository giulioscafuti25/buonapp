//storage_serice.dart - Servizio per la persistenza locale dei dati
//Gestisce tutte le operazioni CRUD sul database SQLite

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/buono_sconto.dart';

//Eccezione personalizzata per errori di storage
class EccezioneStorage implements Exception {
  final String messaggio;
  const EccezioneStorage(this.messaggio);
  @override
  String toString() => 'EccezioneStorage: $messaggio';
}

class ServizioStorage {
  //Istanza singola del servizio (pattern Singleton)
  static final ServizioStorage _istanza = ServizioStorage._interno();

  //Riferimento al database SQLite
  static Database? _database;

  //Costruttore privato per il pattern Singleton
  ServizioStorage._interno();
  
  //Factory che restituisce sempre la stessa istanza
  factory ServizioStorage() => _istanza;

  //Getter che inizializza il database se non esiste ancora
  Future<Database> get database async{
    if (_database != null) return _database!;
    _database = await _inizializzaDatabase();
    return _database!;
  }

  //Inizializza il database SqLite e crea la tabella se non esiste
  Future<Database> _inizializzaDatabase() async {
    try{
    //Ottieni il percorso della cartella dei database sul dispositivo
    final percorsoDatabase = await getDatabasesPath();

    //Percorso completo del file del file del database
    final percorsoCompleto = join(percorsoDatabase, 'buonapp.db');

    return await openDatabase(
      percorsoCompleto,
      version: 1,
      onCreate: _creaTavole,
    );
    } catch (errore){
      throw EccezioneStorage('Errore durante l\'inizializzazione del database: $errore');
    }
  }
  
  //Crea le tavole del databale alla prima apertura
  Future<void> _creaTavole(Database db, int versione) async {
    try{
    await db.execute('''
      CREATA TABLE buoni(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeNegozio TEXT NOT NULL,
        descrizione TEXT NOT NULL,
        dataScadenza TEXT NOT NULL,
        percorsoFoto TEXT,
        latitudine REAL,
        longitudine REAL,
        indirizzo TEXT,
        dataAggiunta TEXT NOT NULL
      )
      ''');
    } catch (errore){
      throw EccezioneStorage('Errore durante la creazione delle tavole: $errore');
    }

  }

  //Inserisce un nuovo buono sconto nel database
  //Restituisce l'id del buono appena inserito
  Future<int> inserisciBuono(BuonoSconto buono) async {
    try{
    final db = await database;
    final mappa = buono.aDatabase();
    //Rimuoviamo l'id dalla mappa perchè è AUTOINCREMENT
    mappa.remove('id');
    return await db.insert('buoni', mappa);
    } catch (errore){
      throw EccezioneStorage('Errore durante l\'inserimento del buono: $errore');
    }
  }

  //Restituisce tutti i buoni sconto presenti nel database
  Future<List<BuonoSconto>> caricaTuttiBuoni() async {
    try {
    final db = await database;
    final listaMappe = await db.query(
      'buoni',
      orderBy: 'dataScadenza ASC' //ordina per data di scadenza crescente
    );
    return listaMappe.map((mappa) => BuonoSconto.dalDatabase(mappa)).toList();
    } catch (errore){
      throw EccezioneStorage('Errore durante il caricamento dei buoni: $errore');
    }

  }

  //Aggiorna un buono esistente nel database
  Future<void> aggiornaBuono(BuonoSconto buono) async {
    try {
    final db = await database;
    await db.update(
      'buoni',
      buono.aDatabase(),
      where: 'id = ?',
      whereArgs: [buono.id]
    );
    } catch (errore){
      throw EccezioneStorage('Errore durante l\'aggiornamento del buono: $errore');
    }
  }

  //Elimina un buono dal database dato il suo id
  Future<void> eliminaBuono(int id) async {
    try {
    final db = await database;
    await db.delete(
      'buoni',
      where: 'id = ?',
      whereArgs: [id]
    );
    } catch (errore){
      throw EccezioneStorage('Errore durante l\'eliminazione del buono: $errore');
    }
  }

  //Chiude la connessione al database 
  Future<void> chiudiDatabase() async {
    try {
    final db = await database;
    await db.close();
    } catch (errore){
      throw EccezioneStorage('Errore durante la chiusura del database: $errore');
    }
  }
}