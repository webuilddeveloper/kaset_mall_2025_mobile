import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:mobile_mart_v3/component/loading_image_network.dart';
import 'package:mobile_mart_v3/component/toast_fail.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/shared/extension.dart';
import 'package:mobile_mart_v3/widget/data_error.dart';
import 'package:mobile_mart_v3/widget/header.dart';
import 'package:mobile_mart_v3/widget/show_loading.dart';

import 'order_details.dart';

class ToReceiveCentralPage extends StatefulWidget {
  const ToReceiveCentralPage({Key? key}) : super(key: key);

  @override
  State<ToReceiveCentralPage> createState() => _ToReceiveCentralPageState();
}

class _ToReceiveCentralPageState extends State<ToReceiveCentralPage> {
  late Future<dynamic> _futureModel;
  bool loading = false;

  @override
  void initState() {
    // _futureModel = Future.value(order); // mock
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _callRead() {
    _futureModel = get(server + 'orders?statuses=20');
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
        appBar: headerCentral(context, title: 'ระหว่างขนส่ง'),
        body: SafeArea(
          child: ShowLoadingWidget(
            loading: loading,
            children: [
              FutureBuilder(
                future: _futureModel,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    loading = false;
                    if (snapshot.data.length > 0) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) => 
                        snapshot
                                    .data[index]['order_details']['data']
                                    .length >
                                0
                            ? 
                        _buildListCategory(
                          snapshot.data[index],
                        ) : SizedBox(),
                        separatorBuilder: (_, __) => SizedBox(height: 0),
                        itemCount: snapshot.data.length,
                      );
                    } else {
                      return Center(
                        child: Text('ยังไม่มีสินค้าที่เตรียมจัดส่ง'),
                      );
                    }
                  } else if (snapshot.hasError) {
                    if(snapshot.data == null) {
                      return Center(
                        child: Text('ไม่มีรายการ'),
                      );
                    }else {
                      return DataError();
                    }
                  } else {
                    return Container();
                  }
                },
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
                  statusText: 'ระหว่างขนส่ง',
                  modePage: "20",
                ),
              ),
            );
        },
        child: Column(
          children: [
            SizedBox(height: 5),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'คำสั่งซื้อ',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  param['id'] ?? "",
                  style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                decoration: BoxDecoration(
                  color: Color(0xFFFBE3E6),
                  borderRadius: BorderRadius.circular(
                    12.5,
                  ),
                ),
                child: Text(
                  'ท่านจะได้รับพัสดุภายในวันที่ ${dateThai(param['destination_shipped_at']).toString()}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFDF0B24),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              ],
            ),
            SizedBox(height: 10),
            // ListView.separated(
            //   shrinkWrap: true,
            //   physics: ClampingScrollPhysics(),
            //   padding: EdgeInsets.zero,
            //   itemBuilder: (context, index) =>
            //       _buildListProductInOrder(param['order_details']['data'][index]),
            //   separatorBuilder: (_, __) => SizedBox(height: 10),
            //   itemCount: param['order_details']['data'].length,
            // ),
            _buildListProductInOrder(param['order_details']['data'] ?? ''),
            Row(
              children: [
                Text(
                  // _calculatePrice(param['total']),
                  'หมายเลขติดตามพัสดุ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  // _calculatePrice(param['total']),
                  param['tracking_code'] ?? "-",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () async =>
                      await FlutterClipboard.copy(param['tracking_code'] ?? "")
                          .then(
                    (value) => toastFail(context, text: '✓  คัดลอกสำเร็จ'),
                  ),
                  child: Image.asset(
                    'assets/images/central/copy_clipboard.png',
                    height: 25,
                    width: 25,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
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
              //     _getProductById(param['product']['data']['id']);
              //     // Navigator.pop(context);
              //   },
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(5),
              //     child: param['media']['data']['url'] != null
              //         ? loadingImageNetwork(
              //             param['media']['data']['url'],
              //             width: 80,
              //             height: 80,
              //             fit: BoxFit.cover,
              //           )
              //         : Image.asset(
              //             'assets/images/no_image.png',
              //             fit: BoxFit.cover,
              //             width: 80,
              //             height: 80,
              //           ),
              //   ),
              // ),
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      _getProductById(param[0]['product']['data']['id']);
                      // Navigator.pop(context);
                    },
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: param[0]['media']['data']['url'] != null
                      ? loadingImageNetwork(
                          param[0]['media']['data']['url'],
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/no_image.png',
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                        ),
                ),
                  ),
                param.length > 1 ?
                Positioned(
                      right: 10,
                      // top: 0,
                      bottom: 5,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // shape: BoxShape.circle,
                          color: Color(0XFFE3E6FE),
                          borderRadius: BorderRadius.all(Radius.circular(25))
                        ),
                        child: Text(
                         '${param.length > 99 ? '99+' : param.length.toString()} ชิ้น',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 12,
                            color: Color(0xFF0B24FB),
                          ),
                        ),
                      ),
                    ) : SizedBox(),
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
                            param[0]['product']['data']['name'],
                            style: TextStyle(
                              fontSize: 13,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          height: 25,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFFE4E4E4),
                            borderRadius: BorderRadius.circular(
                              7,
                            ),
                          ),
                          child: Text(
                            param[0]['product_variant']['data']['name'] ??
                                param[0]['product_variant']['data']['sku'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${moneyFormat(param[0]['product_variant']['data']['price'].toString() ?? '')} บาท',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'จำนวน ' + (param[0]['quantity'].toString() ?? ''),
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
}
