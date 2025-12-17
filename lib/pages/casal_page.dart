import 'package:daviedeborah/stores/casal_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/full_galery.dart';
import '../widgets/section_title.dart';
import '../config/app_theme.dart';

class CasalPage extends StatefulWidget {
  const CasalPage({super.key});

  @override
  State<CasalPage> createState() => _CasalPageState();
}

class _CasalPageState extends State<CasalPage> {
  final casalStore = CasalStore();

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
        ],
      ),
    );
  }

  Widget _buildStorySection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 100,
      ),
      child: Column(
        children: [
          _buildStoryItem(
            'Tudo começou com uma amizade, há cerca de dez anos, que nos conduziu até o momento que vivemos hoje. Ao longo desse tempo, compartilhamos inúmeras experiências: das feiras de ciências do ensino fundamental à formatura da faculdade, passando por mudanças, desafios e muitas conquistas.'
            'No dia 12 de junho de 2022, a amizade deu lugar ao namoro e, quatro anos e um mês depois, estaremos celebrando o nosso casamento. O amor nos acompanhou em cada passo dessa caminhada, e Deus sempre esteve ao nosso lado, guiando-nos até aqui.',
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
    return Column(
      children: [
        // Carrossel
        Container(
          height: isMobile ? 350 : 550,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 100),
          child: Stack(
            children: [
              // PageView com as imagens
              PageView.builder(
                controller: casalStore.pageController,
                onPageChanged: casalStore.onChangePage,
                itemCount: casalStore.galeryImages.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullGaleryImages(
                              imagens: casalStore.galeryImages,
                              index: index,
                              hero: 'galeryImage$index',
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'galeryImage$index',
                        child: Image.asset(
                          casalStore.galeryImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.accentColor.withValues(
                                alpha: 0.3,
                              ),
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
                    ),
                  );
                },
              ),

              // Botões de navegação
              if (!isMobile)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        casalStore.pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          FontAwesomeIcons.chevronLeft,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!isMobile)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        casalStore.pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          FontAwesomeIcons.chevronRight,
                          color: Colors.white,
                          size: 20,
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
        Observer(
          builder: (_) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                casalStore.galeryImages.length,
                (index) => GestureDetector(
                  onTap: () {
                    casalStore.pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: casalStore.currentPage == index ? 32 : 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: casalStore.currentPage == index
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 48),
      ],
    );
  }
}
