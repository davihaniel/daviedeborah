// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsvp_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RsvpStore on _RsvpStore, Store {
  Computed<bool>? _$formularioValidoComputed;

  @override
  bool get formularioValido => (_$formularioValidoComputed ??= Computed<bool>(
    () => super.formularioValido,
    name: '_RsvpStore.formularioValido',
  )).value;

  late final _$nomeAtom = Atom(name: '_RsvpStore.nome', context: context);

  @override
  String get nome {
    _$nomeAtom.reportRead();
    return super.nome;
  }

  @override
  set nome(String value) {
    _$nomeAtom.reportWrite(value, super.nome, () {
      super.nome = value;
    });
  }

  late final _$telefoneAtom = Atom(
    name: '_RsvpStore.telefone',
    context: context,
  );

  @override
  String get telefone {
    _$telefoneAtom.reportRead();
    return super.telefone;
  }

  @override
  set telefone(String value) {
    _$telefoneAtom.reportWrite(value, super.telefone, () {
      super.telefone = value;
    });
  }

  late final _$confirmadoAtom = Atom(
    name: '_RsvpStore.confirmado',
    context: context,
  );

  @override
  bool get confirmado {
    _$confirmadoAtom.reportRead();
    return super.confirmado;
  }

  @override
  set confirmado(bool value) {
    _$confirmadoAtom.reportWrite(value, super.confirmado, () {
      super.confirmado = value;
    });
  }

  late final _$numeroPessoasAtom = Atom(
    name: '_RsvpStore.numeroPessoas',
    context: context,
  );

  @override
  int get numeroPessoas {
    _$numeroPessoasAtom.reportRead();
    return super.numeroPessoas;
  }

  @override
  set numeroPessoas(int value) {
    _$numeroPessoasAtom.reportWrite(value, super.numeroPessoas, () {
      super.numeroPessoas = value;
    });
  }

  late final _$_RsvpStoreActionController = ActionController(
    name: '_RsvpStore',
    context: context,
  );

  @override
  void setNome(String value) {
    final _$actionInfo = _$_RsvpStoreActionController.startAction(
      name: '_RsvpStore.setNome',
    );
    try {
      return super.setNome(value);
    } finally {
      _$_RsvpStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTelefone(String value) {
    final _$actionInfo = _$_RsvpStoreActionController.startAction(
      name: '_RsvpStore.setTelefone',
    );
    try {
      return super.setTelefone(value);
    } finally {
      _$_RsvpStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setConfirmado(bool value) {
    final _$actionInfo = _$_RsvpStoreActionController.startAction(
      name: '_RsvpStore.setConfirmado',
    );
    try {
      return super.setConfirmado(value);
    } finally {
      _$_RsvpStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNumeroPessoas(int value) {
    final _$actionInfo = _$_RsvpStoreActionController.startAction(
      name: '_RsvpStore.setNumeroPessoas',
    );
    try {
      return super.setNumeroPessoas(value);
    } finally {
      _$_RsvpStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void limpar() {
    final _$actionInfo = _$_RsvpStoreActionController.startAction(
      name: '_RsvpStore.limpar',
    );
    try {
      return super.limpar();
    } finally {
      _$_RsvpStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
nome: ${nome},
telefone: ${telefone},
confirmado: ${confirmado},
numeroPessoas: ${numeroPessoas},
formularioValido: ${formularioValido}
    ''';
  }
}
