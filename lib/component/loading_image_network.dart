import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';

ImageProvider? _resolveImageProvider(String url) {
  if (url.isEmpty) return null;

  if (url.startsWith('assets/')) {
    return AssetImage(url);
  }

  if (url.startsWith('file://')) {
    final file = File(Uri.parse(url).toFilePath());
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }

  final file = File(url);
  if (file.existsSync()) {
    return FileImage(file);
  }

  return CachedNetworkImageProvider(url);
}

Widget loadingImageNetwork(
  String url, {
  BoxFit? fit,
  double? height,
  double? width,
  Color? color,
  bool isProfile = false,
}) {
  if (url == '' && isProfile)
    return Container(
      height: 30,
      width: 30,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Image.asset(
        'assets/images/user_not_found.png',
        color: Colors.white,
      ),
    );
  if (url == '')
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image),
    );

  if (url.startsWith('assets/')) {
    return Image.asset(
      url,
      fit: fit,
      height: height,
      width: width,
      color: color,
      errorBuilder: (_, __, ___) => Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image),
      ),
    );
  }

  if (url.startsWith('file://')) {
    final file = File(Uri.parse(url).toFilePath());
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: fit,
        height: height,
        width: width,
        color: color,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          width: width,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image),
        ),
      );
    }
  } else {
    final file = File(url);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: fit,
        height: height,
        width: width,
        color: color,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          width: width,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image),
        ),
      );
    }
  }

  return CachedNetworkImage(
    imageUrl: url,
    fit: fit,
    height: height,
    width: width,
    color: color,
    placeholder: (_, __) => TweenAnimationBuilder(
      duration: Duration(seconds: 1),
      tween: Tween<double>(begin: 0.5, end: 1.0),
      builder: (_, double opacity, __) {
        return Opacity(
          opacity: opacity,
          child: Container(
            height: height ?? 30,
            width: width ?? 30,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/kaset/no-img.png',
            ),
          ),
        );
      },
      onEnd: () {
        Future.delayed(Duration(milliseconds: 500), () {});
      },
    ),
    errorWidget: (_, __, ___) => Container(
      height: 30,
      width: 30,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Image.asset(
        'assets/images/kaset/no-img.png',
      ),
    ),
  );
}

class AdaptiveProductImage extends StatefulWidget {
  const AdaptiveProductImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.borderRadius = 0,
    this.blurThreshold = 0.35,
    this.backgroundOpacity = 0.18,
    this.padding = const EdgeInsets.all(10),
  });

  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double borderRadius;
  final double blurThreshold;
  final double backgroundOpacity;
  final EdgeInsets padding;

  @override
  State<AdaptiveProductImage> createState() => _AdaptiveProductImageState();
}

class _AdaptiveProductImageState extends State<AdaptiveProductImage> {
  ImageProvider? _provider;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ImageInfo? _imageInfo;

  @override
  void initState() {
    super.initState();
    _syncProvider();
  }

  @override
  void didUpdateWidget(covariant AdaptiveProductImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _clearListener();
      _imageInfo = null;
      _syncProvider();
    }
  }

  @override
  void dispose() {
    _clearListener();
    super.dispose();
  }

  void _clearListener() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  void _syncProvider() {
    final provider = _resolveImageProvider(widget.url);
    _provider = provider;
    if (provider == null) return;

    final stream = provider.resolve(const ImageConfiguration());
    final listener = ImageStreamListener(
      (imageInfo, synchronousCall) {
        if (!mounted) return;
        setState(() {
          _imageInfo = imageInfo;
        });
      },
      onError: (exception, stackTrace) {
        if (!mounted) return;
        setState(() {
          _imageInfo = null;
        });
      },
    );
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  bool get _shouldBlur {
    final info = _imageInfo;
    if (info == null) return false;
    final imageAspect = info.image.width / info.image.height;
    const boxAspect = 1.0;
    final ratioDiff = ((imageAspect - boxAspect).abs()) / boxAspect;
    return ratioDiff > widget.blurThreshold;
  }

  Widget _buildImage(ImageProvider provider, {BoxFit? fit}) {
    return Image(
      image: provider,
      fit: fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/kaset/no-img.png',
        fit: BoxFit.contain,
        width: widget.width,
        height: widget.height,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_provider == null) {
      return Container(
        height: widget.height,
        width: widget.width,
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/kaset/no-img.png',
          fit: BoxFit.contain,
          height: widget.height,
          width: widget.width,
        ),
      );
    }

    final provider = _provider!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxHeight = widget.height ?? constraints.maxHeight;
        final boxWidth = widget.width ?? constraints.maxWidth;
        final showBlur = _shouldBlur;

        Widget child;
        if (showBlur) {
          child = Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(provider, fit: BoxFit.cover),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.white.withValues(alpha: widget.backgroundOpacity),
                ),
              ),
              Padding(
                padding: widget.padding,
                child: Center(
                  child: _buildImage(provider, fit: widget.fit),
                ),
              ),
            ],
          );
        } else {
          child = Center(
            child: Padding(
              padding: widget.padding,
              child: _buildImage(provider, fit: widget.fit),
            ),
          );
        }

        return SizedBox(
          height: widget.height ?? boxHeight,
          width: widget.width ?? boxWidth,
          child: child,
        );
      },
    );
  }
}
