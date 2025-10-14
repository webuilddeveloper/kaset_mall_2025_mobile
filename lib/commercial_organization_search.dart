import 'package:flutter/material.dart';
import 'package:kasetmall/menu.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/widget/scroll_behavior.dart';

class CommercialOrganizationSearchPage extends StatefulWidget {
  const CommercialOrganizationSearchPage({Key? key}) : super(key: key);

  @override
  State<CommercialOrganizationSearchPage> createState() =>
      _CommercialOrganizationSearchPageState();
}

class _CommercialOrganizationSearchPageState
    extends State<CommercialOrganizationSearchPage> {
  late Future<dynamic> _futureBranch;
  late TextEditingController _searchController;
  late String keySearch;

  @override
  void initState() {
    _searchController = TextEditingController(text: '');
    _readBranch();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _readBranch() async {
    setState(() {
      keySearch = _searchController.text;
    });
    _futureBranch =
        postDio(server_we_build + 'branch/read', {'title': keySearch});
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
        extendBody: true,
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: 10,
        ),
        body: ScrollConfiguration(
          behavior: CsBehavior(),
          child: ListView(
            children: [
              FutureBuilder<dynamic>(
                future: _futureBranch, // function where you call your api
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length == 0) {
                      return Column(
                        children: [
                          rowSearch(),
                          Container(
                            alignment: Alignment.center,
                            height: 200,
                            child: Text(
                              'ไม่พบข้อมูล',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                color: Color.fromRGBO(0, 0, 0, 0.6),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return content(snapshot.data);
                    }
                  } else if (snapshot.hasError) {
                    return Container(
                      alignment: Alignment.center,
                      height: 200,
                      width: double.infinity,
                      child: Text(
                        'Network ขัดข้อง',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Kanit',
                          color: Color.fromRGBO(0, 0, 0, 0.6),
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  content(model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rowSearch(),
        text(),
        SizedBox(height: 10),
        listView(model),
        SizedBox(height: 70),
      ],
    );
  }

  text() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        keySearch != '' ? 'สาขาที่ค้นหา' : 'สาขาทั้งหมด',
        style: TextStyle(
          color: Color(0xFF0000000),
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  rowSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: EdgeInsets.only(top: 10, right: 15, bottom: 10),
              child: Image.asset(
                'assets/back_black.png',
                height: 15,
                width: 15,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE3E6FE)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      _readBranch();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Image.asset(
                        'assets/images/search.png',
                        height: 15,
                        width: 15,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        _readBranch();
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        fillColor: Colors.white,
                        filled: true,
                        border: InputBorder.none,
                        hintText: 'ค้นหา สาขา',
                        hintStyle: TextStyle(
                          color: Color(0xFF0B24FB),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        suffixIconConstraints: BoxConstraints(maxWidth: 30),
                        suffixIcon: InkWell(
                          onTap: () {
                            _searchController.clear();
                            _readBranch();
                          },
                          child: Container(
                            child: Icon(Icons.close, size: 25),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                ],
              ),
            ),
          ),
          SizedBox(width: 35),
        ],
      ),
    );
  }

  listView(model) {
    return ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 15),
        shrinkWrap: true, // 1st add
        physics: ClampingScrollPhysics(), // 2nd
        itemCount: model.length,
        itemBuilder: (context, index) {
          return Container(
            height: 165,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  child: Image.network(
                    model[index]['imageUrl'],
                    height: 150,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            model[index]['title'],
                            maxLines: 3,
                            style: TextStyle(
                              color: Color(0xFF0000000),
                              fontSize: 15,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            model[index]['address'],
                            maxLines: 3,
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 13,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuCentralPage(
                                  pageIndex: 2,
                                  commercialOrganization: model[index]['code']),
                            ),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 25,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Color(0xFFDF0B24),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'เลือกสาขานี้',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
  //
}
