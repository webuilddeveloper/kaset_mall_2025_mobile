import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';
import 'package:kasetmall/to_ship.dart';

class PaymentStatusCentralPage extends StatefulWidget {
  const PaymentStatusCentralPage({
    super.key,
    this.model,
    this.orderId,
  });

  final dynamic model;
  final String? orderId;

  @override
  State<PaymentStatusCentralPage> createState() =>
      _PaymentStatusCentralPageState();
}

class _PaymentStatusCentralPageState extends State<PaymentStatusCentralPage> {
  final NumberFormat _moneyFormat = NumberFormat('#,###', 'th_TH');

  Timer? _timer;
  int _remainingSeconds = 30;
  bool _loading = true;
  bool _completing = false;
  bool _success = false;
  Map<String, dynamic>? _order;

  String? get _resolvedOrderId {
    final orderId = widget.orderId?.toString();
    if (orderId != null && orderId.isNotEmpty) return orderId;
    final model = widget.model;
    if (model is Map) {
      final raw = model['order_id'] ?? model['id'] ?? model['orderNo'];
      if (raw != null) return raw.toString();
    }
    return null;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String _money(int value) => '${_moneyFormat.format(value)} บาท';

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    final orderId = _resolvedOrderId;
    Map<String, dynamic>? order;

    if (orderId != null) {
      order = await OrderStore.getOrderById(orderId);
    }

    order ??= _buildFallbackOrder();

    if (!mounted) return;
    setState(() {
      _order = order;
      _loading = false;
    });

    _startCountdown();
  }

  Map<String, dynamic> _buildFallbackOrder() {
    final model = widget.model;
    if (model is Map) {
      return {
        'id':
            _resolvedOrderId ?? 'ord_${DateTime.now().millisecondsSinceEpoch}',
        'orderNo': model['orderNo']?.toString() ??
            _resolvedOrderId?.toString() ??
            'KM${DateTime.now().millisecondsSinceEpoch}',
        'status': 'pendingPayment',
        'items': const <Map<String, dynamic>>[],
        'subtotal': _toInt(model['subtotal']),
        'shippingFee': _toInt(model['shippingFee']),
        'discount': _toInt(model['discount']),
        'grandTotal': _toInt(model['grandTotal'] ?? model['total']),
        'createdAt': DateTime.now().toIso8601String(),
        'paymentMethod': 'QR Code',
      };
    }

    return {
      'id': 'ord_${DateTime.now().millisecondsSinceEpoch}',
      'orderNo': 'KM${DateTime.now().millisecondsSinceEpoch}',
      'status': 'pendingPayment',
      'items': const <Map<String, dynamic>>[],
      'subtotal': 0,
      'shippingFee': 0,
      'discount': 0,
      'grandTotal': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'paymentMethod': 'QR Code',
    };
  }

  void _startCountdown() {
    _timer?.cancel();
    _remainingSeconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_success) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _completePayment(auto: true);
        return;
      }
      setState(() {
        _remainingSeconds -= 1;
      });
    });
  }

  Future<void> _completePayment({bool auto = false}) async {
    if (_completing || _success) return;
    final order = _order;
    if (order == null) return;

    setState(() {
      _completing = true;
    });

    _timer?.cancel();

    final now = DateTime.now().toIso8601String();
    await OrderStore.updateOrderStatus(
      order['id'].toString(),
      'preparing',
      paidAt: now,
      preparedAt: null,
    );
    await NotificationStore.addNotification(
      type: 'order',
      title: auto ? 'ชำระเงินเสร็จสิ้นอัตโนมัติ' : 'ชำระเงินเสร็จสิ้น',
      description:
          'คำสั่งซื้อ ${order['orderNo']} ถูกย้ายไปหน้าเตรียมสินค้าแล้ว',
    );

    if (!mounted) return;
    setState(() {
      _success = true;
      _completing = false;
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            ToShipCentralPage(highlightOrderId: order['id'].toString()),
      ),
      (route) => route.isFirst,
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    final qty = _toInt(item['qty']);
    final price = _toInt(item['price']);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tintGreenSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 54,
              height: 54,
              color: Colors.white,
              child: loadingImageNetwork(
                item['image']?.toString() ?? '',
                fit: BoxFit.cover,
                width: 54,
                height: 54,
              ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'จำนวน $qty ชิ้น',
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
          Text(
            _money(price * qty),
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessPanel() {
    return _sectionCard(
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.tintGreenSoft,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.primary,
              size: 46,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'ชำระเงินเสร็จสิ้น',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ระบบกำลังพาคำสั่งซื้อไปที่หน้ากำลังจัดเตรียมสินค้า',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          const CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildQrPanel() {
    final order = _order!;
    final items = (order['items'] as List<dynamic>? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final total = _toInt(order['grandTotal']);
    final subtotal = _toInt(order['subtotal']);
    final shippingFee = _toInt(order['shippingFee']);
    final discount = _toInt(order['discount']);
    final totalSeconds = 30;
    final progress = _remainingSeconds / totalSeconds;
    final deadlineText = _remainingSeconds > 0
        ? 'หมดเวลาใน ${_remainingSeconds}s'
        : 'กำลังยืนยันการชำระเงิน';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _sectionCard(
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.tintGreenSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'ชำระเงินด้วย QR Code',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'สแกนจ่ายผ่านแอปธนาคารและรอระบบยืนยันอัตโนมัติ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 12.5,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 7,
                        color: AppColors.primary,
                        backgroundColor: AppColors.border,
                      ),
                    ),
                    Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        color: AppColors.tintGreenSoft,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.qr_code_rounded,
                        color: AppColors.primaryDark,
                        size: 72,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  deadlineText,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentHover,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildInfoRow(
                  'เลขคำสั่งซื้อ', order['orderNo']?.toString() ?? '-'),
              _buildInfoRow('ยอดที่ต้องชำระ', _money(total),
                  valueColor: AppColors.primary),
              _buildInfoRow('วิธีชำระ', 'QR Code'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'สรุปรายการ',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('ราคาสินค้า', _money(subtotal)),
              _buildInfoRow('ค่าจัดส่ง', _money(shippingFee)),
              _buildInfoRow(
                'ส่วนลดคูปอง',
                '- ${_money(discount)}',
                valueColor: AppColors.primary,
              ),
              const Divider(height: 24, color: AppColors.border),
              _buildInfoRow(
                'ยอดรวม',
                _money(total),
                valueColor: AppColors.primaryDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'รายการสินค้า',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              for (final item in items) _buildItemRow(item),
              if (items.isEmpty)
                const Text(
                  'ไม่มีรายการสินค้า',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _completing ? null : _completePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _completing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'ฉันชำระแล้ว · ${_money(total)}',
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _timer?.cancel();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const KasetAppBar(title: 'ชำระเงินด้วย QR Code'),
        body: _loading || _order == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _success
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildSuccessPanel(),
                    ),
                  )
                : _buildQrPanel(),
      ),
    );
  }
}
