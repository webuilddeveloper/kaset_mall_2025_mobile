// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';
import 'package:kasetmall/to_rate.dart';
import 'package:kasetmall/widget/image_picker.dart';
import 'package:kasetmall/widget/loading_page.dart';

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
  bool loadingImage = false;
  String image = '';
  List<dynamic> imageList = [];

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
    Future<void>.delayed(const Duration(milliseconds: 120)).then((_) {
      String fileName = file.path.split('/').last;
      setState(() {
        image = file.path;
        loadingImage = false;
        imageList.add({
          'value': file.path,
          'id': random.nextInt(100),
          'file': file,
          'fileName': fileName,
        });
        // image = server + res,
        // showLoadingImage = false,
      });
    });
  }

  Widget _buildProductImage(String? source) {
    final value = (source ?? '').trim();
    if (value.isEmpty) {
      return Container(
        color: AppColors.tintGreenSoft,
        alignment: Alignment.center,
        child: const Icon(
          Icons.inventory_2_outlined,
          color: AppColors.primary,
          size: 30,
        ),
      );
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Image.network(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.tintGreenSoft,
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (value.startsWith('file://')) {
      final file = File(Uri.parse(value).toFilePath());
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    } else {
      final file = File(value);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    return Image.asset(
      value,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.tintGreenSoft,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _productTitle() {
    final raw = widget.modelProductData;
    if (raw is Map) {
      return (raw['title'] ?? raw['name'] ?? raw['productName'] ?? 'สินค้า')
          .toString();
    }
    return 'สินค้า';
  }

  String _productImage() {
    final raw = widget.modelMediaData;
    if (raw is Map) {
      return (raw['imageUrl'] ?? raw['image'] ?? raw['path'] ?? '').toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KasetAppBar(title: 'เขียนรีวิว'),
      backgroundColor: AppColors.background,
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
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF143D16).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 74,
                height: 74,
                color: AppColors.tintGreenSoft,
                child: _buildProductImage(_productImage()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.tintGreenSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'รีวิวสินค้า',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _productTitle(),
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      _sectionCard(
        title: 'ความคิดเห็น',
        child: Form(
          key: _formKey,
          child: _textData(
            'ความคิดเห็น',
            commentController,
            maxLines: 6,
          ),
        ),
      ),
      const SizedBox(height: 14),
      _sectionCard(
        title: 'รูปภาพประกอบ',
        subtitle: 'เพิ่มรูปได้สูงสุด 5 รูป',
        child: Container(
          height: 156,
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child:
              imageList.isEmpty ? _imageUploadPicker() : _listViewImageList(),
        ),
      ),
      const SizedBox(height: 14),
      _sectionCard(
        title: 'คะแนนสินค้า',
        child: Column(
          children: [
            _ratingBar(),
            const SizedBox(height: 10),
            const Text(
              'แตะดาวเพื่อให้คะแนนประสบการณ์จริงของคุณ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : () async => save(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            disabledBackgroundColor: AppColors.border,
            disabledForegroundColor: AppColors.textSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'บันทึก',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFamily: 'Kanit',
            ),
          ),
        ),
      ),
      SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
    ];
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D16).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
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
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          fillColor: AppColors.background,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: AppColors.border,
            ),
          ),
          errorStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 10.0,
          ),
          contentPadding: const EdgeInsets.all(15),
          hintText: 'กรอก$title',
        ),
        onSaved: (String? value) {},
      ),
    );
  }

  save() async {
    final now = DateTime.now().toIso8601String();
    if ((widget.orderId ?? '').toString().isNotEmpty) {
      await OrderStore.updateOrderStatus(
        widget.orderId.toString(),
        'reviewed',
        reviewedAt: now,
      );
      await OrderStore.updateOrderReview(
        widget.orderId.toString(),
        rating: _rating,
        comment: commentController.text.trim(),
        images: imageList
            .map((e) => (e['value'] ?? '').toString())
            .where((e) => e.isNotEmpty)
            .toList(),
        reviewedAt: now,
      );
    }
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
