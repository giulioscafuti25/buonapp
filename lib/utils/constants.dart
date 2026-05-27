// constants.dart - Costanti globali dell'applicazione
// Centralizza colori, dimensioni, stili e testi per facilitare la manutenzione

import 'package:flutter/material.dart';

// ============================================================
// COLORI
// ============================================================

class ColoriApp {
  ColoriApp._(); // costruttore privato, non istanziabile

  // Colore principale verde
  static const Color principale = Color(0xFF4CAF50);
  static const Color principaleChiaro = Color(0xFFE8F5E9);
  static const Color principaleScuro = Color(0xFF2E7D32);

  // Colori stato buono valido
  static const Color valido = Color(0xFF2E7D32);
  static const Color validoSfondo = Color(0xFFE8F5E9);

  // Colori stato buono in scadenza
  static const Color inScadenza = Color(0xFFF57F17);
  static const Color inScadenzaSfondo = Color(0xFFFFF8E1);

  // Colori stato buono scaduto
  static const Color scaduto = Color(0xFFC62828);
  static const Color scadutoSfondo = Color(0xFFFFEBEE);

  // Colori neutri
  static const Color sfondoSecondario = Color(0xFFF5F5F5);
  static const Color bordoChiaro = Color(0xFFE0E0E0);
  static const Color testoSecondario = Color(0xFF757575);
}

// ============================================================
// DIMENSIONI
// ============================================================

class DimensioniApp {
  DimensioniApp._(); // costruttore privato, non istanziabile

  // Raggi dei bordi
  static const double raggioBordoCard = 12.0;
  static const double raggioBordoBadge = 6.0;
  static const double raggioBordoFoto = 8.0;
  static const double raggioBordoBottomSheet = 16.0;

  // Padding
  static const double paddingCard = 12.0;
  static const double paddingPagina = 16.0;

  // Dimensioni foto
  static const double larghezzaFotoCard = 70.0;
  static const double altezzaFotoCard = 70.0;
  static const double altezzaFotoForm = 160.0;

  // Dimensioni testo
  static const double dimensioneTitoloCard = 15.0;
  static const double dimensioneDescrizioneCard = 13.0;
  static const double dimensioneBadge = 11.0;
  static const double dimensioneEtichetta = 13.0;
}

// ============================================================
// TESTI
// ============================================================

class TestiApp {
  TestiApp._(); // costruttore privato, non istanziabile

  // Titoli schermate
  static const String titoloBuoni = 'I miei buoni';
  static const String titoloMappa = 'Mappa buoni';
  static const String titoloAvvisi = 'Avvisi';
  static const String titoloNuovoBuono = 'Nuovo buono';
  static const String titoloModificaBuono = 'Modifica buono';
  static const String titoloDettaglio = 'Dettaglio';

  // Filtri lista
  static const String filtroTutti = 'Tutti';
  static const String filtroInScadenza = 'In scadenza';
  static const String filtroScaduti = 'Scaduti';

  // Badge scadenza
  static const String badgeValido = 'Valido';
  static const String badgeScaduto = 'Scaduto';
  static const String badgeScadeOggi = 'Scade oggi!';

  // Foto
  static const String toccoPerFoto = 'Tocca per aggiungere una foto';
  static const String fotoBuono = 'Foto buono';
  static const String scattaFoto = 'Scatta una foto';
  static const String scegliGalleria = 'Scegli dalla galleria';

  // Dialogo eliminazione
  static const String titoloElimina = 'Elimina buono';
  static const String annulla = 'Annulla';
  static const String elimina = 'Elimina';

  // Messaggi errore
  static const String erroreRete = 'Impossibile trovare l\'indirizzo. Controlla la connessione.';
  static const String erroreGps = 'Impossibile ottenere la posizione. Controlla il GPS.';
  static const String erroreFoto = 'Impossibile caricare la foto.';

  // Campi form
  static const String campoNomeNegozio = 'Nome supermercato';
  static const String campoDescrizione = 'Descrizione / nota';
  static const String campoDataScadenza = 'Data di scadenza';
  static const String campoPosizione = 'Posizione negozio';
}

// ============================================================
// VALORI DEFAULT
// ============================================================

class ValoriDefault {
  ValoriDefault._(); // costruttore privato, non istanziabile

  // Giorni di anticipo default per le notifiche
  static const int giorniAnticipo = 3;

  // Orario default delle notifiche (9:00)
  static const int orarioNotifica = 9;

  // Giorni entro cui un buono è considerato "in scadenza"
  static const int giorniSogliScadenza = 7;

  // Qualità di compressione delle foto (0-100)
  static const int qualitaFoto = 80;
}