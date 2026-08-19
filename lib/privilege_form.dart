import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kasetmall/privilege_all.dart';
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
          .map((item) => item is Map ? item['url']?.toString() ?? '' : item.toString())
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
              .map((item) => item is Map ? item['url']?.toString() ?? '' : item.toString())
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.tintGreenSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13.5,
                color: AppColors.textPrimary,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
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
    final points = <String>[
      _string(widget.model?['point1']),
      _string(widget.model?['point2']),
      _string(widget.model?['point3']),
    ].where((e) => e.isNotEmpty).toList();

    if (points.isEmpty) {
      points.addAll([
        'คัดสรรข้อเสนอที่ช่วยให้ลูกค้าประหยัดค่ายิ่งขึ้น',
        'แสดงข้อมูลอย่างชัดเจน อ่านง่าย และใช้งานได้ทันที',
        'สอดคล้องกับสินค้าและหมวดหมู่ภายในแอปเกษตร Mall',
      ]);
    }

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
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 1.55,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      coverImage.isNotEmpty
                          ? Image(
                              image: _imageProvider(coverImage),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.tintGreenSoft,
                              ),
                            )
                          : Container(color: AppColors.tintGreenSoft),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.55),
                              Colors.transparent,
                            ],
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
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              code.isNotEmpty ? 'รหัส $code' : 'รายละเอียดสิทธิประโยชน์',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 12.5,
                                color: Colors.white.withValues(alpha: 0.9),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF143D16).withValues(alpha: 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'รายละเอียดการใช้งาน',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHtmlDescription(
                      widget.model?['description']?.toString().trim().isNotEmpty ==
                              true
                          ? widget.model!['description'].toString()
                          : usageHtml,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoTile('ระยะเวลา', period, Icons.event_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoTile('เงื่อนไข', condition, Icons.rule_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildInfoTile(
                'สิทธิประโยชน์ที่เกี่ยวข้อง',
                _string(widget.model?['related'] ?? widget.model?['category'], 'คัดสรรตามหมวดหมู่และสินค้าในแอป'),
                Icons.star_border_rounded,
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBF8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'รายละเอียดเพิ่มเติม',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...points.map(_buildBullet),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivilegeAllPage(title: 'คูปอง'),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'ดูคูปองทั้งหมด',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
