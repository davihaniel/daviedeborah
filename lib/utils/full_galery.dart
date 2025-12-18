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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _pageController = PageController(initialPage: widget.index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int delta) {
    if (widget.imagens.isEmpty) return;
    final next = (_currentIndex + delta) % widget.imagens.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    _precacheAdjacentImages(next);
  }

  /// Pré-carrega imagens adjacentes para navegação suave
  void _precacheAdjacentImages(int currentIndex) {
    final nextIndex = (currentIndex + 1) % widget.imagens.length;
    final previousIndex =
        currentIndex == 0 ? widget.imagens.length - 1 : currentIndex - 1;

    precacheImage(_providerFromPath(widget.imagens[nextIndex]), context);
    precacheImage(_providerFromPath(widget.imagens[previousIndex]), context);
  }

  ImageProvider _providerFromPath(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    return AssetImage(path);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
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
              setState(() => _currentIndex = i);
              _precacheAdjacentImages(i);
            },
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
        ],
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final item = widget.imagens[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: _providerFromPath(item),
      initialScale: PhotoViewComputedScale.contained,
      heroAttributes: PhotoViewHeroAttributes(tag: widget.hero),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2.0,
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
