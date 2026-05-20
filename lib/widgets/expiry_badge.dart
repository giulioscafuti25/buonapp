// expiry_badge.dart - Widget per il badge di scadenza del buono
// Mostra un badge colorato con lo stato di scadenza del buono

import 'package:flutter/material.dart';

import '../models/buono_sconto.dart';
import '../utils/constants.dart';

class BadgeScadenza extends StatelessWidget {
  // Il buono di cui mostrare lo stato di scadenza
  final BuonoSconto buono;

  const BadgeScadenza({super.key, required this.buono});

  @override
  Widget build(BuildContext context) {
    // Determina il colore e il testo del badge in base allo stato del buono
    late final Color coloreSfondo;
    late final Color coloreTesto;
    late final String testo;
    late final IconData icona;

    if (buono.eScaduto) {
      // Buono scaduto - rosso
      coloreSfondo = ColoriApp.scadutoSfondo;
      coloreTesto = ColoriApp.scaduto;
      testo = TestiApp.badgeScaduto;
      icona = Icons.cancel_outlined;
    } else if (buono.staPerScadere) {
      // Buono in scadenza - arancione
      coloreSfondo = ColoriApp.inScadenzaSfondo;
      coloreTesto = ColoriApp.inScadenza;
      final giorniRimanenti = buono.giorniAllaScadenza;
      testo = giorniRimanenti == 0
          ? TestiApp.badgeScadeOggi
          : 'Scade tra $giorniRimanenti gg';
      icona = Icons.warning_amber_rounded;
    } else {
      // Buono valido - verde
      coloreSfondo = ColoriApp.validoSfondo;
      coloreTesto = ColoriApp.valido;
      testo = TestiApp.badgeValido;
      icona = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: coloreSfondo,
        borderRadius: BorderRadius.circular(DimensioniApp.raggioBordoBadge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icona, size: 12, color: coloreTesto),
          const SizedBox(width: 4),
          Text(
            testo,
            style: TextStyle(
              fontSize: DimensioniApp.dimensioneBadge,
              fontWeight: FontWeight.w500,
              color: coloreTesto,
            ),
          ),
        ],
      ),
    );
  }
}