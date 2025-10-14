// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kaset_mall/widget/header.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/api_provider.dart';
import '../../shared/extension.dart';

class NotificationFormPage extends StatefulWidget {
  NotificationFormPage({Key? key, this.model, this.profileCode})
      : super(key: key);
  final dynamic model;
  final String? profileCode;

  @override
  State<NotificationFormPage> createState() => _NotificationFormPage();
}

class _NotificationFormPage extends State<NotificationFormPage> {
  @override
  void initState() {
    print('>>>>>>>>> ${widget.model}');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: headerCustom(context, title: 'รายละเอียด', menuRight: [
        IconButton(
          iconSize: 25,
          splashRadius: 20,
          alignment: Alignment.center,
          onPressed: () {
            _buildDialogDelete(context, reference: widget.model['code']);
            // if (customBack) {
            //   func();
            // } else {
            //   Navigator.pop(context);
            // }
          },
          icon: Icon(
            Icons.delete,
            color: Colors.black,
          ),
        ),
      ]),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                widget.model['imageUrl'] != "" &&
                        widget.model['imageUrl'] != null
                    ? Image.network(
                        widget.model['imageUrl'],
                        height: MediaQuery.of(context).size.width,
                        width: MediaQuery.of(context).size.width,
                        // fit: BoxFit.cover,
                      )
                    : Container(
                        height: 250,
                        // width: (height * 12) / 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(
                              'assets/icon.png',
                            ),
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.model['title'],
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        // overflow: TextOverflow.ellipsis,
                        // maxLines: 1,
                      ),
                      SizedBox(height: 5),
                      Text(
                        parseHtmlString(widget.model['description']),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          widget.model['textButton'] != ""
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () => {
                      // widget.model['textButton']
                      launch(widget.model['linkUrl']),
                    },
                    child: IntrinsicHeight(
                      child: Container(
                        // height: 50,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        width: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Color(0xFFDF0B24),
                        ),
                        alignment: Alignment.topCenter,
                        child: Text(
                          widget.model['textButton'],
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  _buildDialogDelete(
    BuildContext context, {
    bool pressBarrierToClose = true,
    required String reference,
  }) {
    return showDialog(
      context: context,
      barrierColor: Color(0xFF471299).withOpacity(.5),
      barrierDismissible: pressBarrierToClose,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          elevation: 15,
          insetPadding: const EdgeInsets.symmetric(horizontal: 15),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(36),
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width,
            // height: 180,
            constraints: const BoxConstraints(
                minHeight: 180, maxHeight: double.infinity, maxWidth: 350),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      // alignment: WrapAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'ต้องการลบการแจ้งเตือน ใช่ หรือไม่',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 100,
                              child: TextButton(
                                child:
                                    Text("ไม่", style: TextStyle(fontSize: 16)),
                                style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20)),
                                  shadowColor: MaterialStateProperty.all<Color>(
                                      Color.fromARGB(35, 228, 37, 62)),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color(0xFFe4253f)),
                                  overlayColor:
                                      MaterialStateProperty.all<Color>(
                                          Color.fromARGB(35, 228, 37, 62)),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                      side:
                                          BorderSide(color: Color(0xFFe4253f)),
                                    ),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                  child: Text("ตกลง",
                                      style: TextStyle(fontSize: 16)),
                                  style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20)),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xFFe4253f)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        side: BorderSide(
                                            color: Color(0xFFe4253f)),
                                      ),
                                    ),
                                  ),
                                  onPressed: () => _buildDelete(reference)),
                            )
                          ],
                        )
                        // content!.isNotEmpty ? ...content!.map((e) => e).toList() : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _buildDelete(reference) {
    postDio(
      server_we_build + 'notificationV2/m/deleteNoti',
      {
        'reference': reference,
        'profileCode': widget.profileCode,
        'code': widget.model['notiItemCode'] ?? ""
      },
    ).then((value) => {
          print('============ ${value}'),
          Navigator.pop(context),
          Navigator.pop(context),
        });
  }
}
