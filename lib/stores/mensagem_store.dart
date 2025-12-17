import 'package:mobx/mobx.dart';

part 'mensagem_store.g.dart';

class MensagemStore = _MensagemStore with _$MensagemStore;

class Mensagem {
  final String nome;
  final String mensagem;
  final DateTime data;

  Mensagem({
    required this.nome,
    required this.mensagem,
    required this.data,
  });
}

abstract class _MensagemStore with Store {
  @observable
  ObservableList<Mensagem> mensagens = ObservableList<Mensagem>.of([
    Mensagem(
      nome: 'Maria Silva',
      mensagem: 'Parabéns ao casal! Que Deus abençoe essa união! ❤️',
      data: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Mensagem(
      nome: 'João Santos',
      mensagem: 'Felicidades! Vocês são perfeitos juntos!',
      data: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ]);

  @action
  void adicionarMensagem(String nome, String mensagem) {
    mensagens.add(Mensagem(
      nome: nome,
      mensagem: mensagem,
      data: DateTime.now(),
    ));
  }

  @computed
  int get totalMensagens => mensagens.length;
}
