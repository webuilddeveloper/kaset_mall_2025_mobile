// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/component/toast_fail.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/to_rate.dart';
import 'package:kasetmall/widget/image_picker.dart';
import 'package:kasetmall/widget/loading_page.dart';
import '../widget/header.dart';
import 'package:http_parser/http_parser.dart';

class ReviewsAddPage extends StatefulWidget {
  ReviewsAddPage({
    Key? key,
    this.orderId,
    this.modelProductData,
    this.modelMediaData,
  }) : super(key: key);
  final String? orderId;
  final dynamic modelProductData;
  final dynamic modelMediaData;

  @override
  _ReviewsAddPageState createState() => _ReviewsAddPageState();
}

class _ReviewsAddPageState extends State<ReviewsAddPage> {
  TextEditingController commentController = TextEditingController();
  var _formKey = new GlobalKey<FormState>();
  Random random = new Random();
  bool loading = false;
  dynamic _rating;
  String imagePDF = 'assets/images/pdf.png';
  bool loadingImage = false;
  late XFile imageReviews;
  String image = '';
  List<dynamic> imageList = [];
  late FormData mapData;
  List<MultipartFile> futureMultipartFile = [];
  dynamic futureMultipartFile0;
  dynamic futureMultipartFile1;
  dynamic futureMultipartFile2;
  dynamic futureMultipartFile3;
  dynamic futureMultipartFile4;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    commentController.dispose();
    super.dispose();
  }

  _uploadImage(file) {
    setState(() {
      loadingImage = true;
    });
    uploadImage(file).then((res) {
      String fileName = file.path.split('/').last;
      String fileType = fileName.split('.').last;
      // var id = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        image = res;
        loadingImage = false;
        imageList.add({
          'value': image,
          'id': random.nextInt(100),
          'file': file,
          'fileName': fileName,
          'fileType': fileType,
        });
        // image = server + res,
        // showLoadingImage = false,
      });
    }).catchError((err) {
      setState(() {
        loadingImage = false;
      });
      return toastFail(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerCentral(
        context,
        title: 'เขียนรีวิว',
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: loading
            ? LoadingPage()
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      children: _buildList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  ClipRRect _listViewImageList() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        children: [
          ...imageList
              .map<Widget>(
                (e) => Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Stack(
                    children: [
                      Container(
                        height: double.infinity,
                        width: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Color(
                              0xFFE4E4E4,
                            ))),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: loadingImageNetwork(e['value'],
                              fit: BoxFit.contain),
                        ),
                      ),
                      Positioned(
                        right: 3,
                        top: 3,
                        child: GestureDetector(
                          onTap: (() {
                            setState(
                              () => imageList.removeWhere(
                                (c) => c['id'] == e['id'],
                              ),
                            );
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(
                                15,
                              ),
                            ),
                            child: Icon(
                              Icons.remove_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
              .toList(),
          imageList.length >= 5
              ? Container()
              : Center(
                  child: _imageUploadPicker(),
                ),
        ],
      ),
    );
  }

  _imageUploadPicker() {
    return ImageUploadPicker(
      callback: (file) => {
        setState(
          () {
            _uploadImage(file);
          },
        ),
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/kaset/add_image_file.png',
              height: 50,
              width: 50,
            ),
          ),
          Text(
            'สามารถเพิ่มไฟล์รูปภาพได้สูงสุด 5 รูป',
            style: TextStyle(fontSize: 13, color: Colors.red),
          ),
        ],
      ),
    );
  }

  _ratingBar() {
    return Center(
      child: RatingBar.builder(
        initialRating: 1,
        minRating: 1,
        direction: Axis.horizontal,
        // allowHalfRating: true,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          setState(() {
            _rating = rating.toInt();
          });
        },
      ),
    );
  }

  _buildList() {
    return <Widget>[
      SizedBox(
        height: 80,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.modelMediaData['imageUrl'],
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
                      widget.modelProductData['title'],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleName('comment'),
            _textData('comment', commentController, maxLines: 10),
            SizedBox(height: 40),
            Container(
              height: 150,
              padding: EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  width: 1,
                  color: Color(0xFFE4E4E4),
                ),
              ),
              child: imageList.length == 0
                  ? _imageUploadPicker()
                  : _listViewImageList(),
            ),
            SizedBox(height: 40),
            _ratingBar(),
          ],
        ),
      ),
      SizedBox(height: 40),
      Container(
        // bottom: 50,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 45,
            child: Material(
              elevation: 0,
              borderRadius: BorderRadius.circular(25.0),
              color: Color(0xFFDF0B24),
              child: MaterialButton(
                onPressed: () async {
                  // final form = _formKey.currentState;
                  // if (form!.validate()) {
                  //   save();
                  // } else {}
                  _showDialog('ขอคุณสำหรับการรีวิวสินค้า').then((value) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ToRateCentralPage(),
                      ),
                    );
                  });
                },
                child: new Text(
                  'บันทึก',
                  style: new TextStyle(
                    fontSize: 25.0,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
    ];
  }

  _titleName(title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 15,
          // fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _textData(
    title,
    TextEditingController textC, {
    TextInputType textI = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
  }) {
    return SizedBox(
      height: maxLines != 1 ? null : 40,
      child: new TextFormField(
        validator: (model) {
          if (model!.isEmpty) {
            return 'กรุณากรอก' + title + '.';
          } else {
            return null;
          }
        },
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: textI,
        textInputAction: TextInputAction.next,
        controller: textC,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w300,
          color: Colors.black,
        ),
        cursorColor: Color(0xFF0B24FB),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Color(0xFF0B24FB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Color(0xFF0B24FB)),
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
          contentPadding: EdgeInsets.all(15),
          // labelText: "กรุณากรอกหมายเลขบัตร",
          hintText: title,
        ),
        onSaved: (String? value) {},
      ),
    );
  }

  fromMapData(data) {
    return MultipartFile.fromFileSync(
      data['file'].path,
      filename: data['fileName'],
      contentType: MediaType('image', data['fileType']),
    );
    // futureMultipartFile.add(a);
    // for (var i = 0; i >= imageListlength; i++) {
    //   // MultipartFile.fromFile(
    //   //   imageList[i]['file'].path,
    //   //   filename: imageList[i]['fileName'],
    //   //   contentType: MediaType('image', imageList[i]['fileType']),
    //   // );
    // }

    // if (imageListlength != 0) {
    //   if (imageListlength > 0) {
    //     setState(() {
    //       futureMultipartFile0 = MultipartFile.fromFile(
    //         imageList[0]['file'].path,
    //         filename: imageList[0]['fileName'],
    //         contentType: MediaType('image', imageList[0]['fileType']),
    //       );
    //     });
    //   }
    //   if (imageListlength > 1) {
    //     setState(() {
    //       futureMultipartFile1 = MultipartFile.fromFile(
    //         imageList[1]['file'].path,
    //         filename: imageList[1]['fileName'],
    //         contentType: MediaType('image', imageList[1]['fileType']),
    //       );
    //     });
    //   }
    //   if (imageListlength > 2) {
    //     setState(() {
    //       futureMultipartFile2 = MultipartFile.fromFile(
    //         imageList[2]['file'].path,
    //         filename: imageList[2]['fileName'],
    //         contentType: MediaType('image', imageList[2]['fileType']),
    //       );
    //     });
    //   }
    //   if (imageListlength > 3) {
    //     setState(() {
    //       futureMultipartFile3 = MultipartFile.fromFile(
    //         imageList[3]['file'].path,
    //         filename: imageList[3]['fileName'],
    //         contentType: MediaType('image', imageList[3]['fileType']),
    //       );
    //     });
    //   }
    //   if (imageListlength > 4) {
    //     setState(() {
    //       futureMultipartFile4 = MultipartFile.fromFile(
    //         imageList[4]['file'].path,
    //         filename: imageList[4]['fileName'],
    //         contentType: MediaType('image', imageList[4]['fileType']),
    //       );
    //     });
    //   }
  }

  save() async {
    mapData = FormData.fromMap({
      // 'product_id': widget.modelProductData['id'],
      'order_detail_id': widget.orderId,
      'rating': _rating,
      'comment': commentController.text,
      // 'photos': [await futureMultipartFile0, await futureMultipartFile1],
    });

    var c = 0;
    for (var i in imageList) {
      mapData.files.addAll([
        MapEntry(
          'photos[$c]',
          fromMapData(i),
        ),
      ]);
      c++;
    }

    // futureMultipartFile.add(futureMultipartFile0);
    // futureMultipartFile.add(futureMultipartFile1);

    // mapData = FormData.fromMap({
    //   'product_id': widget.modelProductData['id'],
    //   'order_id': widget.orderId,
    //   'rating': _rating,
    //   'comment': commentController.text,
    //   // 'photos': [await futureMultipartFile0, await futureMultipartFile1],
    // });

    // mapData.files.addAll([
    //   MapEntry(
    //     'photos[0]',
    //     await futureMultipartFile0,
    //   ),
    // ]);

    // mapData.files.addAll([
    //   MapEntry(
    //     'photos[1]',
    //     await futureMultipartFile1,
    //   ),
    // ]);

    // if (imageList.length == 1) {
    //   mapData = FormData.fromMap({
    //     'product_id': widget.modelProductData['id'],
    //     'order_id': widget.orderId,
    //     'rating': _rating,
    //     'comment': commentController.text,
    //     'photos[0]': await futureMultipartFile0,
    //   });
    // } else if (imageList.length == 2) {
    //   mapData = FormData.fromMap({
    //     'product_id': widget.modelProductData['id'],
    //     'order_id': widget.orderId,
    //     'rating': _rating,
    //     'comment': commentController.text,
    //     'photos[0]': await futureMultipartFile0,
    //     'photos[1]': await futureMultipartFile1,
    //   });
    // } else if (imageList.length == 3) {
    //   mapData = FormData.fromMap({
    //     'product_id': widget.modelProductData['id'],
    //     'order_id': widget.orderId,
    //     'rating': _rating,
    //     'comment': commentController.text,
    //     'photos[0]': await futureMultipartFile0,
    //     'photos[1]': await futureMultipartFile1,
    //     'photos[2]': await futureMultipartFile2,
    //   });
    // } else if (imageList.length == 4) {
    //   mapData = FormData.fromMap({
    //     'product_id': widget.modelProductData['id'],
    //     'order_id': widget.orderId,
    //     'rating': _rating,
    //     'comment': commentController.text,
    //     'photos[0]': await futureMultipartFile0,
    //     'photos[1]': await futureMultipartFile1,
    //     'photos[2]': await futureMultipartFile2,
    //     'photos[3]': await futureMultipartFile3,
    //   });
    // } else if (imageList.length == 5) {
    //   mapData = FormData.fromMap({
    //     'product_id': widget.modelProductData['id'],
    //     'order_id': widget.orderId,
    //     'rating': _rating,
    //     'comment': commentController.text,
    //     'photos[0]': await futureMultipartFile0,
    //     'photos[1]': await futureMultipartFile1,
    //     'photos[2]': await futureMultipartFile2,
    //     'photos[3]': await futureMultipartFile3,
    //     'photos[4]': await futureMultipartFile4,
    //   });
    // } else {
    //   mapData = FormData.fromMap({
    //     'product_id': widget.modelProductData['id'],
    //     'order_id': widget.orderId,
    //     'rating': _rating,
    //     'comment': commentController.text,
    //   });
    // }

    var result = await postFormData(server + 'reviews', mapData);
    var message = '';
    // var product_idErrors = '';
    // var order_idErrors = '';
    // var ratingErrors = '';
    // var commentErrors = '';
    // if (result['message'] != null) {
    //   setState(() {
    //     message = result['message'];
    //     // product_idErrors = result['errors']['product_id'][0];
    //     // order_idErrors = result['errors']['order_id'][0];
    //     // ratingErrors = result['errors']['rating'][0];
    //     // commentErrors = result['errors']['comment'][0];
    //   });
    // }
    print('mapData >>>> ${result}');
    if (result != null) {
      if (message != '') {
        _showDialog(
          message,
          // product_idErrors: product_idErrors,
          // order_idErrors: order_idErrors,
          // ratingErrors: ratingErrors,
          // commentErrors: commentErrors,
        );
      } else {
        _showDialog('Success').then((value) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ToRateCentralPage(),
            ),
          );
        });
      }
    } else {}
  }

  _showDialog(
    String title,
    // String product_idErrors,
    // String order_idErrors,
    // String ratingErrors,
    // String commentErrors,
  ) {
    // String errors = '';
    // if (product_idErrors != '' &&
    //     order_idErrors != '' &&
    //     ratingErrors != '' &&
    //     commentErrors != '') {
    //   errors =
    //       '${product_idErrors}\n${order_idErrors}\n${ratingErrors}\n${commentErrors}';
    // } else if (product_idErrors != '' &&
    //     order_idErrors != '' &&
    //     ratingErrors != '') {
    //   errors = '${product_idErrors}\n${order_idErrors}\n${ratingErrors}';
    // } else if (product_idErrors != '' && order_idErrors != '') {
    //   errors = '${product_idErrors}\n${order_idErrors}';
    // } else if (product_idErrors != '') {
    //   errors = '${product_idErrors}';
    // } else {
    //   errors = '';
    // }
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: new Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              // content: errors != '' ? Text(errors) : null,
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    "กลับหน้าหลัก",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFF09665a),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }
  //
}
