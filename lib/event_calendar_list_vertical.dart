import 'package:flutter/material.dart';
import 'package:mobile_mart_v3/component/blank_data.dart';
import 'package:mobile_mart_v3/event_calendar_form.dart';

class EventCalendarListVertical extends StatefulWidget {
  EventCalendarListVertical({
    Key? key,
    required this.model,
    required this.title,
    required this.url,
    required this.urlComment,
    required this.urlGallery,
  }) : super(key: key);

  final Future<dynamic> model;
  final String title;
  final String url;
  final String urlComment;
  final String urlGallery;

  @override
  _EventCalendarListVertical createState() => _EventCalendarListVertical();
}

class _EventCalendarListVertical extends State<EventCalendarListVertical> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                'ไม่พบข้อมูล',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Kanit',
                  color: Color.fromRGBO(0, 0, 0, 0.6),
                ),
              ),
            );
          } else {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return myCard(index, snapshot.data.length,
                      snapshot.data[index], context);
                },
              ),
            );
          }
        } else {
          return blankGridData(context);
        }
      },
    );
  }

  myCard(int index, int lastIndex, dynamic model, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventCalendarFormPage(
              model: model,
              code: model['code'],
            ),
          ),
        );
      },
      child: Container(
        margin: index % 2 == 0
            ? EdgeInsets.only(bottom: 5.0, right: 5.0)
            : EdgeInsets.only(bottom: 5.0, left: 5.0),
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5),
          color: Color(0xFFdec6c6),
        ),
        child: Column(
          // alignment: Alignment.topCenter,
          children: [
            Expanded(
              child: Container(
                height: 157.0,
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(5.0),
                    topRight: const Radius.circular(5.0),
                  ),
                  color: Colors.white.withAlpha(220),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(model['imageUrl']),
                  ),
                ),
              ),
            ),
            Container(
              // margin: EdgeInsets.only(top: 157.0),
              padding: EdgeInsets.all(5),
              alignment: Alignment.topLeft,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: new BorderRadius.only(
                    bottomLeft: const Radius.circular(5.0),
                    bottomRight: const Radius.circular(5.0),
                  ),
                  color: Colors.black.withAlpha(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Color(0xFF9A1120),
                      // color: Colors.black.withAlpha(150),
                      fontFamily: 'Kanit',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
