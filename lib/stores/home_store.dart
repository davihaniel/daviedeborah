import 'dart:async';

import 'package:mobx/mobx.dart';
part 'home_store.g.dart';

// ignore: library_private_types_in_public_api
class HomeStore = _HomeStoreBase with _$HomeStore;

abstract class _HomeStoreBase with Store {
  late Timer timer;
  
  @observable
  DateTime now = DateTime.now();

  @action
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      now = DateTime.now();
    });
  }
}
