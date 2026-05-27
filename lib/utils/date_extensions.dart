// date_extensions.dart - Estensioni su DateTime per la gestione delle date
// Aggiunge metodi utili alla classe DateTime per l'app BuonApp

extension EstensioniData on DateTime {
  // Restituisce la data nel formato italiano "dd/mm/yyyy"
  String get formattoItaliano =>
      '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';

  // Restituisce la data nel formato esteso italiano "1 gennaio 2026"
  String get formattoEsteso {
    // Nomi dei mesi in italiano
    const nomiMesi = [
      'gennaio',
      'febbraio',
      'marzo',
      'aprile',
      'maggio',
      'giugno',
      'luglio',
      'agosto',
      'settembre',
      'ottobre',
      'novembre',
      'dicembre',
    ];
    return '$day ${nomiMesi[month - 1]} $year';
  }

  // Restituisce true se la data è oggi
  bool get eOggi {
    final adesso = DateTime.now();
    return day == adesso.day &&
        month == adesso.month &&
        year == adesso.year;
  }

  // Restituisce true se la data è già passata
  bool get ePassata {
    final oggi = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final data = DateTime(year, month, day);
    return data.isBefore(oggi);
  }

  // Restituisce il numero di giorni rimanenti alla data
  // (negativo se la data è già passata)
  int get giorniRimanenti {
    final oggi = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final scadenza = DateTime(year, month, day);
    return scadenza.difference(oggi).inDays;
  }

  // Restituisce true se la data è entro i prossimi N giorni
  bool entroGiorni(int giorni) {
    final adesso = DateTime.now();
    final differenza = difference(adesso).inDays;
    return differenza >= 0 && differenza <= giorni;
  }

  // Restituisce una stringa descrittiva della scadenza
  String get descrizioneScadenza {
    final giorni = giorniRimanenti;
    if (giorni > 0) return 'Scade tra $giorni giorni';
    if (giorni == 0) return 'Scade oggi';
    return 'Scaduto ${giorni.abs()} giorni fa';
  }
}