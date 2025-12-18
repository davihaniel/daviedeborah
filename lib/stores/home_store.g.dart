// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeStore on _HomeStoreBase, Store {
  late final _$nowAtom = Atom(name: '_HomeStoreBase.now', context: context);

  @override
  DateTime get now {
    _$nowAtom.reportRead();
    return super.now;
  }

  @override
  set now(DateTime value) {
    _$nowAtom.reportWrite(value, super.now, () {
      super.now = value;
    });
  }

  late final _$showAppBarAtom = Atom(
    name: '_HomeStoreBase.showAppBar',
    context: context,
  );

  @override
  bool get showAppBar {
    _$showAppBarAtom.reportRead();
    return super.showAppBar;
  }

  @override
  set showAppBar(bool value) {
    _$showAppBarAtom.reportWrite(value, super.showAppBar, () {
      super.showAppBar = value;
    });
  }

  late final _$lastOffsetAtom = Atom(
    name: '_HomeStoreBase.lastOffset',
    context: context,
  );

  @override
  double get lastOffset {
    _$lastOffsetAtom.reportRead();
    return super.lastOffset;
  }

  @override
  set lastOffset(double value) {
    _$lastOffsetAtom.reportWrite(value, super.lastOffset, () {
      super.lastOffset = value;
    });
  }

  late final _$_HomeStoreBaseActionController = ActionController(
    name: '_HomeStoreBase',
    context: context,
  );

  @override
  void startTimer() {
    final _$actionInfo = _$_HomeStoreBaseActionController.startAction(
      name: '_HomeStoreBase.startTimer',
    );
    try {
      return super.startTimer();
    } finally {
      _$_HomeStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onScroll(ScrollController scrollController) {
    final _$actionInfo = _$_HomeStoreBaseActionController.startAction(
      name: '_HomeStoreBase.onScroll',
    );
    try {
      return super.onScroll(scrollController);
    } finally {
      _$_HomeStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
now: ${now},
showAppBar: ${showAppBar},
lastOffset: ${lastOffset}
    ''';
  }
}
