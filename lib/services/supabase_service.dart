import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/anfitriao.dart';
import '../models/convidado.dart';
import '../models/recado.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  final supabaseKey = const String.fromEnvironment("SUPABASE_KEY");
  final supabaseUrl = const String.fromEnvironment("SUPABASE_URL");

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  /// Inicializa o Supabase
  /// Adicione suas credenciais do Supabase aqui
  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl, // Substitua pela sua URL
      anonKey: supabaseKey, // Substitua pela sua Anon Key
    );
  }

  isAdminLoggedIn() {
    final session = client.auth.currentSession;
    return session != null;
  }

  SupabaseClient get client => Supabase.instance.client;

  /// Autentica o usuário admin
  Future<void> autenticarAdmin(String email, String senha) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: senha,
      );

      if (response.session == null) {
        throw Exception('Falha na autenticação do admin.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // ANFITRIÃO - OPERAÇÕES
  // ============================================

  /// Cria um novo anfitrião
  Future<Anfitriao> criarAnfitriao({
    required String nome,
    required String numero,
    required bool confirmacao,
  }) async {
    try {
      final response = await client
          .from('anfitriao')
          .insert({'nome': nome, 'numero': numero, 'confirmacao': confirmacao})
          .select()
          .single();

      return Anfitriao.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar anfitrião: $e');
    }
  }

  /// Obtém todos os anfitriões
  Future<List<Anfitriao>> obterTodosAnfitriaos() async {
    try {
      final response = await client
          .from('anfitriao')
          .select()
          .isFilter('dat_exclusao', null)
          .order('nome', ascending: true);

      final list = (response as List)
          .map((e) => Anfitriao.fromJson(e))
          .toList();
      return list;
    } catch (e) {
      throw Exception('Erro ao obter anfitriões: $e');
    }
  }

  /// Obtém um anfitrião por ID
  Future<Anfitriao?> obterAnfitriaoPorId(String id) async {
    try {
      final response = await client
          .from('anfitriao')
          .select()
          .eq('id', id)
          .isFilter('dat_exclusao', null)
          .maybeSingle();

      if (response == null) return null;
      return Anfitriao.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao obter anfitrião: $e');
    }
  }

  /// Atualiza confirmação do anfitrião
  Future<Anfitriao> atualizarConfirmacaoAnfitriao(
    String id,
    bool confirmacao,
  ) async {
    try {
      final response = await client
          .from('anfitriao')
          .update({'confirmacao': confirmacao})
          .eq('id', id)
          .select()
          .single();

      return Anfitriao.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar confirmação: $e');
    }
  }

  /// Atualiza dados do anfitrião (nome, número e confirmação)
  Future<Anfitriao> atualizarAnfitriao({
    required String id,
    required String nome,
    required String numero,
    required bool confirmacao,
  }) async {
    try {
      final response = await client
          .from('anfitriao')
          .update({'nome': nome, 'numero': numero, 'confirmacao': confirmacao})
          .eq('id', id)
          .select()
          .single();

      await client
          .from('convidado')
          .update({
            'dat_exclusao': confirmacao
                ? null
                : DateTime.now().toIso8601String(),
          })
          .eq('id_anfitriao', id);

      return Anfitriao.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar anfitrião: $e');
    }
  }

  /// Deleta um anfitrião (soft delete)
  Future<void> deletarAnfitriao(String id) async {
    try {
      await client
          .from('anfitriao')
          .update({'dat_exclusao': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar anfitrião: $e');
    }
  }

  // ============================================
  // CONVIDADO - OPERAÇÕES
  // ============================================

  /// Cria um novo convidado
  Future<Convidado> criarConvidado({
    required String nome,
    required String idAnfitriao,
    int? idade,
  }) async {
    try {
      final response = await client
          .from('convidado')
          .insert({'nome': nome, 'idade': idade, 'id_anfitriao': idAnfitriao})
          .select()
          .single();

      return Convidado.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar convidado: $e');
    }
  }

  /// Obtém convidados de um anfitrião
  Future<List<Convidado>> obterConvidadosPorAnfitriao(
    String idAnfitriao,
  ) async {
    try {
      final response = await client
          .from('convidado')
          .select()
          .eq('id_anfitriao', idAnfitriao)
          .isFilter('dat_exclusao', null)
          .order('nome', ascending: true);

      final list = (response as List)
          .map((e) => Convidado.fromJson(e))
          .toList();
      return list;
    } catch (e) {
      throw Exception('Erro ao obter convidados: $e');
    }
  }

  /// Obtém todos os convidados
  Future<List<Convidado>> obterTodosConvidados() async {
    try {
      final response = await client
          .from('convidado')
          .select()
          .isFilter('dat_exclusao', null)
          .order('nome', ascending: true);

      final list = (response as List)
          .map((e) => Convidado.fromJson(e))
          .toList();
      return list;
    } catch (e) {
      throw Exception('Erro ao obter convidados: $e');
    }
  }

  /// Atualiza um convidado
  Future<Convidado> atualizarConvidado({
    required String id,
    required String nome,
    int? idade,
    String? idAnfitriao,
  }) async {
    try {
      final response = await client
          .from('convidado')
          .update({
            'nome': nome,
            'idade': idade,
            if (idAnfitriao != null) 'id_anfitriao': idAnfitriao,
          })
          .eq('id', id)
          .select()
          .single();

      return Convidado.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar convidado: $e');
    }
  }

  /// Deleta um convidado (soft delete)
  Future<void> deletarConvidado(String id) async {
    try {
      await client
          .from('convidado')
          .update({'dat_exclusao': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar convidado: $e');
    }
  }

  // ============================================
  // RECADO - OPERAÇÕES
  // ============================================

  /// Cria um novo recado
  Future<Recado> criarRecado({
    required String nome,
    required String mensagem,
  }) async {
    try {
      final response = await client
          .from('recado')
          .insert({'nome': nome, 'mensagem': mensagem, 'aprovado': false})
          .select()
          .single();

      return Recado.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar recado: $e');
    }
  }

  /// Obtém recados aprovados
  Future<List<Recado>> obterRecadosAprovados() async {
    try {
      final response = await client
          .from('recado')
          .select()
          .eq('aprovado', true)
          .isFilter('dat_exclusao', null)
          .order('dat_criacao', ascending: false);

      final list = (response as List).map((e) => Recado.fromJson(e)).toList();
      return list;
    } catch (e) {
      throw Exception('Erro ao obter recados: $e');
    }
  }

  /// Obtém todos os recados (incluindo não aprovados)
  Future<List<Recado>> obterTodosRecados() async {
    try {
      final response = await client
          .from('recado')
          .select()
          .isFilter('dat_exclusao', null)
          .order('dat_criacao', ascending: false);

      final list = (response as List).map((e) => Recado.fromJson(e)).toList();
      return list;
    } catch (e) {
      throw Exception('Erro ao obter recados: $e');
    }
  }

  /// Aprova um recado
  Future<Recado> aprovarRecado(String id) async {
    try {
      final response = await client
          .from('recado')
          .update({'aprovado': true})
          .eq('id', id)
          .select()
          .single();

      return Recado.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao aprovar recado: $e');
    }
  }

  /// Atualiza um recado
  Future<Recado> atualizarRecado(String id, Recado recado) async {
    try {
      final response = await client
          .from('recado')
          .update(recado.toJson())
          .eq('id', id)
          .select()
          .single();

      return Recado.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar recado: $e');
    }
  }

  /// Deleta um recado (soft delete)
  Future<void> deletarRecado(String id) async {
    try {
      await client
          .from('recado')
          .update({'dat_exclusao': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar recado: $e');
    }
  }

  // ============================================
  // OPERAÇÕES EM LOTE
  // ============================================

  /// Cria um anfitrião com seus convidados
  Future<Map<String, dynamic>> criarAnfitriaComConvidados({
    required String nome,
    required String numero,
    required List<Map<String, dynamic>> convidados,
    required bool confirmacao,
  }) async {
    try {
      // Criar anfitrião
      final anfitriao = await criarAnfitriao(
        nome: nome,
        numero: numero,
        confirmacao: confirmacao,
      );

      // Criar convidados
      final convidadosCriados = <Convidado>[];
      for (final convidado in convidados) {
        final novoConvidado = await criarConvidado(
          nome: convidado['nome'],
          idAnfitriao: anfitriao.id,
          idade: convidado['idade'],
        );
        convidadosCriados.add(novoConvidado);
      }

      return {'anfitriao': anfitriao, 'convidados': convidadosCriados};
    } catch (e) {
      throw Exception('Erro ao criar anfitrião com convidados: $e');
    }
  }

  /// Obtém estatísticas do casamento
  Future<Map<String, dynamic>> obterEstatisticas() async {
    try {
      final anfitrioes = await obterTodosAnfitriaos();
      final convidados = await obterTodosConvidados();
      final recados = await obterRecadosAprovados();

      final totalAnfitriaos = anfitrioes.length;
      final totalConfirmados = anfitrioes.where((a) => a.confirmacao).length;
      final totalConvidados = convidados.length;
      final totalCriancas = convidados.where((c) => c.isCrianca).length;
      final totalRecados = recados.length;

      return {
        'total_anfitrioes': totalAnfitriaos,
        'total_confirmados': totalConfirmados,
        'taxa_confirmacao': totalAnfitriaos > 0
            ? (totalConfirmados / totalAnfitriaos ) * 100
            : 0,
        'total_convidados': totalConvidados,
        'total_criancas': totalCriancas,
        'total_recados': totalRecados,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }
}
