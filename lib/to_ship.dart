import 'package:flutter/material.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/shared/extension.dart';
import 'package:kasetmall/widget/header.dart';
import 'package:kasetmall/widget/show_loading.dart';

import 'order_details.dart';

class ToShipCentralPage extends StatefulWidget {
  const ToShipCentralPage({Key? key}) : super(key: key);

  @override
  State<ToShipCentralPage> createState() => _ToShipCentralPageState();
}

class _ToShipCentralPageState extends State<ToShipCentralPage> {
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
      "imageUrl":
          "https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255709298.png",
      "purchaseDate": "10/10/2568 10:30:00",
      "paidDate": "10/10/2568 10:35:00",
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
      }
    }
  ];

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _callRead() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: headerCentral(context, title: 'กำลังจัดเตรียม'),
        body: SafeArea(
          child: ShowLoadingWidget(
            loading: loading,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) => orderModel.length > 0
                    ? _buildListCategory(
                        orderModel[index],
                      )
                    : SizedBox(),
                separatorBuilder: (_, __) => SizedBox(height: 0),
                itemCount: orderModel.length,
              )
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
              //               ? _buildListCategory(
              //                   snapshot.data[index],
              //                 )
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
              //       // return DataError();
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
                  statusText: 'กำลังจัดเตรียม',
                  modePage: "10",
                ),
              ),
            );
          },
          child: Column(
            children: [
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 25,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFFE3E6FE),
                      borderRadius: BorderRadius.circular(
                        12.5,
                      ),
                    ),
                    child: Text(
                      'กำลังจัดเตรียม',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF09665a),
                      ),
                    ),
                  ),
                ],
              ),
              // ListView.separated(
              //   shrinkWrap: true,
              //   physics: ClampingScrollPhysics(),
              //   padding: EdgeInsets.zero,
              //   itemBuilder: (context, index) => _buildListProductInOrder(
              //       param['order_details']['data'][index]),
              //   separatorBuilder: (_, __) => SizedBox(height: 10),
              //   itemCount: param['order_details']['data'].length,
              // ),

              _buildListProductInOrder(param ?? ''),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                decoration: BoxDecoration(
                  color: Color(0xFFFBE3E6),
                  borderRadius: BorderRadius.circular(
                    12.5,
                  ),
                ),
                child: Text(
                  // 'พัสดุจะถูกส่งมอบให้บริษัทขนส่งภายในวันที่ ${dateThai(param['shipped_at']).toString()}',
                  'พัสดุจะถูกส่งมอบให้บริษัทขนส่งภายในวันที่ ${param['shipped_at']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFDF0B24),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
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
              // InkWell(
              //   onTap: () {
              //     // _getProductById(param['product']['data']['id']);
              //     // Navigator.pop(context);
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => OrderDetailsPage(
              //           model: param,
              //         ),
              //       ),
              //     );
              //   },
              //   child:
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      // _getProductById(param['code']);
                      // Navigator.pop(context);
                    },
                    // loadingImageNetwork(
                    //         param['imageUrl'],
                    //         width: 90,
                    //         height: 90,
                    //         fit: BoxFit.cover,
                    //       )
                    child: param['imageUrl'] != null
                        ? Image.network(
                            param['imageUrl'],
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
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
                  //               color: Color(0xFF09665a),
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     : SizedBox(),
                ],
              ),

              // ),
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

        //   ],
        // ),
        SizedBox(height: 10),
      ],
    );
  }


}
