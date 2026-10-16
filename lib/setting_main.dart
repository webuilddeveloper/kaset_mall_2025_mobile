import 'dart:async';

// import 'package:cool_alert/cool_alert.dart' as cool_alert;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/delete_user.dart';
import 'package:kasetmall/delivery_address.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/user_profile_form.dart';

class SettingMain extends StatefulWidget {
  SettingMain({Key? key, this.code, this.title, this.callback})
      : super(key: key);

  final String? code;
  final String? title;
  final Function? callback;

  @override
  _SettingMain createState() => _SettingMain();
}

final storage = new FlutterSecureStorage();

class _SettingMain extends State<SettingMain> {
  // ignore: unused_field
  Future<dynamic>? _futureModel;
  int year = 0;
  int month = 0;
  int day = 0;
  DateTime selectedDate = DateTime.now();
  TextEditingController txtDate = TextEditingController();
  TextEditingController? txtName;
  TextEditingController? txtEmail;
  TextEditingController? txtPhone;
  TextEditingController txtBirthday = TextEditingController();
  String? txtAffiliation;
  String? verifyPhonePage;
  String? profileCode;
  var profileFirstName;
  var profileLastName;

  ScrollController scrollController = new ScrollController();
  int selectedIndex = 0;
  @override
  void initState() {
    _getUserData();
    // _futureModel = postDio(comingSoonApi, {'codeShort': widget.code});
    scrollController = ScrollController();
    var now = new DateTime.now();
    setState(() {
      year = now.year;
      month = now.month;
      day = now.day;
    });
    super.initState();
  }

  void goBack() async {
    Navigator.pop(context);
  }

  // _getUserData() async {
  //   profileCode = await storage.read(key: 'profileCode10');
  //   var a = await storage.read(key: 'phoneVerified');
  //   setState(() {
  //     verifyPhonePage = a ?? "";
  //   });
  // }

  _getUserData() async {
    // var a = await storage.read(key: 'phoneVerified');
    // setState(() {
    //   verifyPhonePage = a ?? "";
    // });
    final fistName =
        await new FlutterSecureStorage().read(key: 'firstName') ?? "";
    final lastName =
        await new FlutterSecureStorage().read(key: 'lastName') ?? "";
    setState(() {
      profileFirstName = fistName;
      profileLastName = lastName;
    });
    // Timer(
    //   Duration(seconds: 1),
    //   () => {
    //     setState(
    //       () {
    //         loadingSuccess = true;
    //       },
    //     ),
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KasetAppBar(
        title: 'ตั้งค่า',
        actions: [
          KasetAppBarAction(
            icon: Icons.help_outline_rounded,
            onTap: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            if (profileFirstName != null) ...[
              _settingsSection(
                title: 'บัญชีของฉัน',
                children: [
                  _settingsTile(
                    icon: Icons.badge_outlined,
                    title: 'ข้อมูลเกี่ยวกับบัญชี',
                    subtitle: 'ชื่อ เบอร์โทร และข้อมูลส่วนตัว',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfileForm(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _settingsTile(
                    icon: Icons.location_on_outlined,
                    title: 'ที่อยู่ของฉัน',
                    subtitle: 'จัดการที่อยู่จัดส่ง',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeliveryAddressCentralPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            _settingsSection(
              title: 'การใช้งานแอป',
              children: [
                _settingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'การแจ้งเตือน',
                  subtitle: 'จัดการการแจ้งเตือนและข้อความจากระบบ',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _settingsTile(
                  icon: Icons.language_rounded,
                  title: 'ภาษา',
                  subtitle: 'ภาษาไทย',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _settingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'ความเป็นส่วนตัว',
                  subtitle: 'นโยบายการใช้งานและข้อมูลส่วนบุคคล',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _settingsSection(
              title: 'ช่วยเหลือ',
              children: [
                _settingsTile(
                  icon: Icons.description_outlined,
                  title: 'นโยบายความเป็นส่วนตัว',
                  subtitle: 'อ่านรายละเอียดเงื่อนไขและสิทธิ์การใช้งาน',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _settingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'การยกเลิกการปิดบัญชี',
                  subtitle: 'ส่งคำขอปิดบัญชีและลบข้อมูล',
                  onTap: _dialogConfirm,
                  accent: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.centerRight,
              child: Text(
                'v.$versionName',
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (profileFirstName != null)
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    logout(context);
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'ออกจากระบบ',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _settingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool accent = false,
  }) {
    final iconColor = accent ? AppColors.accent : AppColors.primary;
    final iconBg = accent ? AppColors.accentTint : AppColors.tintGreenSoft;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // _dialogConfirm() {
  //   return cool_alert.CoolAlert.show(
  //     context: context,
  //     type: cool_alert.CoolAlertType.confirm,
  //     animType: cool_alert.CoolAlertAnimType.scale,
  //     // barrierDismissible: false,
  //     title: 'การยกเลิกบัญชี',
  //     text: 'คุณต้องการยกเลิกบัญชีใช่หรือไม่',
  //     loopAnimation: false,
  //     cancelBtnText: 'ย้อนกลับ',
  //     onCancelBtnTap: () => {
  //       Navigator.pop(context),
  //     },
  //     confirmBtnColor: Color(0xFF1CBC51),
  //     confirmBtnText: 'ยืนยัน',
  //     onConfirmBtnTap: () => {
  //       // Navigator.pop(context),
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => DeleteUser(),
  //         ),
  //       ),
  //     },
  //   );
  // }
  _dialogConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'การยกเลิกบัญชี',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'คุณต้องการยกเลิกบัญชีใช่หรือไม่',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              'ย้อนกลับ',
              style: TextStyle(
                fontFamily: 'Kanit',
                color: AppColors.textSecondary,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              'ยืนยัน',
              style: TextStyle(
                fontFamily: 'Kanit',
                color: AppColors.primary,
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // ปิด dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeleteUser(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
