// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PurchaseOrderShippingSumEdit extends StatefulWidget {
  final dynamic order;
  const PurchaseOrderShippingSumEdit({
    Key? key,
    required this.order,
  }) : super(key: key);
  @override
  State<PurchaseOrderShippingSumEdit> createState() =>
      _PurchaseOrderShippingSumEditState();
}

class _PurchaseOrderShippingSumEditState
    extends State<PurchaseOrderShippingSumEdit> {
  void initState() {
    super.initState();
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
              Navigator.pop(context);
            },
          ),
        ),
        title: Center(
            child: Text(
          'ใบขอสั่งซื้อ',
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
      // body: SingleChildScrollView(
      //   child: Padding(
      //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      //     child: Column(
      //       children: [
      //         Align(
      //           alignment: Alignment.centerRight,
      //           child: Container(
      //             padding:
      //                 const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      //             decoration: BoxDecoration(
      //               color: _getStatusColor(widget.order['status']),
      //               borderRadius: BorderRadius.circular(12),
      //             ),
      //             child: Column(
      //               children: [
      //                 Row(
      //                   mainAxisSize: MainAxisSize.min,
      //                   children: [
      //                     _getStatusIcon(widget.order['status']),
      //                     const SizedBox(width: 6),
      //                     Text(
      //                       "${widget.order['status']}",
      //                       overflow: TextOverflow.ellipsis,
      //                       style: TextStyle(
      //                         color:
      //                             _getStatusColorFont(widget.order['status']),
      //                         fontSize: 12,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //         SizedBox(height: 20),
      //         Column(
      //           children: [
      //             Row(
      //               children: [
      //                 Container(
      //                   width: 12,
      //                   height: 12,
      //                   decoration: BoxDecoration(
      //                     borderRadius: BorderRadius.circular(10),
      //                     color: Color(0xFFD92D20),
      //                   ),
      //                 ),
      //                 SizedBox(width: 12),
      //                 Align(
      //                   alignment: Alignment.centerLeft,
      //                   child: Text(
      //                     'สาเหตุการไม่อนุมัติ',
      //                     style: TextStyle(
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.w600,
      //                         color: Colors.black),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             SizedBox(height: 12),
      //             Container(
      //               width: double.infinity,
      //               decoration: BoxDecoration(
      //                 color: Colors.white,
      //                 borderRadius: BorderRadius.circular(20),
      //                 border: Border.all(color: Colors.black.withOpacity(0.2)),
      //               ),
      //               child: Padding(
      //                 padding: const EdgeInsets.all(16.0),
      //                 child: Text(
      //                   'คำสั่งซื้อไม่ตรงกับหนังสืออนุมัติการสั่งซื้อจากเขต',
      //                   style: TextStyle(
      //                       fontSize: 18, fontWeight: FontWeight.w600),
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //         SizedBox(height: 20),
      //         Container(
      //           width: double.infinity,
      //           decoration: BoxDecoration(
      //             color: Colors.white,
      //             borderRadius: BorderRadius.circular(20),
      //             border: Border.all(color: Colors.black.withOpacity(0.2)),
      //           ),
      //           child: Padding(
      //             padding: const EdgeInsets.all(16.0),
      //             child: Column(
      //               children: [
      //                 Column(
      //                   children: [
      //                     Container(
      //                       child: Padding(
      //                         padding: const EdgeInsets.symmetric(vertical: 8),
      //                         child: Column(
      //                           children: [
      //                             Row(
      //                               mainAxisAlignment:
      //                                   MainAxisAlignment.spaceBetween,
      //                               children: [
      //                                 Text(
      //                                   'หมายเลขคำสั่งซื้อ',
      //                                   style: TextStyle(
      //                                       fontSize: 20,
      //                                       fontWeight: FontWeight.w600),
      //                                 ),
      //                                 Text(
      //                                   widget.order['orderNumber'],
      //                                   style: TextStyle(
      //                                       fontSize: 16,
      //                                       fontWeight: FontWeight.w600),
      //                                 )
      //                               ],
      //                             ),
      //                             SizedBox(height: 12),
      //                             Row(
      //                               mainAxisAlignment:
      //                                   MainAxisAlignment.spaceBetween,
      //                               children: [
      //                                 Text(
      //                                   'วันที่ออกใบขอสั่งซื้อ',
      //                                   style: TextStyle(
      //                                       fontSize: 16,
      //                                       fontWeight: FontWeight.w400),
      //                                 ),
      //                                 Text(
      //                                   widget.order['orderDate'],
      //                                   style: TextStyle(
      //                                       fontSize: 16,
      //                                       fontWeight: FontWeight.w400),
      //                                 )
      //                               ],
      //                             ),
      //                             Row(
      //                               mainAxisAlignment:
      //                                   MainAxisAlignment.spaceBetween,
      //                               children: [
      //                                 Text(
      //                                   'วันที่อนุมัติใบขอสั่งซื้อ',
      //                                   style: TextStyle(
      //                                       fontSize: 16,
      //                                       fontWeight: FontWeight.w400),
      //                                 ),
      //                                 Text(
      //                                   widget.order['orderDate'],
      //                                   style: TextStyle(
      //                                       fontSize: 16,
      //                                       fontWeight: FontWeight.w400),
      //                                 )
      //                               ],
      //                             )
      //                           ],
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //         SizedBox(height: 20),
      //         Container(
      //           width: double.infinity,
      //           decoration: BoxDecoration(
      //             color: Colors.white,
      //             borderRadius: BorderRadius.circular(20),
      //             border: Border.all(color: Colors.black.withOpacity(0.2)),
      //           ),
      //           child: Padding(
      //             padding: const EdgeInsets.all(16.0),
      //             child: Column(
      //               children: [
      //                 Align(
      //                   alignment: Alignment.centerLeft,
      //                   child: Text(
      //                     'ที่อยู่ในการจัดส่ง',
      //                     style: TextStyle(
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.w600,
      //                         color: Colors.black),
      //                   ),
      //                 ),
      //                 Column(
      //                   children: [
      //                     Container(
      //                       child: Padding(
      //                         padding: const EdgeInsets.symmetric(vertical: 10),
      //                         child: Column(
      //                           children: [
      //                             ListTile(
      //                               title: Column(
      //                                 crossAxisAlignment:
      //                                     CrossAxisAlignment.start,
      //                                 children: [
      //                                   Text("ออกแบบ ทดลอง",
      //                                       style: TextStyle(
      //                                         fontSize: 13,
      //                                         fontWeight: FontWeight.w400,
      //                                       )),
      //                                   Text(
      //                                     "| (+66 ) 12 345 6789",
      //                                     style: TextStyle(
      //                                       fontSize: 16,
      //                                       fontWeight: FontWeight.w400,
      //                                     ),
      //                                   ),
      //                                   Text(
      //                                     '2249 ถนนลาดพร้าว แขวงลาดพร้าว เขตลาดพร้าว 10230 แขวงสะพานสอง เขตวังทองหลาง กรุงเทพมหานคร 10310',
      //                                     maxLines: 5,
      //                                     overflow: TextOverflow.ellipsis,
      //                                     style: TextStyle(
      //                                         fontSize: 13,
      //                                         fontWeight: FontWeight.w400),
      //                                   ),
      //                                 ],
      //                               ),
      //                             )
      //                           ],
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //         SizedBox(height: 20),
      //         Row(
      //           children: [
      //             Expanded(
      //               child: Column(
      //                 children: [
      //                   Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Text(
      //                       'ตัวเลือกการจัดส่ง',
      //                       style: TextStyle(
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.w600,
      //                           color: Colors.black),
      //                     ),
      //                   ),
      //                   SizedBox(height: 20),
      //                   Container(
      //                     width: MediaQuery.of(context).size.width * 0.45,
      //                     decoration: BoxDecoration(
      //                       color: Colors.white,
      //                       borderRadius: BorderRadius.circular(10),
      //                       border: Border.all(
      //                           color: Colors.black.withOpacity(0.2)),
      //                     ),
      //                     child: Padding(
      //                       padding: const EdgeInsets.symmetric(
      //                           vertical: 10, horizontal: 10),
      //                       child: Column(
      //                         children: [
      //                           Text(
      //                             "EMS",
      //                             style: TextStyle(
      //                               fontSize: 20,
      //                               fontWeight: FontWeight.w400,
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //             SizedBox(width: 20),
      //             Expanded(
      //                 child: Column(
      //               children: [
      //                 Align(
      //                   alignment: Alignment.centerLeft,
      //                   child: Text(
      //                     'ประเภทสั่งซื้อ',
      //                     style: TextStyle(
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.w600,
      //                         color: Colors.black),
      //                   ),
      //                 ),
      //                 SizedBox(height: 20),
      //                 Container(
      //                   width: MediaQuery.of(context).size.width * 0.45,
      //                   decoration: BoxDecoration(
      //                     color: Colors.white,
      //                     borderRadius: BorderRadius.circular(10),
      //                     border:
      //                         Border.all(color: Colors.black.withOpacity(0.2)),
      //                   ),
      //                   child: Padding(
      //                     padding: const EdgeInsets.symmetric(
      //                         vertical: 10, horizontal: 10),
      //                     child: Column(
      //                       children: [
      //                         Text(
      //                           "สั่งซื้อเอง",
      //                           style: TextStyle(
      //                             fontSize: 20,
      //                             fontWeight: FontWeight.w400,
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ))
      //           ],
      //         ),
      //         SizedBox(height: 20),
      //         Align(
      //           alignment: Alignment.centerLeft,
      //           child: Text(
      //             'เอกสารประกอบการสั่งซื้อ',
      //             style: TextStyle(
      //                 fontSize: 16,
      //                 fontWeight: FontWeight.w600,
      //                 color: Colors.black),
      //           ),
      //         ),
      //         SizedBox(height: 20),
      //         Container(
      //           width: double.infinity,
      //           decoration: BoxDecoration(
      //             color: Colors.white,
      //             borderRadius: BorderRadius.circular(20),
      //             border: Border.all(color: Colors.black.withOpacity(0.2)),
      //           ),
      //           child: Padding(
      //             padding: const EdgeInsets.all(20),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 GestureDetector(
      //                   onTap: () {},
      //                   child: Container(
      //                     height: 50,
      //                     width: 200,
      //                     decoration: BoxDecoration(
      //                         color: Colors.white,
      //                         borderRadius: BorderRadius.circular(10),
      //                         border: Border.all(color: Color(0xFFDCE0E5))),
      //                     child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         ImageIcon(
      //                           AssetImage('assets/download-1.png'),
      //                           color: Colors.black,
      //                         ),
      //                         SizedBox(width: 10),
      //                         Text(
      //                           'xxxxxxxxxxxxxx',
      //                           style: TextStyle(
      //                             color: Colors.black,
      //                             fontSize: 16,
      //                             fontWeight: FontWeight.bold,
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ),
      //                 SizedBox(height: 12),
      //                 GestureDetector(
      //                   onTap: () {},
      //                   child: Container(
      //                     height: 50,
      //                     width: 150,
      //                     decoration: BoxDecoration(
      //                       color: Color(0xFFFCA0A6),
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                     child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         ImageIcon(
      //                           AssetImage('assets/upload.png'),
      //                           color: Colors.black,
      //                         ),
      //                         SizedBox(width: 10),
      //                         Text(
      //                           'เลือกไฟล์',
      //                           style: TextStyle(
      //                             color: Colors.black,
      //                             fontSize: 16,
      //                             fontWeight: FontWeight.bold,
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ),
      //                 SizedBox(height: 12),
      //                 Text(
      //                   'กรุณาเลือกไฟล์ .pdf ที่มีขนาดไม่เกิน 1MB',
      //                   style: TextStyle(
      //                     color: Color(0xFF707070),
      //                     fontWeight: FontWeight.w400,
      //                     fontSize: 12,
      //                   ),
      //                 )
      //               ],
      //             ),
      //           ),
      //         ),
      //         SizedBox(height: 20),
      //         widget.order['status'] == 'ได้รับการอนุมัติ' ||
      //                 widget.order['status'] == 'รอรับการอนุมัติ'
      //             ? Column(
      //                 children: [
      //                   Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Text(
      //                       'หลักฐานการชำระเงิน',
      //                       style: TextStyle(
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.w600,
      //                           color: Colors.black),
      //                     ),
      //                   ),
      //                   SizedBox(height: 20),
      //                   Container(
      //                     width: double.infinity,
      //                     decoration: BoxDecoration(
      //                       color: Colors.white,
      //                       borderRadius: BorderRadius.circular(20),
      //                       border: Border.all(
      //                           color: Colors.black.withOpacity(0.2)),
      //                     ),
      //                     child: Padding(
      //                       padding: const EdgeInsets.all(20),
      //                       child: Column(
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         children: [
      //                           GestureDetector(
      //                             onTap: () {},
      //                             child: Container(
      //                               height: 50,
      //                               width: 200,
      //                               decoration: BoxDecoration(
      //                                   color: Colors.white,
      //                                   borderRadius: BorderRadius.circular(10),
      //                                   border: Border.all(
      //                                       color: Color(0xFFDCE0E5))),
      //                               child: Row(
      //                                 mainAxisAlignment:
      //                                     MainAxisAlignment.center,
      //                                 children: [
      //                                   ImageIcon(
      //                                     AssetImage('assets/download-1.png'),
      //                                     color: Colors.black,
      //                                   ),
      //                                   SizedBox(width: 10),
      //                                   Text(
      //                                     'xxxxxxxxxxxxxx',
      //                                     style: TextStyle(
      //                                       color: Colors.black,
      //                                       fontSize: 16,
      //                                       fontWeight: FontWeight.bold,
      //                                     ),
      //                                   ),
      //                                 ],
      //                               ),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                   )
      //                 ],
      //               )
      //             : SizedBox(),
      //         SizedBox(height: 20),
      //         Container(
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(10),
      //             border: Border.all(color: Colors.black.withOpacity(0.1)),
      //           ),
      //           child: Padding(
      //             padding:
      //                 const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      //             child: Column(
      //               children: [
      //                 Align(
      //                   alignment: Alignment.centerLeft,
      //                   child: Text(
      //                     'รายการสินค้า',
      //                     style: TextStyle(
      //                       fontSize: 16,
      //                       fontWeight: FontWeight.w600,
      //                       color: Colors.black,
      //                     ),
      //                   ),
      //                 ),
      //                 SizedBox(height: 12),
      //                 ListView.separated(
      //                   shrinkWrap: true,
      //                   physics: NeverScrollableScrollPhysics(),
      //                   separatorBuilder: (BuildContext context, int index) =>
      //                       const Divider(
      //                     color: Color(0xFFDCE0E5),
      //                     height: 30,
      //                   ),
      //                   itemCount: widget.order['items'].length,
      //                   itemBuilder: (context, index) {
      //                     final item = widget.order['items'];

      //                     return Column(
      //                       children: [
      //                         Row(
      //                           children: [
      //                             Expanded(
      //                               flex: 3,
      //                               child: Column(
      //                                 children: [
      //                                   Row(
      //                                     crossAxisAlignment:
      //                                         CrossAxisAlignment.start,
      //                                     children: [
      //                                       Expanded(
      //                                         flex: 5,
      //                                         child: GestureDetector(
      //                                           child: Text(
      //                                             item[index]['title'],
      //                                             style: TextStyle(
      //                                               fontSize: 12,
      //                                               fontWeight: FontWeight.w600,
      //                                             ),
      //                                             maxLines: 3,
      //                                           ),
      //                                         ),
      //                                       ),
      //                                       Expanded(
      //                                         flex: 2,
      //                                         child: Container(
      //                                           height: 40,
      //                                           decoration: BoxDecoration(
      //                                             color: Color(0xFFF0F0F0),
      //                                             borderRadius:
      //                                                 BorderRadius.circular(20),
      //                                           ),
      //                                           child: Center(
      //                                             child: Text(
      //                                                 '${item[index]['quantity']} / เล่ม'),
      //                                           ),
      //                                         ),
      //                                       ),
      //                                     ],
      //                                   ),
      //                                   SizedBox(height: 10),
      //                                   Row(
      //                                     mainAxisAlignment:
      //                                         MainAxisAlignment.spaceBetween,
      //                                     children: [
      //                                       Expanded(
      //                                         flex: 2,
      //                                         child: Padding(
      //                                           padding:
      //                                               const EdgeInsets.symmetric(
      //                                                   horizontal: 10),
      //                                           child: Row(
      //                                             mainAxisAlignment:
      //                                                 MainAxisAlignment
      //                                                     .spaceAround,
      //                                             children: [
      //                                               Container(
      //                                                 height: 25,
      //                                                 width: 35,
      //                                                 decoration: BoxDecoration(
      //                                                   color:
      //                                                       Color(0xFFFBD5E6),
      //                                                   borderRadius:
      //                                                       BorderRadius
      //                                                           .circular(5),
      //                                                   border: Border.all(
      //                                                       color:
      //                                                           Colors.black),
      //                                                 ),
      //                                                 child: Center(
      //                                                   child: Text(
      //                                                     'ปพ.1:ป',
      //                                                     style: TextStyle(
      //                                                         fontSize: 8),
      //                                                   ),
      //                                                 ),
      //                                               ),
      //                                               Container(
      //                                                 height: 25,
      //                                                 width: 35,
      //                                                 decoration: BoxDecoration(
      //                                                   color:
      //                                                       Color(0xFFFC8D8F),
      //                                                   borderRadius:
      //                                                       BorderRadius
      //                                                           .circular(5),
      //                                                   border: Border.all(
      //                                                       color:
      //                                                           Colors.black),
      //                                                 ),
      //                                                 child: Center(
      //                                                   child: Text(
      //                                                     'อนุมัติ',
      //                                                     style: TextStyle(
      //                                                         fontSize: 8),
      //                                                   ),
      //                                                 ),
      //                                               ),
      //                                               Container(
      //                                                 height: 25,
      //                                                 width: 35,
      //                                                 decoration: BoxDecoration(
      //                                                   color:
      //                                                       Color(0xFFBEFEC7),
      //                                                   borderRadius:
      //                                                       BorderRadius
      //                                                           .circular(5),
      //                                                   border: Border.all(
      //                                                       color:
      //                                                           Colors.black),
      //                                                 ),
      //                                                 child: Center(
      //                                                   child: Text(
      //                                                     'ออนไลน์',
      //                                                     style: TextStyle(
      //                                                         fontSize: 8),
      //                                                   ),
      //                                                 ),
      //                                               ),
      //                                               Text(
      //                                                 '${item[index]['price'].toString()} บาท/เล่ม',
      //                                                 style: TextStyle(
      //                                                   fontSize: 12,
      //                                                   fontWeight:
      //                                                       FontWeight.w400,
      //                                                 ),
      //                                                 maxLines: 3,
      //                                               ),
      //                                             ],
      //                                           ),
      //                                         ),
      //                                       ),
      //                                       Expanded(child: SizedBox())
      //                                     ],
      //                                   ),
      //                                 ],
      //                               ),
      //                             ),
      //                           ],
      //                         ),
      //                       ],
      //                     );
      //                   },
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //         SizedBox(height: 20),
      //         Container(
      //           decoration: BoxDecoration(
      //             color: Colors.white,
      //             borderRadius: BorderRadius.circular(20),
      //             border: Border.all(color: Colors.black.withOpacity(0.2)),
      //           ),
      //           child: Padding(
      //             padding: EdgeInsets.all(20),
      //             child: Column(
      //               children: [
      //                 textDetail(
      //                   title: 'รวมเงิน',
      //                   detail: '${widget.order['totalAmount']} บาท',
      //                   fontWeightTitle: FontWeight.w400,
      //                   colorTitle: Colors.black.withOpacity(0.6),
      //                   fontSizeTitle: 13,
      //                   fontSizeDetail: 13,
      //                 ),
      //                 SizedBox(height: 10),
      //                 textDetail(
      //                   title: 'ค่าขนส่ง ',
      //                   detail: '0.00 บาท',
      //                   fontWeightTitle: FontWeight.w400,
      //                   colorTitle: Colors.black.withOpacity(0.6),
      //                   fontSizeTitle: 13,
      //                   fontSizeDetail: 13,
      //                 ),
      //                 SizedBox(height: 10),
      //                 textDetail(
      //                   title: 'มูลค่าสินค้าและค่าขนส่งก่อนภาษี',
      //                   detail: '${widget.order['totalAmount']} บาท',
      //                   fontWeightTitle: FontWeight.w400,
      //                   colorTitle: Colors.black.withOpacity(0.6),
      //                   fontSizeTitle: 13,
      //                   fontSizeDetail: 13,
      //                 ),
      //                 SizedBox(height: 10),
      //                 textDetail(
      //                   title: 'ภาษีมูลค่าเพิ่ม ',
      //                   detail: '0.00 บาท',
      //                   fontWeightTitle: FontWeight.w400,
      //                   colorTitle: Colors.black.withOpacity(0.6),
      //                   fontSizeTitle: 13,
      //                   fontSizeDetail: 13,
      //                 ),
      //                 SizedBox(height: 10),
      //                 textDetail(
      //                   title: 'ยอดสุทธิ ',
      //                   detail: '${widget.order['totalAmount']} บาท',
      //                   fontWeightTitle: FontWeight.w400,
      //                   colorTitle: Colors.black.withOpacity(0.6),
      //                   fontSizeTitle: 13,
      //                   fontSizeDetail: 13,
      //                 ),
      //                 SizedBox(height: 10),
      //                 Padding(
      //                   padding: const EdgeInsets.symmetric(vertical: 10),
      //                   child: Container(
      //                     height: 1,
      //                     color: Colors.black.withOpacity(0.2),
      //                   ),
      //                 ),
      //                 Align(
      //                     alignment: Alignment.centerRight,
      //                     child: Text(
      //                       convertToThaiBahtText(
      //                           '${widget.order['totalAmount']}'),
      //                       style: TextStyle(
      //                           fontSize: 20, fontWeight: FontWeight.w600),
      //                     )),
      //               ],
      //             ),
      //           ),
      //         ),
      //         SizedBox(height: 20),
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             GestureDetector(
      //               onTap: () {
      //                 Navigator.pop(context);
      //               },
      //               child: Container(
      //                 height: 50,
      //                 width: MediaQuery.of(context).size.width * 0.45,
      //                 decoration: BoxDecoration(
      //                   color: Color(0xFFD9D9D9),
      //                   borderRadius: BorderRadius.circular(10),
      //                 ),
      //                 child: Center(
      //                   child: Padding(
      //                     padding: const EdgeInsets.symmetric(horizontal: 25),
      //                     child: Text(
      //                       'ยกเลิก',
      //                       style: TextStyle(
      //                         color: Colors.black,
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.bold,
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //             GestureDetector(
      //               onTap: () {
      //                 Navigator.push(
      //                     context,
      //                     MaterialPageRoute(
      //                         builder: (context) => PurchaseOrderShippingSum(
      //                               order: widget.order,
      //                             )));
      //               },
      //               child: Container(
      //                 height: 50,
      //                 width: MediaQuery.of(context).size.width * 0.45,
      //                 decoration: BoxDecoration(
      //                   color: Color(0xFF012A6C),
      //                   borderRadius: BorderRadius.circular(10),
      //                 ),
      //                 child: Center(
      //                   child: Padding(
      //                     padding: const EdgeInsets.symmetric(horizontal: 25),
      //                     child: Text(
      //                       'ถัดไป',
      //                       style: TextStyle(
      //                         color: Colors.white,
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.bold,
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //         SizedBox(height: 30),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  Widget textDetail({
    required String title,
    required String detail,
    required FontWeight fontWeightTitle,
    required Color colorTitle,
    required double fontSizeTitle,
    required double fontSizeDetail,
    FontWeight fontWeightDetail = FontWeight.w700,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSizeTitle,
              fontWeight: fontWeightTitle,
              color: colorTitle,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            detail,
            style: TextStyle(
              fontSize: fontSizeDetail,
              fontWeight: fontWeightDetail,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String convertToThaiBahtText(String numberString) {
    final number = double.tryParse(numberString.replaceAll(',', '')) ?? 0.0;
    if (number == 0) return 'ศูนย์บาทถ้วน';

    final bahtText = _readNumberInThai(number.floor()) + 'บาท';
    final satang = ((number - number.floor()) * 100).round();

    if (satang == 0) {
      return bahtText + 'ถ้วน';
    } else {
      return bahtText + _readNumberInThai(satang) + 'สตางค์';
    }
  }

  String _readNumberInThai(int number) {
    const numberText = [
      'ศูนย์',
      'หนึ่ง',
      'สอง',
      'สาม',
      'สี่',
      'ห้า',
      'หก',
      'เจ็ด',
      'แปด',
      'เก้า'
    ];
    const positionText = ['', 'สิบ', 'ร้อย', 'พัน', 'หมื่น', 'แสน', 'ล้าน'];

    if (number == 0) return '';

    String result = '';
    String numberStr = number.toString();
    int len = numberStr.length;

    for (int i = 0; i < len; i++) {
      int digit = int.parse(numberStr[i]);
      int position = len - i - 1;

      if (digit != 0) {
        if (position == 0 && digit == 1 && len > 1) {
          result += 'เอ็ด';
        } else if (position == 1 && digit == 2) {
          result += 'ยี่';
        } else if (position == 1 && digit == 1) {
          result += '';
        } else {
          result += numberText[digit];
        }

        result += positionText[position % 6];
      }
    }

    return result;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'รอรับการอนุมัติ':
        return Color(0xFFFFED9E);
      case 'รอการชำระเงิน':
        return Color(0xFFFFED9E);
      case 'ไม่ได้รับการอนุมัติ':
        return Color(0xFFFFDEE0);
      case 'ได้รับการอนุมัติ':
        return Color(0xFFBEFEC7);
      case 'รายการรอรับการแก้ไข':
        return Color(0xFFD9D9D9);
      default:
        return Colors.lightBlueAccent;
    }
  }

  Color _getStatusColorFont(String status) {
    switch (status) {
      case 'รอรับการอนุมัติ':
        return Color(0xFFDB6E00);
      case 'รอการชำระเงิน':
        return Color(0xFFDB6E00);
      case 'ไม่ได้รับการอนุมัติ':
        return Color(0xFFDF0C3D);
      case 'ได้รับการอนุมัติ':
        return Color(0xFF00A81C);
      case 'รายการรอรับการแก้ไข':
        return Color(0xFF000000);
      default:
        return Colors.white;
    }
  }

  ImageIcon _getStatusIcon(String status) {
    switch (status) {
      case 'รอรับการอนุมัติ':
        return ImageIcon(AssetImage('assets/icon_itme.png'),
            color: Color(0xFFDB6E00));
      case 'รอการชำระเงิน':
        return ImageIcon(AssetImage('assets/icon_itme.png'),
            color: Color(0xFFDB6E00));
      case 'ไม่ได้รับการอนุมัติ':
        return ImageIcon(AssetImage('assets/images/icon_cancel.png'),
            color: Color(0xFFDF0C3D));
      case 'ได้รับการอนุมัติ':
        return ImageIcon(AssetImage('assets/images/icon_check.png'),
            color: Color(0xFF00A81C));
      case 'รายการรอรับการแก้ไข':
        return ImageIcon(AssetImage('assets/images/icon_cancel.png'),
            color: Color(0xFF000000));
      default:
        return ImageIcon(AssetImage('assets/icon_itme.png'),
            color: Colors.white);
    }
  }
}
