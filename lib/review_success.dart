import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/widget/data_error.dart';

import '../component/gallery_view.dart';
import '../component/loading_image_network.dart';
import '../widget/header.dart';
import 'cart.dart';

class ReviewSuccessPage extends StatefulWidget {
  const ReviewSuccessPage({Key? key}) : super(key: key);

  @override
  State<ReviewSuccessPage> createState() => _ReviewSuccessPageState();
}

class _ReviewSuccessPageState extends State<ReviewSuccessPage> {
  late Future<dynamic> _futureModel;
  String result = '';
  late List<dynamic> imageVariantsList;

  @override
  void initState() {
    // _futureModel = Future.value(toRate);
    read();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  read() async {
    // modelUsersMeReviews = await get(server + 'users/me/reviews');
    _futureModel = get(server + 'users/me/reviews?');
    // return get(server + 'users/me/order-details/review-pending');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerCentral(context, title: 'สินค้าที่รีวิวแล้ว'),
      body: FutureBuilder<dynamic>(
        future: _futureModel,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return _buildListOrder(snapshot.data);
            } else {
              return Center(
                child: Text('ยังไม่มีรายการ'),
              );
            }
          } else if (snapshot.hasError) {
            if (snapshot.data == null) {
              return Center(
                child: Text('ยังไม่มีรายการ'),
              );
            } else {
              return DataError();
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildListOrder(param) {
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

  Widget _buildItem(dynamic param) {
    List<dynamic> images = param == null ? [] : param['media']['data'];
    print('============== ${param['media']['data']}');
    return Column(
      children: [
        Container(
          height: param['media']['data'].length > 0 ? 170 : 140,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: loadingImageNetwork(
                  param['product']['data']['media']['data'][0]['url'],
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
                        param['product']['data']['name'],
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFFE4E4E4),
                            borderRadius: BorderRadius.circular(
                              7,
                            ),
                          ),
                          child: Text(
                            _get_product_variant(
                                param['product_variant_id'],
                                param['product']['data']['product_variants']
                                    ['data']),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                            textScaleFactor: ScaleSize.textScaleFactor(context),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    RatingBar.builder(
                      ignoreGestures: true,
                      initialRating: double.parse(param['rating'].toString()),
                      minRating: 1,
                      direction: Axis.horizontal,
                      // allowHalfRating: true,
                      itemCount: 5,
                      // itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemSize: 15, onRatingUpdate: (double value) {},
                      // onRatingUpdate: (rating) {
                      //   setState(() {
                      //     _rating = rating.toInt();
                      //   });
                      // },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Text(
                        param['comment'],
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    param['media']['data'].length > 0
                        ? Container(
                            height: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 30),
                            padding: EdgeInsets.only(top: 0),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              separatorBuilder: (_, __) => SizedBox(width: 5),
                              itemCount: param['media']['data'].length,
                              itemBuilder: (context, index) => ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: GestureDetector(
                                  onTap: () {
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (context) {
                                        return ImageViewer(
                                          initialIndex: 0,
                                          imageProviders: images
                                                  .map((e) =>
                                                      NetworkImage(e['url']))
                                                  .toList() ??
                                              [],
                                        );
                                      },
                                    );
                                  },
                                  child:
                                      // Text(param['media']['data'][index]['url'].toString())
                                      loadingImageNetwork(
                                    // _checkImage(param['media']['data'][index]['url']),
                                    param['media']['data'][index]['url'],
                                    height: AdaptiveTextSize()
                                        .getadaptiveTextSize(context, 50),
                                    width: AdaptiveTextSize()
                                        .getadaptiveTextSize(context, 50),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    // InkWell(
                    //   onTap:
                    //   result != 'true'
                    //       ? () =>
                    //       Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => ReviewsAddPage(
                    //                 orderId: param['order_id'],
                    //                 modelProductData: param['product']['data'],
                    //                 modelMediaData: param['media']['data'],
                    //               ),
                    //             ),
                    //           )
                    //       :
                    //       null,
                    //   child: Container(
                    //     alignment: Alignment.centerRight,
                    //     width: double.infinity,
                    //     child: Container(
                    //       height: 25,
                    //       padding: EdgeInsets.symmetric(horizontal: 28),
                    //       decoration: BoxDecoration(
                    //         border: Border.all(
                    //           width: 1,
                    //           color: result != 'true'
                    //               ? Color(0xFFDF0B24)
                    //               : Colors.grey,
                    //         ),
                    //         borderRadius: BorderRadius.circular(18),
                    //       ),
                    //       child: Text(
                    //         'รีวิว',
                    //         style: TextStyle(
                    //           fontSize: 15,
                    //           color: result != 'true'
                    //               ? Color(0xFFDF0B24)
                    //               : Colors.grey,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
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

  _get_product_variant(String variant_id, List<dynamic> variant_list) {
    if (variant_id == null) {
      return null;
    } else {
      var variant_value = variant_list.firstWhere((i) => i['id'] == variant_id);
      return variant_value['name'] ?? variant_value['sku'];
    }
  }

  _checkImage(param) {
    if (param['media_id'] == null) {
      return null;
    } else {
      var url =
          imageVariantsList.firstWhere((i) => i['id'] == param['media_id']);
      return url['url'];
    }
  }
}
