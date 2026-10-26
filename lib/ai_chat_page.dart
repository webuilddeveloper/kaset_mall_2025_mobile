import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasetmall/shared/app_theme.dart';
import '../shared/api_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _brandColor = AppColors.primary;
const _inkColor = AppColors.textPrimary;
const _slateColor = AppColors.textSecondary;
const _mutedColor = Color(0xFF879383);
const _lineColor = AppColors.border;
const _surfaceColor = AppColors.tintGreenSoft;
const _pageBgTop = Color(0xFFF3F8F3);
const _pageBgMid = AppColors.tintGreenSoft;
const _pageBgBottom = Color(0xFFFFFCF5);
const _darkBackground = Color(0xFF101311);
const _darkSurface = Color(0xFF1A1D1A);
const _darkBorder = Color(0xFF354539);
const _darkText = Color(0xFFE5EEE3);
const _darkMuted = Color(0xFFA5B4A2);
const _radiusCardLg = 20.0;
const _radiusCardMd = 16.0;
const _radiusCardSm = 12.0;

TextStyle _kanit({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'Kanit',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
  );
}

final _apiUri = Uri.parse(server).resolve('AiWebChat');
const _referenceBaseUrl = server;
const _recentQuestionsKey = 'khubdee_ai_recent_questions';
const _maxRecentQuestions = 10;

const _exampleQuestions = <String>[
  'Kaset Mall มีสินค้าหมวดหมู่อะไรบ้าง',
  'มีปุ๋ยและสารปรับปรุงดินอะไรบ้าง',
  'มีเครื่องมือและอุปกรณ์ให้น้ำสำหรับงานเกษตรอะไรบ้าง',
  'มีวัตถุดิบและอาหารสัตว์ประเภทไหนบ้าง',
  'ข่าว Eco Brand เกี่ยวกับอะไร',
  'ค้นหาและกรองสินค้าตามหมวดหมู่หรือราคาได้อย่างไร',
];

class _ChatSource {
  const _ChatSource({
    required this.label,
    this.url,
    this.docId,
    this.referenceId,
    this.filePath,
  });

  factory _ChatSource.fromJson(Map<String, dynamic> json) {
    return _ChatSource(
      label: _stringValue(json['label']) ??
          _stringValue(json['filePath']) ??
          _stringValue(json['file_path']) ??
          'เอกสารอ้างอิง',
      url: _stringValue(json['url']) ?? _stringValue(json['download_url']),
      docId: _stringValue(json['docId']) ?? _stringValue(json['doc_id']),
      referenceId: _stringValue(json['referenceId']) ??
          _stringValue(json['reference_id']),
      filePath:
          _stringValue(json['filePath']) ?? _stringValue(json['file_path']),
    );
  }

  final String label;
  final String? url;
  final String? docId;
  final String? referenceId;
  final String? filePath;

  String? get previewUrl {
    if (docId != null) {
      return '$_referenceBaseUrl/reference/${Uri.encodeComponent(docId!)}';
    }
    if (referenceId != null) {
      return '$_referenceBaseUrl/reference?referenceId=${Uri.encodeQueryComponent(referenceId!)}';
    }
    if (filePath != null) {
      return '$_referenceBaseUrl/reference?filePath=${Uri.encodeQueryComponent(filePath!)}';
    }
    return url;
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.id,
    required this.role,
    required this.body,
    this.imagePath,
    this.sources = const [],
  });

  final String id;
  final String role;
  final String body;
  final String? imagePath;
  final List<_ChatSource> sources;

  _ChatMessage copyWith({String? body}) {
    return _ChatMessage(
      id: id,
      role: role,
      body: body ?? this.body,
      imagePath: imagePath,
      sources: sources,
    );
  }
}

String? _stringValue(dynamic value) {
  if (value is! String || value.trim().isEmpty) return null;
  return value.trim();
}

class AiChatPage extends StatefulWidget {
  const AiChatPage({
    this.onThemeChanged,
    this.initialIsDark = false,
    super.key,
  });

  final ValueChanged<bool>? onThemeChanged;
  final bool initialIsDark;

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _httpClient = http.Client();

  late final AnimationController _examplesController;
  Timer? _typingTimer;
  var _isDark = false;
  var _isThinking = false;
  var _isTyping = false;
  var _isListening = false;
  var _sidebarExpanded = true;
  var _recentQuestions = <String>[];
  var _messages = <_ChatMessage>[];
  XFile? _pendingImage;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isDark = widget.initialIsDark;
    _examplesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _loadRecentQuestions();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _examplesController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _httpClient.close();
    super.dispose();
  }

  Future<void> _loadRecentQuestions() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_recentQuestionsKey) ?? const [];
    if (mounted) {
      setState(
        () => _recentQuestions = stored.take(_maxRecentQuestions).toList(),
      );
    }
  }

  Future<void> _saveRecentQuestion(String question) async {
    final next = <String>[
      question,
      ..._recentQuestions.where(
        (item) => item.toLowerCase() != question.toLowerCase(),
      ),
    ].take(_maxRecentQuestions).toList();
    setState(() => _recentQuestions = next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_recentQuestionsKey, next);
  }

  Future<void> _clearRecentQuestions() async {
    setState(() => _recentQuestions = []);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_recentQuestionsKey);
  }

  void _startNewChat() {
    _typingTimer?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _messages = [];
      _isThinking = false;
      _isTyping = false;
      _pendingImage = null;
      _inputController.clear();
    });
    _examplesController.forward(from: 0);
  }

  Future<void> _toggleListening() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ฟีเจอร์รับคำถามด้วยเสียงยังไม่พร้อมในเวอร์ชันนี้'),
      ),
    );
  }

  Future<void> _send([String? providedText]) async {
    final typed = (providedText ?? _inputController.text).trim();
    final image = _pendingImage;
    if ((typed.isEmpty && image == null) || _isThinking || _isTyping) return;

    final question =
        typed.isNotEmpty ? typed : 'ช่วยดูจากเอกสาร/รูปที่แนบให้หน่อย';
    final apiMessage =
        image == null ? question : '$question\n[แนบรูปภาพ: ${image.name}]';

    FocusManager.instance.primaryFocus?.unfocus();
    final history = _messages
        .where((item) => item.role == 'user' || item.role == 'assistant')
        .toList()
        .reversed
        .take(6)
        .toList()
        .reversed
        .map((item) => {'role': item.role, 'content': item.body})
        .toList();

    _inputController.clear();
    await _saveRecentQuestion(question);
    if (!mounted) return;
    setState(() {
      _pendingImage = null;
      _messages.add(
        _ChatMessage(
          id: 'user-${DateTime.now().microsecondsSinceEpoch}',
          role: 'user',
          body: question,
          imagePath: image?.path,
        ),
      );
      _isThinking = true;
    });
    _scrollToBottom();

    try {
      final response = await _httpClient
          .post(
            _apiUri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'message': apiMessage, 'history': history}),
          )
          .timeout(const Duration(seconds: 90));
      debugPrint(
        'Kaset AI: HTTP ${response.statusCode}, '
        'url=$_apiUri, bytes=${response.bodyBytes.length}',
      );
      if (response.statusCode >= 500) {
        throw Exception(
          'เซิร์ฟเวอร์ AI ขัดข้อง (HTTP ${response.statusCode}) '
          'กรุณาลองใหม่ภายหลัง',
        );
      }
      if (response.statusCode == 404) {
        throw Exception('ไม่พบช่องทางบริการ AI (HTTP 404)');
      }
      final rawBody = utf8.decode(response.bodyBytes).trim();
      if (rawBody.isEmpty) {
        throw Exception(
          'เซิร์ฟเวอร์ไม่ส่งข้อมูลกลับมา (HTTP ${response.statusCode})',
        );
      }
      final decoded = jsonDecode(rawBody);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected an AI response object');
      }
      final data = decoded;
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['status'] == 'E') {
        throw Exception(
          _stringValue(data['message']) ?? 'ไม่สามารถเชื่อมต่อคลังความรู้ได้',
        );
      }

      final rawSources = data['sources'];
      final sources = rawSources is List
          ? rawSources
              .whereType<Map>()
              .map(
                (item) => _ChatSource.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
          : <_ChatSource>[];
      final answer = _stringValue(data['answer']) ??
          'ระบบไม่ได้รับข้อความคำตอบจากคลังความรู้';
      if (!mounted) return;
      setState(() => _isThinking = false);
      _animateAssistant(answer, sources);
    } on TimeoutException {
      _showError('ระบบใช้เวลาตอบนานเกินไป กรุณาลองใหม่อีกครั้ง');
    } on FormatException {
      _showError('รูปแบบคำตอบจากเซิร์ฟเวอร์ไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง');
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      _showError(message);
    }
  }

  Future<void> _showAttachImageSheet() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Theme(
          data: _isDark ? AppTheme.dark() : AppTheme.light(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: _isDark ? _darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _isDark ? _darkBorder : _lineColor,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'แนบรูปภาพ',
                      style: _kanit(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'เลือกจากคลังรูป หรือถ่ายด้วยกล้อง',
                      style: _kanit(
                          fontSize: 12,
                          color: _isDark ? _darkMuted : _slateColor),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _AttachOptionTile(
                            icon: Icons.photo_library_rounded,
                            label: 'คลังรูปภาพ',
                            onTap: () {
                              Navigator.pop(ctx);
                              _pickPendingImage(ImageSource.gallery);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AttachOptionTile(
                            icon: Icons.photo_camera_rounded,
                            label: 'ถ่ายรูป',
                            onTap: () {
                              Navigator.pop(ctx);
                              _pickPendingImage(ImageSource.camera);
                            },
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'ยกเลิก',
                        style: _kanit(
                            fontSize: 14,
                            color: _isDark ? _darkMuted : _slateColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickPendingImage(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() => _pendingImage = file);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเลือกรูปภาพได้')),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _isThinking = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _animateAssistant(String answer, List<_ChatSource> sources) {
    _typingTimer?.cancel();
    final id = 'assistant-${DateTime.now().microsecondsSinceEpoch}';
    var visibleCharacters = 0;
    final chunkSize = answer.length > 1600
        ? 12
        : answer.length > 700
            ? 7
            : 4;

    setState(() {
      _isTyping = true;
      _messages.add(
        _ChatMessage(id: id, role: 'assistant', body: '', sources: sources),
      );
    });
    _typingTimer = Timer.periodic(const Duration(milliseconds: 24), (timer) {
      if (!mounted) return timer.cancel();
      visibleCharacters = (visibleCharacters + chunkSize).clamp(
        0,
        answer.length,
      );
      final index = _messages.indexWhere((item) => item.id == id);
      if (index < 0) return timer.cancel();

      setState(
        () => _messages[index] = _messages[index].copyWith(
          body: answer.substring(0, visibleCharacters),
        ),
      );
      if (timer.tick % 4 == 0) _scrollToBottom();
      if (visibleCharacters >= answer.length) {
        timer.cancel();
        setState(() => _isTyping = false);
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });
  }

  void _openReference(_ChatSource source) {
    final url = source.previewUrl;
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เอกสารนี้ยังไม่มีลิงก์อ้างอิง')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ReferencePage(title: source.label, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final base = (_isDark ? AppTheme.dark() : AppTheme.light()).copyWith(
      scaffoldBackgroundColor: _isDark ? _darkBackground : _surfaceColor,
      dividerColor: _isDark ? _darkBorder : _lineColor,
    );
    return Theme(
      data: base,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: _isDark ? _darkBackground : _surfaceColor,
        drawer:
            wide ? null : Drawer(child: _buildRecentPanel(closeDrawer: true)),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeader(wide),
              Expanded(
                child: Row(
                  children: [
                    if (wide) _buildRecentPanel(),
                    Expanded(child: _buildChatSurface()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool wide) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(8, top + 6, 8, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, _brandColor],
        ),
      ),
      child: Row(
        children: [
          if (Navigator.of(context).canPop())
            _headerIconButton(
              tooltip: 'ย้อนกลับ',
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          if (!wide)
            _headerIconButton(
              tooltip: 'ประวัติคำถาม',
              icon: Icons.menu_rounded,
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          const SizedBox(width: 4),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ผู้ช่วยเกษตร',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Kaset Mall · สินค้าและข่าวสาร',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _kanit(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          _headerIconButton(
            tooltip: 'เริ่มแชทใหม่',
            icon: Icons.refresh_rounded,
            onPressed: _startNewChat,
          ),
          _headerIconButton(
            tooltip: _isDark ? 'โหมดสว่าง' : 'โหมดมืด',
            icon: _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            onPressed: () {
              setState(() => _isDark = !_isDark);
              widget.onThemeChanged?.call(_isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: 0.16),
      ),
      icon: Icon(icon, size: 20),
    );
  }

  Widget _buildRecentPanel({bool closeDrawer = false}) {
    final expanded = closeDrawer || _sidebarExpanded;
    final panelBg = _isDark ? _darkSurface : Colors.white;
    final cardBg =
        _isDark ? _darkBackground : _pageBgTop.withValues(alpha: 0.85);
    final cardBorder = _isDark ? _darkBorder : _lineColor;
    final titleColor = _isDark ? _darkText : _inkColor;
    final mutedColor = _isDark ? _darkMuted : _slateColor;
    final topInset = closeDrawer ? MediaQuery.paddingOf(context).top : 0.0;
    final panel = Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10, 12 + topInset, 10, 10),
          child: Row(
            children: [
              IconButton.filledTonal(
                tooltip: expanded ? 'ยุบแถบด้านข้าง' : 'ขยายแถบด้านข้าง',
                style: IconButton.styleFrom(
                  foregroundColor: _brandColor,
                  backgroundColor: _isDark
                      ? _brandColor.withValues(alpha: 0.18)
                      : _pageBgTop,
                ),
                onPressed: closeDrawer
                    ? () => Navigator.of(context).pop()
                    : () => setState(
                          () => _sidebarExpanded = !_sidebarExpanded,
                        ),
                icon: Icon(
                  closeDrawer
                      ? Icons.close_rounded
                      : expanded
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                ),
              ),
              if (expanded) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ประวัติคำถาม',
                        style: _kanit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      Text(
                        'เก็บล่าสุด 10 รายการ',
                        style: _kanit(
                          fontSize: 12,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'ล้างคำถามล่าสุด',
                  onPressed:
                      _recentQuestions.isEmpty ? null : _clearRecentQuestions,
                  color: mutedColor,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ],
          ),
        ),
        Divider(
          height: 1,
          color: _isDark ? _darkBorder : _lineColor,
        ),
        Expanded(
          child: expanded
              ? ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: _recentQuestions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return Material(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          if (closeDrawer) Navigator.of(context).pop();
                          _send(_recentQuestions[index]);
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: _brandColor,
                                child: Text(
                                  '${index + 1}',
                                  style: _kanit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _recentQuestions[index],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: _kanit(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: titleColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: closeDrawer ? null : (expanded ? 286 : 68),
      decoration: BoxDecoration(
        color: panelBg,
        border: closeDrawer
            ? null
            : Border(
                right: BorderSide(
                  color: _isDark ? _darkBorder : _lineColor,
                ),
              ),
      ),
      child: panel,
    );
  }

  Widget _buildChatSurface() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _isDark
                    ? const [_darkBackground, _darkBackground]
                    : const [_pageBgTop, _pageBgMid, _pageBgBottom],
              ),
            ),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 850),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_messages.isEmpty) _buildExamples(),
                        ..._messages.map(_buildMessage),
                        if (_isThinking) _buildThinking(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildComposer(),
      ],
    );
  }

  Widget _buildExamples() {
    final icons = [
      Icons.category_outlined,
      Icons.grass_rounded,
      Icons.water_drop_outlined,
      Icons.pets_outlined,
      Icons.newspaper_rounded,
      Icons.manage_search_rounded,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: CurvedAnimation(
            parent: _examplesController,
            curve: const Interval(0, 0.35, curve: Curves.easeOut),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDark
                    ? const [_darkSurface, Color(0xFF233827)]
                    : const [
                        _pageBgTop,
                        Colors.white,
                        Color(0xFFFFF7E9),
                      ],
              ),
              borderRadius: BorderRadius.circular(_radiusCardLg),
              border: Border.all(color: _brandColor.withValues(alpha: 0.35)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x142E7D32),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _brandColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(_radiusCardSm),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: AppColors.primaryHover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'สวัสดีค่ะ ยินดีต้อนรับสู่ Kaset Mall',
                            style: _kanit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _isDark ? _darkText : _inkColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ผู้ช่วย AI เรื่องสินค้าและข่าวสารเกษตร',
                            style: _kanit(
                              fontSize: 12,
                              color:
                                  _isDark ? AppColors.tintGreen : _brandColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'ถามเรื่องหมวดสินค้า เครื่องมือเกษตร อาหารสัตว์ ข่าวสาร หรือวิธีใช้งาน Kaset Mall ได้เลยค่ะ',
                  style: _kanit(
                    fontSize: 13,
                    color: _isDark ? _darkMuted : _slateColor,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded,
                size: 18, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              'เริ่มต้นด้วยคำถามเหล่านี้',
              style: _kanit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _isDark ? _darkText : _inkColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._exampleQuestions.asMap().entries.map((entry) {
          final start = 0.10 + (entry.key * 0.11);
          final itemAnimation = CurvedAnimation(
            parent: _examplesController,
            curve: Interval(start, (start + 0.33).clamp(0, 1)),
          );
          return FadeTransition(
            opacity: itemAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0.12),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: itemAnimation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: _isDark ? _darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(_radiusCardMd),
                  elevation: 0,
                  shadowColor: _brandColor.withValues(alpha: 0.12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(_radiusCardMd),
                    onTap: () => _send(entry.value),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_radiusCardMd),
                        border: Border.all(
                            color: _isDark ? _darkBorder : _lineColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A2E7D32),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _brandColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                _radiusCardSm,
                              ),
                            ),
                            child: Icon(
                              icons[entry.key],
                              color:
                                  _isDark ? AppColors.tintGreen : _brandColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: _kanit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                                color: _isDark ? _darkText : _inkColor,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: _isDark ? AppColors.tintGreen : _brandColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMessage(_ChatMessage message) {
    final user = message.role == 'user';
    final dark = _isDark;
    const assistantBgDark = _darkSurface;
    const assistantBorderDark = _darkBorder;
    const assistantTextDark = _darkText;
    const mutedDark = _darkMuted;
    final assistantBg = dark ? assistantBgDark : Colors.white;
    final assistantBorder = dark ? assistantBorderDark : _lineColor;
    final assistantText = dark ? assistantTextDark : _inkColor;
    final muted = dark ? mutedDark : _slateColor;
    final chipBg = dark ? _brandColor.withValues(alpha: 0.18) : _pageBgTop;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * (user ? 0.82 : 0.92),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          gradient: user
              ? const LinearGradient(
                  colors: [AppColors.primaryDark, _brandColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: user ? null : assistantBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(user ? 18 : 6),
            bottomRight: Radius.circular(user ? 6 : 18),
          ),
          border: user ? null : Border.all(color: assistantBorder),
          boxShadow: [
            BoxShadow(
              color: (user ? _brandColor : Colors.black)
                  .withValues(alpha: dark ? 0.28 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user && message.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(message.imagePath!),
                  width: 148,
                  height: 148,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 148,
                    height: 148,
                    color: Colors.white24,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined,
                        color: Colors.white70),
                  ),
                ),
              ),
              if (message.body.isNotEmpty) const SizedBox(height: 8),
            ],
            if (user)
              if (message.body.isNotEmpty)
                Text(
                  message.body,
                  style: _kanit(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.45,
                  ),
                )
              else
                const SizedBox.shrink()
            else
              SelectableText(
                message.body.isEmpty ? ' ' : message.body,
                style: _kanit(
                  fontSize: 14,
                  height: 1.55,
                  color: assistantText,
                ),
              ),
            if (!user && message.sources.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.sources
                    .map(
                      (source) => ActionChip(
                        avatar: Icon(
                          Icons.description_rounded,
                          size: 17,
                          color: dark ? _brandColor : _brandColor,
                        ),
                        label: Text(
                          source.label,
                          overflow: TextOverflow.ellipsis,
                          style: _kanit(
                            fontSize: 12,
                            color: assistantText,
                          ),
                        ),
                        backgroundColor: chipBg,
                        side: BorderSide.none,
                        onPressed: () => _openReference(source),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  IconButton(
                    tooltip: 'คัดลอกคำตอบ',
                    visualDensity: VisualDensity.compact,
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: message.body),
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('คัดลอกคำตอบแล้ว')),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: muted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'คำตอบนี้มีประโยชน์ไหม',
                    style: _kanit(fontSize: 12, color: muted),
                  ),
                  IconButton(
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 18,
                      color: dark ? _brandColor : _brandColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.thumb_down_alt_outlined,
                      size: 18,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThinking() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: _ThinkingBubble(),
    );
  }

  Widget _buildComposer() {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final canSend = !_isThinking &&
        !_isTyping &&
        (_inputController.text.trim().isNotEmpty || _pendingImage != null);
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: _isDark ? _darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: _isDark ? _darkBorder : _lineColor,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_pendingImage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _brandColor),
                            boxShadow: [
                              BoxShadow(
                                color: _brandColor.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.file(
                            File(_pendingImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => setState(() => _pendingImage = null),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: _slateColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              TextField(
                controller: _inputController,
                minLines: 1,
                maxLines: 4,
                style: _kanit(fontSize: 14),
                textInputAction: TextInputAction.send,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: _pendingImage == null
                      ? 'ถามเรื่องสินค้า ข่าวสาร หรือ Kaset Mall...'
                      : 'พิมพ์ข้อความแนบไปกับรูปได้...',
                  hintStyle: _kanit(fontSize: 14, color: _mutedColor),
                  filled: true,
                  fillColor: _isDark ? _darkBackground : _surfaceColor,
                  contentPadding: const EdgeInsets.fromLTRB(8, 14, 8, 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_radiusCardMd),
                    borderSide: const BorderSide(color: _lineColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_radiusCardMd),
                    borderSide: const BorderSide(color: _lineColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_radiusCardMd),
                    borderSide:
                        const BorderSide(color: _brandColor, width: 1.4),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 96),
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'แนบรูปภาพ',
                        onPressed: _isThinking || _isTyping
                            ? null
                            : _showAttachImageSheet,
                        icon: const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: _brandColor,
                        ),
                      ),
                      IconButton(
                        tooltip: _isListening ? 'หยุดรับเสียง' : 'ถามด้วยเสียง',
                        onPressed:
                            _isThinking || _isTyping ? null : _toggleListening,
                        color: _isListening
                            ? const Color(0xFFEF4444)
                            : _brandColor,
                        icon: Icon(
                          _isListening
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded,
                        ),
                      ),
                    ],
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(5),
                    child: IconButton.filled(
                      tooltip: 'ส่งคำถาม',
                      onPressed: canSend ? () => _send() : null,
                      style: IconButton.styleFrom(
                        backgroundColor: _brandColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            _brandColor.withValues(alpha: 0.28),
                        disabledForegroundColor: Colors.white70,
                      ),
                      icon: const Icon(Icons.send_rounded),
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

class _AttachOptionTile extends StatelessWidget {
  const _AttachOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? _darkBackground : _pageBgTop,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: dark ? _darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon,
                    color: dark ? AppColors.tintGreen : _brandColor, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: _kanit(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading bubble with the Kaset Mall brand colors.
class _ThinkingBubble extends StatefulWidget {
  const _ThinkingBubble();

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _dots;
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _dots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _dots.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [
                  _darkSurface,
                  Color(0xFF233827),
                ]
              : [
                  Colors.white,
                  _pageBgTop.withValues(alpha: 0.55),
                ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(
          color: dark ? _darkBorder : _brandColor.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: _brandColor.withValues(alpha: dark ? 0.22 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulse, _shimmer]),
              builder: (context, _) {
                final pulse = Curves.easeInOut.transform(_pulse.value);
                final spin = _shimmer.value * 6.2832;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 0.85 + (pulse * 0.28),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _brandColor.withValues(
                              alpha: 0.10 + pulse * 0.08),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: spin,
                      child: CustomPaint(
                        size: const Size(28, 28),
                        painter: _ArcSpinnerPainter(
                          progress: 0.72,
                          color: _brandColor,
                          trackColor: _pageBgTop,
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(
                                _brandColor, Colors.white, pulse * 0.35)!,
                            _brandColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _brandColor.withValues(alpha: 0.35),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'กำลังค้นหาข้อมูล Kaset Mall',
                style: _kanit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: dark ? _darkText : _inkColor,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedBuilder(
                animation: _dots,
                builder: (context, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final t = (_dots.value + (i * 0.22)) % 1.0;
                      final bounce = Curves.easeInOut.transform(
                        t < 0.5 ? t * 2 : (1 - t) * 2,
                      );
                      return Container(
                        margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
                        child: Transform.translate(
                          offset: Offset(0, -3.5 * bounce),
                          child: Opacity(
                            opacity: 0.45 + (bounce * 0.55),
                            child: Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.lerp(
                                  _brandColor,
                                  _brandColor,
                                  bounce,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcSpinnerPainter extends CustomPainter {
  _ArcSpinnerPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 1.5;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    final arc = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.15),
          color,
          color.withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.2,
      progress * 6.2832,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcSpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}

class _ReferencePage extends StatefulWidget {
  const _ReferencePage({required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<_ReferencePage> createState() => _ReferencePageState();
}

class _ReferencePageState extends State<_ReferencePage> {
  var _reloadKey = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, _brandColor]),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  const Icon(Icons.description_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _kanit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'เอกสารอ้างอิง',
                          style: _kanit(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'โหลดเอกสารใหม่',
                    onPressed: () => setState(() => _reloadKey++),
                    icon:
                        const Icon(Icons.refresh_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 64,
                      color: _brandColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: _kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เปิดเอกสารอ้างอิงในแอปภายนอก',
                      textAlign: TextAlign.center,
                      style: _kanit(
                        fontSize: 13,
                        color: _slateColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () async {
                        final uri = Uri.tryParse(widget.url);
                        if (uri == null) return;
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                        if (!ok && mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('ไม่สามารถเปิดเอกสารได้'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('เปิดเอกสาร'),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => setState(() => _reloadKey++),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
