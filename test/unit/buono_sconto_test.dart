// buono_sconto.dart - Unit test per il modello BuonoSconto
//Testa la logica del modello senza dipendenze esterne

import 'package:flutter_test/flutter_test.dart';
import 'package:buonapp/models/buono_sconto.dart';

void main(){
  //Gruppo di test per il modello BuonoSconto
  group('BuonoSconto', () {
    //Buono di esempio usato nei test
    late BuonoSconto buonoEsempio;

    setUp(() {
      //Inizializza il buono di esempio prima di ogni test
      buonoEsempio = BuonoSconto(
        id: 1,
        nomeNegozio: 'Conad',
        descrizione: '10% su tutto',
        dataScadenza: DateTime.now().add(const Duration(days: 10)),
        dataAggiunta: DateTime.now(),
      );
    });

    //Test 1: verifica che un buono non scaduto sia valido
    test('un buono con data futura non è scaduto', () {
      expect(buonoEsempio.eScaduto, false);
    });

    //Test 2 : verifica che un buono scaduto sia riconosciuto
      test('un buono con data passata è scaduto', (){
        final buonoScaduto = BuonoSconto(
          id: 2,
          nomeNegozio: 'Eurospin',
          descrizione: '5% su tutto',
          dataScadenza: DateTime.now().subtract(const Duration(days: 1)),
          dataAggiunta: DateTime.now(), 
      );
      expect(buonoScaduto.eScaduto, true);
    });

    //Test 3: verifica che un buono in scadenza sia riconosciuto
    test('un buono che scade entro 7 giorni sta per scadere', (){
      final buonoInScadenza = BuonoSconto(
        id: 3,
        nomeNegozio: 'Coop',
        descrizione: '2€ pane',
        dataScadenza: DateTime.now().add(const Duration(days: 5)),
        dataAggiunta: DateTime.now(),
      );
      expect(buonoInScadenza.staPerScadere, true);
    });

    //Test 4: verifica che un buono con scadenza lontana non stia per scadere
    test('un buono che scade tra 30 giorni non sta per scadere', (){
      expect(buonoEsempio.staPerScadere, false);
    });

    //Test 5: verificha il calcolo dei giorni alla scadenza
    test('i giorni alla scadenza solo calcolati correttamente', (){
      final giorni = buonoEsempio.giorniAllaScadenza;
      expect(giorni, greaterThanOrEqualTo(9));
      expect(giorni, lessThanOrEqualTo(10));
    });

    //Test 6: verifica la conversione a database e ritorno
    test('la conversione aDatabase e dalDatabase è consistente',(){
      final mappa = buonoEsempio.aDatabase();
      final buonoRicreato = BuonoSconto.dalDatabase(mappa);
      expect(buonoRicreato.nomeNegozio, buonoEsempio.nomeNegozio);
      expect(buonoRicreato.descrizione, buonoEsempio.descrizione);
      expect(
        buonoRicreato.dataScadenza.toIso8601String(),
        buonoEsempio.dataScadenza.toIso8601String(),
      );
    });

    //Test 7 : verifica il metodo copiaCon
    test('copiaCon crea una copia con i campi aggiornati', (){
      final buonoModificato = buonoEsempio.copiaCon(
        nomeNegozio: 'Lidl',
      );
      expect(buonoModificato.nomeNegozio, 'Lidl');
      expect(buonoModificato.descrizione, buonoEsempio.descrizione);
      expect(buonoModificato.id, buonoEsempio.id);
    });
  });
}