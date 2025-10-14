import 'package:flutter/material.dart';
import 'package:kaset_mall/component/loading_image_network.dart';
import 'package:kaset_mall/reviews_add.dart';
import 'package:kaset_mall/shared/api_provider.dart';
import 'package:kaset_mall/widget/data_error.dart';
import 'package:kaset_mall/widget/header.dart';

import 'order_details.dart';

class ToRateCentralPage extends StatefulWidget {
  const ToRateCentralPage({Key? key}) : super(key: key);

  @override
  State<ToRateCentralPage> createState() => _ToRateCentralPageState();
}

class _ToRateCentralPageState extends State<ToRateCentralPage> {
  late Future<dynamic> _futureModel;
  bool loading = false;
  late List<dynamic> modelUsersMeReviews;
  bool resultOrderId = false;
  bool resultProductId = false;
  String result = '';

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
    // _futureModel = Future.value(toRate);
    // read();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  read() async {
    // modelUsersMeReviews = await get(server + 'users/me/reviews');
    modelUsersMeReviews =
        await get(server + 'users/me/order-details/review-pending');
    return get(server + 'users/me/order-details/review-pending');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerCentral(context, title: 'ที่ต้องรีวิว'),
      body: _buildListOrder(orderModel),
      // FutureBuilder<dynamic>(
      //   future: read(),
      //   builder: (context, snapshot) {
      //     if (snapshot.hasData) {
      //       if (snapshot.data.length > 0) {
      //         return _buildListOrder(snapshot.data);
      //       } else {
      //         return Center(
      //           child: Text('ยังไม่มีสินค้าที่ต้องรีวิว'),
      //         );
      //       }
      //     } else if (snapshot.hasError) {
      //       if (snapshot.data == null){
      //         return Center(
      //           child: Text('ยังไม่มีสินค้าที่ต้องรีวิว'),
      //         );
      //       }else {
      //         return DataError();
      //       }
      //     } else {
      //       return Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //   },
      // ),
    );
  }

  Widget _buildListOrder(List<dynamic> param) {
    return ListView.separated(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10),
      itemBuilder: (context, index) => _buildItem(param[index]),
      separatorBuilder: (_, __) => Container(
        height: 10,
        color: Color(0xFFF7F7F7),
      ),
      itemCount: param.length,
    );
  }

  // _buildOrder(dynamic param) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
  //     color: Colors.white,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.end,
  //       children: [
  //         _buildItem(
  //             // param['id'],
  //             param,
  //           ),
  //         // ListView.separated(
  //         //   shrinkWrap: true,
  //         //   physics: ClampingScrollPhysics(),
  //         //   padding: EdgeInsets.zero,
  //         //   itemBuilder: (context, index) => _buildItem(
  //         //     param['id'],
  //         //     param[index],
  //         //   ),
  //         //   separatorBuilder: (_, __) => SizedBox(height: 20),
  //         //   itemCount: param.length,
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  // _buildListCategory(dynamic param) {
  //   return Column(
  //     children: [
  //       SizedBox(height: 5),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             param['title'],
  //             style: TextStyle(
  //               fontSize: 17,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ],
  //       ),
  //       SizedBox(height: 10),
  //       ListView.separated(
  //         shrinkWrap: true,
  //         physics: ClampingScrollPhysics(),
  //         padding: EdgeInsets.zero,
  //         itemBuilder: (context, index) => _buildItem(param['items'][index]),
  //         separatorBuilder: (_, __) => SizedBox(height: 10),
  //         itemCount: param['items'].length,
  //       ),
  //     ],
  //   );
  // }

  Widget _buildItem(dynamic param) {
    // resultOrderId =
    //     modelUsersMeReviews.any((e) => e['orderId'] == orderId);

    // resultProductId = modelUsersMeReviews.any(
    //     (e) => e['product']['data']['id'] == param['product']['data']['id']);

    // if (resultOrderId && resultProductId) {
    //   result = 'true';
    // }
    return
        // InkWell(
        //   onTap: () {
        //     // Navigator.push(
        //     //       context,
        //     //       MaterialPageRoute(
        //     //         builder: (_) => OrderDetailsPage(
        //     //           model: param,
        //     //         ),
        //     //       ),
        //     //     );
        //   },
        //   child:
        Column(
      children: [
        SizedBox(
          height: 80,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
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
                    Expanded(
                      child: Text(
                        param['title'],
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: result != 'true'
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewsAddPage(
                                    orderId: param['code'],
                                    modelProductData: param,
                                    modelMediaData: param,
                                  ),
                                ),
                              )
                          : null,
                      child: Container(
                        alignment: Alignment.centerRight,
                        width: double.infinity,
                        child: Container(
                          height: 25,
                          padding: EdgeInsets.symmetric(horizontal: 28),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: result != 'true'
                                  ? Color(0xFFDF0B24)
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'รีวิว',
                            style: TextStyle(
                              fontSize: 15,
                              color: result != 'true'
                                  ? Color(0xFFDF0B24)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // );
  }
  //
}
