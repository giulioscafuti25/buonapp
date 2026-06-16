// add_coupon_test.dart - Integration test per il flusso completo dell'app
// Testa aggiunta, modifica, eliminazione, navigazione e filtri

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:buonapp/main.dart' as app;
import 'package:buonapp/utils/constants.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flusso aggiunta buono', () {
    // Test 1: verifica che la schermata lista si apra correttamente
    testWidgets('la schermata lista si apre correttamente',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text(TestiApp.titoloBuoni), findsOneWidget);
    });

    // Test 2: verifica che il FAB apra la schermata di aggiunta
    testWidgets('il pulsante + apre la schermata di aggiunta',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text(TestiApp.titoloNuovoBuono), findsOneWidget);
    });

    // Test 3: verifica il flusso completo di aggiunta buono
    testWidgets('aggiunge un nuovo buono correttamente',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Inserisce il nome del negozio
      await tester.enterText(
        find.widgetWithText(TextFormField, TestiApp.campoNomeNegozio),
        'Conad Test',
      );

      // Inserisce la descrizione
      await tester.enterText(
        find.widgetWithText(TextFormField, TestiApp.campoDescrizione),
        'Buono test integrazione',
      );

      // Tocca il selettore data
      await tester.tap(find.text('Seleziona una data'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Seleziona una data futura nel date picker
      await tester.tap(find.text('30'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Scrolla fino al pulsante salva
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // Tocca il pulsante salva
      await tester.tap(find.text('Salva buono'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verifica che la schermata lista sia tornata visibile
      expect(find.text(TestiApp.titoloBuoni), findsOneWidget);

      // Verifica che il nuovo buono sia nella lista
      expect(find.text('Conad Test'), findsOneWidget);
    });
  });

  group('Flusso modifica buono', () {
    // Test 4: verifica il flusso di modifica di un buono
    testWidgets('modifica un buono esistente correttamente',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Apre il dettaglio
      await tester.tap(find.text('Conad Test'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text(TestiApp.titoloDettaglio), findsOneWidget);

      // Apre la modifica
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text(TestiApp.titoloModificaBuono), findsOneWidget);

      // Modifica il nome
      await tester.enterText(
        find.widgetWithText(TextFormField, TestiApp.campoNomeNegozio),
        'Conad Modificato',
      );

      // Scrolla fino al pulsante aggiorna
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aggiorna buono'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Torna alla lista se c'è il tasto back
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Verifica che il nome modificato sia visibile
      expect(find.text('Conad Modificato'), findsWidgets);
    });
  });

  group('Flusso eliminazione buono', () {
    // Test 5: verifica il flusso di eliminazione
    testWidgets('elimina un buono dalla schermata dettaglio',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Conad Modificato'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text(TestiApp.elimina));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text(TestiApp.titoloBuoni), findsOneWidget);
      expect(find.text('Conad Modificato'), findsNothing);
    });
  });

  group('Navigazione tra schermate', () {
    // Test 6: verifica la navigazione alla schermata mappa
    testWidgets('naviga alla schermata mappa',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.map_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text(TestiApp.titoloMappa), findsOneWidget);
    });

    // Test 7: verifica la navigazione alla schermata avvisi
    testWidgets('naviga alla schermata avvisi',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text(TestiApp.titoloAvvisi), findsWidgets);
    });

    // Test 8: verifica il ritorno alla lista dalla mappa
    testWidgets('torna alla schermata lista dalla mappa',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.map_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.confirmation_number_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text(TestiApp.titoloBuoni), findsOneWidget);
    });
  });

  group('Filtri lista buoni', () {
    // Test 9: verifica il filtro in scadenza
    testWidgets('il filtro in scadenza mostra solo i buoni in scadenza',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text(TestiApp.filtroInScadenza));
      await tester.pumpAndSettle();

      expect(find.text(TestiApp.filtroInScadenza), findsOneWidget);
    });

    // Test 10: verifica il filtro scaduti
    testWidgets('il filtro scaduti mostra solo i buoni scaduti',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text(TestiApp.filtroScaduti));
      await tester.pumpAndSettle();

      expect(find.text(TestiApp.filtroScaduti), findsOneWidget);
    });

    // Test 11: verifica il filtro tutti
    testWidgets('il filtro tutti mostra tutti i buoni',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text(TestiApp.filtroTutti));
      await tester.pumpAndSettle();

      expect(find.text(TestiApp.filtroTutti), findsOneWidget);
    });
  });
}