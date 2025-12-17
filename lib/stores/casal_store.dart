import 'dart:async';

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
  
  // Lista de imagens do carrossel
  final List<String> galeryImages = [
    'assets/images/fundo1.jpg',
    'assets/images/carrossel_1.jpeg',
    'assets/images/carrossel_2.jpeg',
    'assets/images/carrossel_3.jpeg',
    'assets/images/carrossel_4.jpeg',
    'assets/images/carrossel_5.jpeg',
    'assets/images/carrossel_6.jpg',
    'assets/images/carrossel_7.jpg',
  ];

  @action
  void startAutoScroll() {
    autoScrollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (pageController.hasClients) {
        final nextPage = (currentPage + 1) % galeryImages.length;
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
  }
}