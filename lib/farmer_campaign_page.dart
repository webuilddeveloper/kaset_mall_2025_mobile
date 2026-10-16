import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasetmall/delivery_address.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_dialog.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/farmer_campaign_store.dart';
import 'package:kasetmall/shared/mock_store.dart';

class FarmerCampaignPage extends StatefulWidget {
  const FarmerCampaignPage({super.key});

  @override
  State<FarmerCampaignPage> createState() => _FarmerCampaignPageState();
}

class _FarmerCampaignPageState extends State<FarmerCampaignPage> {
  int _step = 0;
  bool _loading = true;
  bool _submitting = false;
  bool _completed = false;
  Map<String, dynamic>? _deliveryAddress;

  String? _agricultureType;
  String? _primaryProduct;
  String _areaSize = '';
  String? _productionTrend;
  final Set<String> _productionReasons = <String>{};
  String _agricultureTypeOther = '';
  String _primaryProductOther = '';
  String _productionReasonOther = '';

  Map<String, dynamic> get _reward => Map<String, dynamic>.from(
        FarmerCampaignStore.rewardForArea(
          FarmerCampaignStore.parseAreaRai(_areaSize),
        ),
      );

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final state = await FarmerCampaignStore.getState();
    final profile = await FarmerCampaignStore.getFarmerProfile();
    final addresses = await AddressStore.getAddresses();
    final deliveryAddress = _preferredAddress(addresses);
    if (!mounted) return;
    setState(() {
      _completed = state['completed'] == true;
      _deliveryAddress = deliveryAddress;
      if (profile != null) {
        _agricultureType = profile['agricultureType']?.toString();
        _primaryProduct = profile['primaryProduct']?.toString();
        _areaSize = profile['areaSize']?.toString() ?? '';
        _productionTrend = profile['productionTrend']?.toString();
        _agricultureTypeOther =
            profile['agricultureTypeOther']?.toString() ?? '';
        _primaryProductOther = profile['primaryProductOther']?.toString() ?? '';
        _productionReasonOther =
            profile['productionReasonOther']?.toString() ?? '';
        _productionReasons
          ..clear()
          ..addAll(
            (profile['productionReasons'] as List<dynamic>? ?? const [])
                .map((item) => item.toString()),
          );
      }
      _loading = false;
    });
  }

  Map<String, dynamic>? _preferredAddress(
    List<Map<String, dynamic>> addresses,
  ) {
    if (addresses.isEmpty) return null;
    for (final address in addresses) {
      if (address['isDefault'] == true) return address;
    }
    return addresses.first;
  }

  Future<void> _refreshDeliveryAddress() async {
    final addresses = await AddressStore.getAddresses();
    if (!mounted) return;
    setState(() => _deliveryAddress = _preferredAddress(addresses));
  }

  Future<void> _openAddresses() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DeliveryAddressCentralPage(notChange: true),
      ),
    );
    await _refreshDeliveryAddress();
  }

  String _addressLine(Map<String, dynamic> address) {
    return [
      address['houseNo'],
      address['road'],
      address['subDistrict'],
      address['district'],
      address['province'],
      address['postalCode'],
    ]
        .where((value) => (value ?? '').toString().trim().isNotEmpty)
        .map((value) => value.toString().trim())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KasetAppBar(
        title: 'ยืนยันสิทธิ์รับปุ๋ยฟรี',
        onBack: _handleBack,
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _completed
                ? _buildSuccess(existing: true)
                : _step == 5
                    ? _buildSummary()
                    : _buildQuestion(),
      ),
    );
  }

  void _handleBack() {
    if (_completed || _step == 0) {
      Navigator.pop(context, _completed);
      return;
    }
    setState(() {
      if (_step == 5) {
        _step = _productionTrend == 'same' ? 3 : 4;
      } else {
        _step--;
      }
    });
  }

  Widget _buildQuestion() {
    final content = _questionContent();
    final currentQuestion = _step + 1;
    final totalQuestions = _productionTrend == null ||
            _productionTrend == 'improved' ||
            _productionTrend == 'declined'
        ? 5
        : 4;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                if (content.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    content.subtitle,
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      'ข้อ $currentQuestion จาก $totalQuestions',
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: currentQuestion / totalQuestions,
                          backgroundColor: AppColors.tintGreenSoft,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                if (content.options.isNotEmpty)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tileWidth = (constraints.maxWidth - 10) / 2;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: content.options.map((option) {
                          final id = option['id'] ?? '';
                          final selected = content.multiSelect
                              ? _productionReasons.contains(id)
                              : content.selectedId == id;
                          return SizedBox(
                            width: tileWidth,
                            child: _ChoiceCard(
                              option: option,
                              selected: selected,
                              onTap: () => _selectOption(
                                id,
                                multiSelect: content.multiSelect,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                if (_shouldShowOtherInput(content)) ...[
                  const SizedBox(height: 14),
                  _buildOtherInput(),
                ],
                if (_step == 2) ...[
                  _buildAreaInput(),
                  const SizedBox(height: 14),
                  _buildAreaRewardPreview(),
                ],
              ],
            ),
          ),
        ),
        if (_step == 4)
          _buildReasonActions()
        else if (_step == 2)
          _buildAreaContinueAction()
        else if ((_step == 0 && _agricultureType == 'other') ||
            (_step == 1 && _primaryProduct == 'other'))
          _buildOtherContinueAction(),
      ],
    );
  }

  bool _shouldShowOtherInput(_QuestionContent content) {
    if (_step == 0) return _agricultureType == 'other';
    if (_step == 1) return _primaryProduct == 'other';
    return content.multiSelect && _productionReasons.contains('other');
  }

  Widget _buildOtherInput() {
    final label = switch (_step) {
      0 => 'โปรดระบุประเภทการเกษตร',
      1 => 'โปรดระบุสิ่งที่ปลูกหรือเลี้ยงเป็นหลัก',
      _ => 'โปรดระบุรายละเอียดเพิ่มเติม',
    };
    final initialValue = switch (_step) {
      0 => _agricultureTypeOther,
      1 => _primaryProductOther,
      _ => _productionReasonOther,
    };

    return TextFormField(
      key: ValueKey<String>('farmer-other-$_step'),
      initialValue: initialValue,
      textInputAction: TextInputAction.done,
      maxLength: 80,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'เช่น เกษตรผสมผสาน, วัตถุดิบเฉพาะทาง, ปัญหาที่พบ',
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.tintGreenSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.edit_note_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF9FCF9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Kanit',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Kanit',
          fontSize: 13,
          color: Color(0xFF9AA39A),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Kanit',
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      onChanged: (value) {
        setState(() {
          switch (_step) {
            case 0:
              _agricultureTypeOther = value;
              break;
            case 1:
              _primaryProductOther = value;
              break;
            default:
              _productionReasonOther = value;
          }
        });
      },
    );
  }

  Widget _buildAreaInput() {
    return TextFormField(
      key: const ValueKey<String>('farmer-area-size'),
      initialValue: _areaSize,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: 'จำนวนไร่ที่ทำเกษตรจริง',
        hintText: 'กรอกตัวเลข เช่น 10',
        suffixText: 'ไร่',
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.tintGreenSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.straighten_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF9FCF9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Kanit',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Kanit',
          fontSize: 13,
          color: Color(0xFF9AA39A),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Kanit',
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      onChanged: (value) {
        setState(() => _areaSize = value);
      },
    );
  }

  Widget _buildAreaRewardPreview() {
    final areaRai = FarmerCampaignStore.parseAreaRai(_areaSize);
    final reward = FarmerCampaignStore.rewardForArea(areaRai);
    final bagCount = reward['bagCount'] as int? ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: areaRai > 0 ? AppColors.tintGreenSoft : const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 23,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'สิทธิ์ปุ๋ยที่จะได้รับ',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  areaRai > 0 ? '$bagCount กระสอบ' : 'กรอกจำนวนไร่เพื่อคำนวณ',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: areaRai > 0 ? 19 : 14,
                    fontWeight: FontWeight.w700,
                    color: areaRai > 0
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                if (areaRai > 10) ...[
                  const SizedBox(height: 2),
                  const Text(
                    'สิทธิ์สูงสุด 10 กระสอบ',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _QuestionContent _questionContent() {
    switch (_step) {
      case 0:
        return _QuestionContent(
          title: 'คุณทำเกษตรประเภทไหน?',
          subtitle: 'เลือกประเภทหลักที่คุณทำอยู่ในปัจจุบัน',
          options: FarmerCampaignStore.agricultureTypes,
          selectedId: _agricultureType,
        );
      case 1:
        final question = switch (_agricultureType) {
          'rice' => 'ปลูกข้าวประเภทไหนเป็นหลัก?',
          'livestock' || 'fishery' => 'เลี้ยงอะไรเป็นหลัก?',
          _ => 'ปลูกหรือทำอะไรเป็นหลัก?',
        };
        return _QuestionContent(
          title: question,
          subtitle: 'เลือกสิ่งที่สร้างรายได้หลักให้กับคุณ',
          options: FarmerCampaignStore.primaryProducts[_agricultureType] ??
              const <Map<String, String>>[],
          selectedId: _primaryProduct,
        );
      case 2:
        return _QuestionContent(
          title: 'กรอกพื้นที่ทำเกษตร',
          subtitle:
              'ระบุจำนวนไร่จริง เพื่อคำนวณสิทธิ์ 1 กระสอบต่อไร่ สูงสุด 10 กระสอบ',
          options: const <Map<String, String>>[],
          selectedId: null,
        );
      case 3:
        return _QuestionContent(
          title: 'ผลผลิตเทียบกับรอบก่อนเป็นอย่างไร?',
          subtitle: 'เลือกภาพรวมที่ใกล้เคียงที่สุด',
          options: FarmerCampaignStore.productionTrends,
          selectedId: _productionTrend,
        );
      default:
        final improved = _productionTrend == 'improved';
        return _QuestionContent(
          title: improved ? 'อะไรช่วยให้ผลผลิตดีขึ้น?' : 'อะไรทำให้ผลผลิตลดลง?',
          subtitle: 'เลือกได้มากกว่า 1 ข้อ',
          options: FarmerCampaignStore
                  .productionReasons[improved ? 'improved' : 'declined'] ??
              const <Map<String, String>>[],
          selectedId: null,
          multiSelect: true,
        );
    }
  }

  void _selectOption(String id, {required bool multiSelect}) {
    if (multiSelect) {
      setState(() {
        if (!_productionReasons.add(id)) {
          _productionReasons.remove(id);
          if (id == 'other') _productionReasonOther = '';
        }
      });
      return;
    }

    setState(() {
      switch (_step) {
        case 0:
          if (_agricultureType != id) {
            _primaryProduct = null;
            _primaryProductOther = '';
          }
          if (id != 'other') _agricultureTypeOther = '';
          _agricultureType = id;
          break;
        case 1:
          if (id != 'other') _primaryProductOther = '';
          _primaryProduct = id;
          break;
        case 3:
          if (_productionTrend != id) _productionReasons.clear();
          _productionTrend = id;
          break;
      }
    });

    if (id == 'other' && (_step == 0 || _step == 1)) return;

    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        if (_step == 3) {
          _step = id == 'same' ? 5 : 4;
        } else {
          _step++;
        }
      });
    });
  }

  Widget _buildOtherContinueAction() {
    final value = _step == 0 ? _agricultureTypeOther : _primaryProductOther;
    return _buildBottomAction(
      label: 'ถัดไป',
      enabled: value.trim().isNotEmpty,
      onPressed: () {
        FocusScope.of(context).unfocus();
        setState(() => _step++);
      },
    );
  }

  Widget _buildAreaContinueAction() {
    final areaRai = FarmerCampaignStore.parseAreaRai(_areaSize);
    return _buildBottomAction(
      label: 'ถัดไป',
      enabled: areaRai > 0,
      onPressed: () {
        FocusScope.of(context).unfocus();
        setState(() => _step++);
      },
    );
  }

  Widget _buildBottomAction({
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.tintGreenSoft,
              disabledForegroundColor: AppColors.textSecondary,
              elevation: enabled ? 0.5 : 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReasonActions() {
    final otherIsValid = !_productionReasons.contains('other') ||
        _productionReasonOther.trim().isNotEmpty;
    return _buildBottomAction(
      label: 'ตรวจสอบข้อมูล',
      enabled: _productionReasons.isNotEmpty && otherIsValid,
      onPressed: () {
        FocusScope.of(context).unfocus();
        setState(() => _step = 5);
      },
    );
  }

  Widget _buildSummary() {
    final reasons = FarmerCampaignStore.productionReasons[_productionTrend] ??
        const <Map<String, String>>[];
    final reasonLabels = reasons
        .where((item) => _productionReasons.contains(item['id']))
        .map(
          (item) => item['id'] == 'other'
              ? _productionReasonOther.trim()
              : item['label'] ?? '',
        )
        .where((item) => item.isNotEmpty)
        .join(' • ');

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ตรวจสอบข้อมูลของคุณ',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'แตะย้อนกลับเพื่อแก้ไขได้ก่อนยืนยัน',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        icon: Icons.grass_rounded,
                        label: 'การทำเกษตร',
                        value: _answerLabel(
                          items: FarmerCampaignStore.agricultureTypes,
                          selectedId: _agricultureType,
                          otherValue: _agricultureTypeOther,
                        ),
                      ),
                      _SummaryRow(
                        icon: Icons.eco_rounded,
                        label: 'ทำหลัก',
                        value: _answerLabel(
                          items: FarmerCampaignStore
                                  .primaryProducts[_agricultureType] ??
                              const <Map<String, String>>[],
                          selectedId: _primaryProduct,
                          otherValue: _primaryProductOther,
                        ),
                      ),
                      _SummaryRow(
                        icon: Icons.straighten_rounded,
                        label: 'พื้นที่',
                        value: '$_areaSize ไร่',
                      ),
                      _SummaryRow(
                        icon: Icons.bar_chart_rounded,
                        label: 'ผลผลิต',
                        value: FarmerCampaignStore.labelOf(
                          FarmerCampaignStore.productionTrends,
                          _productionTrend,
                        ),
                      ),
                      if (reasonLabels.isNotEmpty)
                        _SummaryRow(
                          icon: Icons.auto_awesome_rounded,
                          label: _productionTrend == 'improved'
                              ? 'ปัจจัยที่ช่วย'
                              : 'สาเหตุหลัก',
                          value: reasonLabels,
                          showDivider: false,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildRewardCard(),
              ],
            ),
          ),
        ),
        _buildSummaryActions(),
      ],
    );
  }

  String _answerLabel({
    required List<Map<String, String>> items,
    required String? selectedId,
    required String otherValue,
  }) {
    if (selectedId == 'other' && otherValue.trim().isNotEmpty) {
      return otherValue.trim();
    }
    return FarmerCampaignStore.labelOf(items, selectedId);
  }

  Widget _buildRewardCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentTint),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              size: 22,
              color: AppColors.accentHover,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'สิทธิ์ที่ยืนยันได้',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${_reward['title']} ${_reward['quantity']}',
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  (_reward['condition'] ?? '').toString(),
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_areaSize.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'คำนวณจากพื้นที่ที่กรอกไว้ $_areaSize ไร่',
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            SizedBox(
              width: 92,
              height: 48,
              child: OutlinedButton(
                onPressed: _submitting
                    ? null
                    : () => setState(() {
                          _step = _productionTrend == 'same' ? 3 : 4;
                        }),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'แก้ไข',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0.5,
                    shadowColor: AppColors.primary.withValues(alpha: 0.18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'ยืนยันรับสิทธิ์',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await FarmerCampaignStore.submit({
      'agricultureType': _agricultureType,
      'primaryProduct': _primaryProduct,
      'areaSize': _areaSize,
      'productionTrend': _productionTrend,
      'productionReasons': _productionReasons.toList(),
      'agricultureTypeOther':
          _agricultureType == 'other' ? _agricultureTypeOther.trim() : '',
      'primaryProductOther':
          _primaryProduct == 'other' ? _primaryProductOther.trim() : '',
      'productionReasonOther': _productionReasons.contains('other')
          ? _productionReasonOther.trim()
          : '',
    });
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _completed = true;
    });
  }

  Widget _buildSuccess({required bool existing}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 38, 20, 24),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: AppColors.tintGreenSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 52,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            existing ? 'คุณยืนยันรับสิทธิ์แล้ว' : 'ยืนยันรับสิทธิ์สำเร็จ!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ขอบคุณที่ร่วมอัปเดตข้อมูลการเกษตรของคุณ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _buildRewardCard(),
          const SizedBox(height: 14),
          _buildDeliverySection(),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'กลับหน้าหลัก',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _resetCampaignForTest,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reset ข้อมูลทดสอบ'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              textStyle: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection() {
    final address = _deliveryAddress;
    final hasAddress = address != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasAddress ? AppColors.tintGreenSoft : const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasAddress ? AppColors.border : AppColors.accentTint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasAddress
                      ? Icons.local_shipping_outlined
                      : Icons.location_on_outlined,
                  size: 21,
                  color: hasAddress ? AppColors.primary : AppColors.accentHover,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  hasAddress ? 'การจัดส่งสิทธิ์' : 'ยังไม่มีที่อยู่จัดส่ง',
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (hasAddress)
                TextButton(
                  onPressed: _openAddresses,
                  child: const Text(
                    'จัดการ',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasAddress) ...[
            const Text(
              'สิทธิ์ของคุณจะจัดส่งตามที่อยู่ที่ลงทะเบียนไว้',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${address['recipientName'] ?? ''}  ${address['phone'] ?? ''}',
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _addressLine(address),
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 12.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ] else ...[
            const Text(
              'กรุณาลงทะเบียนที่อยู่ เพื่อให้เราจัดส่งสิทธิ์ให้คุณได้อย่างถูกต้อง',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: _openAddresses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text(
                  'ลงทะเบียนที่อยู่จัดส่ง',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _resetCampaignForTest() async {
    final confirmed = await AppDialog.show(
      context: context,
      title: 'Reset ข้อมูลทดสอบ',
      description:
          'ล้างเฉพาะข้อมูลการตอบและสิทธิ์ของแคมเปญนี้ เพื่อเริ่มทดสอบใหม่ ที่อยู่และข้อมูลบัญชีจะยังอยู่เหมือนเดิม',
      primaryText: 'Reset',
      secondaryText: 'ยกเลิก',
      icon: Icons.refresh_rounded,
    );
    if (confirmed != true) return;

    await FarmerCampaignStore.reset();
    if (!mounted) return;
    setState(() {
      _step = 0;
      _completed = false;
      _submitting = false;
      _agricultureType = null;
      _primaryProduct = null;
      _areaSize = '';
      _productionTrend = null;
      _productionReasons.clear();
      _agricultureTypeOther = '';
      _primaryProductOther = '';
      _productionReasonOther = '';
    });
  }
}

class _QuestionContent {
  const _QuestionContent({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedId,
    this.multiSelect = false,
  });

  final String title;
  final String subtitle;
  final List<Map<String, String>> options;
  final String? selectedId;
  final bool multiSelect;
}

/// Maps the legacy emoji values stored in FarmerCampaignStore option maps
/// (option['icon']) to Material outline icons, so the choice cards render
/// crisp vector icons instead of emoji glyphs (which look inconsistent
/// across devices/fonts). Unrecognized emoji fall back to a generic leaf
/// icon rather than showing nothing.
class _ChoiceIcons {
  static const Map<String, IconData> _map = {
    '🌾': Icons.grass_rounded,
    '🍚': Icons.rice_bowl_rounded,
    '🌽': Icons.eco_rounded,
    '🍎': Icons.eco_rounded,
    '🍌': Icons.eco_rounded,
    '🥭': Icons.eco_rounded,
    '🐄': Icons.pets_rounded,
    '🐖': Icons.pets_rounded,
    '🐓': Icons.pets_rounded,
    '🐟': Icons.set_meal_rounded,
    '🦐': Icons.set_meal_rounded,
    '🌱': Icons.spa_rounded,
    '📐': Icons.straighten_rounded,
    '📈': Icons.trending_up_rounded,
    '📉': Icons.trending_down_rounded,
    '⚖️': Icons.balance_rounded,
    '💧': Icons.water_drop_outlined,
    '🌤️': Icons.wb_sunny_outlined,
    '🐛': Icons.bug_report_outlined,
    '💰': Icons.payments_outlined,
    '🌿': Icons.eco_rounded,
    '❓': Icons.more_horiz_rounded,
  };

  static IconData resolve(String? emoji) {
    if (emoji == null || emoji.isEmpty) return Icons.eco_rounded;
    return _map[emoji] ?? Icons.eco_rounded;
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final Map<String, String> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconData = _ChoiceIcons.resolve(option['icon']);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 70),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? AppColors.tintGreenSoft : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 1.4 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : const Color(0xFFF8FBF8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      iconData,
                      size: 20,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      option['label'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 13.5,
                        height: 1.25,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? AppColors.primaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.border))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.tintGreenSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
