import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FarmerCampaignStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _profileKey = 'mock_farmer_profile_v1';
  static const String _campaignStateKey = 'mock_farmer_campaign_state_v1';

  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static const Map<String, dynamic> campaign = {
    'id': 'farmer_profile_update_2026',
    'title': 'รับปุ๋ยฟรี 1 กระสอบ/ไร่ สูงสุด 10 กระสอบ',
    'description': 'ยืนยันรับสิทธิ์',
    'status': 'active',
    'reward': {
      'id': 'free_fertilizer_by_area',
      'title': 'รับปุ๋ยฟรี',
      'quantity': '0 กระสอบ',
      'description': 'รับปุ๋ยฟรี 1 กระสอบ/ไร่ สูงสุด 10 กระสอบ',
      'maxBags': 10,
    },
  };

  static const List<Map<String, String>> agricultureTypes = [
    {'id': 'rice', 'label': 'ทำนา', 'icon': '🌾'},
    {'id': 'orchard', 'label': 'ทำสวน', 'icon': '🌳'},
    {'id': 'field_crop', 'label': 'ทำไร่', 'icon': '🌱'},
    {'id': 'vegetable', 'label': 'ปลูกผัก', 'icon': '🥬'},
    {'id': 'livestock', 'label': 'ปศุสัตว์', 'icon': '🐄'},
    {'id': 'fishery', 'label': 'ประมง', 'icon': '🐟'},
    {'id': 'other', 'label': 'อื่น ๆ', 'icon': '•••'},
  ];

  static const Map<String, List<Map<String, String>>> primaryProducts = {
    'rice': [
      {'id': 'jasmine_rice', 'label': 'ข้าวหอมมะลิ'},
      {'id': 'sticky_rice', 'label': 'ข้าวเหนียว'},
      {'id': 'white_rice', 'label': 'ข้าวเจ้า'},
      {'id': 'commercial_rice', 'label': 'ข้าวเพื่อการค้า'},
      {'id': 'other', 'label': 'อื่น ๆ'},
    ],
    'orchard': [
      {'id': 'durian', 'label': 'ทุเรียน'},
      {'id': 'mango', 'label': 'มะม่วง'},
      {'id': 'longan', 'label': 'ลำไย'},
      {'id': 'coconut', 'label': 'มะพร้าว'},
      {'id': 'rubber', 'label': 'ยางพารา'},
      {'id': 'oil_palm', 'label': 'ปาล์มน้ำมัน'},
      {'id': 'other', 'label': 'อื่น ๆ'},
    ],
    'field_crop': [
      {'id': 'sugarcane', 'label': 'อ้อย'},
      {'id': 'cassava', 'label': 'มันสำปะหลัง'},
      {'id': 'corn', 'label': 'ข้าวโพด'},
      {'id': 'pineapple', 'label': 'สับปะรด'},
      {'id': 'beans', 'label': 'ถั่ว'},
      {'id': 'other', 'label': 'อื่น ๆ'},
    ],
    'vegetable': [
      {'id': 'leafy', 'label': 'ผักใบ'},
      {'id': 'chili', 'label': 'พริก'},
      {'id': 'eggplant', 'label': 'มะเขือ'},
      {'id': 'melon_family', 'label': 'แตง'},
      {'id': 'herb', 'label': 'สมุนไพร'},
      {'id': 'other', 'label': 'อื่น ๆ'},
    ],
    'livestock': [
      {'id': 'cattle', 'label': 'โค'},
      {'id': 'buffalo', 'label': 'กระบือ'},
      {'id': 'pig', 'label': 'สุกร'},
      {'id': 'chicken', 'label': 'ไก่'},
      {'id': 'duck', 'label': 'เป็ด'},
      {'id': 'other', 'label': 'อื่น ๆ'},
    ],
    'fishery': [
      {'id': 'fish', 'label': 'ปลา'},
      {'id': 'shrimp', 'label': 'กุ้ง'},
      {'id': 'crab', 'label': 'ปู'},
      {'id': 'other_aquatic', 'label': 'สัตว์น้ำอื่น ๆ'},
    ],
    'other': [
      {'id': 'mixed', 'label': 'เกษตรผสมผสาน'},
      {'id': 'other', 'label': 'อื่น ๆ'},
    ],
  };

  static const List<Map<String, String>> areaRanges = [
    {'id': 'under_5', 'label': 'น้อยกว่า 5 ไร่'},
    {'id': '5_10', 'label': '5–10 ไร่'},
    {'id': '11_20', 'label': '11–20 ไร่'},
    {'id': '21_50', 'label': '21–50 ไร่'},
    {'id': 'over_50', 'label': 'มากกว่า 50 ไร่'},
  ];

  static const List<Map<String, String>> productionTrends = [
    {'id': 'improved', 'label': 'ดีขึ้น', 'icon': '📈'},
    {'id': 'same', 'label': 'ใกล้เคียงเดิม', 'icon': '➖'},
    {'id': 'declined', 'label': 'ลดลง', 'icon': '📉'},
  ];

  static const Map<String, List<Map<String, String>>> productionReasons = {
    'improved': [
      {'id': 'better_soil', 'label': 'ดินดีขึ้น', 'icon': '🌱'},
      {'id': 'enough_water', 'label': 'น้ำเพียงพอ', 'icon': '💧'},
      {'id': 'suitable_fertilizer', 'label': 'ใช้ปุ๋ยเหมาะสม', 'icon': '🧪'},
      {'id': 'good_weather', 'label': 'สภาพอากาศดี', 'icon': '🌤️'},
      {'id': 'fewer_pests', 'label': 'โรคและศัตรูพืชลดลง', 'icon': '🐛'},
      {'id': 'better_method', 'label': 'ปรับวิธีการเพาะปลูก', 'icon': '⚙️'},
      {'id': 'other', 'label': 'อื่น ๆ', 'icon': '•••'},
    ],
    'declined': [
      {'id': 'not_enough_water', 'label': 'น้ำไม่เพียงพอ', 'icon': '💧'},
      {'id': 'soil_problem', 'label': 'ปัญหาดิน', 'icon': '🌱'},
      {'id': 'pests', 'label': 'โรคและศัตรูพืช', 'icon': '🐛'},
      {'id': 'weather', 'label': 'สภาพอากาศ', 'icon': '🌦️'},
      {
        'id': 'low_nutrients',
        'label': 'ปุ๋ย/ธาตุอาหารไม่เพียงพอ',
        'icon': '🧪'
      },
      {'id': 'high_cost', 'label': 'ต้นทุนการผลิตสูง', 'icon': '💰'},
      {'id': 'other', 'label': 'อื่น ๆ', 'icon': '•••'},
    ],
  };

  static Future<Map<String, dynamic>> getState() async {
    final raw = await _storage.read(key: _campaignStateKey);
    if (raw == null || raw.isEmpty) {
      return {'completed': false, 'claimedReward': false};
    }
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  static Future<Map<String, dynamic>?> getFarmerProfile() async {
    final raw = await _storage.read(key: _profileKey);
    if (raw == null || raw.isEmpty) return null;
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  static Future<void> submit(Map<String, dynamic> farmerProfile) async {
    final currentState = await getState();

    final now = DateTime.now().toIso8601String();
    final areaRai = parseAreaRai(farmerProfile['areaSize']);
    final reward = rewardForArea(areaRai);
    final profile = <String, dynamic>{
      ...farmerProfile,
      'areaSize': areaRai.toString(),
      'updatedAt': now,
    };
    final state = <String, dynamic>{
      'campaignId': campaign['id'],
      'completed': true,
      'claimedReward': true,
      'submittedAt': now,
      'claimedAt': currentState['claimedAt'] ?? now,
      'reward': reward,
    };

    await _storage.write(key: _profileKey, value: jsonEncode(profile));
    await _storage.write(key: _campaignStateKey, value: jsonEncode(state));
    version.value++;
  }

  static Future<void> reset() async {
    await _storage.delete(key: _profileKey);
    await _storage.delete(key: _campaignStateKey);
    version.value++;
  }

  static int parseAreaRai(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    return int.tryParse(raw) ?? 0;
  }

  static Map<String, dynamic> rewardForArea(int areaRai) {
    final reward = Map<String, dynamic>.from(campaign['reward'] as Map);
    final maxBags = reward['maxBags'] as int? ?? 10;
    final bagCount = areaRai <= 0 ? 0 : areaRai.clamp(1, maxBags).toInt();
    return <String, dynamic>{
      ...reward,
      'title': 'รับปุ๋ยฟรี',
      'quantity': '$bagCount กระสอบ',
      'bagCount': bagCount,
      'areaRai': areaRai,
      'condition': 'รับปุ๋ยฟรี 1 กระสอบ/ไร่ สูงสุด $maxBags กระสอบ',
      'description': areaRai > 0
          ? 'คำนวณจากพื้นที่ที่ลงทะเบียนไว้ $areaRai ไร่'
          : 'คำนวณสิทธิ์ตามพื้นที่ที่ลงทะเบียน',
    };
  }

  static String labelOf(List<Map<String, String>> items, String? id) {
    for (final item in items) {
      if (item['id'] == id) return item['label'] ?? '';
    }
    return '';
  }
}
