import 'package:daviedeborah/models/recado.dart';
import 'package:mobx/mobx.dart';

import '../services/supabase_service.dart';

part 'mensagem_store.g.dart';

// ignore: library_private_types_in_public_api
class MensagemStore = _MensagemStore with _$MensagemStore;

abstract class _MensagemStore with Store {
  _MensagemStore() {
    carregarRecados();
  }

  @observable
  ObservableList<Recado> recados = ObservableList<Recado>();

  @action
  Future carregarRecados() async {
    final supabaseService = SupabaseService();
    final response = await supabaseService.obterRecadosAprovados();
    recados = ObservableList<Recado>.of(response);
  }

  Future<void> adicionarMensagem(String nome, String mensagem) async {
    final supabaseService = SupabaseService();
    try {
      await supabaseService.criarRecado(nome: nome, mensagem: mensagem);
    } catch (e) {
      rethrow;
    }
  }

  @computed
  int get totalMensagens => recados.length;
}
