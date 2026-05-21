// list_screen.dart - Schermata principale con la lista dei buoni sconto
// Mostra tutti i buoni con filtri e permette di aggiungerne di nuovi

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/buono_sconto.dart';
import '../providers/buoni_provider.dart';
import '../utils/constants.dart';
import '../widgets/coupon_card.dart';
import '../screens/add_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/map_screen.dart';
import '../screens/alerts_screen.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Osserva la lista filtrata dei buoni
    final buoniFiltrati = ref.watch(providerBuoniFiltrati);
    // Osserva il filtro attivo
    final filtroAttivo = ref.watch(providerFiltro);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColoriApp.principale,
        title: const Text(
          TestiApp.titoloBuoni,
          style: TextStyle(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _costruisciChipFiltri(context, ref, filtroAttivo),
        ),
      ),
      body: buoniFiltrati.when(
        data: (listaBuoni) => _costruisciLista(context, ref, listaBuoni),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (errore, stack) => _costruisciErrore(context, ref),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _apriSchermataAggiungi(context),
        backgroundColor: ColoriApp.principale,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _costruisciNavBar(context, 0),
    );
  }

  Widget _costruisciChipFiltri(
      BuildContext context, WidgetRef ref, FiltroBuoni filtroAttivo) {
    return Container(
      color: ColoriApp.principale,
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Row(
        children: [
          _costruisciChip(
            context: context,
            ref: ref,
            etichetta: TestiApp.filtroTutti,
            filtro: FiltroBuoni.tutti,
            filtroAttivo: filtroAttivo,
          ),
          const SizedBox(width: 8),
          _costruisciChip(
            context: context,
            ref: ref,
            etichetta: TestiApp.filtroInScadenza,
            filtro: FiltroBuoni.inScadenza,
            filtroAttivo: filtroAttivo,
          ),
          const SizedBox(width: 8),
          _costruisciChip(
            context: context,
            ref: ref,
            etichetta: TestiApp.filtroScaduti,
            filtro: FiltroBuoni.scaduti,
            filtroAttivo: filtroAttivo,
          ),
        ],
      ),
    );
  }

  Widget _costruisciChip({
    required BuildContext context,
    required WidgetRef ref,
    required String etichetta,
    required FiltroBuoni filtro,
    required FiltroBuoni filtroAttivo,
  }) {
    final eAttivo = filtro == filtroAttivo;

    return GestureDetector(
      onTap: () => ref.read(providerFiltro.notifier).cambiaFiltro(filtro),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: eAttivo ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: eAttivo ? Colors.white : Colors.white60,
          ),
        ),
        child: Text(
          etichetta,
          style: TextStyle(
            fontSize: 12,
            fontWeight: eAttivo ? FontWeight.w600 : FontWeight.normal,
            color: eAttivo ? ColoriApp.principale : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _costruisciLista(
      BuildContext context, WidgetRef ref, List<BuonoSconto> listaBuoni) {
    if (listaBuoni.isEmpty) {
      return _costruisciListaVuota();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: listaBuoni.length,
      itemBuilder: (context, indice) {
        final buono = listaBuoni[indice];
        return CardBuono(
          buono: buono,
          onTocco: () => _apriDettaglio(context, buono),
          onElimina: () => _eliminaBuono(context, ref, buono.id!),
        );
      },
    );
  }

  Widget _costruisciListaVuota() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 80,
            color: ColoriApp.principale.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nessun buono trovato',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: ColoriApp.testoSecondario,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Premi + per aggiungere il tuo primo buono',
            style: TextStyle(
              fontSize: 14,
              color: ColoriApp.testoSecondario,
            ),
          ),
        ],
      ),
    );
  }

  Widget _costruisciErrore(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: ColoriApp.scaduto,
          ),
          const SizedBox(height: 16),
          const Text(
            'Impossibile caricare i buoni.\nControlla la memoria del dispositivo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: ColoriApp.testoSecondario,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(providerBuoni),
            icon: const Icon(Icons.refresh),
            label: const Text('Riprova'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoriApp.principale,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _costruisciNavBar(BuildContext context, int indiceAttivo) {
    return BottomNavigationBar(
      currentIndex: indiceAttivo,
      selectedItemColor: ColoriApp.principale,
      onTap: (indice) => _navigaA(context, indice),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_number_outlined),
          label: 'Buoni',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: 'Mappa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: 'Avvisi',
        ),
      ],
    );
  }

  void _navigaA(BuildContext context, int indice) {
    switch (indice) {
      case 0:
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MapScreen()),
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AlertsScreen()),
        );
        break;
    }
  }

  void _apriSchermataAggiungi(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddScreen()),
    );
  }

  void _apriDettaglio(BuildContext context, BuonoSconto buono) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailScreen(buono: buono)),
    );
  }

  Future<void> _eliminaBuono(
      BuildContext context, WidgetRef ref, int id) async {
    try {
      await ref.read(providerBuoni.notifier).eliminaBuono(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buono eliminato con successo!'),
            backgroundColor: ColoriApp.valido,
          ),
        );
      }
    } catch (errore) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossibile eliminare il buono. Riprova più tardi.',
            ),
            backgroundColor: ColoriApp.scaduto,
          ),
        );
      }
    }
  }
}