// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mensagem_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MensagemStore on _MensagemStore, Store {
  Computed<int>? _$totalMensagensComputed;

  @override
  int get totalMensagens => (_$totalMensagensComputed ??= Computed<int>(
    () => super.totalMensagens,
    name: '_MensagemStore.totalMensagens',
  )).value;

  late final _$mensagensAtom = Atom(
    name: '_MensagemStore.mensagens',
    context: context,
  );

  @override
  ObservableList<Mensagem> get mensagens {
    _$mensagensAtom.reportRead();
    return super.mensagens;
  }

  @override
  set mensagens(ObservableList<Mensagem> value) {
    _$mensagensAtom.reportWrite(value, super.mensagens, () {
      super.mensagens = value;
    });
  }

  late final _$_MensagemStoreActionController = ActionController(
    name: '_MensagemStore',
    context: context,
  );

  @override
  void adicionarMensagem(String nome, String mensagem) {
    final _$actionInfo = _$_MensagemStoreActionController.startAction(
      name: '_MensagemStore.adicionarMensagem',
    );
    try {
      return super.adicionarMensagem(nome, mensagem);
    } finally {
      _$_MensagemStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
mensagens: ${mensagens},
totalMensagens: ${totalMensagens}
    ''';
  }
}
