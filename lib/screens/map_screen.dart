// map_screen.dart - Schermata della mappa con i supermercati
// Mostra su una mappa OpenStreetMap tutti i negozi dove hai buoni validi

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/buono_sconto.dart';
import '../providers/buoni_provider.dart';
import '../providers/posizione_provider.dart';
import '../utils/constants.dart';
import '../utils/date_extensions.dart';
import '../screens/list_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/detail_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _StatoMapScreen();
}

class _StatoMapScreen extends ConsumerState<MapScreen> {
  // Controller per spostare la mappa programmaticamente
  final MapController _controllerMappa = MapController();

  // Indica se c'è connessione internet
  bool _haConnessione = true;

  @override
  void initState() {
    super.initState();
    // Recupera la posizione automaticamente all'apertura
    Future.microtask(() =>
        ref.read(providerPosizione.notifier).recuperaPosizione());
    // Controlla la connessione internet
    _verificaConnessione();
  }

  // Verifica se c'è connessione internet
  Future<void> _verificaConnessione() async {
    final risultato = await Connectivity().checkConnectivity();
    setState(() {
      _haConnessione = risultato.any((r) => r != ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tuttiBuoni = ref.watch(providerBuoni);
    final posizione = ref.watch(providerPosizione);

    // Quando la posizione cambia sposta la mappa
    ref.listen(providerPosizione, (precedente, corrente) {
      if (corrente.value != null) {
        _controllerMappa.move(
          LatLng(corrente.value!.latitude, corrente.value!.longitude),
          15,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColoriApp.principale,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              TestiApp.titoloMappa,
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Posizione dei tuoi buoni',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
      body: !_haConnessione
          ? _costruisciErroreConnessione()
          : tuttiBuoni.when(
              data: (listaBuoni) =>
                  _costruisciMappa(context, listaBuoni, posizione),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (errore, stack) => _costruisciErrore(context),
            ),
      bottomNavigationBar: _costruisciNavBar(context, 1),
    );
  }

  // Costruisce il messaggio di errore per mancanza di connessione
  Widget _costruisciErroreConnessione() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_outlined,
            size: 80,
            color: ColoriApp.testoSecondario,
          ),
          const SizedBox(height: 16),
          const Text(
            'Connessione assente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColoriApp.testoSecondario,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'La mappa non è disponibile senza internet.\nI tuoi buoni sono al sicuro!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: ColoriApp.testoSecondario,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _verificaConnessione,
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

  Widget _costruisciMappa(
    BuildContext context,
    List<BuonoSconto> listaBuoni,
    AsyncValue posizioneUtente,
  ) {
    final buoniConPosizione = listaBuoni
        .where((b) =>
            b.latitudine != null &&
            b.longitudine != null &&
            !b.eScaduto)
        .toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _controllerMappa,
          options: const MapOptions(
            initialCenter: LatLng(41.9028, 12.4964),
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.buonapp',
            ),

            // Marker posizione utente
            if (posizioneUtente.value != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      posizioneUtente.value!.latitude,
                      posizioneUtente.value!.longitude,
                    ),
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.navigation,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

            // Marker buoni
            MarkerLayer(
              markers: buoniConPosizione.map((buono) {
                return Marker(
                  point: LatLng(buono.latitudine!, buono.longitudine!),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _mostraInfoNegozio(context, buono),
                    child: Icon(
                      Icons.location_on,
                      color: buono.staPerScadere
                          ? ColoriApp.inScadenza
                          : ColoriApp.principale,
                      size: 40,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Pulsante per centrare sulla posizione utente
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () async {
              await ref
                  .read(providerPosizione.notifier)
                  .recuperaPosizione();
              final pos = ref.read(providerPosizione).value;
              if (pos != null) {
                _controllerMappa.move(
                  LatLng(pos.latitude, pos.longitude),
                  15,
                );
              }
            },
            backgroundColor: Colors.white,
            child: const Icon(
                Icons.my_location, color: ColoriApp.principale),
          ),
        ),

        if (buoniConPosizione.isNotEmpty)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: _costruisciListaNegozi(context, buoniConPosizione),
          ),
      ],
    );
  }

  Widget _costruisciListaNegozi(
      BuildContext context, List<BuonoSconto> buoni) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: buoni.length,
        itemBuilder: (context, indice) {
          final buono = buoni[indice];
          return GestureDetector(
            onTap: () => _mostraInfoNegozio(context, buono),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    DimensioniApp.raggioBordoCard),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buono.nomeNegozio,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    buono.dataScadenza.descrizioneScadenza,
                    style: const TextStyle(
                      fontSize: 11,
                      color: ColoriApp.testoSecondario,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _mostraInfoNegozio(BuildContext context, BuonoSconto buono) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DimensioniApp.raggioBordoBottomSheet),
        ),
      ),
      builder: (contestoSheet) => Padding(
        padding: EdgeInsets.fromLTRB(
          DimensioniApp.paddingPagina,
          DimensioniApp.paddingPagina,
          DimensioniApp.paddingPagina,
          DimensioniApp.paddingPagina +
              MediaQuery.of(contestoSheet).viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              buono.nomeNegozio,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              buono.descrizione,
              style: const TextStyle(
                fontSize: 14,
                color: ColoriApp.testoSecondario,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: ColoriApp.principale),
                const SizedBox(width: 8),
                Text(
                  'Scade il ${buono.dataScadenza.formattoItaliano}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timelapse_outlined,
                    size: 16, color: ColoriApp.principale),
                const SizedBox(width: 8),
                Text(
                  buono.dataScadenza.descrizioneScadenza,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(contestoSheet).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailScreen.fromBuono(buono),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoriApp.principale,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Vedi dettaglio'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _costruisciErrore(BuildContext context) {
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
            'Impossibile caricare la mappa.\nControlla la connessione.',
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ListScreen()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AlertsScreen()),
        );
        break;
    }
  }
}