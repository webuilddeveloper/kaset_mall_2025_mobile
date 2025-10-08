import 'package:http/http.dart' as http;
import 'dart:convert';

const paymentApi = 'https://gateway.webpakpay.com/'; // webpak
const reqToken =
    '0f13a9c9abae1a592cd197d54c089b103aaa7dc7e77f1cd718c3e90fa27b0e8e';
const reqKey = 'c2fa53c3dc8fec2ffc1b87d9897cc7e78cfb07c0';

postPayment(String order, String amount) async {
  Map<String, String> body = {
    'reqKey': reqKey,
    'reqMod': 'PAY',
    'reqToken': reqToken,
    'reqOrder': order,
    'reqMethod': 'TQ',
    'reqAmount': amount,
    'reqCurrency': 'THB'
  };
  var response = await http.post(
    Uri.parse(paymentApi),
    body: body,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded"
    },
    encoding: Encoding.getByName("utf-8"),
  );

  var data = json.decode(response.body);
  return Future.value(data);
}

postPaymentQuery(String reqNumber) async {
  Map<String, String> body = {
    'reqKey': reqKey,
    'reqMod': 'QUERY',
    'reqToken': reqToken,
    'reqNumber': reqNumber,
  };
  var response = await http.post(
    Uri.parse(paymentApi),
    body: body,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded"
    },
    encoding: Encoding.getByName("utf-8"),
  );

  var data = json.decode(response.body);
  return Future.value(data);
}

Future<dynamic> postCreate(String url, dynamic criteria) async {
  var response = await http.post(Uri.parse(url), body: criteria, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  });

  var data = json.decode(response.body);
  return Future.value(data['objectData']);
}

// omise
const pkey_omise = 'pkey_test_5q3v6842asenkdkxbsi';
const skey_omise = 'skey_test_5q3v69ouge2nzju2ah5';
// const pkey_omise = 'pkey_5qevabfk599o5bqtqu3';
// const skey_omise = 'skey_5qevqupbhwugtfss38e';
const endpoint_omise_m = 'https://api.omise.co/';
const endpoint_omise_v = 'https://vault.omise.co/';

getOmise(String url) async {
  String basicAuth = 'Basic ' + base64Encode(utf8.encode("$skey_omise:''"));
  var response = await http.get(Uri.parse(url),
      headers: <String, String>{'authorization': basicAuth});
  var data = json.decode(response.body);
  return Future.value(data);
}

postOmise(String url, Map<String, dynamic> body, {bool pkey = false}) async {
  String key = pkey ? pkey_omise : skey_omise;
  String basicAuth = 'Basic ' + base64Encode(utf8.encode("$key:''"));
  var response = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'authorization': basicAuth,
      "Content-Type": "application/x-www-form-urlencoded"
    },
    encoding: Encoding.getByName("utf-8"),
    body: body,
  );
  var data = json.decode(response.body);
  return Future.value(data);
}
