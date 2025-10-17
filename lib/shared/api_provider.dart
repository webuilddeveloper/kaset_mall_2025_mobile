// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
// import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasetmall/menu.dart';
import 'package:kasetmall/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';

const appName = 'SUKSAPAN Mall';
const versionName = '0.0.1';
const versionNumber = 001;

// flutter build apk --build-name=1.0.0 --build-number=1
// flutter build appbundle

// const server = 'http://192.168.100.104:4900/';
// const server_we_build = 'http://localhost:9000/';
// const server = 'http://122.155.223.63/td-we-mart-api/';
// const server = 'https://0a02-125-24-6-114.au.ngrok.io/';
// const server = 'https://ssp.we-builds.com/ssp-api/';
// const server = 'https://private-anon-a0406381df-sspmall.apiary-mock.com/';
const server = 'https://api.suksapanmall.com/';
// const server_we_build = 'http://122.155.223.63/td-we-mart-api/';
const server_we_build = 'https://gateway.we-builds.com/kaset-mall-api/';

const serverUpload = 'https://ssp.we-builds.com/ssp-document/upload';
const serverReport = 'http://122.155.223.63/td-we-mart-report/';
const serverOTP = 'https://portal-otp.smsmkt.com/api/';

const server_gateway =
    'https://gateway.we-builds.com/sspmall-py-extended/phonics/';

const registerApi = server + 'm/register/';
const newsApi = server_we_build + 'm/news/';
const partnerApi = server + 'm/partner/';
const partnerCategoryApi = server + 'm/partner/category/';
const newsGalleryApi = server + 'm/news/gallery/read';
const pollApi = server + 'm/poll/';
const poiApi = server + 'm/poi/';
const poiGalleryApi = server + 'm/poi/gallery/read';
const faqApi = server + 'm/faq/';
const knowledgeApi = server + 'm/knowledge/';
const cooperativeApi = server + 'm/cooperativeForm/';
const contactApi = server + 'm/contact/';
const bannerApi = server + 'm/banner/';
const bannerGalleryApi = server_we_build + 'm/banner/gallery/read';
const privilegeApi = server_we_build + "m/privilege/";
const menuApi = server + "m/menu/";
const aboutUsApi = server + "m/aboutus/";
const welfareApi = server + 'm/welfare/';
const welfareGalleryApi = server + 'm/welfare/gallery/read';
const eventCalendarApi = server_we_build + 'm/eventCalendar/';
const eventCalendarGalleryApi =
    server_we_build + 'm/eventCalendar/gallery/read';
const pollGalleryApi = server + 'm/poll/gallery/read';
const reporterApi = server + 'm/v2/reporter/';
const reporterGalleryApi = server + 'm/Reporter/gallery/';
const fundApi = server + 'm/fund/';
const fundGalleryApi = server + 'm/fund/gallery/read';
const warningApi = server + 'm/warning/';
const warningGalleryApi = server + 'm/warning/gallery/read';
const privilegeGalleryApi = server_we_build + 'm/privilege/gallery/read';
const productCategoryApi = server + 'm/product/category/';
const promotionApi = server + 'm/promotion/';
const promotionCategoryApi = server + 'm/promotion/category/';
const promotionCommentApi = server + 'm/promotion/comment/';
const promotionGalleryApi = server + 'm/promotion/gallery/read';
const readProvinceApi = 'route/province/read';
const readDistrictApi = 'route/province/read';
const readSubDistrictApi = 'route/province/read';
const examinationApi = server + 'm/examination/';
const examinationGalleryApi = server + 'm/examination/gallery/read';

//banner
const mainBannerApi = server_we_build + 'm/Banner/main/';
const contactBannerApi = server + 'm/Banner/contact/';
const reporterBannerApi = server + 'm/Banner/reporter/';
const privilegeBannerApi = server_we_build + 'm/Banner/main/';
const promotionBannerApi = server + 'm/Banner/main/';
const newsBannerApi = server + 'm/Banner/main/';

//rotation
const rotationApi = server_we_build + 'rotation/';
const mainRotationApi = server_we_build + 'm/Rotation/main/';
const rotationGalleryApi = server + 'm/rotation/gallery/read';
const rotationWarningApi = server + 'm/rotation/warning/read';
const rotationWelfareApi = server + 'm/rotation/welfare/read';
const rotationNewsApi = server + 'm/rotation/news/read';
const rotationPoiApi = server + 'm/rotation/poi/read';
const rotationPrivilegeApi = server_we_build + 'm/rotation/privilege/read';
const rotationNotificationApi = server + 'm/rotation/notification/read';
const rotationEvantCalendarApi = server + 'm/rotation/event/read';
const rotationReporterApi = server + 'm/rotation/reporter/read';

//mainPopup
const mainPopupHomeApi = server_we_build + 'm/MainPopup/';
const forceAdsApi = server + 'm/ForceAds/';

const couponCategoryApi = server + 'm/coupon/category/';

// comment
const newsCommentApi = server_we_build + 'm/news/comment/';
const eventCalendarCommentApi = server_we_build + 'm/eventCalendar/comment/';
const welfareCommentApi = server + 'm/welfare/comment/';
const poiCommentApi = server + 'm/poi/comment/';
const fundCommentApi = server + 'm/fund/comment/';
const warningCommentApi = server + 'm/warning/comment/';

//category
const knowledgeCategoryApi = server_we_build + 'm/knowledge/category/';
const cooperativeCategoryApi = server + 'm/cooperativeForm/category/';
const newsCategoryApi = server_we_build + 'm/news/category/';
const eventCalendarCategoryApi = server_we_build + 'm/eventCalendar/category/';
const privilegeCategoryApi = server_we_build + 'm/privilege/category/';
const contactCategoryApi = server + 'm/contact/category/';
const welfareCategoryApi = server + 'm/welfare/category/';
const fundCategoryApi = server + 'm/fund/category/';
const pollCategoryApi = server + 'm/poll/category/';
const poiCategoryApi = server + 'm/poi/category/';
const reporterCategoryApi = server + 'm/v2/reporter/category/';
const warningCategoryApi = server + 'm/warning/category/';
const examinationCategoryApi = server + 'm/examination/category/';

const splashApi = server + 'm/splash/read';
const versionReadApi = '${server_we_build}m/v2/version/read';
const privilegeSpecialReadApi =
    'http://122.155.223.63/td-we-mart-api/m/privilege/ssp/read';
const privilegeSpecialCategoryReadApi =
    'http://122.155.223.63/td-we-mart-api/m/privilege/category/read';

Future<dynamic> postCategory(String url, dynamic criteria) async {
  // var value = await storage.read(key: 'dataUserLoginDDPM');
  // var dataUser = json.decode(value!);
  List<dynamic> dataOrganization = [];
  // dataOrganization =
  //     dataUser['countUnit'] != '' ? json.decode(dataUser['countUnit']) : [];

  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] != null ? criteria['skip'] : 0,
    "limit": criteria['limit'] != null ? criteria['limit'] : 1,
    "code": criteria['code'] != null ? criteria['code'] : '',
    "reference": criteria['reference'] != null ? criteria['reference'] : '',
    "description":
        criteria['description'] != null ? criteria['description'] : '',
    "category": criteria['category'] != null ? criteria['category'] : '',
    "keySearch": criteria['keySearch'] != null ? criteria['keySearch'] : '',
    "username": criteria['username'] != null ? criteria['username'] : '',
    "isHighlight":
        criteria['isHighlight'] != null ? criteria['isHighlight'] : false,
    "language": criteria['language'] != null ? criteria['language'] : 'th',
    "organization": dataOrganization != null ? dataOrganization : [],
  });

  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });

  var data = json.decode(response.body);

  List<dynamic> list = [
    {'code': "", 'title': 'ทั้งหมด'}
  ];
  list = [...list, ...data['objectData'] ?? []];
  return Future.value(list);
}

//ใช้ในกรณีที่ 'ต้องการ' Login ก่อนยิง AIP เท่านั้น
Future<dynamic> get(String url) async {
  final storage = await new FlutterSecureStorage().read(key: 'token') ?? "";
  var response = await http.get(Uri.parse(url), headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer " + storage
  });
  var data = jsonDecode(utf8.decode(response.bodyBytes));
  if (data['meta'] != null) {
    data['data'][0]['countItem'] = (data['meta']['pagination']['total']);
    data['data'][0]['count'] = (data['meta']['pagination']['count']);
    data['data'][0]['per_page'] = (data['meta']['pagination']['per_page']);
    data['data'][0]['current_page'] =
        (data['meta']['pagination']['current_page']);
    data['data'][0]['total_pages'] =
        (data['meta']['pagination']['total_pages']);
  }
  return Future.value(data['data']);
}

Future<dynamic> getQuestion(String url) async {
  var response = await http.get(Uri.parse(url), headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    // "Authorization": "Bearer " + storage
  });
  var data = jsonDecode(utf8.decode(response.bodyBytes));
  return Future.value(data);
}

//ใช้ในกรณีที่ 'ไม่ต้องการ' Login ก่อนยิง AIP เท่านั้น
Future<dynamic> getData(String url) async {
  var response = await http.get(Uri.parse(url), headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
  });
  var data = jsonDecode(utf8.decode(response.bodyBytes));
  if (data['meta'] != null) {
    data['data'][0]['countItem'] = (data['meta']['pagination']['total']);
    data['data'][0]['count'] = (data['meta']['pagination']['count']);
    data['data'][0]['per_page'] = (data['meta']['pagination']['per_page']);
    data['data'][0]['current_page'] =
        (data['meta']['pagination']['current_page']);
    data['data'][0]['total_pages'] =
        (data['meta']['pagination']['total_pages']);
  }
  return Future.value(data['data']);
}

Future<dynamic> getShippingPrice(String url) async {
  final storage = await new FlutterSecureStorage().read(key: 'token');

  print('getShippingPrice ${url}');
  print('getShippingPrice $storage');
  var response = await http.get(Uri.parse(url), headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer " + storage!
  });
  print('${utf8.decode(response.bodyBytes).toString()}');
  var data = jsonDecode(utf8.decode(response.bodyBytes));
  print('getShippingPrice ${data.toString()}');
  return Future.value(data['shipping_price']);
}

Future<dynamic> getUser(String url) async {
  final storage = await new FlutterSecureStorage().read(key: 'token') ?? "";

  var response = await http.get(Uri.parse(url), headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer " + storage
  });
  var data = jsonDecode(utf8.decode(response.bodyBytes));

  if (data['data'] != null) {
    await new FlutterSecureStorage().write(
        key: 'phoneVerified', value: data['data']['phone_verified'].toString());
    await new FlutterSecureStorage()
        .write(key: 'profileCode', value: data['data']['id'].toString());
  }

  return Future.value(data['data']);
}

Future<dynamic> getQRCode(String url) async {
  final storage = await new FlutterSecureStorage().read(key: 'token');

  var response = await http.get(Uri.parse(url), headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer " + storage!
  });

  var data = await json.decode(json.encode(response.body));
  // Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
  // String encoded = base64.encode(utf8.encode(response.body));
  // String decoded = utf8.decode(base64.decode(encoded));
  return Future.value(data);
}

Future<dynamic> delete(String url) async {
  final storage = await new FlutterSecureStorage().read(key: 'token');

  var response = await http.delete(Uri.parse(url), headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer " + storage!
  });
  var data = jsonDecode(utf8.decode(response.bodyBytes));
  return Future.value(data);
}

Future<dynamic> getCarts(String url) async {
  final storage = await new FlutterSecureStorage().read(key: 'token');

  var response = await http.get(Uri.parse(url), headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer " + storage!
  });
  var data = jsonDecode(utf8.decode(response.bodyBytes));
  return Future.value(data);
}

Future<dynamic> post(String url, dynamic criteria) async {
  // var dataUser = json.decode(value!);
  List<dynamic> dataOrganization = [];
  // dataOrganization =
  //     dataUser['countUnit'] != '' ? json.decode(dataUser['countUnit']) : [];

  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] != null ? criteria['skip'] : 0,
    "limit": criteria['limit'] != null ? criteria['limit'] : 1,
    "code": criteria['code'] != null ? criteria['code'] : '',
    "reference": criteria['reference'] != null ? criteria['reference'] : '',
    "description":
        criteria['description'] != null ? criteria['description'] : '',
    "category": criteria['category'] != null ? criteria['category'] : '',
    "keySearch": criteria['keySearch'] != null ? criteria['keySearch'] : '',
    "username": criteria['username'] != null ? criteria['username'] : '',
    "firstName": criteria['firstName'] != null ? criteria['firstName'] : '',
    "lastName": criteria['lastName'] != null ? criteria['lastName'] : '',
    "title": criteria['title'] != null ? criteria['title'] : '',
    "answer": criteria['answer'] != null ? criteria['answer'] : '',
    "isHighlight":
        criteria['isHighlight'] != null ? criteria['isHighlight'] : false,
    "createBy": criteria['createBy'] != null ? criteria['createBy'] : '',
    "isPublic": criteria['isPublic'] != null ? criteria['isPublic'] : false,
    "language": criteria['language'] != null ? criteria['language'] : 'th',
    "organization": dataOrganization != null ? dataOrganization : [],
  });
  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });
  var data = json.decode(response.body);

  return Future.value(data['objectData']);
}

Future<dynamic> postAny(String url, dynamic criteria) async {
  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] != null ? criteria['skip'] : 0,
    "limit": criteria['limit'] != null ? criteria['limit'] : 1,
    "code": criteria['code'] != null ? criteria['code'] : '',
    "category": criteria['category'] != null ? criteria['category'] : '',
    "username": criteria['username'] != null ? criteria['username'] : '',
    "password": criteria['password'] != null ? criteria['password'] : '',
    "createBy": criteria['createBy'] != null ? criteria['createBy'] : '',
    "profileCode":
        criteria['profileCode'] != null ? criteria['profileCode'] : '',
    "imageUrlCreateBy": criteria['imageUrlCreateBy'] != null
        ? criteria['imageUrlCreateBy']
        : '',
    "reference": criteria['reference'] != null ? criteria['reference'] : '',
    "description":
        criteria['description'] != null ? criteria['description'] : '',
  });

  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });

  var data = json.decode(response.body);

  return Future.value(data['status']);
}

Future<dynamic> postAnyObj(String url, dynamic criteria) async {
  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] != null ? criteria['skip'] : 0,
    "limit": criteria['limit'] != null ? criteria['limit'] : 1,
    "code": criteria['code'] != null ? criteria['code'] : '',
    "createBy": criteria['createBy'] != null ? criteria['createBy'] : '',
    "imageUrlCreateBy": criteria['imageUrlCreateBy'] != null
        ? criteria['imageUrlCreateBy']
        : '',
    "reference": criteria['reference'] != null ? criteria['reference'] : '',
    "description":
        criteria['description'] != null ? criteria['description'] : '',
  });

  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });

  var data = json.decode(response.body);

  return Future.value(data);
}

Future<dynamic> postLogin(String url, dynamic criteria) async {
  var body = json.encode({
    "password": criteria['password'] != null ? criteria['password'] : '',
    "email": criteria['email'] != null ? criteria['email'] : '',
    "device_name":
        criteria['device_name'] != null ? criteria['device_name'] : '',
  });

  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });
  // var data = json.decode(response.body);
  var data = jsonDecode(utf8.decode(response.bodyBytes));
  if (response.statusCode == 200) {
    await new FlutterSecureStorage().write(key: 'token', value: data['token']);
    return Future.value(data);
  } else {
    return {"status": "F"};
  }
}

Future<dynamic> postLoginSocial(String url, dynamic criteria) async {
  var body = json.encode({
    "access_token":
        criteria['access_token'] != null ? criteria['access_token'] : '',
    "device_name":
        criteria['device_name'] != null ? criteria['device_name'] : '',
  });

  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });
  print('------Url-------->>>  ${url}');
  print('--------body----->>>  ${body}');
  // var data = json.decode(response.body);
  var data = jsonDecode(utf8.decode(response.bodyBytes));
  if (response.statusCode == 200) {
    await new FlutterSecureStorage().write(key: 'token', value: data['token']);
    return Future.value(data);
  } else {
    return {"status": "F"};
  }
}

Future<dynamic> postObjectData(String url, dynamic criteria) async {
  print('-- PO 3');
  final token = await new FlutterSecureStorage().read(key: 'token');
  print('----------$token');
  print('----------${criteria.toString()}');
  var body = json.encode(criteria);
  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    // "Authorization": "Bearer " + token!
  });

  print('-----statusCode-----${response.statusCode}');
  print("-----Response Body-----${response.body}");

  var data = jsonDecode(utf8.decode(response.bodyBytes));
  return Future.value(data);
}

Future<dynamic> postQuestion(String url, dynamic criteria) async {
  var body = json.encode(criteria);
  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
  });

  var data = jsonDecode(utf8.decode(response.bodyBytes));
  if (response.statusCode == 200) {
    return Future.value(data);
    // var data = json.decode(response.body);
    // return {
    //   "status": data['status'],
    //   "message": data['message'],
    //   "objectData": data['data']
    // };
  } else {
    // data['data']['status2'] = 'F';
    return Future.value(data);
  }
}

Future<dynamic> postProductData(String url, dynamic criteria) async {
  var body = json.encode(criteria);
  // print(url);
  // print('criteria ===== ${body}');
  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    // "Authorization": "Bearer " + token
  });

  var data = jsonDecode(utf8.decode(response.bodyBytes));

  // print('----------' + data['data'][0].toString());
  // var data = json.decode(response.body);
  if (data['meta'] != null) {
    data['data'][0]['countItem'] = (data['meta']['pagination']['total']);
    data['data'][0]['count'] = (data['meta']['pagination']['count']);
    data['data'][0]['per_page'] = (data['meta']['pagination']['per_page']);
    data['data'][0]['current_page'] =
        (data['meta']['pagination']['current_page']);
    data['data'][0]['total_pages'] =
        (data['meta']['pagination']['total_pages']);
  }
  return Future.value(data['data']);
  // if (response.statusCode == 200) {
  //   data['data']['status2'] = 'S';
  //   return Future.value(data['data']);
  //   // var data = json.decode(response.body);
  //   // return {
  //   //   "status": data['status'],
  //   //   "message": data['message'],
  //   //   "objectData": data['data']
  //   // };
  // } else {
  //   data['data']['status2'] = 'F';
  //   return Future.value(data);
  // }
}

Future<dynamic> postReturnAll(String url, dynamic criteria) async {
  final token = await new FlutterSecureStorage().read(key: 'token') ?? "";
  var body = json.encode(criteria);
  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer " + token
  });
  var data = jsonDecode(utf8.decode(response.bodyBytes));
  if (response.statusCode == 200) {
    data['status2'] = 'S';
    return Future.value(data);
  } else {
    data['status2'] = 'F';
    return Future.value(data);
  }
}

Future<dynamic> postProductHotSale(String url, dynamic criteria) async {
  // final token = await new FlutterSecureStorage().read(key: 'token');
  var body = json.encode(criteria);
  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    // "Authorization": "Bearer " + token
  });
  var data = jsonDecode(utf8.decode(response.bodyBytes));
  if (response.statusCode == 200) {
    data['status2'] = 'S';
    return Future.value(data['objectData']);
  } else {
    data['status2'] = 'F';
    return Future.value(data);
  }
}

Future<dynamic> postFormData(String url, dynamic map) async {
  final token = await new FlutterSecureStorage().read(key: 'token');
  var response = await Dio().post(url,
      data: map,
      options: Options(headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer " + token!
      }));
  if (response.statusCode == 200) {
    return response.data['data'];
  }

  // if (response.statusCode == 200) {
  //   data['data']['status2'] = 'S';
  //   return Future.value(data['data']);
  //   // var data = json.decode(response.body);
  //   // return {
  //   //   "status": data['status'],
  //   //   "message": data['message'],
  //   //   "objectData": data['data']
  //   // };
  // } else {
  //   data['data']['status2'] = 'F';
  //   return Future.value(data);
  // }
}

Future<dynamic> postRegister(String url, dynamic criteria) async {
  var body = json.encode(criteria);
  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });
  var data = jsonDecode(utf8.decode(response.bodyBytes));
  data['statusCode'] = response.statusCode;
  print('--------------register ${data}');
  return Future.value(data);
}

Future<dynamic> postProductHot(String url, dynamic criteria, int limit) async {
  var body = json.encode(criteria);
  var response = await http.post(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
  });
  var data = jsonDecode(utf8.decode(response.bodyBytes));

  if (response.statusCode == 200) {
    return Future.value(data['data']);
  } else {
    return Future.value([]);
  }
}

Future<dynamic> put(String url, dynamic criteria) async {
  final token = await new FlutterSecureStorage().read(key: 'token');
  var body = json.encode(criteria);
  var response = await http.put(Uri.parse(url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer " + token!
  });
  var data = jsonDecode(utf8.decode(response.bodyBytes));
  if (response.statusCode == 200) {
    return Future.value(data['data']);
  } else {
    return {"status": "F"};
  }
}

Future<dynamic> postConfigShare() async {
  var body = json.encode({});

  var response = await http.post(
      Uri.parse(server + 'configulation/shared/read'),
      body: body,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      });
  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return {
      // Future.value(data['objectData']);
      "status": data['status'],
      "message": data['message'],
      "objectData": data['objectData']
    };
  } else {
    return {"status": "F"};
  }
}

Future<LoginRegister> postLoginRegister(String url, dynamic criteria) async {
  var body = json.encode(criteria);

  var response = await http.post(Uri.parse(server + url), body: body, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });

  if (response.statusCode == 200) {
    var userMap = jsonDecode(response.body);

    var user = new LoginRegister.fromJson(userMap);
    return Future.value(user);
  } else {
    // ignore: null_argument_to_non_null_type
    return Future.value();
  }
}

//upload with dio
Future<String> uploadImage(XFile file) async {
  Dio dio = new Dio();

  String fileName = file.path.split('/').last;
  FormData formData = FormData.fromMap({
    "ImageCaption": "flutter",
    "Image": await MultipartFile.fromFile(file.path, filename: fileName),
  });

  var response = await dio.post(serverUpload, data: formData);

  return response.data['imageUrl'];
}

//upload with http
upload(File file) async {
  var uri = Uri.parse(serverUpload);
  var request = http.MultipartRequest('POST', uri)
    ..fields['ImageCaption'] = 'flutter2'
    ..files.add(await http.MultipartFile.fromPath('Image', file.path,
        contentType: MediaType('application', 'x-tar')));
  var response = await request.send();
  if (response.statusCode == 200) {
    return response;
  }
}

createStorageApp({dynamic model, String category = "Guest", String? token}) {
  final storage = new FlutterSecureStorage();

  // var fullName = model['name'].split(' ');
  // var firstName = fullName[0];
  // var lastName = fullName[1];

  storage.write(key: 'profileCategory', value: category);
  storage.write(key: 'token', value: token);

  storage.write(
    key: 'profileCode10',
    value: model['id'],
  );

  storage.write(
    key: 'customerID',
    value: model['customerID'],
  );

  storage.write(
    key: 'profileImageUrl',
    value: model['profile_picture_url'],
  );

  storage.write(
    key: 'profileFirstName',
    value: model['name'],
  );

  storage.write(
    key: 'profilePhone',
    value: model['phone'],
  );

  storage.write(
    key: 'profileUserName',
    value: model['userName'],
  );

  // storage.write(
  //   key: 'profileLastName',
  //   value: lastName,
  // );

  storage.write(
    key: 'referenceShopCode',
    value: model['referenceShopCode'],
  );

  storage.write(
    key: 'referenceShopName',
    value: model['referenceShopName'],
  );

  storage.write(
    key: 'dataUserLoginDDPM',
    value: jsonEncode(model),
  );

  // storage.write(
  //   key: 'phone_verified',
  //   value: model['phone_verified'],
  // );
}

logout(BuildContext context) async {
  final storage = new FlutterSecureStorage();
  var profileCategory = await storage.read(key: 'profileCategory');
  if (profileCategory != '' && profileCategory != null) {
    switch (profileCategory) {
      case 'facebook':
        // logoutFacebook();
        break;
      case 'google':
        // logoutGoogle();
        break;
      case 'line':
        // logoutLine();
        break;
      default:
    }
  }
  storage.deleteAll();
  _updateToken("");
  await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MenuCentralPage()),
      (Route<dynamic> route) => false);
}

_updateToken(profileCode) async {
  FirebaseMessaging.instance.getToken().then(
    (token) {
      postDio(server_we_build + 'notificationV2/m/updateTokenDevice',
          {"token": token, "profileCode": profileCode});
    },
  );
}

Future<dynamic> postDio(String url, dynamic criteria) async {
  final storage = new FlutterSecureStorage();
  final profileCode = await storage.read(key: 'profileCode10');

  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
    criteria['profileCode'] = profileCode;
  }
  // print('12345kkkkkkkkkkk ${criteria}');
  Dio dio = new Dio();

  var response = await dio.post(url, data: criteria);
  if (url == '${mainPopupHomeApi}read') {
    // print(response.data.toString());
  }
  // if (url == server + 'm/goods/isPopular/true/read')
  //   print(response.data.toString());
  return Future.value(response.data['objectData']);
}

Future<dynamic> postDioList(String url, List<dynamic> criteria) async {
  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);
  return Future.value(response.data['objectData']);
}

Future<dynamic> postDioAny(String url, dynamic criteria) async {
  final storage = new FlutterSecureStorage();
  final profileCode = await storage.read(key: 'profileCode10');
  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
    criteria['profileCode'] = profileCode;
  }
  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);
  // print(response.data['objectData'].toString());
  return Future.value(response.data);
}

Future<dynamic> postDioWithOutProfileCode(String url, dynamic criteria) async {
  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);
  // print(response.data['objectData'].toString());
  return Future.value(response.data['objectData']);
}

Future<dynamic> postDioCategory(String url, dynamic criteria) async {
  final storage = new FlutterSecureStorage();
  Platform.operatingSystem.toString();
  final profileCode = await storage.read(key: 'profileCode10');

  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }

  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);

  List<dynamic> list = [
    {'code': "", 'title': 'ทั้งหมด'}
  ];
  list = [...list, ...response.data['objectData']];

  return Future.value(list);
}

Future<dynamic> postDioMessage(String url, dynamic criteria) async {
  final storage = new FlutterSecureStorage();
  final profileCode = await storage.read(key: 'profileCode10');
  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }
  Dio dio = new Dio();
  print('-----dio criteria-----' + criteria.toString());
  print('-----dio criteria-----' + url);
  var response = await dio.post(url, data: criteria);
  print('-----dio message-----' + response.data.toString());
  return Future.value(response.data['objectData']);
}

Future<dynamic> postOTPSend(String url, dynamic criteria) async {
  //https://portal-otp.smsmkt.com/api/otp-send
  //https://portal-otp.smsmkt.com/api/otp-validate
  Dio dio = new Dio();
  dio.options.contentType = Headers.formUrlEncodedContentType;
  dio.options.headers["api_key"] = "db88c29e14b65c9db353c9385f6e5f28";
  dio.options.headers["secret_key"] = "XpM2EfFk7DKcyJzt";
  var response = await dio.post(serverOTP + url, data: criteria);
  // print('----------- -----------  ${response.data['result']}');
  return Future.value(response.data['result']);
}

Future<dynamic> postDioCategoryWeMart(String url, dynamic criteria) async {
  // print(url);
  // print(criteria);
  final storage = new FlutterSecureStorage();
  // var platform = Platform.operatingSystem.toString();
  final profileCode = await storage.read(key: 'profileCode16');

  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }

  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);
  var data = response.data['objectData'];

  List<dynamic> list = [
    {'code': "", 'title': 'ทั้งหมด'}
  ];

  list = [...data, ...list];
  return Future.value(list);
}

Future<dynamic> postDioCategoryWeMartNoAll(String url, dynamic criteria) async {
  // print(url);
  // print(criteria);
  final storage = new FlutterSecureStorage();
  // var platform = Platform.operatingSystem.toString();
  final profileCode = await storage.read(key: 'profileCode16');

  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }

  Dio dio = new Dio();
  var response = await dio.post(url, data: criteria);
  var data = response.data['objectData'];

  List<dynamic> list = [
    // {'code': "", 'title': 'ทั้งหมด'}
  ];

  list = [...data];
  return Future.value(list);
}

const splashReadApi = server + 'm/splash/read';
const newsReadApi = server + 'm/news/read';
const profileReadApi = server + 'm/v2/register/read';
const organizationImageReadApi = server + 'm/v2/organization/image/read';
const notificationApi = server + 'm/v2/notification/';
const reporterReadApi = server + 'm/v2/reporter/read';
const newsCommentReadApi = server + 'm/v2/news/comment/';

const serverLineNoti = 'https://notify-api.line.me/api/notify';
Future<dynamic> postLineNoti(param) async {
  final storage = new FlutterSecureStorage();

  String? profileUserName = await storage.read(key: 'profileUserName');
  String? profileFirstName = await storage.read(key: 'profileFirstName');
  String? profilePhone = await storage.read(key: 'profilePhone');

  Dio dio = new Dio();
  dio.options.contentType = Headers.formUrlEncodedContentType;
  dio.options.headers["Authorization"] =
      "Bearer " + "1RwnPOBFU0sN0LNBNWxkNpSOmpNjjKeVaFzwmg1c5zl";
  var formData = FormData.fromMap({
    'message':
        '\n Mobile \n Username : $profileUserName \n Name : $profileFirstName \n Phone : $profilePhone \n $param'
  });
  var response = await dio.post(serverLineNoti, data: formData);
  return Future.value(response.data['message']);
}
