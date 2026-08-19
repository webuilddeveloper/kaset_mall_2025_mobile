import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';

class DeliveryAddressAddCentralPage extends StatefulWidget {
  const DeliveryAddressAddCentralPage({super.key, this.address});

  final Map<String, dynamic>? address;

  @override
  State<DeliveryAddressAddCentralPage> createState() =>
      _DeliveryAddressAddCentralPageState();
}

class _DeliveryAddressAddCentralPageState
    extends State<DeliveryAddressAddCentralPage> {
  final _formKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseNoController = TextEditingController();
  final _roadController = TextEditingController();
  final _subDistrictController = TextEditingController();
  final _districtController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isDefault = false;
  bool _saving = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    if (address != null) {
      _recipientNameController.text = (address['recipientName'] ?? '').toString();
      _phoneController.text = (address['phone'] ?? '').toString();
      _houseNoController.text = (address['houseNo'] ?? '').toString();
      _roadController.text = (address['road'] ?? '').toString();
      _subDistrictController.text = (address['subDistrict'] ?? '').toString();
      _districtController.text = (address['district'] ?? '').toString();
      _provinceController.text = (address['province'] ?? '').toString();
      _postalCodeController.text = (address['postalCode'] ?? '').toString();
      _noteController.text = (address['note'] ?? '').toString();
      _isDefault = address['isDefault'] == true;
    }
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _phoneController.dispose();
    _houseNoController.dispose();
    _roadController.dispose();
    _subDistrictController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final payload = {
      'recipientName': _recipientNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'houseNo': _houseNoController.text.trim(),
      'road': _roadController.text.trim(),
      'subDistrict': _subDistrictController.text.trim(),
      'district': _districtController.text.trim(),
      'province': _provinceController.text.trim(),
      'postalCode': _postalCodeController.text.trim(),
      'note': _noteController.text.trim(),
      'isDefault': _isDefault,
    };

    if (_isEditing) {
      await AddressStore.updateAddress(
        widget.address!['id'].toString(),
        payload,
      );
    } else {
      await AddressStore.addAddress(payload);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, 'success');
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: const TextStyle(
              fontFamily: 'Kanit',
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KasetAppBar(
        title: _isEditing ? 'แก้ไขที่อยู่' : 'เพิ่มที่อยู่',
        showBackButton: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              children: [
                _field(
                  label: 'ชื่อผู้รับ',
                  controller: _recipientNameController,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'กรุณากรอกชื่อผู้รับ' : null,
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'เบอร์โทร',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.length != 10) {
                      return 'กรุณากรอกเบอร์โทร 10 หลัก';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'บ้านเลขที่',
                  controller: _houseNoController,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'กรุณากรอกบ้านเลขที่' : null,
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'ถนน',
                  controller: _roadController,
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'ตำบล',
                  controller: _subDistrictController,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'กรุณากรอกตำบล' : null,
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'อำเภอ',
                  controller: _districtController,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'กรุณากรอกอำเภอ' : null,
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'จังหวัด',
                  controller: _provinceController,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'กรุณากรอกจังหวัด' : null,
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'รหัสไปรษณีย์',
                  controller: _postalCodeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.length != 5) {
                      return 'กรุณากรอกรหัสไปรษณีย์ 5 หลัก';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'หมายเหตุ',
                  controller: _noteController,
                  hint: 'เช่น ฝากนิติบุคคล / โทรก่อนส่ง',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.tintGreenSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isDefault,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _isDefault = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'ตั้งเป็นค่าเริ่มต้น',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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
                        : Text(
                            _isEditing ? 'บันทึกการแก้ไข' : 'บันทึกที่อยู่',
                            style: const TextStyle(
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
      ),
    );
  }
}
