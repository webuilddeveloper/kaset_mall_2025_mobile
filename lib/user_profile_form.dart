import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';
import 'package:kasetmall/widget/image_picker.dart';

// ignore: must_be_immutable
class UserProfileForm extends StatefulWidget {
  UserProfileForm({
    Key? key,
    this.code,
    this.title,
    this.callback,
    this.phoneFocus,
    this.nameFocus,
    this.emailFocus,
    this.birthFocus,
    this.mode = "",
  }) : super(key: key);

  final String? code;
  final String? title;
  final Function? callback;
  final FocusNode? phoneFocus;
  final FocusNode? nameFocus;
  final FocusNode? emailFocus;
  final FocusNode? birthFocus;
  String mode;

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _birthdayController;

  bool _loading = true;
  bool _saving = false;
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _birthdayController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    await MockStore.loadUserProfile();
    final profile = MockStore.userProfile;

    if (!mounted) return;
    setState(() {
      _firstNameController.text = profile['firstName']?.toString() ?? '';
      _lastNameController.text = profile['lastName']?.toString() ?? '';
      _phoneController.text = profile['phone']?.toString() ?? '';
      _emailController.text = profile['email']?.toString() ?? '';
      _birthdayController.text = profile['birthday']?.toString() ?? '';
      _imagePath = profile['imageUrl']?.toString() ?? '';
      _loading = false;
    });
  }

  String _displayName() {
    final fullName =
        '${_firstNameController.text} ${_lastNameController.text}'.trim();
    return fullName.isEmpty ? 'บัญชีผู้ใช้งาน' : fullName;
  }

  ImageProvider _avatarProvider() {
    if (_imagePath.isEmpty) {
      return const AssetImage('assets/images/kaset/logo_kaset.png');
    }
    if (_imagePath.startsWith('assets/')) {
      return AssetImage(_imagePath);
    }
    if (_imagePath.startsWith('http')) {
      return NetworkImage(_imagePath);
    }
    final file = File(_imagePath);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return const AssetImage('assets/images/kaset/logo_kaset.png');
  }

  DateTime? _parseBirthday(String value) {
    if (value.isEmpty) return null;
    final normalized = value.replaceAll(' ', '');
    final patterns = ['dd/MM/yyyy', 'dd-MM-yyyy'];
    for (final pattern in patterns) {
      try {
        return DateFormat(pattern).parseStrict(normalized);
      } catch (_) {}
    }
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickBirthday() async {
    final current = _parseBirthday(_birthdayController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'เลือกวันเกิด',
      locale: const Locale('th', 'TH'),
    );

    if (picked != null && mounted) {
      setState(() {
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveAvatar(XFile file) async {
    setState(() {
      _imagePath = file.path;
    });
    await MockStore.saveUserProfile({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'birthday': _birthdayController.text.trim(),
      'imageUrl': _imagePath,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เปลี่ยนรูปโปรไฟล์แล้ว')),
      );
    }
  }

  Future<void> _saveProfile({bool showLoading = true}) async {
    if (!_formKey.currentState!.validate()) return;

    if (showLoading && mounted) {
      setState(() {
        _saving = true;
      });
    }

    final profile = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'birthday': _birthdayController.text.trim(),
      'imageUrl': _imagePath,
    };

    await MockStore.saveUserProfile(profile);

    if (!mounted) return;
    setState(() {
      _saving = false;
    });

    if (showLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกข้อมูลเรียบร้อย'),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 19, color: AppColors.primary),
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Kanit',
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: const Color(0xFFF6F8F7),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
            ),
          ),
          validator: (value) {
            if (label == 'เบอร์โทร') {
              if ((value ?? '').trim().isEmpty) {
                return 'กรุณากรอกเบอร์โทร';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return ImageUploadPicker(
      callback: (file) => _saveAvatar(file),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 108,
            height: 108,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: Image(
                image: _avatarProvider(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.tintGreenSoft,
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 54,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 14),
          Text(
            _displayName(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'แก้ไขข้อมูลบัญชีผู้ใช้งานของคุณ',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'บันทึกข้อมูล',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KasetAppBar(
        title: 'บัญชีผู้ใช้งาน',
        showBackButton: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildField(
                      label: 'ชื่อ',
                      controller: _firstNameController,
                      icon: Icons.person_outline,
                      hint: 'กรอกชื่อ',
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      label: 'นามสกุล',
                      controller: _lastNameController,
                      icon: Icons.badge_outlined,
                      hint: 'กรอกนามสกุล',
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      label: 'เบอร์',
                      controller: _phoneController,
                      icon: Icons.call_outlined,
                      hint: 'กรอกเบอร์โทร',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      label: 'Email',
                      controller: _emailController,
                      icon: Icons.mail_outline,
                      hint: 'กรอกอีเมล',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      label: 'วันเกิด',
                      controller: _birthdayController,
                      icon: Icons.cake_outlined,
                      hint: 'เลือกวันเกิด',
                      readOnly: true,
                      onTap: _pickBirthday,
                    ),
                    const SizedBox(height: 20),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }
}
