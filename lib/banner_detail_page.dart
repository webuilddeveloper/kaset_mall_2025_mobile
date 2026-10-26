import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kasetmall/component/link_url_in.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/shared/extension.dart';

class BannerDetailPage extends StatelessWidget {
  const BannerDetailPage({
    super.key,
    required this.model,
    this.gallery = const [],
  });

  final Map<String, dynamic> model;
  final List<String> gallery;

  @override
  Widget build(BuildContext context) {
    final imageUrl = (model['imageUrl'] ?? '').toString();
    final title = (model['title'] ?? '').toString().trim();
    final description = (model['description'] ?? '').toString().trim();
    final linkUrl = (model['linkUrl'] ?? '').toString().trim();
    final createDate = (model['createDate'] ?? '').toString();
    final descriptionImages = RegExp(r'<img[^>]+src="([^"]+)"')
        .allMatches(description)
        .map((m) => m.group(1)!)
        .toList();
    final descriptionHtml = description
        .replaceAll(RegExp(r'<img[^>]*>'), '')
        .replaceAll(RegExp(r'<br\s*/?>'), '');
    final hasDescriptionText = descriptionHtml
        .replaceAll(RegExp(r'<[^>]*>|&#10;|&nbsp;'), '')
        .trim()
        .isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'รายละเอียด',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  if (createDate.length >= 8) ...[
                    const SizedBox(height: 8),
                    Text(
                      dateStringToDate(createDate),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            if (imageUrl.isNotEmpty || gallery.isNotEmpty)
              _BannerGallery(images: [
                if (imageUrl.isNotEmpty) imageUrl,
                ...gallery,
              ]),
            if (hasDescriptionText)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Html(data: descriptionHtml),
              ),
            for (final url in descriptionImages) _buildImage(context, url),
            if (linkUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => launchInWebViewWithJavaScript(linkUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('เปิดลิงก์'),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String url) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _BannerImageViewer(imageUrl: url)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: loadingImageNetwork(
          url,
          fit: BoxFit.fitWidth,
          width: double.infinity,
        ),
      ),
    );
  }
}

class _BannerImageViewer extends StatelessWidget {
  const _BannerImageViewer({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _BannerGallery extends StatefulWidget {
  const _BannerGallery({required this.images});

  final List<String> images;

  @override
  State<_BannerGallery> createState() => _BannerGalleryState();
}

class _BannerGalleryState extends State<_BannerGallery> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _BannerImageViewer(imageUrl: images[_selected]),
            ),
          ),
          child: loadingImageNetwork(
            images[_selected],
            fit: BoxFit.fitWidth,
            width: double.infinity,
          ),
        ),
        if (images.length > 1)
          SizedBox(
            height: 72,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = index == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = index),
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        width: 2,
                        color: selected
                            ? const Color(0xFF09665a)
                            : Colors.transparent,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: loadingImageNetwork(
                        images[index],
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
