// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/cart.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/component/material/loading_tween.dart';
import 'package:kasetmall/product_from.dart';
import 'package:kasetmall/search.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/shared/extension.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'login.dart';

class ProductAllCentralPage extends StatefulWidget {
  ProductAllCentralPage(
      {Key? key,
      @required this.title,
      required this.mode,
      required this.typeelect})
      : super(key: key);
  final String? title;
  late bool mode;
  final String typeelect;
  @override
  State<ProductAllCentralPage> createState() => _ProductAllCentralPageState();
}

class _ProductAllCentralPageState extends State<ProductAllCentralPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final storage = new FlutterSecureStorage();
  Future<dynamic>? _futureModel;
  List<dynamic> _listModelMore = [];
  RefreshController? _refreshController;
  TextEditingController? _searchController;
  TextEditingController txtPriceMin = TextEditingController();
  TextEditingController txtPriceMax = TextEditingController();
  String _filterSelected = '0';
  int _limit = 20;
  bool changeToListView = false;
  int amountItemInCart = 0;
  String profileCode = "";
  String verifyPhonePage = '';
  String orderKey = '';
  bool changOrderKey = false;
  String orderBy = '';
  String filterType = '';
  int page = 1;
  int total_page = 0;
  bool loadProduct = true;
  String? emailProfile;

  @override
  void initState() {
    _refreshController = new RefreshController();
    _searchController = TextEditingController();
    _getCountItemInCart();
    _callRead();
    txtPriceMin.text = '';
    txtPriceMax.text = '';
    super.initState();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    _refreshController?.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> mockProductList = [
    // พรรณพืช
    {
      'id': 1,
      'name': 'เมล็ดพันธุ์ข้าวหอมมะลิ 105',
      'type': '1',
      'price': 120.0,
      'description':
          'เมล็ดพันธุ์ข้าวหอมมะลิคุณภาพดี ให้ผลผลิตสูง เหมาะกับการปลูกในทุกภาคของประเทศไทย',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254112971.png',
      'stock': 10,
    },
    {
      'id': 6,
      'name': 'เมล็ดพันธุ์ผักบุ้งจีน',
      'type': '1',
      'price': 35.0,
      'description':
          'เมล็ดพันธุ์ผักบุ้งจีน ปลูกง่าย โตเร็ว เหมาะสำหรับปลูกในฤดูฝน',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254112971.png',
      'stock': 50,
    },
    {
      'id': 7,
      'name': 'เมล็ดพันธุ์ถั่วฝักยาว',
      'type': '1',
      'price': 40.0,
      'description': 'เมล็ดถั่วฝักยาวพันธุ์ดี ให้ผลผลิตสูง ทนโรคและแมลง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254112971.png',
      'stock': 30,
    },
    {
      'id': 8,
      'name': 'เมล็ดพันธุ์มะเขือเทศ',
      'type': '1',
      'price': 50.0,
      'description': 'มะเขือเทศพันธุ์คุณภาพ ให้ผลผลิตลูกใหญ่ สีแดงสด',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254112971.png',
      'stock': 25,
    },
    {
      'id': 9,
      'name': 'เมล็ดพันธุ์ข้าวโพดหวาน',
      'type': '1',
      'price': 60.0,
      'description': 'ข้าวโพดหวานพันธุ์ดี รสหวาน ปลูกง่าย ผลผลิตสูง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254112971.png',
      'stock': 40,
    },

    // เครื่องมือ
    {
      'id': 2,
      'name': 'เครื่องพ่นยาแบตเตอรี่ 20 ลิตร',
      'type': '2',
      'price': 890.0,
      'description':
          'เครื่องพ่นยาคุณภาพสูง ทำงานด้วยระบบไฟฟ้าแบตเตอรี่ ใช้งานต่อเนื่องได้ยาวนาน เหมาะกับการฉีดพ่นปุ๋ยหรือยาฆ่าแมลง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254704897.png',
      'stock': 10,
    },
    {
      'id': 10,
      'name': 'กรรไกรตัดแต่งกิ่ง',
      'type': '2',
      'price': 150.0,
      'description': 'กรรไกรคุณภาพสูง ตัดแต่งกิ่งไม้และพืชสวนได้สะดวก',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255345172.png',
      'stock': 20,
    },
    // {
    //   'id': 11,
    //   'name': 'จอบขุดดิน',
    //   'type': '2',
    //   'price': 200.0,
    //   'description': 'จอบขุดดินคุณภาพ แข็งแรง ใช้งานได้นาน',
    //   'image':
    //       'https://www.sprayerthai.com/wp-content/uploads/2021/07/shovel.jpg',
    //   'stock': 15,
    // },
    // {
    //   'id': 12,
    //   'name': 'สายยางรดน้ำ 20 ม.',
    //   'type': '2',
    //   'price': 350.0,
    //   'description': 'สายยางคุณภาพสูง ยาว 20 เมตร เหมาะสำหรับรดน้ำสวน',
    //   'image':
    //       'https://www.sprayerthai.com/wp-content/uploads/2021/07/hose.jpg',
    //   'stock': 30,
    // },
    {
      'id': 13,
      'name': 'เครื่องตัดหญ้าไฟฟ้า',
      'type': '2',
      'price': 2500.0,
      'description': 'เครื่องตัดหญ้าไฟฟ้า ประสิทธิภาพสูง ใช้งานง่าย',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255345172.png',
      'stock': 5,
    },

    // อาหารสัตว์
    {
      'id': 3,
      'name': 'อาหารไก่เนื้อเบอร์ 910',
      'type': '3',
      'price': 250.0,
      'description':
          'อาหารชนิดเม็ด สำหรับไก่เล็กถึงอายุ 3 สัปดาห์ มีโปรตีนคุณภาพสูง เหมาะสำหรับฟาร์มไก่เนื้อ',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254715516.png',
      'stock': 10,
    },
    {
      'id': 14,
      'name': 'อาหารหมูลูกพันธุ์ 101',
      'type': '3',
      'price': 300.0,
      'description': 'อาหารหมูลูกพันธุ์ สำหรับลูกหมูอายุ 0-8 สัปดาห์ โปรตีนสูง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254715516.png',
      'stock': 20,
    },
    {
      'id': 15,
      'name': 'อาหารปลานิล',
      'type': '3',
      'price': 220.0,
      'description': 'อาหารปลานิลเม็ดคุณภาพดี ช่วยเร่งการเจริญเติบโตของปลา',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254715516.png',
      'stock': 25,
    },
    {
      'id': 16,
      'name': 'อาหารวัวกระทิง',
      'type': '3',
      'price': 400.0,
      'description': 'อาหารวัวชนิดเม็ด เสริมโปรตีนและแร่ธาตุสำหรับวัวเนื้อ',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254715516.png',
      'stock': 15,
    },
    {
      'id': 17,
      'name': 'อาหารไก่ไข่เบอร์ 210',
      'type': '3',
      'price': 280.0,
      'description': 'อาหารไก่ไข่ เสริมโปรตีนและแคลเซียม ให้ไข่มีคุณภาพ',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254715516.png',
      'stock': 20,
    },

    // เคมีภัณฑ์
    {
      'id': 4,
      'name': 'ปุ๋ยเคมีสูตร 15-15-15',
      'type': '4',
      'price': 450.0,
      'description':
          'ปุ๋ยเคมีสูตรมาตรฐาน เหมาะสำหรับพืชสวนและพืชไร่ ให้ธาตุอาหารครบถ้วนสำหรับการเจริญเติบโต',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255709298.png',
      'stock': 10,
    },
    {
      'id': 5,
      'name': 'ยาฆ่าแมลงตราช้างแดง',
      'type': '4',
      'price': 195.0,
      'description':
          'ยาฆ่าแมลงประสิทธิภาพสูง ปลอดภัยเมื่อใช้ตามคำแนะนำ เหมาะสำหรับพืชสวน พืชไร่ และไม้ดอก',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255709298.png',
      'stock': 0,
    },
    {
      'id': 18,
      'name': 'ปุ๋ยยูเรียเม็ด',
      'type': '4',
      'price': 220.0,
      'description': 'ปุ๋ยยูเรียเสริมไนโตรเจน สำหรับพืชผลผลิตสูง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255709298.png',
      'stock': 30,
    },
    {
      'id': 19,
      'name': 'ยาฆ่าแมลงกำจัดเพลี้ย',
      'type': '4',
      'price': 180.0,
      'description': 'ยาฆ่าแมลงสูตรเข้มข้น กำจัดเพลี้ยและแมลงศัตรูพืชได้ดี',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255709298.png',
      'stock': 20,
    },
    {
      'id': 20,
      'name': 'ปุ๋ยสูตรฟอสฟอรัสสูง',
      'type': '4',
      'price': 350.0,
      'description': 'ปุ๋ยฟอสฟอรัสสูง เพิ่มการเจริญเติบโตของรากพืช',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255709298.png',
      'stock': 25,
    },
    {
      'id': 21,
      'name': 'สารปรับสภาพดิน',
      'type': '4',
      'price': 300.0,
      'description':
          'สารปรับสภาพดิน ช่วยให้ดินร่วนซุย เพิ่มประสิทธิภาพการใช้ปุ๋ย',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255709298.png',
      'stock': 15,
    },

    // ========= 🚜 สินค้าใหม่ที่เด่น ๆ =========
    {
      'id': 22,
      'name': 'โดรนพ่นยาเกษตร DJI Agras T40',
      'type': '2', // จัดเป็นอุปกรณ์เครื่องมือ
      'price': 580000.0,
      'description':
          'โดรนพ่นยา/ปุ๋ย รุ่นล่าสุด DJI Agras T40 ความจุถัง 40 ลิตร พ่นได้รวดเร็ว ประหยัดแรงงาน เหมาะกับไร่ข้าวโพด นาข้าว และพืชเศรษฐกิจ',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_252119760.png',
      'stock': 2,
    },
    {
      'id': 23,
      'name': 'รถไถเดินตาม Kubota รุ่น RT140',
      'type': '2',
      'price': 120000.0,
      'description':
          'รถไถเดินตามขนาดกลาง ใช้งานง่าย เหมาะกับเกษตรกรรายย่อย สามารถติดตั้งอุปกรณ์เสริมได้หลายชนิด',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255759883.png',
      'stock': 3,
    },
    {
      'id': 24,
      'name': 'รถแทรกเตอร์ Kubota MU5501',
      'type': '2',
      'price': 750000.0,
      'description':
          'แทรกเตอร์ขนาดใหญ่ 55 แรงม้า เหมาะสำหรับการเพาะปลูกขนาดกลางถึงใหญ่ รองรับงานไถ พรวน ยกร่อง และลากพ่วง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_250611616.png',
      'stock': 5,
    },
    {
      'id': 25,
      'name': 'ปุ๋ยอินทรีย์ชีวภาพ Premium',
      'type': '4',
      'price': 500.0,
      'description':
          'ปุ๋ยอินทรีย์ผสมจุลินทรีย์ธรรมชาติ เพิ่มความสมบูรณ์ของดิน กระตุ้นการเจริญเติบโตของพืชแบบยั่งยืน',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255709298.png',
      'stock': 50,
    },
    {
      'id': 26,
      'name': 'ระบบ Smart Sensor เกษตร IoT',
      'type': '2',
      'price': 25000.0,
      'description':
          'เซ็นเซอร์ IoT ตรวจวัดความชื้นในดิน อุณหภูมิ และค่า pH ส่งข้อมูลผ่านแอปมือถือ ช่วยเกษตรกรวิเคราะห์และจัดการแปลงเพาะปลูก',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_250621859.png',
      'stock': 10,
    },
    // {
    //   'id': 27,
    //   'name': 'เครื่องเก็บเกี่ยวข้าว Combine Harvester',
    //   'type': '2',
    //   'price': 950000.0,
    //   'description':
    //       'เครื่องเก็บเกี่ยวข้าวอัตโนมัติ ทำงานได้รวดเร็ว ลดแรงงาน ประหยัดเวลา เหมาะกับไร่นาขนาดใหญ่',
    //   'image': 'https://www.agriculture.com/images/harvester.png',
    //   'stock': 2,
    // },
    {
      'id': 28,
      'name': 'ระบบน้ำหยดอัตโนมัติ Smart Drip',
      'type': '2',
      'price': 18000.0,
      'description':
          'ระบบน้ำหยดควบคุมด้วยมือถือ ตั้งเวลาอัตโนมัติ ประหยัดน้ำ เหมาะสำหรับสวนผลไม้และแปลงผัก',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_251239328.png',
      'stock': 8,
    },
    {
      'id': 29,
      'name': 'โรงเรือนอัจฉริยะ Smart Greenhouse',
      'type': '2',
      'price': 350000.0,
      'description':
          'โรงเรือนสำเร็จรูปพร้อมระบบควบคุมอุณหภูมิ ความชื้น และการให้น้ำอัตโนมัติ ผ่านแอปมือถือ',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_253545227.png',
      'stock': 1,
    },
    {
      'id': 30,
      'name': 'โดรนสำรวจพื้นที่การเกษตร Mavic Agro',
      'type': '2',
      'price': 250000.0,
      'description':
          'โดรนสำรวจไร่นา พร้อมกล้องความละเอียดสูงและเซ็นเซอร์ NDVI สำหรับวิเคราะห์สุขภาพพืช',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_252540513.png',
      'stock': 3,
    },
    // {
    //   'id': 31,
    //   'name': 'ปุ๋ยชีวภาพเสริมจุลินทรีย์',
    //   'type': '4',
    //   'price': 380.0,
    //   'description':
    //       'ปุ๋ยชีวภาพพิเศษเสริมจุลินทรีย์ละลายฟอสเฟต เพิ่มธาตุอาหารให้ดินและลดการใช้สารเคมี',
    //   'image': 'https://www.organicfertilizer.com/images/biofert.png',
    //   'stock': 40,
    // },
    {
      'id': 32,
      'name': 'รถไถเล็กอเนกประสงค์ Mini Tractor',
      'type': '2',
      'price': 185000.0,
      'description':
          'รถไถเล็กสำหรับสวนผลไม้ ใช้งานคล่องตัว ประหยัดน้ำมัน เหมาะกับพื้นที่ขนาดเล็กถึงกลาง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_250611616.png',
      'stock': 6,
    },
    {
      'id': 33,
      'name': 'เครื่องเพาะกล้าอัตโนมัติ',
      'type': '2',
      'price': 45000.0,
      'description':
          'เครื่องเพาะกล้ารุ่นใหม่ สามารถหยอดเมล็ด รดน้ำ และควบคุมสภาพแวดล้อมได้อัตโนมัติ',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_253640982.png',
      'stock': 4,
    },
    // {
    //   'id': 34,
    //   'name': 'สารชีวภัณฑ์กำจัดหนอนกอข้าว',
    //   'type': '4',
    //   'price': 250.0,
    //   'description':
    //       'สารชีวภัณฑ์จากแบคทีเรีย Bacillus thuringiensis (BT) ใช้กำจัดหนอนศัตรูพืชโดยไม่กระทบสิ่งแวดล้อม',
    //   'image': 'https://www.bioagro.com/images/bt-bio.png',
    //   'stock': 25,
    // },
    {
      'id': 35,
      'name': 'เครื่องคัดแยกเมล็ดพันธุ์อัตโนมัติ',
      'type': '2',
      'price': 65000.0,
      'description':
          'เครื่องคัดแยกเมล็ดพันธุ์ตามขนาดและน้ำหนัก ลดแรงงาน เพิ่มคุณภาพเมล็ดพันธุ์',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254142264.png',
      'stock': 7,
    },
    {
      'id': 36,
      'name': 'เครื่องอบข้าวโพดพลังงานแสงอาทิตย์',
      'type': '2',
      'price': 98000.0,
      'description':
          'เครื่องอบเมล็ดข้าวโพดด้วยพลังงานแสงอาทิตย์ ลดต้นทุนค่าไฟฟ้าและเป็นมิตรต่อสิ่งแวดล้อม',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_253640982.png',
      'stock': 3,
    },
    {
      'id': 37,
      'name': 'เครื่องบรรจุเมล็ดพืชอัตโนมัติ',
      'type': '2',
      'price': 120000.0,
      'description':
          'เครื่องบรรจุเมล็ดหรือธัญพืชลงถุงแบบอัตโนมัติ ปรับขนาดบรรจุได้ ประหยัดแรงงานและเวลา',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_253229765.png',
      'stock': 4,
    },
    {
      'id': 38,
      'name': 'ระบบพลังงานแสงอาทิตย์สำหรับเกษตร',
      'type': '2',
      'price': 150000.0,
      'description':
          'แผงโซลาร์เซ็ตพร้อมระบบแบตเตอรี่ สำหรับปั๊มน้ำและระบบชลประทานในไร่นา',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_252146409.png',
      'stock': 5,
    },
    {
      'id': 39,
      'name': 'เครื่องย่อยเศษพืช',
      'type': '2',
      'price': 32000.0,
      'description':
          'เครื่องย่อยเศษพืชหลังการเก็บเกี่ยว เปลี่ยนเป็นปุ๋ยหมักหรือนำกลับใช้ในไร่นา',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_252653005.png',
      'stock': 10,
    },
    {
      'id': 40,
      'name': 'หุ่นยนต์เก็บผลไม้ Smart Picker',
      'type': '2',
      'price': 480000.0,
      'description':
          'หุ่นยนต์เก็บผลไม้ เช่น มะม่วง ทุเรียน มะเขือเทศ ลดแรงงานและความเสียหายของผลผลิต',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_251733990.png',
      'stock': 2,
    },
  ];

  _callRead() async {
    // dashboard/readTop20
    // postProductData(
    //       server_we_build + 'dashboard/readTop20',
    //       {"per_page": "${_limit.toString()}"}).then((value) => {
    //         print('value >>> ${value}'),
    //       });

    // profileCode = await storage.read(key: 'profileCode10');
    // dynamic valueStorage = await storage.read(key: 'dataUserLoginDDPM');
    // dynamic dataValue = valueStorage == null ? {'email': ''} : json.decode(valueStorage);

    setState(() {
      loadProduct = true;

      // emailProfile = dataValue['email'].toString() ?? "";
      // _futureModel = getData(server + 'products?per_page=' + _limit.toString());
      _filterSelected = widget.typeelect;
      if (_filterSelected == '0') {
        setState(() {
          _listModelMore = [...mockProductList];
          loadProduct = _listModelMore.isNotEmpty;
        });
      } else {
        if (_filterSelected != '0') {
          _applyFilter();
        }
      }
      // else {
      // _futureModel =
      //     postProductData(server_we_build + 'm/Product/readProduct', {});
      // _futureModel!.then((value) async => {
      //       setState(() {
      //         total_page = value[0]['total_pages'];
      //         _listModelMore = [...value];
      //         _listModelMore.length == 0 ? loadProduct = false : true;
      //         print('total_page ========== ${total_page}');
      //       })
      //     });
    }

        // Timer(
        //   Duration(seconds: 1),
        //   () => {
        //     setState(
        //       () {
        //         _listModelMore.length == 0 ? loadProduct = false : true;
        //       },
        //     ),
        //   },
        // );
        // }
        );
  }

  _applyFilter() {
    setState(() {
      loadProduct = true;

      // เริ่มต้นจากข้อมูลทั้งหมด
      List<dynamic> filteredList = [...mockProductList];

      // กรองตาม type
      if (_filterSelected != '0') {
        filteredList = filteredList
            .where((item) => item['type'] == _filterSelected)
            .toList();
      } else {
        filteredList = [...mockProductList];
      }

      // กรองตามราคา (ถ้ามี)
      if (txtPriceMin.text.isNotEmpty) {
        double minPrice = double.tryParse(txtPriceMin.text) ?? 0;
        filteredList = filteredList
            .where((item) => (item['price'] as num) >= minPrice)
            .toList();
      }

      if (txtPriceMax.text.isNotEmpty) {
        double maxPrice = double.tryParse(txtPriceMax.text) ?? double.infinity;
        filteredList = filteredList
            .where((item) => (item['price'] as num) <= maxPrice)
            .toList();
      }

      // เรียงลำดับข้อมูล
      if (orderKey == 'min_price') {
        // เรียงราคาน้อย -> มาก
        filteredList
            .sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
      } else if (orderKey == 'max_price') {
        // เรียงราคามาก -> น้อย
        filteredList
            .sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
      } else if (orderKey == 'name') {
        if (orderBy == 'asc') {
          // เรียง ก-ฮ หรือ a-z
          filteredList.sort(
              (a, b) => (a['name'] as String).compareTo(b['name'] as String));
        } else if (orderBy == 'desc') {
          // เรียง ฮ-ก หรือ z-a
          filteredList.sort(
              (a, b) => (b['name'] as String).compareTo(a['name'] as String));
        }
      }

      _listModelMore = filteredList;
      loadProduct = _listModelMore.isNotEmpty;
    });
  }

  _hotSale() {
    _applyFilter();
  }

  void _onRefresh() async {
    setState(() {
      _limit = 20;
      orderKey = '';
      orderBy = '';
      txtPriceMin.text = '';
      txtPriceMax.text = '';
      loadProduct = true;
      _listModelMore = [];
      _futureModel = null;
    });

    // เรียกใช้ตามประเภทที่เลือก
    // if (_filterSelected == '0') {
    //   _callRead();
    // } else {
    _applyFilter();
    // }

    _getCountItemInCart();
    _refreshController?.refreshCompleted();
  }

  // _hotSale() {
  //   setState(() {
  //     loadProduct = true;
  //     _limit = 20;
  //     orderKey = '';
  //     orderBy = '';
  //     txtPriceMin.text = '';
  //     txtPriceMax.text = '';
  //     loadProduct = true;
  //     _listModelMore = [];
  //     _futureModel = [...mockProductList] as Future?;

  //     _futureModel!.then((value) async {
  //       setState(() {
  //         // ดึงข้อมูลทั้งหมดก่อน
  //         _listModelMore = [...value];

  //         // 🔹 กรองข้อมูลตาม _filterSelected
  //         if (_filterSelected != null &&
  //             _filterSelected.toString().isNotEmpty) {
  //           _listModelMore = _listModelMore
  //               .where((item) =>
  //                   item['category'] ==
  //                       _filterSelected || // ตัวอย่างเงื่อนไขที่ใช้เทียบ
  //                   item['type'] == _filterSelected)
  //               .toList();
  //         }

  //         // สุ่มข้อมูล
  //         _listModelMore.shuffle();

  //         // ตรวจสอบว่ามีข้อมูลหรือไม่
  //         loadProduct = _listModelMore.isNotEmpty;
  //       });
  //     });
  //     // _futureModel = getData(server + 'products?per_page=' + _limit.toString());
  //     // _futureModel = postProductHotSale(
  //     //     // server_we_build + 'm/Product/readProduct',
  //     //     server_we_build + 'm/Product/readProductHot',
  //     //     // {"per_page": "${_limit.toString()}"}
  //     //     {});

  //     // _futureModel!.then((value) async => {
  //     //       setState(() {
  //     //         // total_page = value[0]['total_pages'];
  //     //         _listModelMore = [...value];
  //     //         _listModelMore.shuffle();
  //     //         _listModelMore.length == 0 ? loadProduct = false : true;
  //     //       })
  //     //     });
  //     // Timer(
  //     //   Duration(seconds: 1),
  //     //   () => {
  //     //     setState(
  //     //       () {
  //     //         _listModelMore.length == 0 ? loadProduct = false : true;
  //     //       },
  //     //     ),
  //     //   },
  //     // );
  //   });
  // }

  _getCountItemInCart() async {
    //get amount item in cart.
    await get(server + 'carts').then((value) async {
      if (value != null)
        setState(() {
          amountItemInCart = value.length;
        });
    });
  }

  // business logic.
  // void _onRefresh() async {
  //   setState(() {
  //     _limit = 20;
  //     orderKey = '';
  //     orderBy = '';
  //     txtPriceMin.text = '';
  //     txtPriceMax.text = '';
  //     loadProduct = true;
  //     _listModelMore = [];
  //     _futureModel = null;
  //   });
  //   _filterSelected == '0' ? _callRead() : _hotSale;
  //   _getCountItemInCart();
  //   _refreshController?.refreshCompleted();
  // }

  void _onLoading() async {
    setState(() {
      // loadProduct = true;
      if (widget.mode) {
        // _listModelMore = [];
        // _futureModel = postProductHotSale(
        //   server_we_build + 'm/Product/readProductHot',
        //   {
        //     // "per_page": "$_limit",
        //     "order_key": "$orderKey",
        //     "order_by": "$orderBy",
        //     "min_price": "${txtPriceMin.text}",
        //     "max_price": "${txtPriceMax.text}",
        //     // "page": "$page",
        //   },
        // );

        // _futureModel.then((value) async => {
        //       await setState(() {
        //         // total_page = value[0]['total_pages'],
        //         // _listModelMore = [..._listModelMore, ...value],
        //         _listModelMore = [...value];
        //         _filterSelected == 'ทั้งหมด'
        //             ? null
        //             : _listModelMore.shuffle();
        //         _listModelMore.length == 0 ? loadProduct = false : true;
        //       })
        //     });
      } else {
        // if (_listModelMore.length < 20) {
        if (page < total_page) {
          page += 1;
          if (changOrderKey) {
            _listModelMore = [];
            page = 0;
            // itemProductCount = 0;
          }
          // print('mode ========== ${page}');
          //      _futureModel = getData(server +
          // 'products?per_page=' +
          // _limit.toString() +
          // '&order_key=' +
          // (orderKey ?? '') +
          // '&order_by=' +
          // (orderBy ?? '') +
          // '&min_price=' +
          // (txtPriceMin.text ?? '0') +
          // '&max_price=' +
          // (txtPriceMax.text ?? '0') +
          // '&page=' +
          // page.toString());

          _futureModel = postProductData(
            server_we_build + 'm/Product/readProduct',
            {
              "per_page": "$_limit",
              "order_key": "$orderKey",
              "order_by": "$orderBy",
              "min_price": "${txtPriceMin.text}",
              "max_price": "${txtPriceMax.text}",
              "page": "$page",
            },
          );

          _futureModel!.then((value) async => {
                setState(() {
                  total_page = value[0]['total_pages'];
                  _listModelMore = [..._listModelMore, ...value];
                  // _listModelMore = [...value];
                  // _filterSelected == 'ทั้งหมด' ? null : _listModelMore.shuffle();
                  _listModelMore.length == 0 ? loadProduct = false : true;
                  print('total_page ========== ${total_page}');
                })
              });

          changOrderKey = false;
          _refreshController?.loadComplete();
        } else {
          // _refreshController.loadNoData();
        }
        // } else {
        //   _refreshController.loadNoData();
        // }
      }
    });

    // if (_listModelMore.length < 20) {
    //   if (page < total_page) {
    //     setState(() {
    //       if (changOrderKey) {
    //         _listModelMore = [];
    //         page = 0;
    //         // itemProductCount = 0;
    //       }
    //       page += 1;
    //       // _futureModel = getData(server +
    //       //     'products?per_page=' +
    //       //     _limit.toString() +
    //       //     '&order_key=' +
    //       //     (orderKey ?? '') +
    //       //     '&order_by=' +
    //       //     (orderBy ?? '') +
    //       //     '&min_price=' +
    //       //     (txtPriceMin.text ?? '0') +
    //       //     '&max_price=' +
    //       //     (txtPriceMax.text ?? '0') +
    //       //     '&page=' +
    //       //     page.toString());
    //       _futureModel = postProductData(
    //         server_we_build_local + 'm/Product/readProductHot',
    //         {
    //           // "per_page": "$_limit",
    //           "order_key": "$orderKey",
    //           "order_by": "$orderBy",
    //           "min_price": "${txtPriceMin.text ?? '0'}",
    //           "max_price": "${txtPriceMax.text ?? '0'}",
    //           // "page": "$page",
    //         },
    //       );
    //       _futureModel.then((value) => {
    //             // total_page = value[0]['total_pages'],
    //             // _listModelMore = [..._listModelMore, ...value],
    //             _listModelMore = [...value['objectData']],

    //             _listModelMore.shuffle(),
    //             _listModelMore.length == 0 ? loadProduct = false : true,
    //           });
    //       // Timer(
    //       //   Duration(seconds: 1),
    //       //   () => {
    //       //     setState(
    //       //       () {
    //       //         _listModelMore.length == 0 ? loadProduct = false : true;
    //       //       },
    //       //     ),
    //       //   },
    //       // );
    //       changOrderKey = false;
    //     });
    // _refreshController.loadComplete();
    //   } else {
    //     _refreshController.loadNoData();
    //   }
    // } else {
    //   _refreshController.loadNoData();
    // }
  }

  // _addLog(param) async {
  //   await postObjectData(server_we_build + 'log/logGoods/create', {
  //     "username": emailProfile ?? "",
  //     "profileCode": profileCode ?? "",
  //     "platform": Platform.isAndroid
  //         ? "android"
  //         : Platform.isIOS
  //             ? "ios"
  //             : "other",
  //     "prodjctId": param['id'] ?? "",
  //     "title": param['name'] ?? "",
  //     "categoryId": param['category']['data']['id'] ?? "",
  //     "category": param['category']['data']['name'] ?? "",
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _key,
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: <Widget>[
            new Container(),
          ],
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: 50,
          flexibleSpace: Container(
            color: Colors.transparent,
            child: Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios),
                        Text(
                          widget.title!,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                        )
                      ],
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SearchPage()));
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFFE3E6FE).withOpacity(0.2),
                      ),
                      child: Image.asset(
                        'assets/images/kaset/search.png',
                        color: Color(0xFF09665a),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () =>
                        setState(() => changeToListView = !changeToListView),
                    child: Container(
                      height: 35,
                      width: 35,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFFE3E6FE).withOpacity(0.2),
                      ),
                      child: changeToListView
                          ? Image.asset(
                              'assets/images/kaset/grid.png',
                              color: Color(0xFF09665a),
                            )
                          : Image.asset(
                              'assets/images/kaset/list.png',
                              color: Color(0xFF09665a),
                            ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // InkWell(
                  //   onTap: () {
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (_) => CartCentralPage()));
                  //   },
                  //   child: Container(
                  //     height: 35,
                  //     width: 35,
                  //     padding: EdgeInsets.all(8),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(10),
                  //       color: Color(0xFFE3E6FE).withOpacity(0.2),
                  //     ),
                  //     child: Image.asset(
                  //       'assets/images/kaset/basket.png',
                  //       color: Color(0xFF09665a),
                  //     ),
                  //   ),
                  // )
                  GestureDetector(
                    onTap: () {
                      if (profileCode == '') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                LoginCentralPage(),
                          ),
                        );
                        // } else if (verifyPhonePage == 'false') {
                        //   // _showVerifyCheckDialog();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CartCentralPage(),
                          ),
                        ).then((value) => _getCountItemInCart());
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFE3E6FE).withOpacity(0.2),
                          ),
                          child: Image.asset(
                            'assets/images/kaset/basket.png',
                            color: Color(0xFF09665a),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            height: 15,
                            width: 15,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Text(
                              amountItemInCart > 99
                                  ? '99+'
                                  : amountItemInCart.toString(),
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: amountItemInCart.toString().length <=
                                        1
                                    ? 10
                                    : amountItemInCart.toString().length == 2
                                        ? 9
                                        : 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => {
                            setState(() {
                              _filterSelected = '0';
                            }),
                            _onRefresh(),
                          },
                          child: Text(
                            'ทั้งหมด',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _filterSelected == '0'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _filterSelected == '0'
                                  ? Color(0xFF09665a)
                                  : Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => {
                            setState(() {
                              _filterSelected = '1';
                              orderBy = '';
                              loadProduct = true;
                              changOrderKey = true;
                              page = 0;
                            }),
                            _hotSale(),
                          },
                          child: Text(
                            'พรรณพืช',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _filterSelected == '1'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _filterSelected == '1'
                                  ? Color(0xFF09665a)
                                  : Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => {
                            setState(
                              () {
                                _filterSelected = '2';
                                orderKey = 'min_price';
                                filterType = 'minPrice';
                                orderBy = '';
                                loadProduct = true;
                                changOrderKey = true;
                                page = 0;
                              },
                            ),
                            _hotSale(),
                          },
                          child: Text(
                            'เครื่องมือ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _filterSelected == '2'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _filterSelected == '2'
                                  ? Color(0xFF09665a)
                                  : Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => {
                            setState(() {
                              _filterSelected = '3';
                              orderBy = '';
                              loadProduct = true;
                              changOrderKey = true;
                              page = 0;
                            }),
                            _hotSale(),
                          },
                          child: Text(
                            'อาหารสัตว์',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _filterSelected == '3'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _filterSelected == '3'
                                  ? Color(0xFF09665a)
                                  : Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => {
                            setState(() {
                              _filterSelected = '4';
                              orderBy = '';
                              loadProduct = true;
                              changOrderKey = true;
                              page = 0;
                            }),
                            _hotSale(),
                          },
                          child: Text(
                            'เคมีภัณฑ์',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _filterSelected == '4'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _filterSelected == '4'
                                  ? Color(0xFF09665a)
                                  : Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        // Expanded(
                        //   child: SizedBox(),
                        // ),
                        GestureDetector(
                          onTap: () {
                            _key.currentState!.openEndDrawer();
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/kaset/filter_new.png',
                                height: 15,
                                width: 15,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'ขั้นสูง',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildMain(),
            ),
          ],
        ),
        endDrawer: Drawer(
            child: SafeArea(
                child: Column(
          children: [
            Expanded(
              flex: 12,
              child: ListView(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Image.asset(
                          // "assets/images/kaset/filter_new.png",
                          'assets/images/kaset/filter_new.png',
                          height: 25,
                          width: 25,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'ขั้นสูง',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 20,
                    color: Color.fromARGB(255, 76, 76, 76),
                  ),
                  Container(
                    // padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            'ราคาต่ำสุด',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF000000),
                              // fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            controller: txtPriceMin,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                            cursorColor: Color(0xFF09665a),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF09665a)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF09665a)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),
                              errorStyle: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 10.0,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              // labelText: "กรุณากรอกหมายเลขบัตร",
                              hintText: 'ราคาต่ำสุด',
                            ),
                            onSaved: (String? value) {},
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    // padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            'ราคาสูงสุด',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF000000),
                              // fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            controller: txtPriceMax,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                            cursorColor: Color(0xFF09665a),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF09665a)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF09665a)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),
                              errorStyle: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 10.0,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              // labelText: "กรุณากรอกหมายเลขบัตร",
                              hintText: 'ราคาสูงสุด',
                            ),
                            onSaved: (String? value) {},
                          ),
                        )
                      ],
                    ),
                  ),

                  Divider(
                    height: 20,
                    color: Color.fromARGB(255, 76, 76, 76),
                  ),

                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      'ราคา',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              orderKey = 'min_price';
                              filterType = 'minPrice';
                              orderBy = '';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            constraints: BoxConstraints(minWidth: 10),
                            decoration: BoxDecoration(
                              color: filterType == 'minPrice'
                                  ? Color(0XFFE3E6FE)
                                  : Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: filterType == 'minPrice'
                                    ? Color(0XFFE3E6FE)
                                    : Color(0xFF000000),
                              ),
                            ),
                            child: Text(
                              'น้อย - มาก',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                // fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              orderKey = 'max_price';
                              filterType = 'maxPrice';
                              orderBy = '';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            constraints: BoxConstraints(minWidth: 10),
                            decoration: BoxDecoration(
                              color: filterType == 'maxPrice'
                                  ? Color(0XFFE3E6FE)
                                  : Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: filterType == 'maxPrice'
                                    ? Color(0XFFE3E6FE)
                                    : Color(0xFF000000),
                              ),
                            ),
                            child: Text(
                              'มาก - น้อย',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                // fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    height: 20,
                    color: Color.fromARGB(255, 76, 76, 76),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      'ชื่อสินค้า',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              orderBy = 'asc';
                              filterType = 'abc';
                              orderKey = 'name';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            constraints: BoxConstraints(minWidth: 10),
                            decoration: BoxDecoration(
                              color: filterType == 'abc'
                                  ? Color(0XFFE3E6FE)
                                  : Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: filterType == 'abc'
                                    ? Color(0XFFE3E6FE)
                                    : Color(0xFF000000),
                              ),
                            ),
                            child: Text(
                              'ก-ฮ หรือ a-z',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                // fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              orderBy = 'desc';
                              filterType = 'cba';
                              orderKey = 'name';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            constraints: BoxConstraints(minWidth: 10),
                            decoration: BoxDecoration(
                              color: filterType == 'cba'
                                  ? Color(0XFFE3E6FE)
                                  : Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: filterType == 'cba'
                                    ? Color(0XFFE3E6FE)
                                    : Color(0xFF000000),
                              ),
                            ),
                            child: Text(
                              'ฮ-ก หรือ z-a',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                // fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  // ListTile(
                  //   title: const Text('Item 1'),
                  //   onTap: () {
                  //     // Update the state of the app
                  //     // ...
                  //     // Then close the drawer
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  // ListTile(
                  //   title: const Text('Item 2'),
                  //   onTap: () {
                  //     // Update the state of the app
                  //     // ...
                  //     // Then close the drawer
                  //     Navigator.pop(context);
                  //   },
                  // ),
                ],
              ),
            ),
            Expanded(
                flex: 1,
                child: InkWell(
                  onTap: (() {
                    setState(
                      () {
                        loadProduct = true;
                        changOrderKey = true;
                        page = 0;
                      },
                    );
                    _onLoading();
                    Navigator.pop(context);
                  }),
                  child: Container(
                      decoration: BoxDecoration(
                        // color: Color(0xFFDF0B24),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      padding:
                          EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        color: Color(0xFFDF0B24),
                        child: Text(
                          'ตกลง',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ))
          ],
        ))),
      ),
    );
  }

  _buildMain() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: widget.mode ? false : true,
      header: WaterDropHeader(
        complete: Container(
          child: Text(''),
        ),
        completeDuration: Duration(milliseconds: 0),
      ),
      footer: CustomFooter(
        builder: (BuildContext? context, LoadStatus? mode) {
          Widget body;
          TextStyle styleText = TextStyle(
            color: Color(0xFFDF0B24),
          );
          if (mode == LoadStatus.idle) {
            body = Text("pull up load", style: styleText);
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("Load Failed!Click retry!", style: styleText);
          } else if (mode == LoadStatus.canLoading) {
            body = Text("release to load more", style: styleText);
          } else {
            body = Text("No more Data", style: styleText);
          }
          return Container(
            alignment: Alignment.center,
            child: body,
          );
        },
      ),
      controller: _refreshController!,
      onRefresh: _onRefresh,
      onLoading:
          widget.mode ? (() => _refreshController?.loadComplete()) : _onLoading,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: FutureBuilder(
          future: _futureModel,
          builder: (context, snapshot) {
            if (_listModelMore.length > 0) {
              if (changeToListView) {
                return _buildListView(_listModelMore);
              } else
                return
                    // Container();
                    _buildGridView(_listModelMore);
            } else {
              return loadProduct == true
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        childAspectRatio: 9 / 14,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) => Column(
                        children: [
                          SizedBox(height: 10),
                          LoadingTween(
                            height: 165,
                          ),
                          SizedBox(height: 5),
                          LoadingTween(
                            height: 40,
                          ),
                          SizedBox(height: 5),
                          LoadingTween(
                            height: 17,
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: 165,
                      child: Center(
                        child: Text('ไม่พบสินค้า'),
                      ),
                    );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGridView(List<dynamic> param) {
    return GridView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.65,
          // 9/15,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemCount: param.length,
      itemBuilder: (context, index) => _buildCardGrid(param[index]),
    );
  }

  Widget _buildCardGrid(dynamic param) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductFormCentralPage(model: param),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพ
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child:
                  param['image'] != null && param['image'].toString().isNotEmpty
                      ? loadingImageNetwork(
                          param['image'],
                          fit: BoxFit.cover,
                          height: 160,
                          width: double.infinity,
                        )
                      : Image.asset(
                          'assets/images/kaset/no-img.png',
                          fit: BoxFit.contain,
                          height: 160,
                          width: double.infinity,
                        ),
            ),

            // เนื้อหา
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    param['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (param['description'] != null &&
                      param['description'].toString().trim().isNotEmpty)
                    Text(
                      parseHtmlString(param['description'] ?? ''),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildListView(List<dynamic> param) {
    return ListView.separated(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (context, index) => _buildCardList(param[index]),
      separatorBuilder: (_, __) => SizedBox(height: 10),
      itemCount: param.length,
    );
  }

  _buildCardList(dynamic param) {
    return GestureDetector(
      onTap: () {
        // _addLog(param);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductFormCentralPage(model: param),
          ),
        );
      },
      child: SizedBox(
          height: 165,
          child: Container(
            padding: EdgeInsets.only(
              left: 15,
              // top: 15,
              right: 15,
              // bottom: 15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      height: 165,
                      width: 165,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: param['image'].length > 0
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: loadingImageNetwork(
                                  param['image'],
                                  // width: 80,
                                  // height: 80,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  // color: Color(0xFF09665a),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Image.asset(
                                  'assets/images/kaset/no-img.png',
                                  fit: BoxFit.contain,
                                  // color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    // param['product_variants']['data'][0]['promotion_active']
                    //     ? Positioned(
                    //         // left: 15,
                    //         top: 5,
                    //         right: 0,
                    //         // top: MediaQuery.of(context).padding.top + 5,
                    //         child: Container(
                    //           // height: AdaptiveTextSize()
                    //           //     .getadaptiveTextSize(context, 42),
                    //           // width: AdaptiveTextSize()
                    //           //     .getadaptiveTextSize(context, 20),
                    //           padding: EdgeInsets.symmetric(horizontal: 10),
                    //           alignment: Alignment.center,
                    //           decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.horizontal(
                    //                 left: Radius.circular(40),
                    //               ),
                    //               gradient: LinearGradient(
                    //                 begin: Alignment.topLeft,
                    //                 end: Alignment.bottomRight,
                    //                 colors: [
                    //                   Color(0xFFFFD45A),
                    //                   Color(0xFFFFD45A),
                    //                 ],
                    //               )),
                    //           child: Text(
                    //             'โปรโมชั่น',
                    //             style: TextStyle(
                    //               fontSize: 11,
                    //               color: Color(0XFFee4d2d),
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //             textScaleFactor:
                    //                 ScaleSize.textScaleFactor(context),
                    //           ),
                    //         ),
                    //         // child: snapshot.data[index]
                    //         //                 ['product_variants']['data']
                    //         //             [0]['promotions']['data'] >
                    //         //         0
                    //         //     ? Container(
                    //         //         // height: AdaptiveTextSize()
                    //         //         //     .getadaptiveTextSize(context, 42),
                    //         //         // width: AdaptiveTextSize()
                    //         //         //     .getadaptiveTextSize(context, 20),
                    //         //         padding: EdgeInsets.symmetric(
                    //         //             horizontal: 10),
                    //         //         alignment: Alignment.center,
                    //         //         decoration: BoxDecoration(
                    //         //             borderRadius:
                    //         //                 BorderRadius.horizontal(
                    //         //               left: Radius.circular(40),
                    //         //             ),
                    //         //             gradient: LinearGradient(
                    //         //               begin: Alignment.topLeft,
                    //         //               end: Alignment.bottomRight,
                    //         //               colors: [
                    //         //                 Color(0xFFFFD45A),
                    //         //                 Color(0xFFFFD45A),
                    //         //               ],
                    //         //             )),
                    //         //         child: Text(
                    //         //           'โปรโมชั่น',
                    //         //           style: TextStyle(
                    //         //             fontSize: 11,
                    //         //             color: Color(0XFFee4d2d),
                    //         //             fontWeight: FontWeight.bold,
                    //         //           ),
                    //         //           textScaleFactor:
                    //         //               ScaleSize.textScaleFactor(
                    //         //                   context),
                    //         //         ),
                    //         //       )
                    //         //     : Container(),
                    //       )
                    //     : Container(),
                  ],
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        param['name'],
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      param['description'] != 'null'
                          ? Text(
                              parseHtmlString(param['description'] ?? ''),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : SizedBox(),
                      // SizedBox(height: 10),
                      // param['product_variants']['data'].length > 0
                      //     ? param['product_variants']['data'][0]
                      //             ['promotion_active']
                      //         ? Text(
                      //             (moneyFormat(param['product_variants']['data']
                      //                             [0]['promotion_price']
                      //                         .toString()) +
                      //                     " บาท") ??
                      //                 '',
                      //             style: TextStyle(
                      //               fontSize: 20,
                      //               color: Color(0xFFED168B),
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //             textAlign: TextAlign.center,
                      //             maxLines: 1,
                      //             overflow: TextOverflow.ellipsis,
                      //           )
                      //         : Text(
                      //             (moneyFormat(param['product_variants']['data']
                      //                             [0]['price']
                      //                         .toString()) +
                      //                     " บาท") ??
                      //                 '',
                      //             style: TextStyle(
                      //               fontSize: 20,
                      //               color: Color(0xFFED168B),
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //             textAlign: TextAlign.center,
                      //             maxLines: 1,
                      //             overflow: TextOverflow.ellipsis,
                      //           )
                      //     : Text(
                      //         'สินค้าหมด',
                      //         style: TextStyle(
                      //           fontSize: 20,
                      //           color: Color(0xFFED168B),
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //         textAlign: TextAlign.center,
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //       )
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  // _showVerifyCheckDialog() {
  //   return showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return WillPopScope(
  //           onWillPop: () {
  //             return Future.value(false);
  //           },
  //           child: CupertinoAlertDialog(
  //             title: new Text(
  //               'บัญชีนี้ยังไม่ได้ยืนยันเบอร์โทรศัพท์\nกด ตกลง เพื่อยืนยัน',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontFamily: 'Kanit',
  //                 color: Colors.black,
  //                 fontWeight: FontWeight.normal,
  //               ),
  //             ),
  //             content: Text(" "),
  //             actions: [
  //               CupertinoDialogAction(
  //                 isDefaultAction: true,
  //                 child: new Text(
  //                   "ตกลง",
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontFamily: 'Kanit',
  //                     color: Color(0xFFFF7514),
  //                     fontWeight: FontWeight.normal,
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => VerifyPhonePage(),
  //                     ),
  //                   );
  //                 },
  //               ),
  //               CupertinoDialogAction(
  //                 isDefaultAction: false,
  //                 child: new Text(
  //                   "ไม่ใช่ตอนนี้",
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontFamily: 'Kanit',
  //                     color: Color(0xFFFF7514),
  //                     fontWeight: FontWeight.normal,
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.pop(
  //                     context,
  //                   );
  //                 },
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }

}
