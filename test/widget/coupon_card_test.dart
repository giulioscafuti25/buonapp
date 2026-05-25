//coupon_card_test.dart - Widget test per la CardBuono
//Testa il rendering e le interazioni della card del buono

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buonapp/models/buono_sconto.dart';
import 'package:buonapp/widgets/coupon_card.dart';

void main(){
  //Buono di esempio usato nei test
  final buonoEsempio = BuonoSconto(
    id: 1,
    nomeNegozio: 'Conad',
    descrizione: '10% su tutto',
    dataScadenza: DateTime.now().add(const Duration(days: 10)),
    dataAggiunta: DateTime.now(),
  );

  //Funzione helper per costruire il widget in un contesto di test
  Widget costruisciWidget({
    VoidCallback? onTocco,
    VoidCallback? onElimina,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CardBuono(
          buono: buonoEsempio,
          onTocco: onTocco ?? () {},
          onElimina: onElimina ?? () {},
        ),
      ),
    );
  }

  group('CardBuono', (){
    //Test 1: verifica che il nome del negozio sia visualizzato
    testWidgets('mostra il nome del negozio', (WidgetTester tester) async{
      await tester.pumpWidget(costruisciWidget());
      expect(find.text('Conad'), findsOneWidget);
    });

    //Test 2: verifica che la descrizione sia visualizzata
    testWidgets('mostra la descrizione del buono', (WidgetTester tester) async {
      await tester.pumpWidget(costruisciWidget());
      expect(find.text('10% su tutto'), findsOneWidget);
    });

    //Test 3: verifica che il badge di scadenza sia visualizzato
    testWidgets('mostra il badge di scadenza', (WidgetTester tester) async{
      await tester.pumpWidget(costruisciWidget());
      expect(find.text('Valido'), findsOneWidget);
    });

    //Test 4: verifica che il tocco sulla card chiami la callback
    testWidgets('chiama onTocco quando viene toccata',
    (WidgetTester tester) async{
      //Flag per verificare che la callback sia stata chiamata
      bool toccato = false;

      await tester.pumpWidget(costruisciWidget(
        onTocco: () => toccato = true,
      ));

      //Tocca la card
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(toccato, true);
    });

    //Test 5: verifica che un buono scaduto mostri il badge corretto
    testWidgets('mostra badge scaduto per un buono scaduto',
      (WidgetTester tester) async{
        final buonoScaduto = BuonoSconto(
          id: 2,
          nomeNegozio: 'Esselunga',
          descrizione: '5% su tutto',
          dataScadenza: DateTime.now().subtract(const Duration(days: 1)),
          dataAggiunta: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CardBuono(
                buono: buonoScaduto,
                onTocco: () {},
                onElimina: () {},
              ),
            ),
          ),
        );

        expect(find.text('Scaduto'), findsOneWidget);
      });
  });
}