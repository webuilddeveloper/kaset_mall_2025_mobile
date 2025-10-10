import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_mart_v3/payment_status.dart';
import 'package:mobile_mart_v3/widget/data_error.dart';

import '../component/loading_image_network.dart';
import '../shared/api_provider.dart';
import '../shared/extension.dart';
import '../widget/header.dart';
import '../widget/show_loading.dart';
import 'order_details.dart';

class ToSuccessPage extends StatefulWidget {
  const ToSuccessPage({Key? key}) : super(key: key);

  @override
  State<ToSuccessPage> createState() => _ToSuccessPageState();
}

class _ToSuccessPageState extends State<ToSuccessPage> {
  late Future<dynamic> _futureModel;
  bool loading = false;

  List<dynamic> orderModel = [
    {
      "code": "1",
      "title": "ปุ๋ยเคมี",
      "price": 99000,
      "qty": "2",
      "discount": 0,
      "priceTotal": 203000,
      "shipping": 5000,
      "imageUrl": "assets/images/mock_pro_1.png",
      "purchaseDate": "10/10/2568 10:30:00",
      "paidDate": "10/10/2568 10:35:00",
      "destination_shipped_at": "15/10/2568",
      "trackingCode": "ES83990293818",
      "receiptShipping": "receiptShipping.pdf",
      "receipt": "receipt.pdf",
      "taxId": "1004293962218",
      "phone": "0999999999",
      "name": "สมศักดิ์ ศักดิ์สม",
      "shipped_at": "15/10/2568",
      "address": {
        "no": "19/1-2 ชั้น8 ห้อง8บี ซ.ยาสูบ1 ถ.วิภาวดีรังสิต",
        "subDistrict": "จอมพล",
        "district": "จตุจักร",
        "province": "กรุงเทพมหานครฯ",
        "postNo": "10900"
      },
      "status": "30"
    }
  ];

  @override
  void initState() {
    // _futureModel = Future.value(order); // mock
    // _callRead();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _callRead() {
    _futureModel = get(server + 'orders?statuses=[30,40]');
  }

  _calculatePrice(List<dynamic> param) {
    int a = 0;
    param.forEach((e) {
      a += ((e['total'] ?? 0) as num).toInt();
      // e['items'].forEach((ee) => {
      //       a += ee['price'] * ee['amount'],
      //     });
    });
    return 'ยอดรวมส่วนนี้ ' + moneyFormat(a.toString()) + ' บาท';
  }

  updateStatus(item) async {
    setState(() {
      loading = true;
    });
    var status = item['status'];
    if (item['status'] == 'W') status = 'P';
    if (item['status'] == 'P') status = 'A';
    await postDio('${server}m/cart/order/status/update', {
      'code': item['orderNoReference'],
      'status': status,
    });
    setState(() {
      _futureModel = postDio('${server}m/cart/order/read', {'status': 'W'});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: headerCentral(context, title: 'เสร็จสิ้น'),
        body: SafeArea(
          child: ShowLoadingWidget(
            loading: loading,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) => orderModel.length > 0
                    ? _buildListCategory(orderModel[index])
                    : SizedBox(),
                separatorBuilder: (_, __) => SizedBox(height: 0),
                itemCount: orderModel.length,
              ),
              // FutureBuilder(
              //   future: _futureModel,
              //   builder: (context, snapshot) {
              //     if (snapshot.hasData) {
              //       loading = false;
              //       if (snapshot.data.length > 0) {
              //         return ListView.separated(
              //           shrinkWrap: true,
              //           physics: ClampingScrollPhysics(),
              //           padding: EdgeInsets.zero,
              //           itemBuilder: (context, index) => snapshot
              //                       .data[index]['order_details']['data']
              //                       .length >
              //                   0
              //               ? _buildListCategory(snapshot.data[index])
              //               : SizedBox(),
              //           separatorBuilder: (_, __) => SizedBox(height: 0),
              //           itemCount: snapshot.data.length,
              //         );
              //       } else {
              //         return Center(
              //           child: Text('ไม่มีรายการ'),
              //         );
              //       }
              //     } else if (snapshot.hasError) {
              //       if (snapshot.data == null) {
              //         return Center(
              //           child: Text('ไม่มีรายการ'),
              //         );
              //       } else {
              //         return DataError();
              //       }
              //     } else {
              //       return Container();
              //     }
              //   },
              // )
            ],
          ),
        ));
  }

  _buildListCategory(dynamic param) {
    return Container(
        color: Colors.white,
        margin: EdgeInsets.only(
            // bottom: 10.0,
            top: 10),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsPage(
                  model: param,
                  statusText: 'เสร็จสิ้น',
                  modePage: "30",
                ),
              ),
            );
          },
          child: Column(
            children: [
              // SizedBox(height: 5),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     Container(
              //       height: 25,
              //       padding: EdgeInsets.symmetric(horizontal: 15),
              //       alignment: Alignment.center,
              //       decoration: BoxDecoration(
              //         color: Color(0xFFE3E6FE),
              //         borderRadius: BorderRadius.circular(
              //           12.5,
              //         ),
              //       ),
              //       child: Text(
              //         'กำลังดำเนินการ',
              //         style: TextStyle(
              //           fontSize: 13,
              //           color: Color(0xFF0B24FB),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),

              // ListView.separated(
              //   shrinkWrap: true,
              //   physics: ClampingScrollPhysics(),
              //   padding: EdgeInsets.zero,
              //   itemBuilder: (context, index) =>
              //       _buildListProductInOrder(param['order_details']['data'][index]),
              //   separatorBuilder: (_, __) => SizedBox(height: 10),
              //   itemCount: param['order_details']['data'].length,
              // ),

              _buildListProductInOrder(param ?? ''),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    // padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      // _calculatePrice(param['total']),
                      'ยอดรวมส่วนนี้ ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    // padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      // _calculatePrice(param['total']),
                      moneyFormat(param['priceTotal'].toString()) + ' บาท',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              param['status'] == '30'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () {
                              // _acceptProduct(param['code']);
                            },
                            style: ElevatedButton.styleFrom(
                              // primary: Color.fromARGB(255, 208, 141, 147),
                              backgroundColor: Color(0xFF33cd32),
                              // backgroundColor: Colors.teal,
                              side: BorderSide(
                                  color: Color(0xFF33cd32),
                                  width: 1,
                                  style: BorderStyle.solid),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                              ),
                            ),
                            child: Text(
                              'ยอมรับสินค้า',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ),
                        )
                        // MaterialButton(
                        //   height: 50,
                        //   // minWidth: 168,
                        //   shape: RoundedRectangleBorder(
                        //       borderRadius: new BorderRadius.circular(25)),
                        //   onPressed: () {
                        //     _acceptProduct(param['id']);
                        //     // toPay(param['id']);
                        //   },
                        //   child: Container(
                        //     color: Color(0xFF33cd32),

                        //     alignment: Alignment.center,
                        //     // height: double.infinity,
                        //     height: 40,
                        //     width: 120,
                        //     child: Text(
                        //       'ยอมรับสินค้า',
                        //       style: TextStyle(
                        //         fontSize: 20,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    )
                  : Container(),
              // SizedBox(height: 10),

              // MaterialButton(
              //   height: 50,
              //   // minWidth: 168,
              //   // shape: RoundedRectangleBorder(
              //   //     borderRadius: new BorderRadius.circular(25)),
              //   onPressed: () {
              //     // toPay(param['id']);
              //   },
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       Container(
              //         child: Text(
              //           'ดูรายละเอียดสินค้า',
              //           style: TextStyle(
              //             fontSize: 20,
              //             color: Color(0xFFDF0B24),
              //           ),
              //         ),
              //       ),
              //       Container(
              //         child: Icon(
              //           Icons.chevron_right,
              //           color: Color(0xFFDF0B24),
              //           size: 20,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ));
  }

  _buildListProductInOrder(param) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 5),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  _getProductById(param['code']);
                  // Navigator.pop(context);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    param['imageUrl'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      // height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            param['title'],
                            style: TextStyle(
                              fontSize: 13,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${moneyFormat(param['price'].toString())} บาท',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'จำนวน ' + param['qty'].toString(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
      ],
      //     // ),
      //     SizedBox(height: 10),
      //   ],
      // ) :
    );
  }

  _getProductById(param) async {
    var res = await getData(server + 'products' + param);
  }

  Widget _buildItem(dynamic param) {
    return GestureDetector(
      onLongPress: () => updateStatus(param),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: loadingImageNetwork(
                    param['imageUrl'],
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        param['title'],
                        style: TextStyle(
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        param['goodsTitle'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF707070),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              moneyFormat(param['price'].toString()) + ' บาท',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            'จำนวน ${param['qty']}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  toPay(order_id) {
    dynamic modelData = {
      'payment_type': '3',
      // 'order_id': 'order_BYW95EGWJDN6VK'
      'order_id': order_id
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentStatusCentralPage(model: modelData),
      ),
    );
  }

  _acceptProduct(param) {
    put(server + 'orders/' + param, {}).then((value) => {
          setState(() {
            _callRead();
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return WillPopScope(
                    onWillPop: () {
                      return Future.value(false);
                    },
                    child: CupertinoAlertDialog(
                      title: new Text(
                        'ยอมรับสินค้าแล้ว',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Kanit',
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      content: Text(" "),
                      actions: [
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          child: new Text(
                            "ตกลง",
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Kanit',
                              color: Color(0xFFFF7514),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => VerifyPhonePage(),
                            //   ),
                            // );
                          },
                        ),
                      ],
                    ),
                  );
                });
          }),
        });
  }
}
