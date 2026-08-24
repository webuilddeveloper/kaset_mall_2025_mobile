import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';

class PrivilegeForm extends StatefulWidget {
  const PrivilegeForm({
    super.key,
    this.url,
    this.code,
    this.model,
    this.urlComment,
    this.urlGallery,
  });

  final String? url;
  final String? code;
  final dynamic model;
  final String? urlComment;
  final String? urlGallery;

  @override
  State<PrivilegeForm> createState() => _PrivilegeFormState();
}

class _PrivilegeFormState extends State<PrivilegeForm> {
  String _string(dynamic value, [String fallback = '']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  List<String> _imageList() {
    final raw = widget.model?['imageUrl'] ??
        widget.model?['image'] ??
        widget.model?['banner'] ??
        widget.model?['photo'];

    if (raw == null) return <String>[];
    if (raw is List) {
      return raw
          .map((item) =>
              item is Map ? item['url']?.toString() ?? '' : item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    final text = raw.toString().trim();
    if (text.isEmpty) return <String>[];

    if (text.startsWith('[')) {
      try {
        final decoded = jsonDecode(text);
        if (decoded is List) {
          return decoded
              .map((item) =>
                  item is Map ? item['url']?.toString() ?? '' : item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList();
        }
      } catch (_) {}
    }

    return <String>[text];
  }

  ImageProvider _imageProvider(String path) {
    if (path.isEmpty) {
      return const AssetImage('assets/images/kaset/no-img.png');
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return const AssetImage('assets/images/kaset/no-img.png');
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHtmlDescription(String html) {
    return Html(
      data: html,
      style: {
        '*': Style(
          fontFamily: 'Kanit',
          fontSize: FontSize(13.5),
          color: AppColors.textPrimary,
          lineHeight: const LineHeight(1.55),
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        'p': Style(
          margin: Margins.only(bottom: 10),
        ),
        'strong': Style(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        'ul': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        'li': Style(
          margin: Margins.only(bottom: 8),
        ),
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildCodeBox(String code) {
    final displayCode = code.isNotEmpty ? code : 'ไม่มีโค้ด';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.confirmation_number_rounded,
          color: AppColors.primary,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'โค้ดสำหรับใช้แลก',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                displayCode,
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: code.isEmpty
              ? null
              : () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('คัดลอกโค้ดแล้ว'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'คัดลอก',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _string(widget.model?['title'], 'สิทธิประโยชน์');
    final usageHtml = _string(
      widget.model?['description'] ??
          widget.model?['detail'] ??
          widget.model?['summary'],
      'รายละเอียดสิทธิประโยชน์จาก เกษตร Mall สำหรับลูกค้าที่ต้องการความคุ้มค่าและความสะดวกในการใช้งาน',
    );
    final bannerImages = _imageList();
    final coverImage = bannerImages.isNotEmpty
        ? bannerImages.first
        : _string(widget.model?['imageUrl'] ?? widget.model?['image']);
    final code = _string(widget.model?['code'], widget.code ?? '');
    final tag = _string(widget.model?['tag'], 'สิทธิประโยชน์');
    final period = _string(
      widget.model?['period'] ??
          widget.model?['date'] ??
          widget.model?['startDate'] ??
          widget.model?['expiry'],
      'ตรวจสอบตามช่วงเวลาที่ประกาศ',
    );
    final condition = _string(
      widget.model?['condition'] ??
          widget.model?['terms'] ??
          widget.model?['detailCondition'] ??
          widget.model?['minimumOrderTotal'],
      'ใช้ได้กับสินค้าที่ร่วมรายการตามเงื่อนไขของแอป',
    );
    final detailText = _string(
      widget.model?['detail'] ??
          widget.model?['description'] ??
          widget.model?['summary'],
      'สิทธิประโยชน์จากพาร์ทเนอร์ที่ช่วยให้ลูกค้าได้รับความคุ้มค่าเพิ่มเติมจากการใช้งาน',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KasetAppBar(
        title: title,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 205,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (coverImage.isNotEmpty)
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Image(
                            image: _imageProvider(coverImage),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.tintGreenSoft,
                            ),
                          ),
                        )
                      else
                        Container(color: AppColors.tintGreenSoft),
                      Container(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          child: Image(
                            image: _imageProvider(coverImage),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              code.isNotEmpty
                                  ? 'รหัส $code'
                                  : 'รายละเอียดสิทธิประโยชน์',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 12.5,
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'รายละเอียดสิทธิประโยชน์',
                child: _buildHtmlDescription(
                  detailText.isNotEmpty ? detailText : usageHtml,
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'เงื่อนไขการใช้',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoTile(
                      'ระยะเวลา',
                      period,
                      Icons.event_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      'เงื่อนไข',
                      condition,
                      Icons.rule_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'โค้ดสำหรับใช้แลก',
                child: _buildCodeBox(code),
              ),
              // const SizedBox(height: 18),
              // SizedBox(
              //   width: double.infinity,
              //   height: 48,
              //   child: ElevatedButton(
              //     onPressed: () => Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => const PrivilegeAllPage(title: 'คูปอง'),
              //       ),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.primary,
              //       foregroundColor: Colors.white,
              //       elevation: 0,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(16),
              //       ),
              //     ),
              //     child: const Text(
              //       'ดูคูปองทั้งหมด',
              //       style: TextStyle(
              //         fontFamily: 'Kanit',
              //         fontSize: 15,
              //         fontWeight: FontWeight.w700,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
