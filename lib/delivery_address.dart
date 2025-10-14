import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kaset_mall/delivery_address_add.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../shared/api_provider.dart';
import '../widget/header.dart';

class DeliveryAddressCentralPage extends StatefulWidget {
  DeliveryAddressCentralPage({Key? key, this.notChange = false})
      : super(key: key);

  final notChange;

  @override
  _DeliveryAddressCentralPageState createState() =>
      _DeliveryAddressCentralPageState();
}

class _DeliveryAddressCentralPageState
    extends State<DeliveryAddressCentralPage> {
  late Future<dynamic> _futureModel;
  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // var tempData = List<dynamic>();
  bool latestCard = false;

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerCentral(context, title: 'ที่อยู่จัดส่ง'),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(child: _buildSmartRefresher(_buildCreditCard())),
          Padding(
            padding: EdgeInsets.fromLTRB(
              15,
              0,
              15,
              MediaQuery.of(context).padding.bottom + 10,
            ),
            child: _buildButton(
              'เพิ่มที่อยู่',
              callback: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeliveryAddressAddCentralPage(),
                ),
              ).then(
                (value) => {
                  if (value == 'success') _onRefresh(),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartRefresher(Widget child) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(
        complete: Container(
          child: Text(''),
        ),
        completeDuration: Duration(milliseconds: 0),
      ),
      footer: CustomFooter(
        builder: (context, mode) {
          Widget? body;
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: child,
    );
  }

  _buildCreditCard() {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      // ignore: missing_return
      builder: (BuildContext context, AsyncSnapshot<dynamic> snap) {
        if (snap.hasData) {
          if (snap.data.length > 0) {
            return ListView.separated(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).padding.bottom + 50,
                top: 10,
              ),
              itemCount: snap.data.length,
              itemBuilder: (context, index) => buildItem(snap.data[index]),
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 10),
            );
          } else if (snap.data == null) {
            return Container(
              height: 120,
              child: Center(
                child: InkWell(
                  child: Text('ยังไม่มีรายการที่อยู่จัดส่ง',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
            );
          }
        } else if (snap.hasError) {
          // return DataError(onTap: () => _callRead());
          return Center(
            child: InkWell(
              child: Text('ยังไม่มีรายการที่อยู่จัดส่ง',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    // return Container();
  }

  Widget _buildButton(title, {required Function callback}) {
    return InkWell(
      onTap: () => callback(),
      child: Container(
        height: 45,
        constraints: BoxConstraints(maxWidth: 400, minWidth: 350),
        padding: EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0XFFDF0B24),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 25,
            color: Color(0XFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  InkWell buildItem(dynamic model) {
    return InkWell(
      onTap: () {
        if (widget.notChange) {
          Navigator.pop(context, {'status': '1', ...model});
        } else {
          changeDefault(model['id'], model['main']);
        }
      },
      child: Slidable(
        key: const ValueKey(1),
        closeOnScroll: true,
        endActionPane: ActionPane(
          // motion: const ScrollMotion(),
          extentRatio: 0.3,
          motion: BehindMotion(),
          // dismissible: DismissiblePane(onDismissed: () {}),
          children: [
            SlidableAction(
              flex: 2,
              autoClose: true,
              onPressed: (BuildContext) {
                _deleteAddress(model['id']);
              },
              backgroundColor: Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'ลบที่อยู่',
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: model['main'] ? Color(0XFF0B24FB) : Color(0XFFE4E4E4),
              // color: Color(0XFFE4E4E4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model['name'] ?? "",
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        ' | ${model['phone'] ?? ""}',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          color: Color(0XFF707070),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // FocusScope.of(context).unfocus();
                      // widget.onChange(snapshot.data[index]['code']);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         DeliveryAddressAddCentralPage(code: model['code']),
                      //   ),
                      // );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DeliveryAddressAddCentralPage(code: model['id']),
                        ),
                      );
                      setState(() {});
                    },
                    child: Image.asset(
                      "assets/logo/edit_address.png",
                      width: 15,
                      height: 15,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Text(
                  (model['address'] ?? "") +
                      " " +
                      (model['tambon']['data']["name_th"] ?? "") +
                      " " +
                      (model['amphoe']['data']["name_th"] ?? "") +
                      " " +
                      (model['province']['data']["name_th"] ?? "") +
                      " " +
                      (model['tambon']['data']["zip"] ?? ""),
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                    color: Color(0XFF707070),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(25.0),
              //     border: Border.all(
              //       color: model['isDefault']
              //           ? Color(0XFF0B24FB)
              //           : Color(0XFFE4E4E4),
              //       // color: Color(0XFF707070),
              //     ),
              //   ),
              //   child: Text(
              //     model['addressType'] == 0
              //         ? 'ที่บ้าน'
              //         : model['addressType'] == 1
              //             ? 'ที่ทำงาน'
              //             : 'อื่นๆ',
              //     style: TextStyle(
              //       fontFamily: 'Kanit',
              //       fontSize: 15,
              //       color: model['isDefault']
              //           ? Color(0XFF0B24FB)
              //           : Color(0XFF707070),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRefresh() async {
    _callRead();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    _callRead();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _callRead() {
    setState(() {
      _futureModel = get('${server}shipping-addresses');
    });
  }

  changeDefault(param, isSelect) async {
    if (!isSelect) {
      await put('${server}shipping-addresses/' + param, {
        "main": true,
        // 'isDefault': isDefault,
      });
      setState(() {
        _callRead();
      });
    }
  }

  void _deleteAddress(param) async {
    await delete('${server}shipping-addresses/' + param);
    setState(() {
      _callRead();
    });
  }
}
