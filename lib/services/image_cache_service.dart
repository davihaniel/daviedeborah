import 'package:flutter/material.dart';

/// Serviço de cache e pré-carregamento de imagens
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();

  factory ImageCacheService() {
    return _instance;
  }

  ImageCacheService._internal();

  ImageProvider _providerFromPath(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    return AssetImage(path);
  }

  /// Pré-carrega todas as imagens da galeria no background (asset ou URL)
  Future<void> precacheAllImages(
    BuildContext context,
    List<String> imagePaths,
  ) async {
    try {
      for (final path in imagePaths) {
        precacheImage(_providerFromPath(path), context);
      }
      debugPrint('✅ Imagens pré-carregadas com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao pré-carregar imagens: $e');
    }
  }

  /// Pré-carrega um grupo de imagens com delay para não sobrecarregar
  Future<void> precacheImagesWithDelay(
    BuildContext context,
    List<String> imagePaths, {
    Duration delayBetween = const Duration(milliseconds: 100),
  }) async {
    try {
      for (int i = 0; i < imagePaths.length; i++) {
        // ignore: use_build_context_synchronously
        precacheImage(_providerFromPath(imagePaths[i]), context);
        if (i < imagePaths.length - 1) {
          await Future.delayed(delayBetween);
        }
      }
      debugPrint('✅ Imagens pré-carregadas com delay');
    } catch (e) {
      debugPrint('❌ Erro ao pré-carregar imagens: $e');
    }
  }

  /// Limpa o cache de imagens
  void clearImageCache() {
    imageCache.clearLiveImages();
    imageCache.clear();
    debugPrint('🧹 Cache de imagens limpo');
  }

  /// Limpa cache mas mantém imagens em memória
  void clearOnlyPersistentCache() {
    imageCache.clear();
    debugPrint('🧹 Cache persistente limpo');
  }

  /// Obtém informações sobre o cache
  ImageCacheStatus getCacheStatus() {
    return imageCache.statusForKey(AssetImage(''));
  }
}

/// Widget que pré-carrega imagens automaticamente ao aparecer na tela
class ImagePrecacheWidget extends StatefulWidget {
  final List<String> imagePaths;
  final Widget child;
  final Duration delayBetween;
  final bool precacheOnInit;

  const ImagePrecacheWidget({
    super.key,
    required this.imagePaths,
    required this.child,
    this.delayBetween = const Duration(milliseconds: 100),
    this.precacheOnInit = true,
  });

  @override
  State<ImagePrecacheWidget> createState() => _ImagePrecacheWidgetState();
}

class _ImagePrecacheWidgetState extends State<ImagePrecacheWidget> {
  final ImageCacheService _cacheService = ImageCacheService();
  bool precachingComplete = false;

  @override
  void initState() {
    super.initState();
    if (widget.precacheOnInit) {
      _precacheImages();
    }
  }

  Future<void> _precacheImages() async {
    await _cacheService.precacheImagesWithDelay(
      context,
      widget.imagePaths,
      delayBetween: widget.delayBetween,
    );
    setState(() => precachingComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Widget que carrega imagem com fade animation
class FadedAssetImage extends StatefulWidget {
  final String assetPath; // agora aceita URL ou asset
  final BoxFit fit;
  final Duration duration;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;

  const FadedAssetImage({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.duration = const Duration(milliseconds: 500),
    this.width,
    this.height,
    this.loadingBuilder,
  });

  @override
  State<FadedAssetImage> createState() => _FadedAssetImageState();
}

class _FadedAssetImageState extends State<FadedAssetImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Precache a imagem
    final ImageProvider<Object> provider = widget.assetPath.startsWith('http')
        ? NetworkImage(widget.assetPath)
        : AssetImage(widget.assetPath);

    precacheImage(provider, context).then((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object> provider = widget.assetPath.startsWith('http')
        ? NetworkImage(widget.assetPath)
        : AssetImage(widget.assetPath);

    return FadeTransition(
      opacity: _animation,
      child: Image(
        image: provider,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.shade200,
            child: const Center(child: Icon(Icons.image_not_supported)),
          );
        },
      ),
    );
  }
}
