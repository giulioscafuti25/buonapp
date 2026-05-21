// detail_screen.dart - Schermata di dettaglio del buono sconto
// Mostra tutte le informazioni del buono con opzioni di modifica ed eliminazione

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/buono_sconto.dart';
import '../providers/buoni_provider.dart';
import '../utils/constants.dart';
import '../utils/date_extensions.dart';
import '../widgets/expiry_badge.dart';
import '../screens/edit_screen.dart';

class DetailScreen extends ConsumerWidget {
  // Il buono da visualizzare
  final BuonoSconto buono;

  const DetailScreen({super.key, required this.buono});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColoriApp.principale,
        title: const Text(
          TestiApp.titoloDettaglio,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Tasto modifica
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _apriModifica(context),
          ),
          // Tasto elimina
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confermaElimina(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto del buono
            _costruisciFoto(),

            Padding(
              padding: const EdgeInsets.all(DimensioniApp.paddingPagina),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome negozio e badge scadenza
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          buono.nomeNegozio,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      BadgeScadenza(buono: buono),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Data di scadenza
                  _costruisciRigaInfo(
                    icona: Icons.calendar_today_outlined,
                    etichetta: 'Data di scadenza',
                    valore: buono.dataScadenza.formattoItaliano,
                  ),
                  const SizedBox(height: 12),

                  // Descrizione scadenza
                  _costruisciRigaInfo(
                    icona: Icons.timelapse_outlined,
                    etichetta: 'Stato',
                    valore: buono.dataScadenza.descrizioneScadenza,
                  ),
                  const SizedBox(height: 12),

                  // Descrizione
                  _costruisciRigaInfo(
                    icona: Icons.note_outlined,
                    etichetta: 'Descrizione',
                    valore: buono.descrizione,
                  ),
                  const SizedBox(height: 12),

                  // Data aggiunta
                  _costruisciRigaInfo(
                    icona: Icons.add_circle_outline,
                    etichetta: 'Aggiunto il',
                    valore: buono.dataAggiunta.formattoItaliano,
                  ),

                  // Indirizzo se disponibile
                  if (buono.indirizzo != null) ...[
                    const SizedBox(height: 12),
                    _costruisciRigaInfo(
                      icona: Icons.location_on_outlined,
                      etichetta: 'Negozio',
                      valore: buono.indirizzo!,
                    ),
                  ],

                  // Mappa se le coordinate sono disponibili
                  if (buono.latitudine != null &&
                      buono.longitudine != null) ...[
                    const SizedBox(height: 20),
                    _costruisciMappa(context, ref),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Costruisce la foto del buono in cima alla schermata
  Widget _costruisciFoto() {
    if (buono.percorsoFoto != null) {
      return Image.file(
        File(buono.percorsoFoto!),
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, errore, stack) => _costruisciPlaceholderFoto(),
      );
    }
    return _costruisciPlaceholderFoto();
  }

  // Costruisce il placeholder quando non c'è foto
  Widget _costruisciPlaceholderFoto() {
    return Container(
      width: double.infinity,
      height: 220,
      color: ColoriApp.principaleChiaro,
      child: const Icon(
        Icons.confirmation_number_outlined,
        size: 80,
        color: ColoriApp.principale,
      ),
    );
  }

  // Costruisce una riga con icona, etichetta e valore
  Widget _costruisciRigaInfo({
    required IconData icona,
    required String etichetta,
    required String valore,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icona, size: 20, color: ColoriApp.principale),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etichetta,
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoriApp.testoSecondario,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valore,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Costruisce la mappa con il pin del negozio
  Widget _costruisciMappa(BuildContext context, WidgetRef ref) {
    final coordinateNegozio = LatLng(buono.latitudine!, buono.longitudine!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Posizione negozio',
          style: TextStyle(
            fontSize: 12,
            color: ColoriApp.testoSecondario,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(DimensioniApp.raggioBordoCard),
          child: SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: coordinateNegozio,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.buonapp',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: coordinateNegozio,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: ColoriApp.scaduto,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _apriInMaps(context, ref),
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const Text('Apri in Maps'),
          style: TextButton.styleFrom(
            foregroundColor: ColoriApp.principale,
          ),
        ),
      ],
    );
  }

  // Apre la schermata di modifica del buono
  void _apriModifica(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditScreen(buono: buono)),
    );
  }

  // Mostra il dialogo di conferma eliminazione
  Future<void> _confermaElimina(BuildContext context, WidgetRef ref) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (contestoDialogo) => AlertDialog(
        title: const Text(TestiApp.titoloElimina),
        content: Text(
          'Vuoi eliminare il buono di ${buono.nomeNegozio}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contestoDialogo).pop(false),
            child: const Text(TestiApp.annulla),
          ),
          TextButton(
            onPressed: () => Navigator.of(contestoDialogo).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: ColoriApp.scaduto,
            ),
            child: const Text(TestiApp.elimina),
          ),
        ],
      ),
    );

    if (conferma == true) {
      try {
        await ref.read(providerBuoni.notifier).eliminaBuono(buono.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Buono eliminato con successo!'),
              backgroundColor: ColoriApp.valido,
            ),
          );
          Navigator.of(context).pop();
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

  // Apre la posizione del negozio in Maps
  Future<void> _apriInMaps(BuildContext context, WidgetRef ref) async {
    try {
      final urlMaps =
          'https://www.google.com/maps/search/?api=1&query=${buono.latitudine},${buono.longitudine}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Apri questo link in Maps: $urlMaps'),
        ),
      );
    } catch (errore) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossibile aprire Maps. Riprova più tardi.',
            ),
            backgroundColor: ColoriApp.scaduto,
          ),
        );
      }
    }
  }
}