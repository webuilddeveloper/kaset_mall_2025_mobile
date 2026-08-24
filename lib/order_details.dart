import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/payment_status.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({
    Key? key,
    this.orderId,
    this.model,
    this.statusText,
    this.modePage,
  }) : super(key: key);

  final String? orderId;
  final dynamic model;
  final String? statusText;
  final String? modePage;

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final NumberFormat _moneyFormat = NumberFormat('#,###', 'th_TH');
  bool _loading = true;
  Map<String, dynamic>? _order;

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

  Future<void> _loadOrder() async {
    Map<String, dynamic>? order;
    final orderId = widget.orderId ??
        (widget.model is Map
            ? (widget.model['id'] ?? widget.model['code'])?.toString()
            : null);

    if (orderId != null) {
      order = await OrderStore.getOrderById(orderId);
    }

    order ??= _normalizeLegacyOrder();

    if (!mounted) return;
    setState(() {
      _order = order;
      _loading = false;
    });
  }

  Map<String, dynamic> _normalizeLegacyOrder() {
    final raw = widget.model;
    if (raw is Map<String, dynamic>) {
      final qty = _toInt(raw['qty'] ?? raw['quantity'] ?? 1).clamp(1, 999);
      final price = _toInt(raw['price'] ?? raw['priceTotal'] ?? 0);
      final shipping = _toInt(raw['shipping'] ?? 0);
      final discount = _toInt(raw['discount'] ?? 0);
      final subtotal = _toInt(raw['priceTotal'] ?? (price * qty));
      final grandTotal =
          _toInt(raw['grandTotal'] ?? subtotal + shipping - discount);

      return {
        'id': (raw['id'] ??
                raw['code'] ??
                'legacy_${DateTime.now().millisecondsSinceEpoch}')
            .toString(),
        'orderNo': (raw['orderNo'] ??
                raw['code'] ??
                'KM${DateTime.now().millisecondsSinceEpoch}')
            .toString(),
        'status': _statusFromLegacy(),
        'items': [
          {
            'id': (raw['id'] ?? raw['code'] ?? 'legacy_item').toString(),
            'name': raw['title']?.toString() ?? 'รายการสินค้า',
            'image':
                raw['imageUrl']?.toString() ?? raw['image']?.toString() ?? '',
            'price': price == 0 ? subtotal : price,
            'qty': qty,
          }
        ],
        'subtotal': subtotal,
        'shippingFee': shipping,
        'discount': discount,
        'grandTotal': grandTotal,
        'couponName': raw['couponName'],
        'couponId': raw['couponId'],
        'shippingMethod': raw['shippingMethod'] ?? 'จัดส่งมาตรฐาน',
        'paymentMethod': 'QR Code',
        'address': raw['address'] == null
            ? null
            : Map<String, dynamic>.from(raw['address'] as Map),
        'createdAt':
            raw['purchaseDate']?.toString() ?? DateTime.now().toIso8601String(),
        'paidAt': raw['paidDate']?.toString(),
        'preparedAt': raw['preparedAt']?.toString(),
        'shippedAt': raw['shipped_at']?.toString(),
        'completedAt': raw['completedAt']?.toString(),
      };
    }

    return {
      'id': 'legacy_${DateTime.now().millisecondsSinceEpoch}',
      'orderNo': 'KM${DateTime.now().millisecondsSinceEpoch}',
      'status': 'pendingPayment',
      'items': const <Map<String, dynamic>>[],
      'subtotal': 0,
      'shippingFee': 0,
      'discount': 0,
      'grandTotal': 0,
      'paymentMethod': 'QR Code',
      'address': null,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  String _statusFromLegacy() {
    final mode = widget.modePage?.toString();
    if (mode == '0') return 'pendingPayment';
    if (mode == '10') return 'preparing';
    if (mode == '20') return 'shipping';
    if (mode == '30') return 'completed';

    final text = (widget.statusText ?? '').toLowerCase();
    if (text.contains('ชำระ')) return 'pendingPayment';
    if (text.contains('เตรียม')) return 'preparing';
    if (text.contains('จัดส่ง')) return 'shipping';
    if (text.contains('สำเร็จ')) return 'completed';
    return 'pendingPayment';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pendingPayment':
        return 'รอชำระเงิน';
      case 'preparing':
        return 'กำลังจัดเตรียม';
      case 'shipping':
        return 'กำลังจัดส่ง';
      case 'completed':
        return 'สำเร็จ';
      case 'received':
        return 'รับสินค้าแล้ว';
      case 'reviewed':
        return 'รีวิวแล้ว';
      default:
        return widget.statusText ?? 'คำสั่งซื้อ';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pendingPayment':
        return AppColors.accentHover;
      case 'preparing':
        return AppColors.primary;
      case 'shipping':
        return AppColors.infoBlue;
      case 'completed':
      case 'received':
      case 'reviewed':
        return AppColors.primaryDark;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pendingPayment':
        return Icons.payments_rounded;
      case 'preparing':
        return Icons.inventory_2_rounded;
      case 'shipping':
        return Icons.local_shipping_rounded;
      case 'completed':
      case 'received':
      case 'reviewed':
        return Icons.verified_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  List<Map<String, dynamic>> _timeline(String status) {
    final stages = [
      {'title': 'รอชำระเงิน', 'key': 'pendingPayment'},
      {'title': 'กำลังจัดเตรียม', 'key': 'preparing'},
      {'title': 'กำลังจัดส่ง', 'key': 'shipping'},
      {'title': 'สำเร็จ', 'key': 'completed'},
      {'title': 'รับสินค้าแล้ว', 'key': 'received'},
    ];
    final currentIndex = stages.indexWhere((item) => item['key'] == status);
    return stages.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return {
        ...item,
        'done': currentIndex > index,
        'active': currentIndex == index,
        'pending': currentIndex < index,
      };
    }).toList();
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

  Widget _buildTimeline(String status) {
    final timeline = _timeline(status);
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'สถานะคำสั่งซื้อ',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildCompactStatusAction(status),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < timeline.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: timeline[i]['done'] == true ||
                            timeline[i]['active'] == true
                        ? AppColors.primary
                        : AppColors.tintGreenSoft,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: timeline[i]['done'] == true ||
                              timeline[i]['active'] == true
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    timeline[i]['done'] == true
                        ? Icons.check_rounded
                        : timeline[i]['active'] == true
                            ? Icons.circle
                            : Icons.radio_button_unchecked_rounded,
                    size: 12,
                    color: timeline[i]['done'] == true ||
                            timeline[i]['active'] == true
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      timeline[i]['title'].toString(),
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 14,
                        fontWeight: timeline[i]['active'] == true
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: timeline[i]['done'] == true ||
                                timeline[i]['active'] == true
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (i != timeline.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 10.5),
                child: Container(
                  width: 1.5,
                  height: 26,
                  color: timeline[i]['done'] == true
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactStatusAction(String status) {
    if (status == 'reviewed' || status == 'completed' || status == 'received') {
      return const SizedBox.shrink();
    }

    final label = status == 'pendingPayment'
        ? 'ย้ายไปเตรียม'
        : status == 'preparing'
            ? 'ย้ายไปจัดส่ง'
            : 'ย้ายไปสำเร็จ';

    return TextButton(
      onPressed: () async {
        if (status == 'pendingPayment') {
          final now = DateTime.now().toIso8601String();
          await OrderStore.updateOrderStatus(
            _order!['id'].toString(),
            'preparing',
            paidAt: now,
            preparedAt: now,
          );
        } else if (status == 'preparing') {
          final now = DateTime.now().toIso8601String();
          await OrderStore.updateOrderStatus(
            _order!['id'].toString(),
            'shipping',
            shippedAt: now,
          );
        } else if (status == 'shipping') {
          final now = DateTime.now().toIso8601String();
          await OrderStore.updateOrderStatus(
            _order!['id'].toString(),
            'completed',
            completedAt: now,
          );
        }
        if (!mounted) return;
        await _loadOrder();
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: AppColors.primary,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Kanit',
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
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

  Widget _buildTopSummary(Map<String, dynamic> order) {
    final status = order['status'].toString();
    final label = _statusLabel(status);
    final color = _statusColor(status);
    final items = (order['items'] as List<dynamic>? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.tintGreenSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _statusIcon(status),
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เลขที่คำสั่งซื้อ',
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order['orderNo']?.toString() ?? '-',
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tintGreenSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ยอดรวมทั้งหมด',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _money(_toInt(order['grandTotal'])),
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow('สินค้าทั้งหมด', '${items.length} รายการ'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoRow(
                  'วิธีชำระ',
                  order['paymentMethod']?.toString() ?? 'QR Code',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic>? address) {
    if (address == null) {
      return _sectionCard(
        child: const Text(
          'ยังไม่มีที่อยู่จัดส่ง',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final parts = [
      address['houseNo'],
      address['road'],
      address['subDistrict'],
      address['district'],
      address['province'],
      address['postalCode'],
    ]
        .where((value) => (value ?? '').toString().isNotEmpty)
        .map((value) => value.toString())
        .toList();

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ที่อยู่จัดส่ง',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            address['recipientName']?.toString() ?? '',
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address['phone']?.toString() ?? '',
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            parts.join(' '),
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13,
              height: 1.45,
              color: AppColors.textPrimary,
            ),
          ),
          if ((address['note'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'หมายเหตุ: ${address['note']}',
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> order) {
    return _sectionCard(
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
          _buildInfoRow('ราคาสินค้า', _money(_toInt(order['subtotal']))),
          _buildInfoRow('ค่าจัดส่ง', _money(_toInt(order['shippingFee']))),
          _buildInfoRow(
            'ส่วนลดคูปอง',
            '- ${_money(_toInt(order['discount']))}',
            valueColor: AppColors.primary,
          ),
          const Divider(height: 24, color: AppColors.border),
          _buildInfoRow(
            'ยอดรวม',
            _money(_toInt(order['grandTotal'])),
            valueColor: AppColors.primaryDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(Map<String, dynamic> order) {
    final status = order['status'].toString();
    if (status != 'pendingPayment' && status != 'completed') {
      return const SizedBox.shrink();
    }

    if (status == 'completed') {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            await OrderStore.updateOrderStatus(
              order['id'].toString(),
              'received',
            );
            await _loadOrder();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'กดรับสินค้า',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentStatusCentralPage(
                orderId: order['id'].toString(),
              ),
            ),
          ).then((_) => _loadOrder());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'ชำระเงินตอนนี้',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const KasetAppBar(title: 'รายละเอียดคำสั่งซื้อ'),
      body: _loading || _order == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    children: [
                      _buildTopSummary(_order!),
                      const SizedBox(height: 14),
                      _buildTimeline(_order!['status'].toString()),
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
                            for (final item in (_order!['items']
                                        as List<dynamic>? ??
                                    const [])
                                .map(
                                    (e) => Map<String, dynamic>.from(e as Map)))
                              _buildItemCard(item),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildAddressCard(
                        _order!['address'] == null
                            ? null
                            : Map<String, dynamic>.from(
                                _order!['address'] as Map),
                      ),
                      const SizedBox(height: 14),
                      _buildSummaryCard(_order!),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildActions(_order!),
                ),
              ],
            ),
    );
  }
}
