import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
part 'home_store.g.dart';

// ignore: library_private_types_in_public_api
class HomeStore = _HomeStoreBase with _$HomeStore;

abstract class _HomeStoreBase with Store {
  late Timer timer;
  
  @observable
  DateTime now = DateTime.now();

  @observable
  bool showAppBar = true;
  
  @observable
  double lastOffset = 0;

  @action
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      now = DateTime.now();
    });
  }

  
  @action
  void onScroll(ScrollController scrollController) {
    final current = scrollController.offset;
    final atTop = current <= 0;

    bool nextShow = showAppBar;
    if (atTop) {
      nextShow = true;
    } else if (current > lastOffset + 8) {
      nextShow = false;
    } else if (current < lastOffset - 8) {
      nextShow = true;
    }

    if (nextShow != showAppBar) {
        showAppBar = nextShow;
    }

    lastOffset = current;
  }
}
