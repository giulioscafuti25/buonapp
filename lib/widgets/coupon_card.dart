// coupon_card.dart - Widget per la card del buono sconto
// Mostra le informazioni principali del buono in una card cliccabile

import 'dart:io';
import 'package:flutter/material.dart';

import '../models/buono_sconto.dart';
import '../utils/constants.dart';
import '../widgets/expiry_badge.dart';

class CardBuono extends StatelessWidget {
  // Il buono da visualizzare nella card
  final BuonoSconto buono;

  // Callback chiamata quando l'utente tocca la card
  final VoidCallback onTocco;

  // Callback chiamata quando l'utente fa swipe per eliminare
  final VoidCallback onElimina;

  const CardBuono({
    super.key,
    required this.buono,
    required this.onTocco,
    required this.onElimina,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // Chiave univoca per il Dismissible basata sull'id del buono
      key: Key('buono_${buono.id}'),

      // Direzione dello swipe: solo da destra a sinistra
      direction: DismissDirection.endToStart,

      // Conferma prima di eliminare
      confirmDismiss: (direzione) async {
        return await _mostraDialogoConferma(context);
      },

      // Callback chiamata dopo la conferma dell'eliminazione
      onDismissed: (direzione) => onElimina(),

      // Sfondo rosso con icona cestino mostrato durante lo swipe
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: DimensioniApp.paddingPagina,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: ColoriApp.scaduto,
          borderRadius:
              BorderRadius.circular(DimensioniApp.raggioBordoCard),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),

      child: Card(
        child: InkWell(
          onTap: onTocco,
          borderRadius:
              BorderRadius.circular(DimensioniApp.raggioBordoCard),
          child: Padding(
            padding: const EdgeInsets.all(DimensioniApp.paddingCard),
            child: Row(
              children: [
                // Foto del buono o icona placeholder
                _costruisciFoto(),
                const SizedBox(width: 12),

                // Informazioni del buono
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome del negozio
                      Text(
                        buono.nomeNegozio,
                        style: const TextStyle(
                          fontSize: DimensioniApp.dimensioneTitoloCard,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Descrizione del buono
                      Text(
                        buono.descrizione,
                        style: const TextStyle(
                          fontSize: DimensioniApp.dimensioneDescrizioneCard,
                          color: ColoriApp.testoSecondario,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Badge di scadenza
                      BadgeScadenza(buono: buono),
                    ],
                  ),
                ),

                // Freccia per indicare che la card è cliccabile
                const Icon(
                  Icons.chevron_right,
                  color: ColoriApp.bordoChiaro,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Costruisce il widget della foto del buono
  Widget _costruisciFoto() {
    if (buono.percorsoFoto != null) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(DimensioniApp.raggioBordoFoto),
        child: Image.file(
          File(buono.percorsoFoto!),
          width: DimensioniApp.larghezzaFotoCard,
          height: DimensioniApp.altezzaFotoCard,
          fit: BoxFit.cover,
          errorBuilder: (context, errore, stack) =>
              _costruisciPlaceholder(),
        ),
      );
    }
    return _costruisciPlaceholder();
  }

  // Costruisce il widget placeholder quando non c'è foto
  Widget _costruisciPlaceholder() {
    return Container(
      width: DimensioniApp.larghezzaFotoCard,
      height: DimensioniApp.altezzaFotoCard,
      decoration: BoxDecoration(
        color: ColoriApp.principaleChiaro,
        borderRadius:
            BorderRadius.circular(DimensioniApp.raggioBordoFoto),
      ),
      child: const Icon(
        Icons.confirmation_number_outlined,
        color: ColoriApp.principale,
        size: 32,
      ),
    );
  }

  // Mostra un dialogo di conferma prima di eliminare il buono
  Future<bool> _mostraDialogoConferma(BuildContext context) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (contestoDialogo) => AlertDialog(
        title: const Text(TestiApp.titoloElimina),
        content: Text(
          'Vuoi eliminare il buono di ${buono.nomeNegozio}?',
        ),
        actions: [
          // Tasto annulla
          TextButton(
            onPressed: () => Navigator.of(contestoDialogo).pop(false),
            child: const Text(TestiApp.annulla),
          ),
          // Tasto elimina
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
    return conferma ?? false;
  }
}