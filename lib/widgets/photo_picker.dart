// photo_picker.dart - Widget per la selezione della foto del buono
// Permette di scattare una foto con la fotocamera o sceglierne una dalla galleria

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/constants.dart';

// Eccezione personalizzata per gli errori del selettore foto
class EccezioneFoto implements Exception {
  // Messaggio di errore
  final String messaggio;

  const EccezioneFoto(this.messaggio);

  @override
  String toString() => 'EccezioneFoto: $messaggio';
}

class SelettoreFoto extends StatelessWidget {
  // Percorso della foto attualmente selezionata (null se non c'è foto)
  final String? percorsoFoto;

  // Callback chiamata quando l'utente seleziona una nuova foto
  final Function(String percorso) onFotoSelezionata;

  // Callback chiamata quando l'utente rimuove la foto
  final VoidCallback onFotoRimossa;

  const SelettoreFoto({
    super.key,
    this.percorsoFoto,
    required this.onFotoSelezionata,
    required this.onFotoRimossa,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etichetta del campo
        Text(
          TestiApp.fotoBuono,
          style: const TextStyle(
            fontSize: DimensioniApp.dimensioneEtichetta,
            color: ColoriApp.testoSecondario,
          ),
        ),
        const SizedBox(height: 8),

        // Area della foto
        GestureDetector(
          onTap: () => _mostraOpzioniFoto(context),
          child: Container(
            width: double.infinity,
            height: DimensioniApp.altezzaFotoForm,
            decoration: BoxDecoration(
              color: ColoriApp.sfondoSecondario,
              borderRadius: BorderRadius.circular(
                DimensioniApp.raggioBordoCard,
              ),
              border: Border.all(
                color: percorsoFoto != null
                    ? ColoriApp.principale
                    : ColoriApp.bordoChiaro,
              ),
            ),
            child: percorsoFoto != null
                ? _costruisciAnteprimaFoto()
                : _costruisciPlaceholder(),
          ),
        ),
      ],
    );
  }

  // Costruisce l'anteprima della foto selezionata
  Widget _costruisciAnteprimaFoto() {
    return Stack(
      children: [
        // Foto selezionata
        ClipRRect(
          borderRadius: BorderRadius.circular(DimensioniApp.raggioBordoCard),
          child: Image.file(
            File(percorsoFoto!),
            width: double.infinity,
            height: DimensioniApp.altezzaFotoForm,
            fit: BoxFit.cover,
          ),
        ),

        // Tasto per rimuovere la foto
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onFotoRimossa,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: ColoriApp.scaduto,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Costruisce il placeholder quando non c'è foto
  Widget _costruisciPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.add_a_photo_outlined,
          size: 40,
          color: ColoriApp.testoSecondario,
        ),
        const SizedBox(height: 8),
        const Text(
          TestiApp.toccoPerFoto,
          style: TextStyle(
            fontSize: DimensioniApp.dimensioneEtichetta,
            color: ColoriApp.testoSecondario,
          ),
        ),
      ],
    );
  }

  // Mostra un bottom sheet con le opzioni per la foto
  void _mostraOpzioniFoto(BuildContext context) {
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
            // Maniglia del bottom sheet
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: ColoriApp.bordoChiaro,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Opzione fotocamera
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text(TestiApp.scattaFoto),
              onTap: () async {
                Navigator.of(contestoSheet).pop();
                try {
                  await _scattaFoto();
                } catch (_) {
                  // Mostra un messaggio all'utente se la fotocamera non è disponibile
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(TestiApp.erroreFoto)),
                    );
                  }
                }
              },
            ),

            // Opzione galleria
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(TestiApp.scegliGalleria),
              onTap: () async {
                Navigator.of(contestoSheet).pop();
                try {
                  await _scegliDaGalleria();
                } catch (_) {
                  // Mostra un messaggio all'utente se la galleria non è disponibile
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(TestiApp.erroreFoto)),
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Scatta una foto con la fotocamera
  Future<void> _scattaFoto() async {
    try {
      final raccoglitore = ImagePicker();
      final fotoScattata = await raccoglitore.pickImage(
        source: ImageSource.camera,
        imageQuality: ValoriDefault.qualitaFoto,
      );
      if (fotoScattata != null) {
        onFotoSelezionata(fotoScattata.path);
      }
    } catch (errore) {
      throw EccezioneFoto('Errore durante lo scatto della foto: $errore');
    }
  }

  // Sceglie una foto dalla galleria
  Future<void> _scegliDaGalleria() async {
    try {
      final raccoglitore = ImagePicker();
      final fotoScelta = await raccoglitore.pickImage(
        source: ImageSource.gallery,
        imageQuality: ValoriDefault.qualitaFoto,
      );
      if (fotoScelta != null) {
        onFotoSelezionata(fotoScelta.path);
      }
    } catch (errore) {
      throw EccezioneFoto('Errore durante la selezione della foto: $errore');
    }
  }
}