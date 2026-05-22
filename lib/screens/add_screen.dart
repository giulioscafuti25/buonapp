// add_screen.dart - Schermata per aggiungere un nuovo buono sconto
// Permette di inserire tutti i dati del buono con foto e posizione GPS

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/buono_sconto.dart';
import '../providers/buoni_provider.dart';
import '../providers/posizione_provider.dart';
import '../services/geocoding_service.dart';
import '../utils/constants.dart';
import '../utils/date_extensions.dart';
import '../widgets/photo_picker.dart';

class AddScreen extends ConsumerStatefulWidget {
  const AddScreen({super.key});

  @override
  ConsumerState<AddScreen> createState() => _StatoAddScreen();
}

class _StatoAddScreen extends ConsumerState<AddScreen> {
  // Chiave per la validazione del form
  final _chiaveForm = GlobalKey<FormState>();

  // Controller per i campi di testo
  final _controllerNomeNegozio = TextEditingController();
  final _controllerDescrizione = TextEditingController();
  final _controllerIndirizzo = TextEditingController();

  // Data di scadenza selezionata
  DateTime? _dataScadenzaSelezionata;

  // Percorso della foto selezionata
  String? _percorsoFotoSelezionata;

  // Coordinate ottenute dalla ricerca indirizzo
  double? _latitudineRicercata;
  double? _longitudineRicercata;
  String? _indirizzoRicercato;

  // Indica se sta salvando il buono
  bool _staSalvando = false;

  // Indica se sta cercando l'indirizzo
  bool _staRicercando = false;

  @override
  void dispose() {
    // Libera i controller quando il widget viene distrutto
    _controllerNomeNegozio.dispose();
    _controllerDescrizione.dispose();
    _controllerIndirizzo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Osserva la posizione corrente
    final statoPosizione = ref.watch(providerPosizione);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColoriApp.principale,
        title: const Text(
          TestiApp.titoloNuovoBuono,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DimensioniApp.paddingPagina),
        child: Form(
          key: _chiaveForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selettore foto
              SelettoreFoto(
                percorsoFoto: _percorsoFotoSelezionata,
                onFotoSelezionata: (percorso) {
                  setState(() => _percorsoFotoSelezionata = percorso);
                },
                onFotoRimossa: () {
                  setState(() => _percorsoFotoSelezionata = null);
                },
              ),
              const SizedBox(height: 20),

              // Campo nome negozio
              TextFormField(
                controller: _controllerNomeNegozio,
                decoration: const InputDecoration(
                  labelText: TestiApp.campoNomeNegozio,
                  prefixIcon: Icon(Icons.store_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (valore) {
                  if (valore == null || valore.trim().isEmpty) {
                    return 'Inserisci il nome del negozio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo descrizione
              TextFormField(
                controller: _controllerDescrizione,
                decoration: const InputDecoration(
                  labelText: TestiApp.campoDescrizione,
                  prefixIcon: Icon(Icons.note_outlined),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (valore) {
                  if (valore == null || valore.trim().isEmpty) {
                    return 'Inserisci una descrizione';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Selettore data di scadenza
              _costruisciSelettoreData(context),
              const SizedBox(height: 16),

              // Sezione posizione GPS
              _costruisciSezionePosizione(context, statoPosizione),
              const SizedBox(height: 32),

              // Pulsante salva
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _staSalvando ? null : () => _salvaBuono(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoriApp.principale,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        DimensioniApp.raggioBordoCard,
                      ),
                    ),
                  ),
                  child: _staSalvando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Salva buono',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Costruisce il selettore della data di scadenza
  Widget _costruisciSelettoreData(BuildContext context) {
    return GestureDetector(
      onTap: () => _selezionaData(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: ColoriApp.bordoChiaro),
          borderRadius: BorderRadius.circular(DimensioniApp.raggioBordoCard),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: ColoriApp.testoSecondario),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  TestiApp.campoDataScadenza,
                  style: TextStyle(
                    fontSize: 12,
                    color: ColoriApp.testoSecondario,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _dataScadenzaSelezionata != null
                      ? _dataScadenzaSelezionata!.formattoItaliano
                      : 'Seleziona una data',
                  style: TextStyle(
                    fontSize: 15,
                    color: _dataScadenzaSelezionata != null
                        ? Colors.black87
                        : ColoriApp.testoSecondario,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Costruisce la sezione della posizione
  Widget _costruisciSezionePosizione(
      BuildContext context, AsyncValue statoPosizione) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: ColoriApp.bordoChiaro),
        borderRadius: BorderRadius.circular(DimensioniApp.raggioBordoCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            TestiApp.campoPosizione,
            style: TextStyle(
              fontSize: 12,
              color: ColoriApp.testoSecondario,
            ),
          ),
          const SizedBox(height: 8),

          // Riga GPS automatico
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: ColoriApp.principale),
              const SizedBox(width: 8),
              Expanded(
                child: statoPosizione.when(
                  data: (posizione) => Text(
                    posizione != null
                        ? 'Posizione GPS rilevata ✓'
                        : 'Posizione non ancora rilevata',
                    style: TextStyle(
                      color: posizione != null
                          ? ColoriApp.valido
                          : ColoriApp.testoSecondario,
                    ),
                  ),
                  loading: () => const Text('Rilevamento in corso...'),
                  error: (e, s) => const Text(
                    TestiApp.erroreGps,
                    style: TextStyle(color: ColoriApp.scaduto),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => ref
                    .read(providerPosizione.notifier)
                    .recuperaPosizione(),
                icon: const Icon(Icons.my_location, size: 16),
                label: const Text('GPS'),
                style: TextButton.styleFrom(
                  foregroundColor: ColoriApp.principale,
                ),
              ),
            ],
          ),

          const Divider(),

          // Campo ricerca per indirizzo
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controllerIndirizzo,
                  decoration: InputDecoration(
                    hintText: 'Cerca per indirizzo...',
                    hintStyle:
                        const TextStyle(color: ColoriApp.testoSecondario),
                    prefixIcon: const Icon(Icons.search,
                        color: ColoriApp.testoSecondario),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DimensioniApp.raggioBordoCard),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Pulsante cerca indirizzo
              _staRicercando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      onPressed: () => _cercaIndirizzo(context),
                      icon: const Icon(Icons.search),
                      color: ColoriApp.principale,
                    ),
            ],
          ),

          // Mostra l'indirizzo trovato se disponibile
          if (_indirizzoRicercato != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: ColoriApp.valido, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _indirizzoRicercato!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColoriApp.valido,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Pulsante per rimuovere l'indirizzo cercato
                IconButton(
                  onPressed: () {
                    setState(() {
                      _latitudineRicercata = null;
                      _longitudineRicercata = null;
                      _indirizzoRicercato = null;
                      _controllerIndirizzo.clear();
                    });
                  },
                  icon: const Icon(Icons.close,
                      size: 16, color: ColoriApp.testoSecondario),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Cerca le coordinate di un indirizzo tramite geocoding
  Future<void> _cercaIndirizzo(BuildContext context) async {
    if (_controllerIndirizzo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserisci un indirizzo da cercare.'),
        ),
      );
      return;
    }

    setState(() => _staRicercando = true);

    try {
      final coordinate = await ServizioGeocoding.indirizzoACoordinate(
        _controllerIndirizzo.text.trim(),
      );

      if (coordinate == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Indirizzo non trovato. Prova con un indirizzo più preciso.'),
            ),
          );
        }
        return;
      }

      // Ottieni l'indirizzo formattato dalle coordinate trovate
      final indirizzoFormattato =
          await ServizioGeocoding.coordinateAdIndirizzo(
        latitudine: coordinate['latitudine']!,
        longitudine: coordinate['longitudine']!,
      );

      setState(() {
        _latitudineRicercata = coordinate['latitudine'];
        _longitudineRicercata = coordinate['longitudine'];
        _indirizzoRicercato = indirizzoFormattato ?? _controllerIndirizzo.text;
      });
    } catch (errore) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Impossibile cercare l\'indirizzo. Controlla la connessione.'),
            backgroundColor: ColoriApp.scaduto,
          ),
        );
      }
    } finally {
      setState(() => _staRicercando = false);
    }
  }

  // Apre il date picker per selezionare la data di scadenza
  Future<void> _selezionaData(BuildContext context) async {
    try {
      final dataSelezionata = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 30)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        locale: const Locale('it'),
      );
      if (dataSelezionata != null) {
        setState(() => _dataScadenzaSelezionata = dataSelezionata);
      }
    } catch (errore) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossibile aprire il calendario. Riprova.'),
          ),
        );
      }
    }
  }

  // Salva il buono nel database
  Future<void> _salvaBuono(BuildContext context) async {
    if (!_chiaveForm.currentState!.validate()) return;

    if (_dataScadenzaSelezionata == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona una data di scadenza prima di salvare.'),
        ),
      );
      return;
    }

    setState(() => _staSalvando = true);

    try {
      // Ottieni la posizione: prima quella ricercata, poi quella GPS
      final posizione = ref.read(providerPosizione).value;
      final latitudine = _latitudineRicercata ?? posizione?.latitude;
      final longitudine = _longitudineRicercata ?? posizione?.longitude;
      final indirizzo = _indirizzoRicercato;

      final nuovoBuono = BuonoSconto(
        nomeNegozio: _controllerNomeNegozio.text.trim(),
        descrizione: _controllerDescrizione.text.trim(),
        dataScadenza: _dataScadenzaSelezionata!,
        percorsoFoto: _percorsoFotoSelezionata,
        latitudine: latitudine,
        longitudine: longitudine,
        indirizzo: indirizzo,
        dataAggiunta: DateTime.now(),
      );

      await ref.read(providerBuoni.notifier).aggiungiBuono(nuovoBuono);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buono aggiunto con successo!'),
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
              'Impossibile salvare il buono. Controlla i dati e riprova.',
            ),
            backgroundColor: ColoriApp.scaduto,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _staSalvando = false);
    }
  }
}