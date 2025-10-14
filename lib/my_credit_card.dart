import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kasetmall/credit_card_form_field.dart';
import 'package:kasetmall/my_bank_add.dart';
import 'package:kasetmall/my_credit_card_add.dart';
import 'package:kasetmall/widget/data_error.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../shared/api_provider.dart';
import '../widget/header.dart';

class MyCreditCardCentralPage extends StatefulWidget {
  MyCreditCardCentralPage({Key? key, this.productList = dynamic})
      : super(key: key);

  final dynamic productList;
  @override
  _MyCreditCardCentralPageState createState() =>
      _MyCreditCardCentralPageState();
}

class _MyCreditCardCentralPageState extends State<MyCreditCardCentralPage> {
  Future<dynamic>? _futureModel;
  Future<dynamic>? _futureModelBank;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool latestCard = false;
  var _paymentCard = PaymentCard();
  TextEditingController numberController = TextEditingController();

  @override
  void initState() {
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.pop(context);
        } else if (details.delta.dx < -0) {
          //Left Swipe
        }
      },
      child: Scaffold(
        appBar: headerCentral(context, title: 'ตัวเลือกชำระเงิน'),
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: _buildSmartRefresher(
            ListView(
              children: _buildList(),
            ),
          ),
        ),
      ),
    );
  }

  _buildSmartRefresher(Widget child) {
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
      // onLoading: _onLoading,
      child: child,
    );
  }

  _buildList() {
    return <Widget>[
      SizedBox(height: 10),
      _textTitle('บัตรเครดิต / บัตรเดบิต'),
      SizedBox(height: 10),
      _buildCreditCard(),
      _buildButton('เพิ่มบัตรใหม่',
          callback: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyCreditCardAddCentralPage(),
                ),
              ).then((value) => {if (value == 'success') _onRefresh()})),
      _textTitle('บัญชีธนาคาร'),
      SizedBox(height: 10),
      _buildBank(),
      _buildButton('เพิ่มบัญชีธนาคาร',
          callback: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyBankAddCentralPage(),
                ),
              ).then((value) => {if (value == 'success') _onRefresh()})),
    ];
  }

  _textTitle(title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Kanit',
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  _buildCreditCard() {
    return FutureBuilder(
      future: _futureModel,
      builder: (context, snap) {
        if (snap.hasData) {
          if (snap.data.length > 0) {
            return ListView.separated(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: snap.data.length,
              itemBuilder: (context, index) => buildItem(snap.data[index]),
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 10),
            );
          } else {
            return Container(
              height: 120,
              child: Center(
                child: InkWell(
                  child: Text('ยังไม่มีรายการบัญชีธนาคาร',
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
          return Container(
            height: 100,
            child: Center(
              child: InkWell(
                child: Text('ไม่มีรายการ',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  _buildBank() {
    return FutureBuilder(
      future: _futureModelBank,
      builder: (context, snap) {
        if (snap.hasData) {
          if (snap.data.length > 0) {
            return ListView.separated(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: snap.data.length,
              itemBuilder: (context, index) => buildItem(snap.data[index]),
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 10),
            );
          } else {
            return Container(
              height: 120,
              child: Center(
                child: InkWell(
                  child: Text('ยังไม่มีรายการบัญชีธนาคาร',
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
          return DataError(onTap: () => _callRead());
        } else {
          return Container();
        }
      },
    );
  }

  _buildButton(title, {required Function callback}) {
    return InkWell(
      onTap: () => callback(),
      child: Container(
        height: 45,
        constraints: BoxConstraints(maxWidth: 400, minWidth: 350),
        padding: EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0XFFDF0B24),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 15,
            color: Color(0XFFDF0B24),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  InkWell buildItem(dynamic model) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: 80,
        constraints: BoxConstraints(maxWidth: 400, minWidth: 350),
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0XFFE4E4E4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              model['type'] == 'Visa'
                  ? 'assets/images/central/visa.png'
                  : 'assets/images/central/master-card.png',
              width: 50.0,
              height: 50.0,
            ),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model['title'],
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'บัตรเครดิต xxxx-${model['number']}',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ],
            )
          ],
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

  _callRead() {
    setState(() {
      _futureModel = postDio('${server}m/manageCreditCard/read', {});
    });
  }
}
