import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/data/mock_kaset_data.dart';

class CouponStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _savedKey = 'mock_saved_coupons_v1';

  static final List<Map<String, dynamic>> _coupons = [
    {
      'id': 'c1',
      'name': 'ส่วนลดข้าวหอมมะลิ',
      'title': 'Cash Back เกษตรปลอดภัย',
      'subtitle': 'ใช้กับข้าวและธัญพืช',
      'discount': '10%',
      'discountType': 'percent',
      'discountValue': 10,
      'minimumOrderTotal': 500,
      'eligibleKeywords': ['ข้าว', 'ธัญพืช', 'เมล็ดพันธุ์'],
      'expiry': '31 ส.ค. 2026',
      'period': '31 ส.ค. 2026',
      'image': 'assets/images/kaset/logo_kaset.png',
      'tag': 'ยอดนิยม',
      'description': 'ใช้กับสินค้ากลุ่มข้าวและธัญพืช',
      'condition': 'ใช้ได้กับสินค้าที่ร่วมรายการ',
      'canSave': true,
      'canRedeem': true,
    },
    {
      'id': 'c2',
      'name': 'คูปองผักสดประจำวัน',
      'title': 'คูปองผักสดประจำวัน',
      'subtitle': 'สดใหม่ คุ้มค่า ใช้กับผักและผลไม้',
      'discount': '฿50',
      'discountType': 'amount',
      'discountValue': 50,
      'minimumOrderTotal': 300,
      'eligibleKeywords': ['ผัก', 'ผลไม้', 'สมุนไพร'],
      'expiry': '5 ก.ย. 2026',
      'period': '5 ก.ย. 2026',
      'image': 'assets/images/kaset/category_basket.png',
      'tag': 'วันนี้เท่านั้น',
      'description': 'ใช้กับผัก ผลไม้ และสมุนไพร',
      'condition': 'ใช้ได้กับสินค้าที่ร่วมรายการ',
      'canSave': true,
      'canRedeem': true,
    },
    {
      'id': 'c3',
      'name': 'ลดเครื่องมือเกษตร',
      'title': 'ส่วนลดเครื่องมือเกษตร',
      'subtitle': 'สิทธิ์สำหรับอุปกรณ์และเครื่องมือ',
      'discount': '15%',
      'discountType': 'percent',
      'discountValue': 15,
      'minimumOrderTotal': 800,
      'eligibleKeywords': ['เครื่องมือ', 'อุปกรณ์', 'เกษตร'],
      'expiry': '10 ก.ย. 2026',
      'period': '10 ก.ย. 2026',
      'image': 'assets/images/kaset/category_tools.png',
      'tag': 'แนะนำ',
      'description': 'ใช้กับเครื่องมือและอุปกรณ์การเกษตร',
      'condition': 'ใช้ได้กับสินค้าที่ร่วมรายการ',
      'canSave': true,
      'canRedeem': true,
    },
    {
      'id': 'c4',
      'name': 'อาหารสัตว์คุ้มกว่า',
      'title': 'สิทธิ์อาหารสัตว์คุ้มกว่า',
      'subtitle': 'เหมาะกับฟาร์มและการเลี้ยงสัตว์',
      'discount': '฿30',
      'discountType': 'amount',
      'discountValue': 30,
      'minimumOrderTotal': 400,
      'eligibleKeywords': ['อาหารสัตว์', 'สัตว์', 'ฟาร์ม'],
      'expiry': '15 ก.ย. 2026',
      'period': '15 ก.ย. 2026',
      'image': 'assets/images/kaset/category_feed.png',
      'tag': 'คัดพิเศษ',
      'description': 'ใช้กับอาหารสัตว์และสินค้าที่ร่วมรายการ',
      'condition': 'ใช้ได้กับสินค้าที่ร่วมรายการ',
      'canSave': true,
      'canRedeem': true,
    },
  ];

  static Future<List<String>> _readSavedIds() async {
    final raw = await _storage.read(key: _savedKey);
    if (raw == null || raw.isEmpty) {
      return <String>[];
    }
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  static Future<void> _writeSavedIds(List<String> ids) async {
    await _storage.write(key: _savedKey, value: jsonEncode(ids));
  }

  static Map<String, dynamic> _withSavedState(
    Map<String, dynamic> coupon,
    bool isSaved,
  ) {
    return {
      ...coupon,
      'isSaved': isSaved,
    };
  }

  static Future<List<Map<String, dynamic>>> getAllCoupons() async {
    final savedIds = await _readSavedIds();
    return _coupons
        .map((coupon) =>
            _withSavedState(coupon, savedIds.contains(coupon['id'])))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getSavedCoupons() async {
    final all = await getAllCoupons();
    return all.where((item) => item['isSaved'] == true).toList();
  }

  static Future<List<Map<String, dynamic>>> getUnsavedCoupons() async {
    final all = await getAllCoupons();
    return all.where((item) => item['isSaved'] != true).toList();
  }

  static Future<void> saveCoupon(String id) async {
    final savedIds = await _readSavedIds();
    if (!savedIds.contains(id)) {
      savedIds.add(id);
      await _writeSavedIds(savedIds);
    }
  }

  static Future<bool> isSaved(String id) async {
    final savedIds = await _readSavedIds();
    return savedIds.contains(id);
  }
}

class OrderItemNormalizer {
  static String _firstNonEmptyString(Iterable<dynamic> values,
      {String fallback = ''}) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  static String resolveImage(dynamic source) {
    if (source == null) return '';

    if (source is List) {
      for (final item in source) {
        final resolved = resolveImage(item);
        if (resolved.isNotEmpty) return resolved;
      }
      return '';
    }

    if (source is Map) {
      return _firstNonEmptyString([
        source['url'],
        source['imageUrl'],
        source['path'],
        source['src'],
      ]);
    }

    final text = source.toString().trim();
    if (text.isEmpty) return '';

    if (text.startsWith('[')) {
      try {
        final decoded = jsonDecode(text);
        if (decoded is List) {
          return resolveImage(decoded);
        }
      } catch (_) {}
    }

    return text;
  }

  static Map<String, dynamic> normalize(
    Map<String, dynamic> raw, {
    int defaultQty = 1,
  }) {
    final productId = _firstNonEmptyString(
      [
        raw['productId'],
        raw['product_id'],
        raw['productCode'],
        raw['product_code'],
        raw['id'],
        raw['cart_id'],
        raw['sku'],
        raw['code'],
      ],
      fallback: _firstNonEmptyString([raw['name'], raw['title']], fallback: ''),
    );
    final name =
        (raw['name'] ?? raw['title'] ?? raw['productName'] ?? '').toString();
    var image = resolveImage(
      raw['image'] ?? raw['imageUrl'] ?? raw['url'] ?? raw['photo'],
    );
    if (image.isEmpty) {
      image = _resolveImageFromCatalog(productId: productId, name: name);
    }
    final qty =
        _toInt(raw['qty'] ?? raw['quantity'] ?? defaultQty).clamp(1, 999);
    final price = _toInt(raw['price'] ?? raw['salePrice'] ?? raw['netPrice']);
    final shopName = _firstNonEmptyString(
      [
        raw['shopName'],
        raw['shop'],
        raw['sellerName'],
        raw['merchantName'],
        raw['lv1ShopName'],
      ],
      fallback: 'เกษตร Mall',
    );
    final shopCode = _firstNonEmptyString(
      [
        raw['shopCode'],
        raw['shop_id'],
        raw['sellerCode'],
        raw['merchantCode'],
      ],
    );
    return {
      ...raw,
      'id': productId,
      'productId': productId,
      'name': name,
      'image': image,
      'imageUrl': image,
      'price': price,
      'qty': qty,
      'quantity': qty,
      'shopName': shopName,
      if (shopCode.isNotEmpty) 'shopCode': shopCode,
    };
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static String _resolveImageFromCatalog({
    required String productId,
    required String name,
  }) {
    final normalizedId = productId.toString().trim();
    final normalizedName = name.toString().trim();

    Map<String, dynamic>? match;
    if (normalizedId.isNotEmpty) {
      match = mockProductList.cast<Map<String, dynamic>?>().firstWhere(
            (item) => item?['id']?.toString() == normalizedId,
            orElse: () => null,
          );
    }

    match ??= mockProductList.cast<Map<String, dynamic>?>().firstWhere(
          (item) => item?['name']?.toString() == normalizedName,
          orElse: () => null,
        );

    return match?['image']?.toString() ?? '';
  }
}

class AddressStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _addressKey = 'mock_addresses_v1';

  static const List<Map<String, dynamic>> _defaultAddresses = [
    {
      'id': 'a1',
      'recipientName': 'สมชาย ใจดี',
      'phone': '0812345678',
      'houseNo': '99/12',
      'road': 'ถนนพหลโยธิน',
      'subDistrict': 'ลาดยาว',
      'district': 'จตุจักร',
      'province': 'กรุงเทพมหานคร',
      'postalCode': '10900',
      'note': 'ฝากไว้กับนิติฯ',
      'isDefault': true,
    },
  ];

  static Future<List<Map<String, dynamic>>> _readAddresses() async {
    final raw = await _storage.read(key: _addressKey);
    if (raw == null || raw.isEmpty) {
      return List<Map<String, dynamic>>.from(_defaultAddresses);
    }
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return List<Map<String, dynamic>>.from(_defaultAddresses);
  }

  static Future<void> _writeAddresses(List<Map<String, dynamic>> items) async {
    await _storage.write(key: _addressKey, value: jsonEncode(items));
  }

  static Future<List<Map<String, dynamic>>> getAddresses() async {
    return _readAddresses();
  }

  static Future<void> addAddress(Map<String, dynamic> address) async {
    final items = await _readAddresses();
    final newItem = {
      ...address,
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'isDefault': address['isDefault'] == true,
    };
    if (newItem['isDefault'] == true) {
      for (final item in items) {
        item['isDefault'] = false;
      }
    }
    items.add(newItem);
    if (!items.any((item) => item['isDefault'] == true) && items.isNotEmpty) {
      items.last['isDefault'] = true;
    }
    await _writeAddresses(items);
  }

  static Future<void> updateAddress(
    String id,
    Map<String, dynamic> address,
  ) async {
    final items = await _readAddresses();
    final index = items.indexWhere((item) => item['id'].toString() == id);
    if (index == -1) return;
    final updated = {
      ...items[index],
      ...address,
      'id': id,
      'isDefault': address['isDefault'] == true,
    };
    if (updated['isDefault'] == true) {
      for (final item in items) {
        item['isDefault'] = false;
      }
    }
    items[index] = updated;
    if (!items.any((item) => item['isDefault'] == true) && items.isNotEmpty) {
      items[index]['isDefault'] = true;
    }
    await _writeAddresses(items);
  }

  static Future<void> deleteAddress(String id) async {
    final items = await _readAddresses();
    items.removeWhere((item) => item['id'].toString() == id);
    if (items.isNotEmpty && !items.any((item) => item['isDefault'] == true)) {
      items.first['isDefault'] = true;
    }
    await _writeAddresses(items);
  }

  static Future<void> setDefault(String id) async {
    final items = await _readAddresses();
    for (final item in items) {
      item['isDefault'] = item['id'].toString() == id;
    }
    await _writeAddresses(items);
  }
}

class ProfileStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _profileKey = 'mock_user_profile_v1';

  static const Map<String, dynamic> _defaultProfile = {
    'firstName': 'สมชาย',
    'lastName': 'ใจดี',
    'phone': '0812345678',
    'email': 'somchai@kasetmall.co.th',
    'birthday': '18 สิงหาคม 2538',
    'imageUrl': '',
  };

  static Future<Map<String, dynamic>> getProfile() async {
    final raw = await _storage.read(key: _profileKey);
    if (raw == null || raw.isEmpty) {
      return Map<String, dynamic>.from(_defaultProfile);
    }
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  static Future<void> saveProfile(Map<String, dynamic> profile) async {
    await _storage.write(key: _profileKey, value: jsonEncode(profile));
  }
}

class MockStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static Map<String, dynamic> userProfile = {};
  static final ValueNotifier<int> authVersion = ValueNotifier<int>(0);
  static final ValueNotifier<int> cartVersion = ValueNotifier<int>(0);

  static Future<bool> isLoggedIn() async {
    final firstName = await _storage.read(key: 'profileFirstName');
    final token = await _storage.read(key: 'token');
    final profileCode = await _storage.read(key: 'profileCode10');

    return (firstName ?? '').isNotEmpty ||
        (token ?? '').isNotEmpty ||
        (profileCode ?? '').isNotEmpty;
  }

  static Future<String> displayName() async {
    await loadUserProfile();
    final firstName = userProfile['firstName']?.toString() ?? '';
    final lastName = userProfile['lastName']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? 'ยังไม่เข้าสู่ระบบ' : fullName;
  }

  static Future<Map<String, dynamic>> loadUserProfile() async {
    final profile = await ProfileStore.getProfile();
    final firstName = await _storage.read(key: 'profileFirstName') ?? '';
    final lastName = await _storage.read(key: 'profileLastName') ?? '';
    final phone = await _storage.read(key: 'profilePhone') ?? '';
    final imageUrl = await _storage.read(key: 'profileImageUrl') ?? '';
    final email = await _storage.read(key: 'profileEmail') ?? '';
    final birthday = await _storage.read(key: 'profileBirthday') ?? '';

    userProfile = {
      ...profile,
      if (firstName.isNotEmpty) 'firstName': firstName,
      if (lastName.isNotEmpty) 'lastName': lastName,
      if (phone.isNotEmpty) 'phone': phone,
      if (imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      if (email.isNotEmpty) 'email': email,
      if (birthday.isNotEmpty) 'birthday': birthday,
    };
    return userProfile;
  }

  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    userProfile = Map<String, dynamic>.from(profile);
    await ProfileStore.saveProfile(userProfile);
    await _storage.write(
      key: 'profileFirstName',
      value: userProfile['firstName']?.toString() ?? '',
    );
    await _storage.write(
      key: 'profileLastName',
      value: userProfile['lastName']?.toString() ?? '',
    );
    await _storage.write(
      key: 'profilePhone',
      value: userProfile['phone']?.toString() ?? '',
    );
    await _storage.write(
      key: 'profileImageUrl',
      value: userProfile['imageUrl']?.toString() ?? '',
    );
    await _storage.write(
      key: 'profileEmail',
      value: userProfile['email']?.toString() ?? '',
    );
    await _storage.write(
      key: 'profileBirthday',
      value: userProfile['birthday']?.toString() ?? '',
    );
    authVersion.value++;
  }

  static Future<void> resetUserProfile() async {
    await saveUserProfile({
      'firstName': 'สมชาย',
      'lastName': 'ใจดี',
      'phone': '0812345678',
      'email': 'somchai@kasetmall.co.th',
      'birthday': '18 สิงหาคม 2538',
      'imageUrl': '',
    });
  }

  static Future<void> clearSession() async {
    const keys = [
      'profileFirstName',
      'profileLastName',
      'profilePhone',
      'profileImageUrl',
      'profileEmail',
      'profileBirthday',
      'profileCode10',
      'Agency',
      'isShop',
      'policyAccepted',
      'loginSource',
      'token',
    ];
    for (final key in keys) {
      await _storage.delete(key: key);
    }
    userProfile = {};
    authVersion.value++;
  }
}

class CartStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _cartKey = 'cartItems';

  static Future<List<Map<String, dynamic>>> _readCart() async {
    final raw = await _storage.read(key: _cartKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return <Map<String, dynamic>>[];
  }

  static Future<void> _writeCart(List<Map<String, dynamic>> items) async {
    await _storage.write(key: _cartKey, value: jsonEncode(items));
  }

  static Future<List<Map<String, dynamic>>> getCart() async {
    final cart = await _readCart();
    return cart.map((item) => OrderItemNormalizer.normalize(item)).toList();
  }

  static Future<void> addToCart(Map<String, dynamic> item,
      {int qty = 1}) async {
    final cart = await _readCart();
    final normalizedItem = OrderItemNormalizer.normalize(item, defaultQty: qty);
    final index = cart.indexWhere(
        (e) => e['id'].toString() == normalizedItem['id'].toString());
    if (index >= 0) {
      cart[index]['qty'] = (cart[index]['qty'] as int? ?? 1) + qty;
      cart[index]['quantity'] = cart[index]['qty'];
    } else {
      cart.add({
        ...normalizedItem,
        'qty': qty,
        'quantity': qty,
        'selected': false,
      });
    }
    await _writeCart(cart);
    MockStore.cartVersion.value++;
  }

  static Future<void> updateQty(String id, int qty) async {
    final cart = await _readCart();
    final index = cart.indexWhere((e) => e['id'].toString() == id);
    if (index >= 0) {
      cart[index]['qty'] = qty;
      await _writeCart(cart);
      MockStore.cartVersion.value++;
    }
  }

  static Future<void> removeItem(String id) async {
    final cart = await _readCart();
    cart.removeWhere((e) => e['id'].toString() == id);
    await _writeCart(cart);
    MockStore.cartVersion.value++;
  }

  static Future<void> clearCart() async {
    await _writeCart(<Map<String, dynamic>>[]);
    MockStore.cartVersion.value++;
  }
}

class FavoriteStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _favoriteKey = 'mock_favorites_v1';

  static Future<List<String>> _readFavorites() async {
    final raw = await _storage.read(key: _favoriteKey);
    if (raw == null || raw.isEmpty) return <String>[];
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  static Future<void> _writeFavorites(List<String> ids) async {
    await _storage.write(key: _favoriteKey, value: jsonEncode(ids));
  }

  static Future<List<String>> getFavorites() async => _readFavorites();

  static Future<bool> isFavorite(String id) async {
    final ids = await _readFavorites();
    return ids.contains(id);
  }

  static Future<void> toggleFavorite(String id) async {
    final ids = await _readFavorites();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await _writeFavorites(ids);
  }
}

class NotificationStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _notificationKey = 'mock_notifications_v1';
  static final ValueNotifier<int> notificationVersion = ValueNotifier<int>(0);

  static final List<Map<String, dynamic>> _defaultNotifications = [
    {
      'id': 'n1',
      'type': 'order',
      'title': 'คำสั่งซื้อกำลังจัดเตรียม',
      'description': 'รายการสั่งซื้อของคุณกำลังถูกจัดเตรียม',
      'time': '10 นาทีที่แล้ว',
      'read': false,
      'iconName': 'inventory_2_outlined',
    },
    {
      'id': 'n2',
      'type': 'promo',
      'title': 'คูปองใหม่ประจำวัน',
      'description': 'รับส่วนลดเพิ่มสำหรับสินค้าเกษตรที่ร่วมรายการ',
      'time': '1 ชั่วโมงที่แล้ว',
      'read': false,
      'iconName': 'local_offer_outlined',
    },
    {
      'id': 'n3',
      'type': 'general',
      'title': 'อัปเดตระบบ',
      'description': 'ปรับปรุงประสบการณ์ใช้งานให้ลื่นไหลยิ่งขึ้น',
      'time': 'เมื่อวาน',
      'read': true,
      'iconName': 'notifications_none_rounded',
    },
  ];

  static Future<List<Map<String, dynamic>>> _readNotifications() async {
    final raw = await _storage.read(key: _notificationKey);
    if (raw == null || raw.isEmpty) {
      return List<Map<String, dynamic>>.from(_defaultNotifications);
    }
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return List<Map<String, dynamic>>.from(_defaultNotifications);
  }

  static Future<void> _writeNotifications(
    List<Map<String, dynamic>> items,
  ) async {
    await _storage.write(key: _notificationKey, value: jsonEncode(items));
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    return _readNotifications();
  }

  static Future<List<Map<String, dynamic>>> getByType(String type) async {
    final items = await _readNotifications();
    return items.where((item) => item['type'] == type).toList();
  }

  static Future<void> markAsRead(String id) async {
    final items = await _readNotifications();
    for (final item in items) {
      if (item['id'].toString() == id) {
        item['read'] = true;
      }
    }
    await _writeNotifications(items);
    notificationVersion.value++;
  }

  static Future<void> addNotification({
    required String type,
    required String title,
    required String description,
  }) async {
    final items = await _readNotifications();
    items.insert(0, {
      'id': 'n_${DateTime.now().microsecondsSinceEpoch}',
      'type': type,
      'title': title,
      'description': description,
      'time': 'เมื่อสักครู่',
      'read': false,
      'iconName': 'notifications_none_rounded',
    });
    await _writeNotifications(items);
    notificationVersion.value++;
  }

  static Future<void> removeNotification(String id) async {
    final items = await _readNotifications();
    items.removeWhere((item) => item['id'].toString() == id);
    await _writeNotifications(items);
    notificationVersion.value++;
  }

  static Future<int> unreadCount() async {
    final items = await _readNotifications();
    return items.where((item) => item['read'] != true).length;
  }
}

class OrderStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _orderKey = 'mock_orders_v1';

  static dynamic _jsonSafe(dynamic value) {
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Map) {
      return value
          .map((key, item) => MapEntry(key.toString(), _jsonSafe(item)));
    }
    if (value is List) {
      return value.map(_jsonSafe).toList();
    }
    return value;
  }

  static final List<Map<String, dynamic>> _defaultOrders = [
    {
      'id': 'ord_1001',
      'orderNo': 'KM2608191001',
      'status': 'pendingPayment',
      'items': [
        {
          'id': 'p1',
          'name': 'ข้าวหอมมะลิใหม่ 100%',
          'image': 'assets/images/kaset/logo_kaset.png',
          'price': 320,
          'qty': 2,
          'shopName': 'ศูนย์ข้าวหอมมะลิ',
        },
        {
          'id': 'p2',
          'name': 'ปุ๋ยเคมีสูตร 15-15-15',
          'image': 'assets/images/kaset/category_fertilizer.png',
          'price': 240,
          'qty': 1,
          'shopName': 'ศูนย์ปุ๋ยและเคมีภัณฑ์',
        },
      ],
      'shopName': 'ศูนย์ข้าวหอมมะลิ',
      'subtotal': 880,
      'shippingFee': 30,
      'discount': 65,
      'grandTotal': 845,
      'couponName': 'ส่วนลดข้าวหอมมะลิ',
      'couponId': 'c1',
      'shippingMethod': 'จัดส่งมาตรฐาน',
      'paymentMethod': 'QR Code',
      'address': {
        'recipientName': 'สมชาย ใจดี',
        'phone': '0812345678',
        'houseNo': '99/12',
        'road': 'ถนนพหลโยธิน',
        'subDistrict': 'ลาดยาว',
        'district': 'จตุจักร',
        'province': 'กรุงเทพมหานคร',
        'postalCode': '10900',
        'note': 'ฝากไว้กับนิติฯ',
        'isDefault': true,
      },
      'createdAt': '2026-08-19T09:10:00.000',
      'paymentDeadline': '2026-08-19T09:40:00.000',
      'statusTimeline': [
        {'title': 'รอชำระเงิน', 'done': true},
        {'title': 'กำลังจัดเตรียม', 'done': false},
        {'title': 'กำลังจัดส่ง', 'done': false},
        {'title': 'สำเร็จ', 'done': false},
      ],
    },
    {
      'id': 'ord_1002',
      'orderNo': 'KM2608191002',
      'status': 'preparing',
      'items': [
        {
          'id': 'p3',
          'name': 'เมล็ดพันธุ์ผักบุ้งจีน',
          'image': 'assets/images/kaset/basket.png',
          'price': 35,
          'qty': 3,
          'shopName': 'แปลงผักเกษตร',
        },
      ],
      'shopName': 'แปลงผักเกษตร',
      'subtotal': 105,
      'shippingFee': 30,
      'discount': 0,
      'grandTotal': 135,
      'couponName': null,
      'couponId': null,
      'shippingMethod': 'จัดส่งมาตรฐาน',
      'paymentMethod': 'QR Code',
      'address': {
        'recipientName': 'สมชาย ใจดี',
        'phone': '0812345678',
        'houseNo': '99/12',
        'road': 'ถนนพหลโยธิน',
        'subDistrict': 'ลาดยาว',
        'district': 'จตุจักร',
        'province': 'กรุงเทพมหานคร',
        'postalCode': '10900',
        'note': 'โทรก่อนมาส่ง',
        'isDefault': true,
      },
      'createdAt': '2026-08-18T15:30:00.000',
      'paidAt': '2026-08-18T15:31:00.000',
      'preparedAt': null,
      'paymentDeadline': null,
      'statusTimeline': [
        {'title': 'รอชำระเงิน', 'done': true},
        {'title': 'กำลังจัดเตรียม', 'done': true},
        {'title': 'กำลังจัดส่ง', 'done': false},
        {'title': 'สำเร็จ', 'done': false},
      ],
    },
    {
      'id': 'ord_1003',
      'orderNo': 'KM2608191003',
      'status': 'shipping',
      'items': [
        {
          'id': 'p4',
          'name': 'เครื่องมือพ่นน้ำแรงดัน',
          'image': 'assets/images/kaset/tractor.png',
          'price': 650,
          'qty': 1,
          'shopName': 'อุปกรณ์เกษตร',
        },
      ],
      'shopName': 'อุปกรณ์เกษตร',
      'subtotal': 650,
      'shippingFee': 30,
      'discount': 0,
      'grandTotal': 680,
      'couponName': null,
      'couponId': null,
      'shippingMethod': 'จัดส่งด่วน',
      'paymentMethod': 'QR Code',
      'address': {
        'recipientName': 'สมชาย ใจดี',
        'phone': '0812345678',
        'houseNo': '99/12',
        'road': 'ถนนพหลโยธิน',
        'subDistrict': 'ลาดยาว',
        'district': 'จตุจักร',
        'province': 'กรุงเทพมหานคร',
        'postalCode': '10900',
        'note': 'โทรก่อนมาส่ง',
        'isDefault': true,
      },
      'createdAt': '2026-08-17T09:20:00.000',
      'paidAt': '2026-08-17T09:22:00.000',
      'preparedAt': '2026-08-17T14:00:00.000',
      'shippedAt': '2026-08-18T08:10:00.000',
      'trackingCode': 'TH2608190001',
      'destination_shipped_at': '2026-08-20',
      'statusTimeline': [
        {'title': 'รอชำระเงิน', 'done': true},
        {'title': 'กำลังจัดเตรียม', 'done': true},
        {'title': 'กำลังจัดส่ง', 'done': true},
        {'title': 'สำเร็จ', 'done': false},
      ],
    },
    {
      'id': 'ord_1004',
      'orderNo': 'KM2608191004',
      'status': 'completed',
      'items': [
        {
          'id': 'p5',
          'name': 'เมล็ดพันธุ์ถั่วฝักยาว',
          'image': 'assets/images/kaset/pet-bowl.png',
          'price': 40,
          'qty': 2,
          'shopName': 'แปลงผักเกษตร',
        },
      ],
      'shopName': 'แปลงผักเกษตร',
      'subtotal': 80,
      'shippingFee': 30,
      'discount': 0,
      'grandTotal': 110,
      'couponName': null,
      'couponId': null,
      'shippingMethod': 'จัดส่งมาตรฐาน',
      'paymentMethod': 'QR Code',
      'address': {
        'recipientName': 'สมชาย ใจดี',
        'phone': '0812345678',
        'houseNo': '99/12',
        'road': 'ถนนพหลโยธิน',
        'subDistrict': 'ลาดยาว',
        'district': 'จตุจักร',
        'province': 'กรุงเทพมหานคร',
        'postalCode': '10900',
        'note': '',
        'isDefault': true,
      },
      'createdAt': '2026-08-15T10:10:00.000',
      'paidAt': '2026-08-15T10:12:00.000',
      'preparedAt': '2026-08-16T08:30:00.000',
      'shippedAt': '2026-08-17T09:00:00.000',
      'completedAt': '2026-08-18T11:15:00.000',
      'statusTimeline': [
        {'title': 'รอชำระเงิน', 'done': true},
        {'title': 'กำลังจัดเตรียม', 'done': true},
        {'title': 'กำลังจัดส่ง', 'done': true},
        {'title': 'สำเร็จ', 'done': true},
      ],
    },
  ];

  static Future<List<Map<String, dynamic>>> _readOrders() async {
    final raw = await _storage.read(key: _orderKey);
    if (raw == null || raw.isEmpty) {
      return _defaultOrders
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.map((e) {
        final order = Map<String, dynamic>.from(e);
        final items = (order['items'] as List<dynamic>? ?? const [])
            .map((item) => OrderItemNormalizer.normalize(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
        return {
          ...order,
          'items': items,
          'shopName': (order['shopName'] ??
                  (items.isNotEmpty ? items.first['shopName'] : 'เกษตร Mall'))
              .toString(),
          'itemCount': items.fold<int>(
              0, (sum, item) => sum + (item['qty'] as int? ?? 1)),
        };
      }).toList();
    }
    return _defaultOrders
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<void> _writeOrders(List<Map<String, dynamic>> items) async {
    await _storage.write(
      key: _orderKey,
      value: jsonEncode(_jsonSafe(items)),
    );
  }

  static Map<String, dynamic> _cloneOrder(Map<String, dynamic> order) {
    final items = (order['items'] as List<dynamic>? ?? const [])
        .map((item) => OrderItemNormalizer.normalize(
            Map<String, dynamic>.from(item as Map)))
        .toList();
    return {
      ...order,
      'items': items,
      'shopName': (order['shopName'] ??
              (items.isNotEmpty ? items.first['shopName'] : 'เกษตร Mall'))
          .toString(),
      'itemCount': order['itemCount'] ??
          items.fold<int>(0, (sum, item) => sum + (item['qty'] as int? ?? 1)),
    };
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    return _readOrders();
  }

  static Future<Map<String, dynamic>?> getOrderById(String id) async {
    final items = await _readOrders();
    for (final item in items) {
      if (item['id'].toString() == id || item['orderNo'].toString() == id) {
        return _cloneOrder(item);
      }
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getOrdersByStatus(
      String status) async {
    final items = await _readOrders();
    return items
        .where((item) => item['status'].toString() == status)
        .map(_cloneOrder)
        .toList();
  }

  static Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> payload,
  ) async {
    final items = await _readOrders();
    final now = DateTime.now().toIso8601String();
    final id = payload['id']?.toString() ??
        'ord_${DateTime.now().microsecondsSinceEpoch}';
    final orderNo = payload['orderNo']?.toString() ??
        'KM${DateTime.now().millisecondsSinceEpoch}';
    final order = <String, dynamic>{
      'id': id,
      'orderNo': orderNo,
      'status': payload['status']?.toString() ?? 'pendingPayment',
      'items': (payload['items'] as List<dynamic>? ?? const [])
          .map((item) => OrderItemNormalizer.normalize(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      'subtotal': payload['subtotal'] ?? 0,
      'shippingFee': payload['shippingFee'] ?? 0,
      'discount': payload['discount'] ?? 0,
      'grandTotal': payload['grandTotal'] ?? 0,
      'couponId': payload['couponId'],
      'couponName': payload['couponName'],
      'shippingMethod': payload['shippingMethod'] ?? 'จัดส่งมาตรฐาน',
      'paymentMethod': payload['paymentMethod'] ?? 'QR Code',
      'shopName': payload['shopName'] ??
          ((payload['items'] as List<dynamic>? ?? const []).isNotEmpty
              ? OrderItemNormalizer.normalize(
                  Map<String, dynamic>.from(
                      (payload['items'] as List<dynamic>).first as Map),
                )['shopName']
              : 'เกษตร Mall'),
      'itemCount': (payload['items'] as List<dynamic>? ?? const []).fold<int>(
        0,
        (sum, item) =>
            sum +
            (OrderItemNormalizer.normalize(
                  Map<String, dynamic>.from(item as Map),
                )['qty'] as int? ??
                1),
      ),
      'address': payload['address'] == null
          ? null
          : Map<String, dynamic>.from(payload['address'] as Map),
      'createdAt': payload['createdAt'] ?? now,
      'paymentDeadline': payload['paymentDeadline'],
      'paidAt': payload['paidAt'],
      'preparedAt': payload['preparedAt'],
      'shippedAt': payload['shippedAt'],
      'completedAt': payload['completedAt'],
      'reviewedAt': payload['reviewedAt'],
      'statusTimeline': payload['statusTimeline'],
    };
    items.insert(0, order);
    await _writeOrders(items);
    return _cloneOrder(order);
  }

  static Future<Map<String, dynamic>> createOrderFromProduct(
    Map<String, dynamic> product, {
    int qty = 1,
    int shippingFee = 0,
    int discount = 0,
    String? couponId,
    String? couponName,
    String shippingMethod = 'จัดส่งมาตรฐาน',
    String paymentMethod = 'QR Code',
    Map<String, dynamic>? address,
    String? createdAt,
    String? paymentDeadline,
  }) async {
    final item = OrderItemNormalizer.normalize(product, defaultQty: qty);
    final subtotal =
        (item['price'] as int? ?? 0) * (item['qty'] as int? ?? qty);
    return createOrder({
      'status': 'pendingPayment',
      'items': [item],
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'discount': discount,
      'grandTotal': (subtotal + shippingFee - discount).clamp(0, 1 << 31),
      'couponId': couponId,
      'couponName': couponName,
      'shippingMethod': shippingMethod,
      'paymentMethod': paymentMethod,
      'shopName': item['shopName'],
      'address': address,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
      'paymentDeadline': paymentDeadline,
    });
  }

  static Future<Map<String, dynamic>> createOrderFromCartItems(
    List<dynamic> rawItems, {
    int shippingFee = 0,
    int discount = 0,
    String? couponId,
    String? couponName,
    String shippingMethod = 'จัดส่งมาตรฐาน',
    String paymentMethod = 'QR Code',
    Map<String, dynamic>? address,
    String? createdAt,
    String? paymentDeadline,
  }) async {
    final items = rawItems
        .map((item) => OrderItemNormalizer.normalize(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
    final subtotal = items.fold<int>(
      0,
      (sum, item) =>
          sum + ((item['price'] as int? ?? 0) * (item['qty'] as int? ?? 1)),
    );
    return createOrder({
      'status': 'pendingPayment',
      'items': items,
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'discount': discount,
      'grandTotal': (subtotal + shippingFee - discount).clamp(0, 1 << 31),
      'couponId': couponId,
      'couponName': couponName,
      'shippingMethod': shippingMethod,
      'paymentMethod': paymentMethod,
      'shopName': items.isNotEmpty ? items.first['shopName'] : 'เกษตร Mall',
      'address': address,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
      'paymentDeadline': paymentDeadline,
    });
  }

  static Future<void> updateOrderStatus(
    String id,
    String status, {
    String? paidAt,
    String? preparedAt,
    String? shippedAt,
    String? completedAt,
    String? reviewedAt,
  }) async {
    final items = await _readOrders();
    final index = items.indexWhere(
      (item) => item['id'].toString() == id || item['orderNo'].toString() == id,
    );
    if (index == -1) return;
    items[index]['status'] = status;
    if (paidAt != null) items[index]['paidAt'] = paidAt;
    if (preparedAt != null) items[index]['preparedAt'] = preparedAt;
    if (shippedAt != null) items[index]['shippedAt'] = shippedAt;
    if (completedAt != null) items[index]['completedAt'] = completedAt;
    if (reviewedAt != null) items[index]['reviewedAt'] = reviewedAt;
    await _writeOrders(items);
  }

  static Future<void> updateOrderReview(
    String id, {
    int? rating,
    String? comment,
    List<String>? images,
    String? reviewedAt,
  }) async {
    final items = await _readOrders();
    final index = items.indexWhere(
      (item) => item['id'].toString() == id || item['orderNo'].toString() == id,
    );
    if (index == -1) return;
    items[index]['review'] = {
      'rating': rating,
      'comment': comment,
      'images': images ?? const [],
      'reviewedAt': reviewedAt,
    };
    await _writeOrders(items);
  }

  static Future<void> resetOrders() async {
    await _writeOrders(
        _defaultOrders.map((item) => Map<String, dynamic>.from(item)).toList());
  }
}

class BenefitStore {
  static List<Map<String, dynamic>> get items {
    return CouponStore._coupons.map((coupon) {
      return {
        'id': coupon['id'],
        'title': coupon['title'] ?? coupon['name'] ?? '',
        'subtitle': coupon['subtitle'] ?? coupon['description'] ?? '',
        'description': coupon['description'] ?? '',
        'condition': coupon['condition'] ?? 'ใช้ได้กับสินค้าที่ร่วมรายการ',
        'period': coupon['period'] ?? coupon['expiry'] ?? '',
        'image': coupon['image'] ?? '',
        'tag': coupon['tag'] ?? 'สิทธิประโยชน์',
        'discount': coupon['discount'] ?? '',
        'discountType': coupon['discountType'] ?? '',
        'discountValue': coupon['discountValue'] ?? 0,
        'minimumOrderTotal': coupon['minimumOrderTotal'] ?? 0,
        'eligibleKeywords': coupon['eligibleKeywords'] ?? const [],
        'canSave': coupon['canSave'] ?? true,
        'canRedeem': coupon['canRedeem'] ?? true,
      };
    }).toList(growable: false);
  }
}
