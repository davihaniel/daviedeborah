class Convidado {
  final String id;
  final String nome;
  final int? idade;
  final String idAnfitriao;
  final DateTime datCriacao;
  final DateTime datAtualizacao;
  final DateTime? datExclusao;

  Convidado({
    required this.id,
    required this.nome,
    this.idade,
    required this.idAnfitriao,
    required this.datCriacao,
    required this.datAtualizacao,
    this.datExclusao,
  });

  /// Cria um Convidado a partir de um Map (JSON do Supabase)
  factory Convidado.fromJson(Map<String, dynamic> json) {
    return Convidado(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      idade: json['idade'],
      idAnfitriao: json['id_anfitriao'] ?? '',
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

  /// Converte Convidado para Map (para enviar ao Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'idade': idade,
      'id_anfitriao': idAnfitriao,
      'dat_criacao': datCriacao.toIso8601String(),
      'dat_atualizacao': datAtualizacao.toIso8601String(),
      'dat_exclusao': datExclusao?.toIso8601String(),
    };
  }

  /// Cria uma cópia com campos modificados
  Convidado copyWith({
    String? id,
    String? nome,
    int? idade,
    String? idAnfitriao,
    DateTime? datCriacao,
    DateTime? datAtualizacao,
    DateTime? datExclusao,
  }) {
    return Convidado(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      idade: idade ?? this.idade,
      idAnfitriao: idAnfitriao ?? this.idAnfitriao,
      datCriacao: datCriacao ?? this.datCriacao,
      datAtualizacao: datAtualizacao ?? this.datAtualizacao,
      datExclusao: datExclusao ?? this.datExclusao,
    );
  }

  /// Verifica se é criança (idade <= 6)
  bool get isCrianca => idade != null && idade! <= 6;

  @override
  String toString() {
    return 'Convidado(id: $id, nome: $nome, idade: $idade, idAnfitriao: $idAnfitriao)';
  }
}
