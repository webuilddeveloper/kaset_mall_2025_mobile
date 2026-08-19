import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/menu.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';

class PolicyCentralPage extends StatelessWidget {
  const PolicyCentralPage({
    super.key,
    required this.source,
    required this.pendingProfile,
  });

  final String source;
  final Map<String, dynamic> pendingProfile;

  static const Color _primary = AppColors.primary;
  static const Color _text = AppColors.textPrimary;
  static const Color _muted = AppColors.textSecondary;
  static const Color _border = AppColors.border;
  static const Color _surface = AppColors.surface;
  static const Color _softSurface = Color(0xFFF8FBF8);

  bool get _isReadOnly => source == 'profile';

  Future<void> _acceptPolicy(BuildContext context) async {
    const storage = FlutterSecureStorage();
    final profile = {
      'firstName': pendingProfile['firstName'] ?? '',
      'lastName': pendingProfile['lastName'] ?? '',
      'phone': pendingProfile['phone'] ?? '',
      'email': pendingProfile['email'] ?? '',
      'birthday': pendingProfile['birthday'] ?? '',
      'imageUrl': pendingProfile['imageUrl'] ?? '',
    };
    await storage.write(key: 'firstName', value: profile['firstName']);
    await storage.write(key: 'lastName', value: profile['lastName']);
    await storage.write(
      key: 'profileFirstName',
      value: pendingProfile['profileFirstName'],
    );
    await storage.write(
      key: 'profileLastName',
      value: pendingProfile['profileLastName'],
    );
    await storage.write(
      key: 'profileCode10',
      value: pendingProfile['profileCode10'],
    );
    await storage.write(key: 'token', value: pendingProfile['token']);
    await storage.write(key: 'Agency', value: pendingProfile['agency']);
    await storage.write(key: 'policyAccepted', value: 'true');
    await storage.write(key: 'loginSource', value: source);
    await MockStore.saveUserProfile(profile);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MenuCentralPage()),
      (route) => false,
    );
  }

  _PolicyContent get _content {
    return _PolicyContent(
      title: 'นโยบายการใช้งานแอปพลิเคชัน เกษตร Mall',
      intro:
          'แอปพลิเคชันนี้จัดทำขึ้นเพื่อให้บริการข้อมูลสินค้าเกษตร สินค้าอุปโภคบริโภค และบริการที่เกี่ยวข้องแก่ผู้ใช้งานก่อนเริ่มใช้งาน กรุณาอ่านนโยบายฉบับนี้อย่างละเอียด',
      confirmText: 'ยอมรับและเข้าสู่ระบบ',
      sections: [
        _PolicySection(
          title: '1. การยอมรับเงื่อนไขการใช้งาน',
          body:
              'เมื่อผู้ใช้งานกด “ยอมรับ” ถือว่าผู้ใช้งานรับทราบและยินยอมปฏิบัติตามนโยบายการใช้งาน ข้อกำหนด และเงื่อนไขต่าง ๆ ของแอปพลิเคชันนี้ทุกประการ',
        ),
        _PolicySection(
          title: '2. การใช้งานบัญชีและการยืนยันตัวตน',
          body:
              'ผู้ใช้งานต้องให้ข้อมูลที่ถูกต้อง ครบถ้วน และเป็นปัจจุบันในการสมัครใช้งานหรือเข้าสู่ระบบผ่านแอปพลิเคชัน ในกรณีที่มีการเข้าถึงข้อมูลสำคัญ ระบบอาจกำหนดให้มีการยืนยันตัวตนเพิ่มเติม เช่น รหัส OTP หรือช่องทาง ThaiD ตามความเหมาะสม',
        ),
        _PolicySection(
          title: '3. การเก็บ ใช้ และประมวลผลข้อมูลส่วนบุคคล',
          body:
              'แอปพลิเคชันมีการเก็บ ใช้ และประมวลผลข้อมูลส่วนบุคคลของผู้ใช้งานเท่าที่จำเป็น เพื่อใช้สำหรับการสมัครสมาชิก การเข้าสู่ระบบ การยืนยันตัวตน การทำรายการสั่งซื้อ และการให้บริการภายในแอปพลิเคชัน ข้อมูลที่อาจจัดเก็บประกอบด้วย ชื่อที่ใช้แสดงบนแอปพลิเคชัน อีเมล ข้อมูลบัญชี ที่อยู่จัดส่ง เบอร์โทรศัพท์ ประวัติการสั่งซื้อ ตะกร้าสินค้า คูปอง และข้อมูลการใช้งานภายในแอปพลิเคชัน',
        ),
        _PolicySection(
          title: '4. การแนะนำสินค้า ข่าวสาร และบริการที่เกี่ยวข้อง',
          body:
              'ระบบอาจนำข้อมูลความสนใจ ประวัติการเข้าชม การค้นหา หรือประวัติการสั่งซื้อของผู้ใช้งานมาใช้เพื่อแนะนำสินค้า ข่าวสาร โปรโมชั่น คูปอง หรือบริการที่เกี่ยวข้อง โดยมีวัตถุประสงค์เพื่อให้ผู้ใช้งานได้รับข้อมูลที่เหมาะสมและตรงกับความต้องการมากขึ้น',
        ),
        _PolicySection(
          title: '5. การแจ้งเตือนผ่านแอปพลิเคชัน',
          body:
              'ผู้ใช้งานยินยอมให้แอปพลิเคชันส่งการแจ้งเตือนที่เกี่ยวข้องกับการให้บริการ เช่น ข่าวประชาสัมพันธ์ โปรโมชั่น คูปอง ส่วนลด คำสั่งซื้อ การจัดส่ง การเปลี่ยนแปลงสถานะคำสั่งซื้อ หรือข้อมูลสำคัญอื่น ๆ ที่เกี่ยวข้องกับผู้ใช้งาน ผู้ใช้งานสามารถตั้งค่าการแจ้งเตือนได้ตามความสามารถของระบบและการตั้งค่าของอุปกรณ์',
        ),
        _PolicySection(
          title: '6. การแสดงข้อมูลสินค้า คำสั่งซื้อ และสิทธิประโยชน์',
          body:
              'ข้อมูลสินค้า ราคา รายละเอียดสินค้า คำสั่งซื้อ คูปอง โปรโมชั่น หรือสิทธิประโยชน์ที่แสดงในแอปพลิเคชัน เป็นข้อมูลที่จัดทำขึ้นเพื่อการให้บริการแก่ผู้ใช้งานเท่านั้น แอปพลิเคชันทำหน้าที่แสดงผลข้อมูลดังกล่าวเพื่ออำนวยความสะดวกในการใช้งาน โดยผู้ใช้งานต้องไม่นำข้อมูล ภาพสินค้า หรือเอกสารที่ปรากฏในแอปพลิเคชันไปดัดแปลง แอบอ้าง หรือใช้งานในทางที่ผิดกฎหมาย',
        ),
        _PolicySection(
          title: '7. ข้อห้ามในการใช้งาน',
          body:
              'ผู้ใช้งานตกลงว่าจะไม่กระทำการใด ๆ ที่อาจก่อให้เกิดความเสียหายต่อระบบ ข้อมูล ผู้ใช้งานรายอื่น หรือหน่วยงานที่เกี่ยวข้อง เช่น ใช้ข้อมูลเท็จหรือแอบอ้างตัวตนของผู้อื่น เข้าถึงข้อมูลของบุคคลอื่นโดยไม่ได้รับอนุญาต ปลอมแปลง แก้ไข หรือเผยแพร่ข้อมูลสินค้า คำสั่งซื้อ คูปอง หรือเอกสารโดยมิชอบ หรือใช้งานแอปพลิเคชันเพื่อวัตถุประสงค์ที่ผิดกฎหมาย',
        ),
        _PolicySection(
          title: '8. ความถูกต้องของข้อมูล',
          body:
              'หน่วยงานจะพยายามดูแลให้ข้อมูลในแอปพลิเคชันมีความถูกต้องและเป็นปัจจุบัน อย่างไรก็ตาม ข้อมูลบางส่วนอาจมีการเปลี่ยนแปลงหรืออยู่ระหว่างการปรับปรุง ผู้ใช้งานควรตรวจสอบข้อมูลกับหน่วยงานที่เกี่ยวข้องอีกครั้งในกรณีที่ต้องใช้ข้อมูลเพื่อการอ้างอิงอย่างเป็นทางการ',
        ),
        _PolicySection(
          title: '9. การเปลี่ยนแปลงนโยบายการใช้งาน',
          body:
              'หน่วยงานขอสงวนสิทธิ์ในการปรับปรุง แก้ไข หรือเปลี่ยนแปลงนโยบายการใช้งานนี้ได้ตามความเหมาะสม โดยอาจแจ้งให้ผู้ใช้งานทราบผ่านแอปพลิเคชันหรือช่องทางอื่นที่เหมาะสม',
        ),
        _PolicySection(
          title: '10. การติดต่อสอบถาม',
          body:
              'หากผู้ใช้งานมีข้อสงสัยเกี่ยวกับการใช้งานแอปพลิเคชัน ข้อมูลส่วนบุคคล หรือบริการที่เกี่ยวข้อง สามารถติดต่อหน่วยงานผู้ดูแลระบบหรือช่องทางที่กำหนดภายในแอปพลิเคชัน โดยการกด “ยอมรับ” ผู้ใช้งานรับทราบ เข้าใจ และยินยอมปฏิบัติตามนโยบายการใช้งานแอปพลิเคชันฉบับนี้',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    final isThaiD = source == 'thaid';

    return Scaffold(
      backgroundColor: _softSurface,
      appBar: const KasetAppBar(
        title: 'นโยบายการใช้งาน',
        showBackButton: true,
        bottomBorder: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF143D16).withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _text,
                      height: 1.25,
                      fontFamily: 'Kanit',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.intro,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.65,
                      color: _muted,
                      fontFamily: 'Kanit',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PolicyTag(
                        text: isThaiD ? 'ThaiD' : 'เข้าสู่ระบบปกติ',
                        isAccent: isThaiD,
                      ),
                      const _PolicyTag(text: 'ข้อมูลส่วนบุคคล'),
                      const _PolicyTag(text: 'ความปลอดภัย'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...content.sections.map(
                    (section) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: _text,
                              fontFamily: 'Kanit',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            section.body,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.65,
                              fontWeight: FontWeight.w600,
                              color: _text,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (!_isReadOnly) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _acceptPolicy(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    content.confirmText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Kanit',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCDD9CD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'ยังไม่ยอมรับ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4B5A4B),
                      fontFamily: 'Kanit',
                    ),
                  ),
                ),
              ),
            ] else ...[
              const Text(
                'หน้านี้แสดงข้อมูลนโยบายสำหรับการอ่านเท่านั้น',
                style: TextStyle(
                  fontSize: 12.5,
                  color: _muted,
                  fontFamily: 'Kanit',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PolicyContent {
  const _PolicyContent({
    required this.title,
    required this.intro,
    required this.confirmText,
    required this.sections,
  });

  final String title;
  final String intro;
  final String confirmText;
  final List<_PolicySection> sections;
}

class _PolicySection {
  const _PolicySection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class _PolicyTag extends StatelessWidget {
  const _PolicyTag({
    required this.text,
    this.isAccent = false,
  });

  final String text;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isAccent ? const Color(0xFFEEF7EE) : const Color(0xFFEEF7EE),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isAccent
              ? const Color(0xFF2E7D32).withValues(alpha: 0.18)
              : const Color(0xFFDDEBDD),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color:
              isAccent ? const Color(0xFF2E7D32) : PolicyCentralPage._primary,
        ),
      ),
    );
  }
}
