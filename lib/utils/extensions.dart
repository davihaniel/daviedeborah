extension DateExtension on DateTime {
  static const _meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  static const _mesesAbrev = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];

  String get dataHora {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year às ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  /// "15 de abr. de 2026 às 14:30"
  String get dataHoraAbrev {
    return '${day.toString().padLeft(2, '0')} de ${_mesesAbrev[month - 1]}. de $year às ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// "15/04/2026"
  String get data {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  String get dataNomeMes {
    return '${day.toString().padLeft(2, '0')} de ${_meses[month - 1]} de $year';
  }

  /// "15 de abr. de 2026"
  String get dataNomeMesAbrev {
    return '${day.toString().padLeft(2, '0')} de ${_mesesAbrev[month - 1]}. de $year';
  }

  String get hora {
    return '${hour.toString().padLeft(2, '0')}h${minute.toString().padLeft(2, '0')}';
  }
}