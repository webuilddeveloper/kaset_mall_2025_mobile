import 'package:flutter/material.dart';
import 'package:kasetmall/delivery_address_add.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';

class DeliveryAddressCentralPage extends StatefulWidget {
  const DeliveryAddressCentralPage({super.key, this.notChange = false});

  final bool notChange;

  @override
  State<DeliveryAddressCentralPage> createState() =>
      _DeliveryAddressCentralPageState();
}

class _DeliveryAddressCentralPageState extends State<DeliveryAddressCentralPage> {
  Future<List<Map<String, dynamic>>>? _futureAddresses;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _futureAddresses = AddressStore.getAddresses();
  }

  Future<void> _refresh() async {
    setState(_reload);
  }

  String _buildAddressLine(Map<String, dynamic> item) {
    final parts = [
      item['houseNo'],
      item['road'],
      item['subDistrict'],
      item['district'],
      item['province'],
      item['postalCode'],
    ].where((value) => (value ?? '').toString().isNotEmpty).map((e) => e.toString()).toList();
    return parts.join(' ');
  }

  Future<void> _openForm({Map<String, dynamic>? address}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeliveryAddressAddCentralPage(address: address),
      ),
    );
    if (result == 'success') {
      await _refresh();
    }
  }

  Future<void> _setDefault(String id) async {
    await AddressStore.setDefault(id);
    await _refresh();
  }

  Future<void> _deleteAddress(String id) async {
    await AddressStore.deleteAddress(id);
    await _refresh();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.tintGreenSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'ยังไม่มีที่อยู่บันทึกไว้',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'เพิ่มที่อยู่เพื่อใช้ในการสั่งซื้อและจัดส่ง',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () => _openForm(),
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final isDefault = item['isDefault'] == true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault ? AppColors.primary : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D16).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.tintGreenSoft,
                  borderRadius: BorderRadius.circular(12),
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
                            item['recipientName'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentTint,
                              borderRadius: BorderRadius.circular(999),
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
                    const SizedBox(height: 2),
                    Text(
                      item['phone'] ?? '',
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
            _buildAddressLine(item),
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.textPrimary,
            ),
          ),
          if ((item['note'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'หมายเหตุ: ${item['note']}',
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openForm(address: item),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'แก้ไข',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: isDefault ? null : () => _setDefault(item['id']),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDefault ? AppColors.border : AppColors.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isDefault ? 'ค่าเริ่มต้น' : 'ตั้งเป็นค่าเริ่มต้น',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w700,
                      color:
                          isDefault ? AppColors.textSecondary : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _deleteAddress(item['id']),
              child: const Text(
                'ลบที่อยู่',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KasetAppBar(
        title: 'ที่อยู่ของฉัน',
        showBackButton: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureAddresses,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const [];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Column(
            children: [
              Expanded(
                child: items.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, index) => _buildItem(items[index]),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _openForm(),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
