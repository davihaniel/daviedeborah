class Recado {
  final String id;
  final String nome;
  final String mensagem;
  final bool aprovado;
  final DateTime datCriacao;
  final DateTime? datExclusao;

  Recado({
    required this.id,
    required this.nome,
    required this.mensagem,
    required this.aprovado,
    required this.datCriacao,
    this.datExclusao,
  });

  /// Cria um Recado a partir de um Map (JSON do Supabase)
  factory Recado.fromJson(Map<String, dynamic> json) {
    return Recado(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      mensagem: json['mensagem'] ?? '',
      aprovado: json['aprovado'] ?? false,
      datCriacao: json['dat_criacao'] != null
          ? DateTime.parse(json['dat_criacao'])
          : DateTime.now(),
      datExclusao: json['dat_exclusao'] != null
          ? DateTime.parse(json['dat_exclusao'])
          : null,
    );
  }

  /// Converte Recado para Map (para enviar ao Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'mensagem': mensagem,
      'aprovado': aprovado,
      'dat_criacao': datCriacao.toIso8601String(),
      'dat_exclusao': datExclusao?.toIso8601String(),
    };
  }

  /// Cria uma cópia com campos modificados
  Recado copyWith({
    String? id,
    String? nome,
    String? mensagem,
    bool? aprovado,
    DateTime? datCriacao,
    DateTime? datExclusao,
  }) {
    return Recado(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      mensagem: mensagem ?? this.mensagem,
      aprovado: aprovado ?? this.aprovado,
      datCriacao: datCriacao ?? this.datCriacao,
      datExclusao: datExclusao ?? this.datExclusao,
    );
  }

  @override
  String toString() {
    return 'Recado(id: $id, nome: $nome, aprovado: $aprovado)';
  }
}
