// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/component/toast_fail.dart';
import 'package:kasetmall/confirm_order.dart';
import 'package:kasetmall/menu.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_dialog.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';
import 'package:kasetmall/widget/show_loading.dart';

class CartCentralPage extends StatefulWidget {
  const CartCentralPage({Key? key, this.changePage}) : super(key: key);

  @override
  State<CartCentralPage> createState() => _CartCentralPageState();
  final Function? changePage;
}

class AdaptiveTextSize {
  const AdaptiveTextSize();

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 720) *
        ((MediaQuery.of(context).size.height +
                MediaQuery.of(context).size.width) /
            1.6);
  }
}

class ScaleSize {
  static double textScaleFactor(BuildContext context,
      {double maxTextScaleFactor = 1.5}) {
    final width = MediaQuery.of(context).size.width;
    final aspectratio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;
    double val = (width / 1080) * aspectratio;
    return max(1, min(val, aspectratio));
  }
}

class _CartCentralPageState extends State<CartCentralPage> {
  List<dynamic> model = [];
  List<dynamic> selectedProduct = [];
  bool loading = true;
  String imageMock =
      'http://122.155.223.63/td-doc/images/news/news_221814384.jpg';
  bool buyAll = false;
  String verifyPhonePage = 'true';
  String profilePhone = '1';
  String? verifyPhone;
  final storage = new FlutterSecureStorage();
  String profileCode = "";
  String? emailProfile;
  int totalPrice = 0;
  late final VoidCallback _cartListener;
  @override
  initState() {
    super.initState();

    setState(() {});

    _cartListener = () {
      if (mounted) {
        _readLocalCart();
      }
    };
    MockStore.cartVersion.addListener(_cartListener);
    _readLocalCart();
  }

  @override
  void dispose() {
    MockStore.cartVersion.removeListener(_cartListener);
    super.dispose();
  }

  _readLocalCart() async {
    setState(() {
      loading = true;
    });

    final storage = FlutterSecureStorage();
    String? cartData = await storage.read(key: 'cartItems');

    if (cartData != null && cartData.isNotEmpty) {
      List<dynamic> cartList = jsonDecode(cartData);

      setState(() {
        model = cartList.map((item) {
          final normalized = OrderItemNormalizer.normalize(
            Map<String, dynamic>.from(item as Map),
          );
          normalized['selected'] = item['selected'] == true;
          return normalized;
        }).toList();
        loading = false;
      });
    } else {
      setState(() {
        model = [];
        loading = false;
      });
    }
  }

  Future<void> checkItem(int indexItem) async {
    if (model[indexItem]['stock'] > 0) {
      setState(
        () {
          model[indexItem]['selected'] = !model[indexItem]['selected'];
        },
      );
      await _saveCartToStorage();
    }
    return;
  }

  Future<void> checkAll() async {
    final nextValue = !(model.isNotEmpty && model.every((e) => e['selected'] == true));
    setState(
      () {
        buyAll = nextValue;
        model.forEach(
          (e) {
            if (e['stock'] > 0) {
              e['selected'] = nextValue;
            }
            ;
          },
        );
      },
    );
    await _saveCartToStorage();
  }

  String _priceAll() {
    num totalPrice = 0;

    for (var item in model) {
      if (item['selected'] == true) {
        num price = num.tryParse(item['price'].toString()) ?? 0;
        num qty = num.tryParse(item['qty'].toString()) ?? 0;
        totalPrice += (price * qty);
      }
    }

    return '${formatPrice(totalPrice.round().toString())} บาท';
  }

  String formatPrice(dynamic price) {
    if (price == null) return '0';
    final number = num.tryParse(price.toString()) ?? 0;
    return NumberFormat('#,###').format(number);
  }

  _changeCarts(action, param) async {
    if (action == 0) {
      if (param['qty'] == 1) {
        return null;
      } else {
        setState(() {
          param['qty']--;
        });
        await _saveCartToStorage();
      }
    } else {
      int stock = param['stock'] ?? 999;

      if (param['qty'] >= stock) {
        toastFail(context, text: 'สินค้าเหลือเพียง $stock ชิ้น เท่านั้น');
        return null;
      } else {
        setState(() {
          param['qty']++;
        });
        await _saveCartToStorage();
      }
    }
  }

  Future<void> _saveCartToStorage() async {
    final storage = FlutterSecureStorage();
    String cartData = jsonEncode(model);
    await storage.write(key: 'cartItems', value: cartData);
    MockStore.cartVersion.value++;
  }

  Future<void> _deleteCartItem(String id) async {
    setState(() {
      loading = true;
    });
    model.removeWhere((item) => item['id'].toString() == id);
    await _saveCartToStorage();
    await _readLocalCart();
  }

  deleteAll() async {
    setState(() {
      loading = true;
    });
    model.removeWhere((item) => item['selected'] == true);
    await _saveCartToStorage();

    setState(() {
      loading = false;
      buyAll = false;
    });
  }

  readProduct(param) async {
    var result;
    await get(server + 'products/' + param).then((value) => {
          setState(
            () {
              result = value;
            },
          )
        });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KasetAppBar(
        title: 'ตะกร้า',
        showBackButton: true,
        onBack: () {
          if (widget.changePage != null) {
            widget.changePage!(0);
          } else {
            Navigator.pop(context);
          }
        },
        actions: [
          if (model.where((x) => x['selected'] == true).isNotEmpty)
            GestureDetector(
              onTap: _buildDialogDeleteAll,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Text(
                    'ลบ',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ShowLoadingWidget(
        loading: loading,
        children: [
          if (model.isEmpty)
            _cartEmpty()
          else
            ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                85 + MediaQuery.of(context).padding.bottom,
              ),
              physics: const ClampingScrollPhysics(),
              children: [
                for (int i = 0; i < model.length; i++) _buildCard(model[i], i),
                const SizedBox(height: 8),
                _buildCartSummaryCard(),
              ],
            ),
        ],
      ),
    );
  }

  // _buildGroup(dynamic param, index) {
  //   return Container(
  //     color: Colors.white,
  //     padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
  //     child: Column(
  //       children: [
  //         // Row(
  //         //   children: [
  //         //     GestureDetector(
  //         //       onTap: () {
  //         //         setState(() => {
  //         //               model[index]['selected'] = !model[index]['selected'],
  //         //             });
  //         //         model[index]['items'].forEach(
  //         //           (e) {
  //         //             setState(() {
  //         //               e['selected'] = model[index]['selected'];
  //         //             });
  //         //           },
  //         //         );
  //         //       },
  //         //       child: SizedBox(
  //         //         width: 20,
  //         //         child: Icon(
  //         //           param['selected']
  //         //               ? Icons.check_box_rounded
  //         //               : Icons.check_box_outline_blank_rounded,
  //         //           color: param['selected']
  //         //               ? Color(0xFFDF0B24)
  //         //               : Color(0xFF707070),
  //         //           size: 25,
  //         //         ),
  //         //       ),
  //         //     ),
  //         //     SizedBox(width: 10),
  //         //     Text('${param['lv1ShopName']}')
  //         //   ],
  //         // ),
  //         SizedBox(height: 5),
  //         ListView.separated(
  //           shrinkWrap: true,
  //           padding: EdgeInsets.zero,
  //           physics: ClampingScrollPhysics(),
  //           itemBuilder: (context, indexItem) =>
  //               _buildCard(param[indexItem], index, indexItem),
  //           separatorBuilder: (_, __) => SizedBox(height: 10),
  //           itemCount: param.length,
  //         )
  //       ],
  //     ),
  //   );
  // }

  _buildCard(param, indexItem) {
    final qty = num.tryParse(param['qty'].toString()) ?? 1;
    final price = num.tryParse(param['price'].toString()) ?? 0;
    final stock = num.tryParse(param['stock']?.toString() ?? '0') ?? 0;
    final total = price * qty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              flex: 2,
              onPressed: (_) => _buildDialogDelete(indexItem, param['id']),
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              icon: Icons.delete_forever,
              label: 'ลบ',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () async {},
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => checkItem(indexItem),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: param['selected']
                          ? AppColors.tintGreenSoft
                          : const Color(0xFFF7F8F7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      param['selected']
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: param['selected']
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: param['image'] != null
                            ? loadingImageNetwork(
                                param['image'],
                                width: 74,
                                height: 74,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/kaset/no-img.png',
                                fit: BoxFit.contain,
                                width: 74,
                                height: 74,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              param['name'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${formatPrice(total.round().toString())} บาท',
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _CartQtyButton(
                                  icon: Icons.remove,
                                  enabled: param['qty'] > 1,
                                  onTap: () => _changeCarts(0, param),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 42,
                                  height: 34,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.tintGreenSoft,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    param['qty'].toString(),
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _CartQtyButton(
                                  icon: Icons.add,
                                  enabled: stock == 0 || param['qty'] < stock,
                                  onTap: () => _changeCarts(1, param),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _CartQtyButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.tintGreenSoft : const Color(0xFFF7F8F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 17,
          color: enabled ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildCartSummaryCard() {
    final selectedCount = model.where((x) => x['selected'] == true).length;
    final hasSelection = selectedCount > 0;
    final allSelected =
        model.isNotEmpty && model.every((e) => e['selected'] == true);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: checkAll,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: allSelected
                        ? AppColors.tintGreenSoft
                        : const Color(0xFFF7F8F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    allSelected
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color:
                        allSelected ? AppColors.primary : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'เลือกทั้งหมด',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _priceAll(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '$selectedCount รายการ',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: hasSelection
                  ? () async {
                      final data = <dynamic>[];

                      for (final e in model) {
                        if (e['selected']) {
                          data.add({
                            'productId': e['productId'] ?? e['id'] ?? '',
                            'name': e['name'] ?? '',
                            'image': e['image'] ?? '',
                            'imageUrl': e['imageUrl'] ?? e['image'] ?? '',
                            'price': e['price'] ?? 0,
                            'qty': e['qty'] ?? 1,
                            'quantity': e['qty'] ?? 1,
                            'shopName': e['shopName'] ?? '',
                            'cart_id': e['id'],
                          });
                        }
                      }

                      if (data.isNotEmpty) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConfirmOrderCentralPage(
                                modelCode: data, type: 'cart'),
                          ),
                        );
                        await _readLocalCart();
                      } else {
                        toastFail(context,
                            text: 'กรุณาเลือกสินค้าที่ต้องการชำระเงิน');
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                disabledForegroundColor: AppColors.textSecondary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'ชำระเงิน',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _cartEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ตะกร้ายังว่างอยู่',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 15),
          Image.asset(
            'assets/images/kaset/basket.png',
            height: 50,
            width: 50,
            color: AppColors.primary,
          ),
          SizedBox(height: 15),
          InkWell(
            onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MenuCentralPage()),
                (route) => false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.tintGreenSoft,
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'กลับไปเลือกสินค้า',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 14.5,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // _cartNoVerify() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text(
  //           'บัญชีนี้ยังไม่ได้ยืนยันเบอร์โทรศัพท์',
  //           style: TextStyle(fontFamily: 'Kanit', fontSize: 18),
  //         ),
  //         SizedBox(height: 15),
  //         Icon(Icons.perm_device_info, size: 70, color: Color(0xFFDF0B24)),
  //         // Image.asset(
  //         //   'assets/images/kaset/basket.png',
  //         //   height: 50,
  //         //   width: 50,
  //         //   color: Color(0xFF09665a),
  //         // ),
  //         SizedBox(height: 15),
  //         InkWell(
  //           onTap: () {},
  //           // Navigator.pushAndRemoveUntil(
  //           //     context,
  //           //     MaterialPageRoute(builder: (context) => VerifyPhonePage()),
  //           //     (route) => false),
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(3),
  //               border: Border.all(
  //                 width: 1,
  //                 color: Color(0xFFDF0B24),
  //               ),
  //             ),
  //             child: Text(
  //               'ยืนยันเบอร์โทรศัพท์',
  //               style: TextStyle(
  //                 fontFamily: 'Kanit',
  //                 fontSize: 15,
  //                 color: Color(0xFFDF0B24),
  //               ),
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  // _cartNoAddPhone() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text(
  //           'บัญชีนี้ยังไม่ได้เพิ่มเบอร์โทรศัพท์',
  //           style: TextStyle(fontFamily: 'Kanit', fontSize: 18),
  //         ),
  //         SizedBox(height: 15),
  //         Icon(Icons.add_call, size: 70, color: Color(0xFFDF0B24)),
  //         // Image.asset(
  //         //   'assets/images/kaset/basket.png',
  //         //   height: 50,
  //         //   width: 50,
  //         //   color: Color(0xFF09665a),
  //         // ),
  //         SizedBox(height: 15),
  //         InkWell(
  //           onTap: () => {
  //             // Navigator.push(
  //             //     context,
  //             //     MaterialPageRoute(
  //             //       builder: (BuildContext context) =>
  //             //           UserProfileForm(mode: "addPhone"),
  //             //     )).then((value) => {_readProfile()})
  //           },
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(3),
  //               border: Border.all(
  //                 width: 1,
  //                 color: Color(0xFFDF0B24),
  //               ),
  //             ),
  //             child: Text(
  //               'เพิ่มเบอร์โทรศัพท์',
  //               style: TextStyle(
  //                 fontFamily: 'Kanit',
  //                 fontSize: 15,
  //                 color: Color(0xFFDF0B24),
  //               ),
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  _buildDialogDelete(index, id) {
    return AppDialog.show(
      context: context,
      title: 'ลบสินค้า',
      description: 'คุณต้องการลบสินค้ารายการนี้ออกจากตะกร้าหรือไม่',
      primaryText: 'ลบ',
      secondaryText: 'ยกเลิก',
      icon: Icons.delete_outline_rounded,
      primaryColor: AppColors.accent,
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteCartItem(id.toString());
      }
    });
  }

  _buildDialogDeleteAll() {
    return AppDialog.show(
      context: context,
      title: 'ลบรายการที่เลือก',
      description: 'คุณต้องการลบสินค้าที่เลือกทั้งหมดออกจากตะกร้าหรือไม่',
      primaryText: 'ลบ',
      secondaryText: 'ยกเลิก',
      icon: Icons.delete_sweep_outlined,
      primaryColor: AppColors.accent,
    ).then((confirmed) {
      if (confirmed == true) {
        deleteAll();
      }
    });
  }
}
