// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/policy.dart';
import 'package:kasetmall/register.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/widget/text_field.dart';

DateTime now = new DateTime.now();
void main() {
  // Intl.defaultLocale = 'th';
  runApp(LoginCentralPage());
}

class LoginCentralPage extends StatefulWidget {
  LoginCentralPage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _LoginCentralPageState createState() => _LoginCentralPageState();
}

class _LoginCentralPageState extends State<LoginCentralPage> {
  final storage = new FlutterSecureStorage();
  bool _isProcessing = false;
  static const String _agencyName = 'องค์การตลาดเพื่อเกษตรกร (อตก.)';

  final txtUsername = TextEditingController();
  final txtPassword = TextEditingController();

  static const Color kPrimary = AppColors.primary;
  static const Color kPrimaryDark = AppColors.primaryDark;
  static const Color kAccent = AppColors.accent;
  static const Color kBorder = AppColors.border;
  static const Color kMuted = AppColors.textSecondary;
  static const Color kText = AppColors.textPrimary;

  @override
  void initState() {
    setState(() {});

    super.initState();
  }

  @override
  void dispose() {
    txtUsername.dispose();
    txtPassword.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBackground();
  }

  _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEEF7EE),
            Color(0xFFFAFCF8),
            Colors.white,
          ],
          stops: [0.0, 0.28, 0.55],
        ),
      ),
      child: _buildScaffold(),
    );
  }

  _buildScaffold() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: const KasetAppBar(
        title: 'เข้าสู่ระบบ',
        backgroundColor: Colors.transparent,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(),
                const SizedBox(height: 26),
                _buildLoginCard(),
                const SizedBox(height: 18),
                _buildFooterNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(9),
          child: Image.asset(
            "assets/images/kaset/logo_kaset.png",
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เกษตร Mall',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryDark,
                  height: 1.1,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'เข้าสู่ระบบเพื่อเริ่มใช้งาน',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: kMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D16).withValues(alpha: 0.06),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'เข้าสู่ระบบ',
            style: TextStyle(
              fontSize: 23,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'กรอกข้อมูลเพื่อเข้าสู่ระบบสมาชิก',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Kanit',
              color: kMuted,
            ),
          ),
          const SizedBox(height: 20),
          labelTextField(
            'อีเมล',
            const Icon(
              Icons.person_outline,
              color: kPrimary,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          _buildInputWrapper(
            child: textFieldCentral(
              txtUsername,
              null,
              'อีเมล',
              'อีเมล',
              true,
              false,
            ),
          ),
          const SizedBox(height: 16),
          labelTextField(
            'รหัสผ่าน',
            const Icon(
              Icons.lock_outline,
              color: kPrimary,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          _buildInputWrapper(
            child: textFieldCentral(
              txtPassword,
              null,
              'รหัสผ่าน',
              'รหัสผ่าน',
              true,
              true,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'ลืมรหัสผ่าน?',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: kPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _buildLoginButton(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: kBorder)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'หรือ',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12.5,
                    color: kMuted,
                  ),
                ),
              ),
              Expanded(child: Container(height: 1, color: kBorder)),
            ],
          ),
          const SizedBox(height: 12),
          _buildThaiDButton(),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => RegisterCentralPage(),
                  ),
                );
              },
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13.5,
                    color: kMuted,
                  ),
                  children: [
                    TextSpan(text: 'ยังไม่มีบัญชีใช่ไหม? '),
                    TextSpan(
                      text: 'สมัครสมาชิก',
                      style: TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
      ),
      child: child,
    );
  }

  Widget _buildFooterNote() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.verified_outlined,
              size: 14,
              color: kAccent,
            ),
            SizedBox(width: 6),
            Text(
              'มั่นใจในสินค้าคุณภาพจาก อ.ต.ก.',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 12.5,
                color: kMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: kPrimary),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            await _startAuthFlow(source: 'password');
          },
          child: const Center(
            child: Text(
              'เข้าสู่ระบบ ',
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'Kanit',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThaiDButton() {
    return GestureDetector(
      onTap: _isProcessing ? null : () => _startAuthFlow(source: 'thaid'),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _isProcessing ? 0.65 : 1,
        child: Container(
          width: double.infinity,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/kaset/icon_thaid.png",
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'เข้าสู่ระบบด้วย ThaiD',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Kanit',
                  color: kText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startAuthFlow({required String source}) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: kPrimary,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      source == 'thaid'
                          ? 'กำลังเชื่อมต่อ ThaiD...'
                          : 'กำลังเข้าสู่ระบบ...',
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 14,
                        color: kText,
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

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PolicyCentralPage(
          source: source,
          pendingProfile: {
            'firstName': 'สมศักดิ์',
            'lastName': 'ศักดิ์สม',
            'profileFirstName': 'สมศักดิ์',
            'profileLastName': 'ศักดิ์สม',
            'profileCode10': 'mock-user',
            'token': 'mock-token',
            'agency': _agencyName,
          },
        ),
      ),
    );
  }
}
