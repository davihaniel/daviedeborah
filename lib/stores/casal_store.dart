import 'dart:async';

import 'package:daviedeborah/main.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'casal_store.g.dart';

// ignore: library_private_types_in_public_api
class CasalStore = _CasalStoreBase with _$CasalStore;

abstract class _CasalStoreBase with Store {
  late Timer autoScrollTimer;
  late PageController pageController;

  @observable
  int currentPage = 0;
  

  @action
  void startAutoScroll() {
    autoScrollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (pageController.hasClients) {
        final nextPage = (currentPage + 1) % appSettings.galeryImages.length;
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @action
  onChangePage(int index) {
    currentPage = index;
    // resetar o timer ao trocar de página manualmente
    autoScrollTimer.cancel();
    startAutoScroll();
  }
}