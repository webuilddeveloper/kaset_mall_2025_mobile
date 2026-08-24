import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasetmall/delivery_address.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';
import 'package:kasetmall/payment_status.dart';
import 'package:kasetmall/privilege_all.dart';

class ConfirmOrderCentralPage extends StatefulWidget {
  const ConfirmOrderCentralPage({super.key, this.modelCode, this.type});

  final List<dynamic>? modelCode;
  final String? type;

  @override
  State<ConfirmOrderCentralPage> createState() =>
      _ConfirmOrderCentralPageState();
}

class _ConfirmOrderCentralPageState extends State<ConfirmOrderCentralPage> {
  late final List<Map<String, dynamic>> _items;

  final NumberFormat _priceFormat = NumberFormat('#,###', 'th_TH');
  final List<Map<String, dynamic>> _shippingOptions = const [
    {
      'id': 'standard',
      'title': 'จัดส่งมาตรฐาน',
      'subtitle': 'รับสินค้าภายใน 3-5 วัน',
      'price': 30,
    },
    {
      'id': 'express',
      'title': 'จัดส่งด่วน',
      'subtitle': 'รับสินค้าภายใน 1-2 วัน',
      'price': 60,
    },
  ];

  bool _loading = true;
  bool _openingQr = false;
  List<Map<String, dynamic>> _addresses = [];
  List<Map<String, dynamic>> _savedCoupons = [];
  Map<String, dynamic>? _selectedAddress;
  String _selectedShippingId = 'standard';
  String? _selectedCouponId;

  @override
  void initState() {
    super.initState();
    _items = _normalizeItems(widget.modelCode ?? const []);
    _initData();
  }

  Future<void> _initData() async {
    await MockStore.loadUserProfile();
    await _reloadAddresses();
    await _reloadCoupons();

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _normalizeItems(List<dynamic> rawItems) {
    return rawItems.map((raw) {
      final item = Map<String, dynamic>.from(raw as Map);
      return OrderItemNormalizer.normalize(item);
    }).toList();
  }

  Future<void> _reloadAddresses() async {
    final addresses = await AddressStore.getAddresses();
    Map<String, dynamic>? selected;

    if (addresses.isNotEmpty) {
      selected = addresses.firstWhere(
        (item) => item['isDefault'] == true,
        orElse: () => addresses.first,
      );
    }

    if (!mounted) return;
    setState(() {
      _addresses = addresses;
      _selectedAddress = selected;
    });
  }

  Future<void> _reloadCoupons() async {
    final savedCoupons = await CouponStore.getSavedCoupons();
    final couponId = _selectedCouponId;
    if (!mounted) return;
    setState(() {
      _savedCoupons = savedCoupons;
      if (_selectedCouponId != null) {
        final selectedCoupon = _savedCoupons.firstWhere(
          (coupon) => coupon['id'].toString() == couponId,
          orElse: () => <String, dynamic>{},
        );
        if (selectedCoupon.isEmpty || !_isCouponEligible(selectedCoupon)) {
          _selectedCouponId = null;
        }
      }
    });
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String _money(int value) {
    return '${_priceFormat.format(value)} บาท';
  }

  int get _subtotal {
    return _items.fold<int>(
      0,
      (sum, item) => sum + (_toInt(item['price']) * _toInt(item['qty'])),
    );
  }

  Map<String, dynamic> get _selectedShippingOption {
    return _shippingOptions.firstWhere(
      (item) => item['id'] == _selectedShippingId,
      orElse: () => _shippingOptions.first,
    );
  }

  int get _shippingFee => _toInt(_selectedShippingOption['price']);

  Map<String, dynamic>? get _selectedCoupon {
    if (_selectedCouponId == null) return null;
    try {
      return _savedCoupons.firstWhere(
        (item) => item['id'].toString() == _selectedCouponId,
      );
    } catch (_) {
      return null;
    }
  }

  bool _matchesCouponKeywords(Map<String, dynamic> coupon) {
    final keywords = (coupon['eligibleKeywords'] as List<dynamic>?)
            ?.map((item) => item.toString().toLowerCase())
            .toList() ??
        const [];
    if (keywords.isEmpty) {
      return true;
    }

    final itemNames =
        _items.map((item) => item['name'].toString().toLowerCase()).toList();

    for (final keyword in keywords) {
      if (itemNames.any((name) => name.contains(keyword))) {
        return true;
      }
    }
    return false;
  }

  bool _isCouponEligible(Map<String, dynamic> coupon) {
    final minimumOrderTotal = _toInt(coupon['minimumOrderTotal']);
    if (_subtotal < minimumOrderTotal) return false;
    return _matchesCouponKeywords(coupon);
  }

  int _couponDiscount(Map<String, dynamic>? coupon) {
    if (coupon == null || !_isCouponEligible(coupon)) {
      return 0;
    }

    final discountType = (coupon['discountType'] ?? '').toString();
    final discountValue = _toInt(coupon['discountValue']);

    if (discountType == 'percent') {
      final amount = ((_subtotal * discountValue) / 100).round();
      return amount.clamp(0, _subtotal);
    }

    return discountValue.clamp(0, _subtotal);
  }

  int get _discount => _couponDiscount(_selectedCoupon);

  int get _grandTotal {
    final total = _subtotal + _shippingFee - _discount;
    return total < 0 ? 0 : total;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Kanit'),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  Future<void> _openAddressManager() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DeliveryAddressCentralPage(),
      ),
    );
    await _reloadAddresses();
  }

  Future<void> _openQrSheet() async {
    if (_selectedAddress == null) {
      _showMessage('กรุณาเพิ่มที่อยู่จัดส่งก่อน');
      return;
    }

    if (_openingQr) return;

    setState(() {
      _openingQr = true;
    });

    final createdOrder = await OrderStore.createOrderFromCartItems(
      _items,
      shippingFee: _shippingFee,
      discount: _discount,
      couponId: _selectedCoupon?['id']?.toString(),
      couponName: _selectedCoupon?['name']?.toString(),
      shippingMethod: _selectedShippingOption['title'].toString(),
      paymentMethod: 'QR Code',
      address: _selectedAddress,
      createdAt: DateTime.now().toIso8601String(),
      paymentDeadline:
          DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
    );

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentStatusCentralPage(
          orderId: createdOrder['id'].toString(),
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _openingQr = false;
      });
    }
  }

  Widget _sectionHeader(String title,
      {String? actionText, VoidCallback? onTap}) {
    return Row(
      children: [
        Expanded(
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
        if (actionText != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionText,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D16).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAddressSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'ที่อยู่จัดส่ง',
            actionText: _addresses.isEmpty ? 'เพิ่ม' : 'จัดการ',
            onTap: _openAddressManager,
          ),
          const SizedBox(height: 12),
          if (_selectedAddress == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.tintGreenSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ยังไม่มีที่อยู่สำหรับจัดส่ง',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'เพิ่มที่อยู่เพื่อใช้ในการสั่งซื้อ และข้อมูลจะซิงก์กับหน้าโปรไฟล์ทันที',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 12.5,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 130,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _openAddressManager,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'เพิ่มที่อยู่',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: _openAddressManager,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tintGreenSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedAddress!['recipientName']
                                              ?.toString() ??
                                          '',
                                      style: const TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (_selectedAddress!['isDefault'] == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentTint,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'ค่าเริ่มต้น',
                                        style: TextStyle(
                                          fontFamily: 'Kanit',
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.accentHover,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedAddress!['phone']?.toString() ?? '',
                                style: const TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _buildAddressLine(_selectedAddress!),
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 13.5,
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if ((_selectedAddress!['note'] ?? '')
                        .toString()
                        .isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'หมายเหตุ: ${_selectedAddress!['note']}',
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _buildAddressLine(Map<String, dynamic> item) {
    final parts = [
      item['houseNo'],
      item['road'],
      item['subDistrict'],
      item['district'],
      item['province'],
      item['postalCode'],
    ]
        .where((value) => (value ?? '').toString().isNotEmpty)
        .map((value) => value.toString())
        .toList();
    return parts.join(' ');
  }

  Widget _buildItemImage(String image) {
    if (image.isEmpty) {
      return Container(
        color: AppColors.tintGreenSoft,
        child: const Icon(
          Icons.inventory_2_outlined,
          color: AppColors.primary,
          size: 34,
        ),
      );
    }

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.tintGreenSoft,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.primary,
            size: 34,
          ),
        ),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.tintGreenSoft,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.primary,
          size: 34,
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 66,
              height: 66,
              color: AppColors.tintGreenSoft,
              child: _buildItemImage(item['image']?.toString() ?? ''),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']?.toString() ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'จำนวน ${item['qty']} ชิ้น',
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(_toInt(item['price'])),
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'รวม ${_money(_toInt(item['price']) * _toInt(item['qty']))}',
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('รายการสินค้า'),
          const SizedBox(height: 12),
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) => _buildItemCard(_items[index]),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: _items.length,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required int price,
    required bool selected,
    required VoidCallback onTap,
    bool showPrice = true,
    String? trailingText,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.tintGreenSoft : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.tintGreenSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: selected ? Colors.white : AppColors.primary,
                  size: 21,
                ),
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
                    const SizedBox(height: 2),
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
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showPrice)
                    Text(
                      _money(price),
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tintGreenSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        trailingText ?? 'ไม่มีค่าธรรมเนียม',
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShippingSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('ตัวเลือกการจัดส่ง'),
          const SizedBox(height: 12),
          ..._shippingOptions.map((option) {
            final selected = option['id'] == _selectedShippingId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildOptionCard(
                title: option['title'].toString(),
                subtitle: option['subtitle'].toString(),
                price: _toInt(option['price']),
                selected: selected,
                onTap: () {
                  setState(() {
                    _selectedShippingId = option['id'].toString();
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('ตัวเลือกการชำระเงิน'),
          const SizedBox(height: 12),
          _buildOptionCard(
            title: 'QR Code',
            subtitle: 'สแกนจ่ายผ่านแอปธนาคาร',
            price: 0,
            selected: true,
            onTap: () {},
            showPrice: false,
            trailingText: 'ไม่มีค่าธรรมเนียม',
          ),
        ],
      ),
    );
  }

  Future<void> _openCouponPicker() async {
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => PrivilegeAllPage(
          title: 'คูปอง',
          savedOnly: true,
          selectable: true,
          orderSubtotal: _subtotal,
          orderKeywords: _items.map((item) => item['name'].toString()).toList(),
        ),
      ),
    );

    if (!mounted || result == null) return;
    setState(() {
      _selectedCouponId = result['id']?.toString();
    });
  }

  Widget _buildCouponSection() {
    final selectedCoupon = _selectedCoupon;
    final hasSavedCoupon = _savedCoupons.isNotEmpty;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'คูปองของฉัน',
            actionText: hasSavedCoupon ? 'ดูรายการ' : 'ไปเก็บคูปอง',
            onTap: _openCouponPicker,
          ),
          const SizedBox(height: 6),
          Text(
            hasSavedCoupon
                ? 'แตะการ์ดด้านล่างเพื่อเลือกคูปองที่เก็บไว้ใช้กับคำสั่งซื้อนี้'
                : 'ยังไม่มีคูปองที่เก็บไว้ กดปุ่มด้านล่างเพื่อไปดูและเก็บคูปอง',
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openCouponPicker,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selectedCoupon == null
                      ? AppColors.tintGreenSoft
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: selectedCoupon == null
                            ? Colors.white
                            : AppColors.tintGreenSoft,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.local_offer_outlined,
                        color: AppColors.primary,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedCoupon != null
                                ? selectedCoupon['name']?.toString() ??
                                    'คูปองที่เลือก'
                                : hasSavedCoupon
                                    ? 'แตะเพื่อเลือกคูปอง'
                                    : 'ไปเก็บคูปองก่อน',
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedCoupon != null
                                ? 'ใช้กับคำสั่งซื้อนี้ได้'
                                : hasSavedCoupon
                                    ? 'คูปองที่เก็บไว้จะแสดงรายการให้เลือก'
                                    : 'กดเพื่อไปดูรายการคูปอง',
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (selectedCoupon != null)
                          Text(
                            '- ${_money(_discount)}',
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'เลือก',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ],
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

  Widget _buildSummaryRow(String label, String value,
      {bool emphasize = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: emphasize ? 14.5 : 13,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: emphasize ? 15 : 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('สรุปรายการ'),
          const SizedBox(height: 12),
          _buildSummaryRow('ราคาสินค้า', _money(_subtotal)),
          _buildSummaryRow('ค่าจัดส่ง', _money(_shippingFee)),
          _buildSummaryRow('ส่วนลดคูปอง', '- ${_money(_discount)}',
              valueColor: AppColors.primary),
          const Divider(height: 22, color: AppColors.border),
          _buildSummaryRow(
            'ยอดชำระทั้งหมด',
            _money(_grandTotal),
            emphasize: true,
            valueColor: AppColors.primaryDark,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D16).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  (_openingQr || _selectedAddress == null || _items.isEmpty)
                      ? null
                      : _openQrSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                disabledForegroundColor: AppColors.textSecondary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _openingQr
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'ยืนยันและแสดง QR Code',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const KasetAppBar(
        title: 'ยืนยันคำสั่งซื้อ',
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    children: [
                      _buildAddressSection(),
                      const SizedBox(height: 14),
                      _buildItemsSection(),
                      const SizedBox(height: 14),
                      _buildShippingSection(),
                      const SizedBox(height: 14),
                      _buildPaymentSection(),
                      const SizedBox(height: 14),
                      _buildCouponSection(),
                      const SizedBox(height: 14),
                      _buildSummarySection(),
                    ],
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }
}
