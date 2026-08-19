import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/order_details.dart';
import 'package:kasetmall/payment_status.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';

class ToPayCentralPage extends StatefulWidget {
  const ToPayCentralPage({Key? key}) : super(key: key);

  @override
  State<ToPayCentralPage> createState() => _ToPayCentralPageState();
}

class _ToPayCentralPageState extends State<ToPayCentralPage> {
  final NumberFormat _moneyFormat = NumberFormat('#,###', 'th_TH');
  late Future<List<Map<String, dynamic>>> _futureOrders;

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
    _futureOrders = OrderStore.getOrdersByStatus('pendingPayment');
  }

  Future<void> _reload() async {
    setState(() {
      _futureOrders = OrderStore.getOrdersByStatus('pendingPayment');
    });
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.tintGreenSoft,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primary,
                size: 46,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'ยังไม่มีรายการที่ต้องชำระ',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'เมื่อมีคำสั่งซื้อที่ยังไม่ได้ชำระ ระบบจะแสดงที่หน้านี้',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = (order['items'] as List<dynamic>? ?? const []);
    final total = _toInt(order['grandTotal']);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(orderId: order['id'].toString()),
            ),
          ).then((_) => _reload());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'รอชำระเงิน',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentHover,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  order['orderNo']?.toString() ?? '-',
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 68,
                    height: 68,
                    color: AppColors.tintGreenSoft,
                    child: loadingImageNetwork(
                      items.isNotEmpty
                          ? (items.first as Map)['image']?.toString() ?? ''
                          : '',
                      fit: BoxFit.cover,
                      width: 68,
                      height: 68,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items.isNotEmpty
                            ? (items.first as Map)['name']?.toString() ?? ''
                            : 'คำสั่งซื้อ',
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
                      const SizedBox(height: 4),
                      Text(
                        '${items.length} รายการ · ${_money(total)}',
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ยอดรวม ${_money(total)}',
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentStatusCentralPage(
                            orderId: order['id'].toString(),
                          ),
                        ),
                      ).then((_) => _reload());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'ชำระเงิน',
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const KasetAppBar(title: 'ที่ต้องชำระ'),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureOrders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final orders = snapshot.data ?? const <Map<String, dynamic>>[];
            if (orders.isEmpty) {
              return _emptyState();
            }

            return RefreshIndicator(
              onRefresh: _reload,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  const Text(
                    'คำสั่งซื้อที่ยังรอการชำระ',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'แตะการ์ดเพื่อดูรายละเอียด หรือกดชำระเงินเพื่อเข้าสู่ QR Code',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final order in orders) _buildOrderCard(order),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
