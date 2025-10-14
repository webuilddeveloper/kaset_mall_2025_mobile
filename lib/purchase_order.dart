// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasetmall/purchase_menu.dart';
import 'dart:math';
import 'package:kasetmall/purchase_shipping.dart';

class purchaseOrder extends StatefulWidget {
  final dynamic result;

  final dynamic draftorder;
  const purchaseOrder({
    Key? key,
    required this.result,
    this.draftorder,
  }) : super(key: key);

  @override
  State<purchaseOrder> createState() => _purchaseOrderState();
}

class _purchaseOrderState extends State<purchaseOrder>
    with WidgetsBindingObserver {
  String? selectedValue;
  List<dynamic> orderCart = [];

  TextEditingController searchController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  String searchText = '';
  List<Map<String, dynamic>> filteredProducts = [];
  Map<String, dynamic>? selectedProduct;
  FocusNode searchFocusNode = FocusNode();

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  bool showSuggestions = false;
  final List<Map<String, dynamic>> PurchaseItem = [];
  Map<String, dynamic> purchaseproduct = {};
  bool _isLoadding = false;

  List<String> level = [
    "ทุกระดับชั้นการศึกษา",
    "ประถมฯ",
    "ม.ต้น",
    "ม.ปลาย",
  ];

  void initState() {
    super.initState();
    _loadData();
    filteredProducts = [];
    searchFocusNode.addListener(() {
      if (searchFocusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
    searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = Navigator.of(context);
      navigator.focusNode.enclosingScope!.addListener(() {
        if (navigator.focusNode.enclosingScope!.hasFocus && mounted) {
          _loadData();
        }
      });
    });
  }

  Future<void> _loadData() async {
    await getstocklist().then((_) {
      if (mounted) {
        setState(() {
          if (purchaseproduct.containsKey('result') &&
              purchaseproduct['result'] != null) {
            filteredProducts =
                List<Map<String, dynamic>>.from(purchaseproduct['result']);
          }
        });
      }
    });

    await getordercart();
  }

  Future<void> getstocklist() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };

    String levelParam = "all";

    print('เลือกระดับชั้น: ${selectedValue}');

    if (selectedValue != null) {
      switch (selectedValue) {
        case "ทุกระดับชั้นการศึกษา":
          levelParam = "all";
          break;
        case "ประถมฯ":
          levelParam = "M1";
          break;
        case "ม.ต้น":
          levelParam = "M2";
          break;
        case "ม.ปลาย":
          levelParam = "M3";
          break;
      }
    }

    var data = json.encode({"level": levelParam});
    var dio = Dio();
    try {
      var response = await dio.request(
        'https://etranscript.suksapan.or.th/otepmobileapi/getstocklist.php',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        setState(() {
          purchaseproduct = response.data;
          if (purchaseproduct.containsKey('result') &&
              purchaseproduct['result'] != null) {
            filteredProducts =
                List<Map<String, dynamic>>.from(purchaseproduct['result']);
          } else {
            filteredProducts = [];
          }
        });
      } else {
        print('API error: ${response.statusCode} - ${response.statusMessage}');
        setState(() {
          filteredProducts = [];
        });
      }
    } catch (e) {
      print('Error fetching stock list: $e');
      setState(() {
        filteredProducts = [];
      });
    }
  }

  Future<void> getordercart() async {
    setState(() {
      _isLoadding = true;
    });
    try {
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
        'Content-Type': 'application/json'
      };
      print(widget.result['transactionid']);

      var data = json.encode({
        "transactionid": (widget.draftorder?.isEmpty ?? true)
            ? widget.result['transactionid']
            : widget.draftorder
      });

      var dio = Dio();
      var response = await dio.request(
        'https://etranscript.suksapan.or.th/otepmobileapi/getordercartlist.php',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print(json.encode(response.data));

        setState(() {
          orderCart = response.data['result'];
        });
      }
    } catch (e) {
      print('Error in getordercart: $e');
      setState(() {
        orderCart = [];
      });
    } finally {
      setState(() {
        _isLoadding = false;
      });
    }
  }

  Future<void> removeItem({
    required String orderCart,
  }) async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({
      "id": orderCart,
      "transactionid": (widget.draftorder?.isEmpty ?? true)
          ? widget.result['transactionid']
          : widget.draftorder
    });
    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/orderdeletelist.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print(json.encode(response.data));
    } else {
      print(response.statusMessage);
    }
  }

  void _filterProducts() {
    if (purchaseproduct.containsKey('result') &&
        purchaseproduct['result'] != null) {
      var allProducts =
          List<Map<String, dynamic>>.from(purchaseproduct['result']);

      if (searchText.isNotEmpty) {
        filteredProducts = allProducts.where((product) {
          if (product.containsKey('name')) {
            final bool matches = product['name']
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase());
            return matches;
          }
          return false;
        }).toList();
      } else {
        filteredProducts = allProducts;
      }
    } else {
      filteredProducts = [];
    }
  }

  double calculateTotal(List<Map<String, dynamic>> items) {
    double total = 0;
    for (var item in items) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchController.dispose();
    quantityController.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchText = searchController.text;
      _filterProducts();

      if (searchText.isNotEmpty) {
        if (!showSuggestions) {
          _showOverlay();
        } else {
          _overlayEntry?.markNeedsBuild();
        }
      } else {
        _hideOverlay();
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _hideOverlay();
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    showSuggestions = true;
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    showSuggestions = false;
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, 45.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: StatefulBuilder(builder: (context, setStateOverlay) {
              return Container(
                height: filteredProducts.isEmpty
                    ? 50
                    : min(200, filteredProducts.length * 50.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF707070)),
                ),
                child: filteredProducts.isEmpty
                    ? Center(child: Text('ไม่พบรายการ'))
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            dense: true,
                            title: Text(
                              filteredProducts[index]['name'],
                              style: TextStyle(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              setState(() {
                                selectedProduct = filteredProducts[index];

                                searchController.text =
                                    filteredProducts[index]['name'];
                                _hideOverlay();
                                searchFocusNode.unfocus();
                              });
                            },
                          );
                        },
                      ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาเลือกสินค้าก่อน'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int quantity = 1;

    try {
      quantity = int.parse(quantityController.text);
      if (quantity <= 0) throw FormatException('จำนวนต้องมากกว่า 0');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาระบุจำนวนสินค้าที่ถูกต้อง'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };

    var data = json.encode({
      "uid": widget.result['uid'],
      "cartid": selectedProduct!['cartid'],
      "quantity": quantity,
      "transactionid": (widget.draftorder?.isEmpty ?? true)
          ? widget.result['transactionid']
          : widget.draftorder,
      "schoolid": widget.result['schoolid'],
    });
    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/orderinsertlist.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print('---------_addToCart-----------');
      print(json.encode(response.data));
      print(response.data['returnmessage']);
      response.data['returnmessage'] == 'success'
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('เพิ่มสินค้าสำเร็จ'),
                backgroundColor: Colors.green,
              ),
            )
          : ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('เพิ่มสินค้าไม่สำเร็จ'),
                backgroundColor: Colors.red,
              ),
            );

      quantityController.clear();
      searchController.clear();
      selectedValue = null;
      getordercart();
    } else {
      print(response.statusMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF012A6C),
        leading: Padding(
          padding: EdgeInsets.only(left: 12),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigator.popUntil(context, (route) => route.isFirst);
              if (widget.draftorder == null) {
                Navigator.popUntil(context, (route) => route.isFirst);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        title: Center(
            child: Text(
          'ออกใบขอสั่งซื้อ ',
          style: TextStyle(color: Colors.white),
        )),
        actions: [
          Padding(
            padding: EdgeInsets.only(left: 12),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.transparent,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(right: 15, left: 15, top: 20, bottom: 40),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ระดับชั้นการศึกษา',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Container(
                  height: 45,
                  child: DropdownButtonFormField<String>(
                    value: selectedValue,
                    isDense: true,
                    decoration: InputDecoration(
                      hintText: 'เลือกระดับชั้นการศึกษา',
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF707070)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF707070)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF012A6C)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: level.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlign: TextAlign.start,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue;
                        getstocklist().then((_) {
                          _filterProducts();
                        });
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'รายการสินค้า',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 8),
              CompositedTransformTarget(
                link: _layerLink,
                child: Container(
                  height: 45,
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'กรุณากรอกคำค้นหา',
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: ImageIcon(
                          AssetImage('assets/icon_Searching.png'),
                          color: Colors.black,
                        ),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF707070)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF707070)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF012A6C)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'จำนวนสินค้า',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'กรุณากรอกจำนวนสินค้า',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF707070)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF707070)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF012A6C)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF012A6C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'เพิ่มสินค้า',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 1,
                color: Colors.black.withOpacity(0.2),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'รายการสินค้า  ${orderCart.length}',
                  style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              _isLoadding
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : orderCart.isEmpty
                      ? Center(
                          child: Text(
                          'ไม่พบข้อมูล โปรดพิมพ์คำค้นหาที่ท่านต้องการ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ))
                      : Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF707070).withOpacity(0.2),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.only(top: 10),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(
                              color: Color(0xFFDCE0E5),
                              height: 30,
                            ),
                            itemCount: orderCart.length,
                            itemBuilder: (context, index) {
                              final item = orderCart[index];
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 5,
                                                  child: GestureDetector(
                                                    child: Text(
                                                      item['name'],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      maxLines: 3,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: IconButton(
                                                    onPressed: () async {
                                                      await removeItem(
                                                          orderCart:
                                                              orderCart[index]
                                                                  ['id']);
                                                      setState(() {
                                                        orderCart
                                                            .removeAt(index);
                                                      });
                                                    },
                                                    icon: Image.asset(
                                                      'assets/delete-bin.png',
                                                      fit: BoxFit.contain,
                                                      height: 35,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          height: 25,
                                                          width: 35,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: item['typeprint'] ==
                                                                    'ปพ.1:ป'
                                                                ? Color(
                                                                    0xFFFBD5E6)
                                                                : item['typeprint'] ==
                                                                        'ปพ.1:บ'
                                                                    ? Color(
                                                                        0xFFD5F7FB)
                                                                    : Color(
                                                                        0xFFFDE86C),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              item['typeprint'],
                                                              style: TextStyle(
                                                                  fontSize: 8),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                        if (item['type'] == 'T')
                                                          Container(
                                                            height: 25,
                                                            width: 35,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFFFC8D8F),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                'อนุมัติ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        8),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                        Container(
                                                          height: 25,
                                                          width: 35,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFFFC8D8F),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              'อนุมัติ',
                                                              style: TextStyle(
                                                                  fontSize: 8),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                        if (item['type'] == 'P')
                                                          Container(
                                                            height: 25,
                                                            width: 35,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFFBEFEC7),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                'ออนไลน์',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        8),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                        Text(
                                                          '${item['priceCart']} บาท / ${item['unit']} ',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                          maxLines: 3,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center, // <<< ให้กลางด้วย
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.15,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          border: Border.all(
                                                            color: Color(
                                                                0xFF707070),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '${item['quantityCart']}',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color(
                                                                  0xFF012A6C),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
              SizedBox(height: 20),
              orderCart.length > 0
                  ? Row(
                      children: [
                        Container(
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          'รายการสินค้าที่ท่านเลือก มีสินค้าควบคุมต้องได้รับการอนุมัติ',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (orderCart.length > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchaseShipping(
                          allItems: orderCart,
                          result: widget.result,
                          orderid: widget.draftorder,
                        ),
                      ),
                    ).then((_) {
                      setState(() {});
                    });
                  }
                },
                child: Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: orderCart.length > 0
                        ? Color(0xFF012A6C)
                        : Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'สรุปรายการสินค้า',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
