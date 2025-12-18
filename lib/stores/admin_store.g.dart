// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AdminStore on _AdminStore, Store {
  late final _$isAutenticadoAtom = Atom(
    name: '_AdminStore.isAutenticado',
    context: context,
  );

  @override
  bool get isAutenticado {
    _$isAutenticadoAtom.reportRead();
    return super.isAutenticado;
  }

  @override
  set isAutenticado(bool value) {
    _$isAutenticadoAtom.reportWrite(value, super.isAutenticado, () {
      super.isAutenticado = value;
    });
  }

  late final _$nomeUsuarioAtom = Atom(
    name: '_AdminStore.nomeUsuario',
    context: context,
  );

  @override
  String get nomeUsuario {
    _$nomeUsuarioAtom.reportRead();
    return super.nomeUsuario;
  }

  @override
  set nomeUsuario(String value) {
    _$nomeUsuarioAtom.reportWrite(value, super.nomeUsuario, () {
      super.nomeUsuario = value;
    });
  }

  late final _$carregandoAtom = Atom(
    name: '_AdminStore.carregando',
    context: context,
  );

  @override
  bool get carregando {
    _$carregandoAtom.reportRead();
    return super.carregando;
  }

  @override
  set carregando(bool value) {
    _$carregandoAtom.reportWrite(value, super.carregando, () {
      super.carregando = value;
    });
  }

  late final _$mensagemErroAtom = Atom(
    name: '_AdminStore.mensagemErro',
    context: context,
  );

  @override
  String? get mensagemErro {
    _$mensagemErroAtom.reportRead();
    return super.mensagemErro;
  }

  @override
  set mensagemErro(String? value) {
    _$mensagemErroAtom.reportWrite(value, super.mensagemErro, () {
      super.mensagemErro = value;
    });
  }

  late final _$fazerLoginAsyncAction = AsyncAction(
    '_AdminStore.fazerLogin',
    context: context,
  );

  @override
  Future<bool> fazerLogin(String usuario, String senha) {
    return _$fazerLoginAsyncAction.run(() => super.fazerLogin(usuario, senha));
  }

  late final _$_AdminStoreActionController = ActionController(
    name: '_AdminStore',
    context: context,
  );

  @override
  void fazerLogout() {
    final _$actionInfo = _$_AdminStoreActionController.startAction(
      name: '_AdminStore.fazerLogout',
    );
    try {
      return super.fazerLogout();
    } finally {
      _$_AdminStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void limparErro() {
    final _$actionInfo = _$_AdminStoreActionController.startAction(
      name: '_AdminStore.limparErro',
    );
    try {
      return super.limparErro();
    } finally {
      _$_AdminStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isAutenticado: ${isAutenticado},
nomeUsuario: ${nomeUsuario},
carregando: ${carregando},
mensagemErro: ${mensagemErro}
    ''';
  }
}
