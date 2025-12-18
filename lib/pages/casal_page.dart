import 'package:daviedeborah/stores/casal_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;
import '../utils/full_galery.dart';
import '../utils/variables.dart';
import '../widgets/section_title.dart';
import '../config/app_theme.dart';

class CasalPage extends StatefulWidget {
  const CasalPage({super.key});

  @override
  State<CasalPage> createState() => _CasalPageState();
}

class _CasalPageState extends State<CasalPage> {
  final casalStore = CasalStore();

  static bool _isYoutubeRegistered = false;

  static void _registerYoutubeIfNeeded() {
    if (_isYoutubeRegistered) return;

    // Registra o iframe do YouTube
    ui.platformViewRegistry.registerViewFactory('youtube-iframe', (
      int viewId,
    ) {
      final iframe = web.HTMLIFrameElement()
        ..src =
            'https://www.youtube.com/embed/R41bUKb_svo?si=BDH6-n_-8BGJ-rtR'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true
        ..loading = 'lazy';

      return iframe;
    });

    _isYoutubeRegistered = true;
  }

  @override
  void initState() {
    super.initState();
    casalStore.pageController = PageController();
    casalStore.startAutoScroll();
  }

  @override
  void dispose() {
    casalStore.autoScrollTimer.cancel();
    casalStore.pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final currentPage = casalStore.currentPage;
    final nextPage = (currentPage + 1) % galeryImages.length;
    casalStore.pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    final currentPage = casalStore.currentPage;
    final previousPage = currentPage == 0
        ? galeryImages.length - 1
        : currentPage - 1;
    casalStore.pageController.animateToPage(
      previousPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  /// Pré-carrega próxima e anterior imagem do carrossel
  void _precacheNextImage(int currentIndex) {
    final nextIndex = (currentIndex + 1) % galeryImages.length;
    final previousIndex =
        currentIndex == 0 ? galeryImages.length - 1 : currentIndex - 1;

    precacheImage(AssetImage(galeryImages[nextIndex]), context);
    precacheImage(AssetImage(galeryImages[previousIndex]), context);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const SectionTitle(
            title: 'Nossa História',
            subtitle: 'Como tudo começou...',
          ),
          const SizedBox(height: 48),

          // História do casal
          _buildStorySection(isMobile),

          const SizedBox(height: 64),

          _buildGalery(context, isMobile),

          const SizedBox(height: 64),

          _buildYoutubeVideo(isMobile),
        ],
      ),
    );
  }

  Widget _buildStorySection(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 1200,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48),
      child: Column(
        children: [
          _buildStoryItem(
            'Tudo começou com uma amizade, há cerca de dez anos, que nos conduziu até o momento que vivemos hoje. Ao longo desse tempo, compartilhamos inúmeras experiências: das feiras de ciências do ensino fundamental à formatura da faculdade, passando por mudanças, desafios e muitas conquistas.'
            ' No dia 12 de junho de 2022, a amizade deu lugar ao namoro e, quatro anos e um mês depois, estaremos celebrando o nosso casamento. O amor nos acompanhou em cada passo dessa caminhada, e Deus sempre esteve ao nosso lado, guiando-nos até aqui.',
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(String text, bool isMobile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.lato(
                fontSize: isMobile ? 15 : 17,
                color: AppTheme.textColor,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalery(BuildContext context, bool isMobile) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Carrossel
        SizedBox(
          height: height* .96,
          child: Stack(
            children: [
              // PageView com as imagens
              Observer(
                builder: (_) {
                  return PageView.builder(
                    controller: casalStore.pageController,
                    onPageChanged: casalStore.onChangePage,
                    itemCount: galeryImages.length,
                    itemBuilder: (context, index) {
                      // Pré-carregar próxima e anterior imagem
                      _precacheNextImage(index);
                      
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullGaleryImages(
                                imagens: galeryImages,
                                index: index,
                                hero: 'galeryImage$index',
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'galeryImage$index',
                          child: Image.asset(
                            galeryImages[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppTheme.accentColor.withValues(alpha: 0.3),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.image,
                                        size: isMobile ? 40 : 60,
                                        color: AppTheme.primaryColor.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Foto ${index + 1}',
                                        style: GoogleFonts.lato(
                                          fontSize: isMobile ? 14 : 16,
                                          color: AppTheme.primaryColor.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              ),

              // Botões de navegação
              if (!isMobile)
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Hero(
                      tag: 'previousButton',
                      child: IconButton.filled(
                        onPressed: _previousPage,
                        icon: const Icon(
                          FontAwesomeIcons.chevronLeft,
                          color: Colors.white,
                          size: 17,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.3,
                          ),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
              if (!isMobile)
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Hero(
                      tag: 'nextButton',
                      child: IconButton.filled(
                        onPressed: _nextPage,
                        icon: const Icon(
                          FontAwesomeIcons.chevronRight,
                          color: Colors.white,
                          size: 17,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.3,
                          ),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Indicadores (dots)
        Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 7,
          children: List.generate(
            galeryImages.length,
            (index) => InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                casalStore.pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: Observer(
                builder: (_) {
                  return Container(
                    width: casalStore.currentPage == index ? 32 : 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: casalStore.currentPage == index
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }
              ),
            ),
          ),
        ),

        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildYoutubeVideo(bool isMobile) {
    _registerYoutubeIfNeeded();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: isMobile ? double.infinity : 1200,
          height: isMobile ? MediaQuery.of(context).size.width * 0.5625 : 675,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const HtmlElementView(viewType: 'youtube-iframe'),
        ),
      ),
    );
  }
}
