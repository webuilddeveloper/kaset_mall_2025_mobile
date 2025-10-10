import 'package:flutter/material.dart';
import 'package:mobile_mart_v3/chats_staff.dart';
import 'package:mobile_mart_v3/component/loading_image_network.dart';
import 'package:mobile_mart_v3/order_details.dart';
import 'package:mobile_mart_v3/payment_status.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/shared/extension.dart';
import 'package:mobile_mart_v3/widget/data_error.dart';
import 'package:mobile_mart_v3/widget/header.dart';
import 'package:mobile_mart_v3/widget/show_loading.dart';

class ToPayCentralPage extends StatefulWidget {
  const ToPayCentralPage({Key? key}) : super(key: key);

  @override
  State<ToPayCentralPage> createState() => _ToPayCentralPageState();
}

class _ToPayCentralPageState extends State<ToPayCentralPage> {
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
      "taxId": "1004293962218",
      "phone": "0999999999",
      "name": "สมศักดิ์ ศักดิ์สม",
      "address": {
        "no": "19/1-2 ชั้น8 ห้อง8บี ซ.ยาสูบ1 ถ.วิภาวดีรังสิต",
        "subDistrict": "จอมพล",
        "district": "จตุจักร",
        "province": "กรุงเทพมหานครฯ",
        "postNo": "10900"
      }
    }
  ];
  late String _userId;
  late String _username;

  @override
  void initState() {
    // _futureModel = Future.value(order); // mock
    // _callRead();
    _readUser();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _callRead() {
    _futureModel = get(server + 'orders?statuses=[0, 1]');
  }

  _readUser() async {
    // try {
    //   final result = await get(server + 'users/me');
    //   print('Result: $result');
    //   // print(result['id']);
    //   if (result != null) {
    //     _userId = result['id'];
    //     _username = result['name'];
    //   } else {
    //     print('No result from API');
    //   }
    // } catch (e) {
    //   print('Error fetching user data: $e');
    // }
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
        appBar: headerCentral(context, title: 'ที่ต้องชำระเงิน'),
        body: SafeArea(
          child: ShowLoadingWidget(
            loading: loading,
            children: [
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
              //           child: Text('ยังไม่มีสินค้าที่ต้องชำระเงิน'),
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

              ListView.separated(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) =>
                    orderModel.length > 0
                        ? _buildListCategory(orderModel[index])
                        : SizedBox(),
                separatorBuilder: (_, __) => SizedBox(height: 0),
                itemCount: orderModel.length,
              )
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
                  statusText: 'รอชำระเงิน',
                  modePage: "0",
                ),
              ),
            );
          },
          child: Column(
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      
                    },

                    style: ElevatedButton.styleFrom(
                      // primary: Color.fromARGB(255, 208, 141, 147),
                      backgroundColor: Color(0xFFDF0B24),
                      // backgroundColor: Colors.teal,
                      side: BorderSide(
                          color: Color(0xFFDF0B24),
                          width: 1,
                          style: BorderStyle.solid),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                      ),
                    ),
                    child: Text(
                      'แชท',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      toPay(param['id']);
                    },
                    style: ElevatedButton.styleFrom(
                      // primary: Color.fromARGB(255, 208, 141, 147),
                      backgroundColor: Color(0xFFDF0B24),
                      // backgroundColor: Colors.teal,
                      side: BorderSide(
                          color: Color(0xFFDF0B24),
                          width: 1,
                          style: BorderStyle.solid),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                      ),
                    ),
                    child: Text(
                      'ชำระเงิน',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                  // MaterialButton(
                  //   height: 50,
                  //   // minWidth: 168,
                  //   shape: RoundedRectangleBorder(
                  //       borderRadius: new BorderRadius.circular(25)),
                  //   onPressed: () {
                  //     toPay(param['id']);
                  //   },
                  //   child: Container(
                  //     color: Color(0xFFDF0B24),
                  //     alignment: Alignment.center,
                  //     // height: double.infinity,
                  //     height: 40,
                  //     width: 120,
                  //     child: Text(
                  //       'ชำระเงิน',
                  //       style: TextStyle(
                  //         fontSize: 20,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              // SizedBox(height: 10),

              // MaterialButton(
              //   height: 50,
              //   // minWidth: 168,
              //   // shape: RoundedRectangleBorder(
              //   //     borderRadius: new BorderRadius.circular(25)),
              //   onPressed: () {
              //     //toPay (param['id']);
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
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      // _getProductById(param[0]['product']['data']['id']);
                      // Navigator.pop(context);
                    },
                    child: param['imageUrl'] != null
                        ? loadingImageNetwork(
                            param['imageUrl'],
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/kaset/no-img.png',
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                          ),
                  ),
                  // param.length > 1
                  //     ? Positioned(
                  //         right: 10,
                  //         // top: 0,
                  //         bottom: 5,
                  //         child: Container(
                  //           padding: EdgeInsets.symmetric(horizontal: 6),
                  //           alignment: Alignment.center,
                  //           decoration: BoxDecoration(
                  //               // shape: BoxShape.circle,
                  //               color: Color(0XFFE3E6FE),
                  //               borderRadius:
                  //                   BorderRadius.all(Radius.circular(25))),
                  //           child: Text(
                  //             '${param.length > 99 ? '99+' : param.length.toString()} ชิ้น',
                  //             style: TextStyle(
                  //               fontFamily: 'Kanit',
                  //               fontSize: 12,
                  //               color: Color(0xFF0B24FB),
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     : SizedBox(),
                ],
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
    print('----------order_id---------------${order_id}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentStatusCentralPage(model: modelData),
      ),
    );
  }
}
