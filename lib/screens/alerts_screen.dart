// alerts_screen.dart - Schermata degli avvisi e impostazioni notifiche
// Permette di gestire le preferenze delle notifiche e vedere lo storico degli avvisi

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/buono_sconto.dart';
import '../providers/buoni_provider.dart';
import '../providers/preferenze_provider.dart';
import '../utils/constants.dart';
import '../utils/date_extensions.dart';
import '../widgets/expiry_badge.dart';
import '../screens/list_screen.dart';
import '../screens/map_screen.dart';
import '../screens/detail_screen.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Osserva le preferenze notifiche
    final preferenze = ref.watch(providerPreferenze);
    // Osserva la lista dei buoni
    final tuttiBuoni = ref.watch(providerBuoni);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColoriApp.principale,
        title: const Text(
          TestiApp.titoloAvvisi,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DimensioniApp.paddingPagina),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _costruisciTitoloSezione('Impostazioni notifiche'),
            const SizedBox(height: 8),
            preferenze.when(
              data: (prefs) => _costruisciImpostazioni(context, ref, prefs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (errore, stack) => const Text(
                'Impossibile caricare le impostazioni. Riprova più tardi.',
                style: TextStyle(color: ColoriApp.scaduto),
              ),
            ),
            const SizedBox(height: 24),
            _costruisciTitoloSezione('Avvisi recenti'),
            const SizedBox(height: 8),
            tuttiBuoni.when(
              data: (listaBuoni) =>
                  _costruisciStoricoAvvisi(context, listaBuoni),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (errore, stack) => const Text(
                'Impossibile caricare gli avvisi. Riprova più tardi.',
                style: TextStyle(color: ColoriApp.scaduto),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _costruisciNavBar(context, 2),
    );
  }

  // Costruisce il titolo di una sezione
  Widget _costruisciTitoloSezione(String titolo) {
    return Text(
      titolo.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: ColoriApp.testoSecondario,
        letterSpacing: 0.5,
      ),
    );
  }

  // Costruisce la sezione delle impostazioni notifiche
  Widget _costruisciImpostazioni(
      BuildContext context, WidgetRef ref, PreferenzeNotifiche prefs) {
    return Card(
      child: Column(
        children: [
          // Toggle notifiche attive
          _costruisciRigaToggle(
            icona: Icons.notifications_outlined,
            titolo: 'Notifiche attive',
            descrizione: 'Ricevi avvisi di scadenza',
            valore: prefs.notificheAttive,
            onCambiamento: (nuovoValore) {
              ref
                  .read(providerPreferenze.notifier)
                  .impostaNotificheAttive(nuovoValore);
            },
          ),
          const Divider(height: 1),

          // Selettore giorni anticipo
          _costruisciRigaSelettore(
            icona: Icons.access_time_outlined,
            titolo: 'Avvisa con anticipo',
            descrizione: 'Giorni prima della scadenza',
            valore: '${prefs.giorniAnticipo} gg',
            abilitato: prefs.notificheAttive,
            onTocco: () => _mostraSelettoreGiorni(context, ref, prefs),
          ),
          const Divider(height: 1),

          // Selettore orario notifica
          _costruisciRigaSelettore(
            icona: Icons.wb_sunny_outlined,
            titolo: 'Orario notifica',
            descrizione: 'Quando ricevere l\'avviso',
            valore:
                '${prefs.orarioNotifica.toString().padLeft(2, '0')}:${prefs.minutiNotifica.toString().padLeft(2, '0')}',
            abilitato: prefs.notificheAttive,
            onTocco: () => _mostraSelettoreOrario(context, ref, prefs),
          ),
        ],
      ),
    );
  }

  // Costruisce una riga con toggle
  Widget _costruisciRigaToggle({
    required IconData icona,
    required String titolo,
    required String descrizione,
    required bool valore,
    bool abilitato = true,
    required Function(bool) onCambiamento,
  }) {
    return Opacity(
      opacity: abilitato ? 1.0 : 0.5,
      child: ListTile(
        leading: Icon(icona, color: ColoriApp.principale),
        title: Text(titolo, style: const TextStyle(fontSize: 14)),
        subtitle: Text(descrizione,
            style: const TextStyle(
                fontSize: 12, color: ColoriApp.testoSecondario)),
        trailing: Switch(
          value: valore,
          onChanged: abilitato ? onCambiamento : null,
          activeThumbColor: ColoriApp.principale,
        ),
      ),
    );
  }

  // Costruisce una riga con selettore
  Widget _costruisciRigaSelettore({
    required IconData icona,
    required String titolo,
    required String descrizione,
    required String valore,
    bool abilitato = true,
    required VoidCallback onTocco,
  }) {
    return Opacity(
      opacity: abilitato ? 1.0 : 0.5,
      child: ListTile(
        leading: Icon(icona, color: ColoriApp.principale),
        title: Text(titolo, style: const TextStyle(fontSize: 14)),
        subtitle: Text(descrizione,
            style: const TextStyle(
                fontSize: 12, color: ColoriApp.testoSecondario)),
        trailing: GestureDetector(
          onTap: abilitato ? onTocco : null,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ColoriApp.sfondoSecondario,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: ColoriApp.bordoChiaro),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(valore,
                    style: const TextStyle(
                        fontSize: 13, color: ColoriApp.testoSecondario)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down,
                    size: 16, color: ColoriApp.testoSecondario),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Costruisce lo storico degli avvisi
  // Mostra solo i buoni in scadenza entro 7 giorni e quelli scaduti
  Widget _costruisciStoricoAvvisi(
      BuildContext context, List<BuonoSconto> listaBuoni) {
    final buoniDaAvvisare = listaBuoni
        .where((buono) => buono.staPerScadere || buono.eScaduto)
        .toList()
      ..sort((a, b) {
        if (a.eScaduto && !b.eScaduto) return 1;
        if (!a.eScaduto && b.eScaduto) return -1;
        return a.dataScadenza.compareTo(b.dataScadenza);
      });

    if (buoniDaAvvisare.isEmpty) {
      return const Center(
        child: Text(
          'Nessun avviso — tutti i buoni sono validi! 🎉',
          style: TextStyle(color: ColoriApp.testoSecondario),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: buoniDaAvvisare.map((buono) {
        return _costruisciRigaAvviso(context, buono);
      }).toList(),
    );
  }

  // Costruisce una riga dello storico avvisi
  // Toccando la riga naviga al dettaglio del buono
  Widget _costruisciRigaAvviso(BuildContext context, BuonoSconto buono) {
    final IconData icona;
    final Color coloreIcona;
    final Color coloreSfondo;

    if (buono.eScaduto) {
      icona = Icons.cancel_outlined;
      coloreIcona = ColoriApp.scaduto;
      coloreSfondo = ColoriApp.scadutoSfondo;
    } else if (buono.staPerScadere) {
      icona = Icons.warning_amber_rounded;
      coloreIcona = ColoriApp.inScadenza;
      coloreSfondo = ColoriApp.inScadenzaSfondo;
    } else {
      icona = Icons.check_circle_outline;
      coloreIcona = ColoriApp.valido;
      coloreSfondo = ColoriApp.validoSfondo;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailScreen(buono: buono),
          ),
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: coloreSfondo,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icona, color: coloreIcona, size: 20),
        ),
        title: Text(
          buono.nomeNegozio,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scade il ${buono.dataScadenza.formattoItaliano}',
              style: const TextStyle(
                  fontSize: 11, color: ColoriApp.testoSecondario),
            ),
            const SizedBox(height: 2),
            Text(
              buono.dataScadenza.descrizioneScadenza,
              style: TextStyle(
                fontSize: 11,
                color: buono.eScaduto
                    ? ColoriApp.scaduto
                    : buono.staPerScadere
                        ? ColoriApp.inScadenza
                        : ColoriApp.valido,
              ),
            ),
            const SizedBox(height: 4),
            BadgeScadenza(buono: buono),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: ColoriApp.bordoChiaro,
        ),
        isThreeLine: true,
      ),
    );
  }

  // Mostra il selettore dei giorni di anticipo
  void _mostraSelettoreGiorni(
      BuildContext context, WidgetRef ref, PreferenzeNotifiche prefs) {
    final opzioniGiorni = [1, 3, 5, 7];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DimensioniApp.raggioBordoBottomSheet),
        ),
      ),
      builder: (contestoSheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: ColoriApp.bordoChiaro,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Giorni di anticipo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...opzioniGiorni.map((giorni) {
              final eSelezionato = giorni == prefs.giorniAnticipo;
              return ListTile(
                title: Text('$giorni giorni prima'),
                trailing: eSelezionato
                    ? const Icon(Icons.check, color: ColoriApp.principale)
                    : null,
                onTap: () {
                  ref
                      .read(providerPreferenze.notifier)
                      .impostaGiorniAnticipo(giorni);
                  Navigator.of(contestoSheet).pop();
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Mostra il selettore dell'orario della notifica
  void _mostraSelettoreOrario(
      BuildContext context, WidgetRef ref, PreferenzeNotifiche prefs) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: prefs.orarioNotifica,
        minute: prefs.minutiNotifica,
      ),
    ).then((orarioSelezionato) {
      if (orarioSelezionato != null) {
        try {
          ref
              .read(providerPreferenze.notifier)
              .impostaOrarioNotifica(
                orarioSelezionato.hour,
                orarioSelezionato.minute,
              );
        } catch (errore) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Impossibile salvare l\'orario. Riprova più tardi.',
                ),
                backgroundColor: ColoriApp.scaduto,
              ),
            );
          }
        }
      }
    });
  }

  // Costruisce la barra di navigazione inferiore
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

  // Naviga alla schermata corrispondente all'indice
  void _navigaA(BuildContext context, int indice) {
    switch (indice) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ListScreen()),
        );
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MapScreen()),
        );
        break;
      case 2:
        break;
    }
  }
}