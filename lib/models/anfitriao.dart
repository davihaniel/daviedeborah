class Anfitriao {
  final String id;
  final String nome;
  final String numero;
  final bool confirmacao;
  final DateTime datCriacao;
  final DateTime datAtualizacao;
  final DateTime? datExclusao;

  Anfitriao({
    required this.id,
    required this.nome,
    required this.numero,
    required this.confirmacao,
    required this.datCriacao,
    required this.datAtualizacao,
    this.datExclusao,
  });

  /// Cria um Anfitriao a partir de um Map (JSON do Supabase)
  factory Anfitriao.fromJson(Map<String, dynamic> json) {
    return Anfitriao(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      numero: json['numero'] ?? '',
      confirmacao: json['confirmacao'] ?? false,
      datCriacao: json['dat_criacao'] != null
          ? DateTime.parse(json['dat_criacao'])
          : DateTime.now(),
      datAtualizacao: json['dat_atualizacao'] != null
          ? DateTime.parse(json['dat_atualizacao'])
          : DateTime.now(),
      datExclusao: json['dat_exclusao'] != null
          ? DateTime.parse(json['dat_exclusao'])
          : null,
    );
  }

  /// Converte Anfitriao para Map (para enviar ao Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'numero': numero,
      'confirmacao': confirmacao,
      'dat_criacao': datCriacao.toIso8601String(),
      'dat_atualizacao': datAtualizacao.toIso8601String(),
      'dat_exclusao': datExclusao?.toIso8601String(),
    };
  }

  /// Cria uma cópia com campos modificados
  Anfitriao copyWith({
    String? id,
    String? nome,
    String? numero,
    bool? confirmacao,
    DateTime? datCriacao,
    DateTime? datAtualizacao,
    DateTime? datExclusao,
  }) {
    return Anfitriao(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      numero: numero ?? this.numero,
      confirmacao: confirmacao ?? this.confirmacao,
      datCriacao: datCriacao ?? this.datCriacao,
      datAtualizacao: datAtualizacao ?? this.datAtualizacao,
      datExclusao: datExclusao ?? this.datExclusao,
    );
  }

  @override
  String toString() {
    return 'Anfitriao(id: $id, nome: $nome, numero: $numero, confirmacao: $confirmacao)';
  }
}
