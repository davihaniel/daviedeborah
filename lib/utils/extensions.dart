extension DateExtension on DateTime {

  String get dataHora {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year às ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  String get dataNomeMes {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return '${day.toString().padLeft(2, '0')} de ${meses[month - 1]} de $year';
  }

  String get hora {
    return '${hour.toString().padLeft(2, '0')}h${minute.toString().padLeft(2, '0')}';
  }
}