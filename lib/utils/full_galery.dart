import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullGaleryImages extends StatefulWidget {
  final List<String> imagens;
  final int index;
  final String hero;

  const FullGaleryImages({
    super.key,
    required this.imagens,
    required this.index,
    required this.hero,
  });

  @override
  State<FullGaleryImages> createState() => _FullGaleryImagesState();
}

class _FullGaleryImagesState extends State<FullGaleryImages> {
  late PageController _pageController;
  late int _currentIndex;
  final Set<int> _cachedIndices = {};
  static const int _maxCachedPages =
      5; // Máximo de páginas em cache para mobile

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    // viewportFraction 1.0 garante que apenas uma imagem é visível por vez
    // keepPage false permite liberar memória de páginas não visíveis
    _pageController = PageController(
      initialPage: widget.index,
      viewportFraction: 1.0,
      keepPage: false,
    );
    _cachedIndices.add(widget.index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Limpa cache de imagens ao sair da galeria
    _cachedIndices.clear();
    super.dispose();
  }

  void _manageCacheSize(int currentPage) {
    // Mantém apenas as imagens próximas em cache
    if (_cachedIndices.length > _maxCachedPages) {
      // Remove índices mais distantes do atual
      final toRemove = _cachedIndices
          .where((idx) => (idx - currentPage).abs() > 2)
          .toList();
      _cachedIndices.removeAll(toRemove);

      // Força garbage collection das imagens removidas
      // evictando-as do cache de imagens do Flutter
      for (var idx in toRemove) {
        if (idx >= 0 && idx < widget.imagens.length) {
          CachedNetworkImageProvider(widget.imagens[idx]).evict();
        }
      }
    }

    // Adiciona páginas adjacentes ao cache
    for (var i = currentPage - 1; i <= currentPage + 1; i++) {
      if (i >= 0 && i < widget.imagens.length) {
        _cachedIndices.add(i);
      }
    }
  }

  void _goTo(int delta) {
    if (widget.imagens.isEmpty) return;
    final next = (_currentIndex + delta) % widget.imagens.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 40, left: 16),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Voltar'),
        ),
      ),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: _buildItem,
            itemCount: widget.imagens.length,
            loadingBuilder: (context, event) =>
                const Center(child: CircularProgressIndicator()),
            pageController: _pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: (i) {
              setState(() {
                _currentIndex = i;
                // Gerencia o cache a cada mudança de página
                _manageCacheSize(i);
              });
            },
            // Adiciona configuração para liberar memória
            gaplessPlayback: false,
          ),
          // Navegação para desktop
          if (!isMobile && widget.imagens.length > 1) ...[
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavButton(
                  tag: 'previousButton',
                  icon: Icons.chevron_left,
                  onTap: () => _goTo(-1),
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavButton(
                  tag: 'nextButton',
                  icon: Icons.chevron_right,
                  onTap: () => _goTo(1),
                ),
              ),
            ),
          ],
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Text(
                  "Clique duas vezes na imagem para ampliar",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final item = widget.imagens[index];
    final isMobile = MediaQuery.of(context).size.width < 900;

    return PhotoViewGalleryPageOptions(
      imageProvider: CachedNetworkImageProvider(
        item,
        // Configuração otimizada para mobile
        maxHeight: isMobile ? 1080 : null,
        maxWidth: isMobile ? 1920 : null,
      ),
      initialScale: PhotoViewComputedScale.contained,
      heroAttributes: PhotoViewHeroAttributes(tag: widget.hero),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2.0,
      // Permite que o Flutter libere a imagem quando não estiver visível
      tightMode: true,
      filterQuality: isMobile ? FilterQuality.medium : FilterQuality.high,
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String tag;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,

      child: Material(
        color: Colors.black.withValues(alpha: 0.4),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
