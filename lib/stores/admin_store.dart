import 'package:daviedeborah/services/supabase_service.dart';
import 'package:mobx/mobx.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'admin_store.g.dart';

// ignore: library_private_types_in_public_api
class AdminStore = _AdminStore with _$AdminStore;

abstract class _AdminStore with Store {
  _AdminStore() {
    final SupabaseService supabaseService = SupabaseService();
    isAutenticado = supabaseService.isAdminLoggedIn();
    if (isAutenticado) {
      nomeUsuario = supabaseService.client.auth.currentUser?.email ?? '';
    }
  }

  @observable
  bool isAutenticado = false;

  @observable
  String nomeUsuario = '';

  @observable
  bool carregando = false;

  @observable
  String? mensagemErro;

  @action
  Future<bool> fazerLogin(String usuario, String senha) async {
    try {
      carregando = true;
      mensagemErro = null;

      SupabaseService supabaseService = SupabaseService();
      await supabaseService.autenticarAdmin(usuario, senha);

      // Validação simples (em produção, chamar Supabase Auth)
      nomeUsuario = usuario;
      isAutenticado = true;
      carregando = false;
      return true;
    } on AuthApiException catch (e) {
      // Mensagens customizadas para erros de autenticação
      switch (e.statusCode) {
        case '400':
        case '401':
          mensagemErro =
              'Credenciais inválidas. Por favor, verifique seu usuário e senha.';
          break;
        case '403':
          mensagemErro =
              'Acesso negado. Você não tem permissão para acessar este recurso.';
          break;
        case '500':
          mensagemErro = 'Erro no servidor. Tente novamente mais tarde.';
          break;
        default:
          mensagemErro = 'Erro de autenticação: ${e.message}';
      }

      carregando = false;
      return false;
    } catch (e) {
      mensagemErro = 'Erro ao fazer login: $e';
      carregando = false;
      return false;
    }
  }

  @action
  void fazerLogout() {
    isAutenticado = false;
    nomeUsuario = '';
    mensagemErro = null;
    SupabaseService supabaseService = SupabaseService();
    supabaseService.client.auth.signOut();
  }

  @action
  void limparErro() {
    mensagemErro = null;
  }
}
