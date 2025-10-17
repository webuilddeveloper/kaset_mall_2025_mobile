// ignore_for_file: must_be_immutable

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/widget/data_error.dart';
import 'package:kasetmall/widget/header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseMain extends StatefulWidget {
  ExerciseMain({this.coverImg, super.key});

  String? coverImg;

  @override
  State<ExerciseMain> createState() => _ExerciseMainState();
}

class _ExerciseMainState extends State<ExerciseMain> {
  Future<dynamic>? _futureCategory;

  List<Map<dynamic, dynamic>> categoryList = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _callReadExercise() {
    _futureCategory = postQuestion(server_we_build + 'm/exercise/read', {});
  }

  @override
  void initState() {
    _callReadExercise();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    super.dispose();
  }

  void _onRefresh() async {
    _callReadExercise();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    _callReadExercise();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
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
        builder: (BuildContext? context, LoadStatus? mode) {
          Widget? body;
          return Container(
            height: 60,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerCentral(context, title: 'แบบฝึกหัด'),
      body: _buildSmartRefresher(
        Column(
          children: [
            // Text(data.toString()),
            Expanded(
              child: FutureBuilder(
                future: _futureCategory,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = groupBy(snapshot.data['objectData'],
                        (Map obj) => obj['categoryList'][0]['title']);
                    final keys = data.keys.toList();
                    final listData = [...data.values];

                    return ListView.separated(
                      itemCount: data.length,
                      padding: EdgeInsets.zero,
                      separatorBuilder: (context, index) => Container(
                        height: 15,
                        color: Theme.of(context).colorScheme.surfaceBright,
                      ),
                      itemBuilder: (context, index) => build_list_book(
                          keys[index].toString(), listData[index]),
                    );
                  } else if (snapshot.hasError) {
                    return DataError(onTap: () => {});
                  } else {
                    return ListView.separated(
                      itemCount: 10,
                      separatorBuilder: (context, index) => Container(
                        height: 1,
                        color: Theme.of(context).colorScheme.surfaceBright,
                      ),
                      itemBuilder: (context, index) => Container(
                        height: 50,
                        width: double.infinity,
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build_list_book(titleCat, list) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleCat,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (context, index) => SizedBox(
                width: 20,
              ),
              itemBuilder: (context, index) => build_book(list[index]),
            ),
          )
        ],
      ),
    );
  }

  Widget build_book(data) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(data['fileUrl'])),
      child: Container(
          width: 130,
          // height: 100,
          child: Column(
            children: [
              Image.network(
                data['imageUrl'],
                fit: BoxFit.contain,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                data['title'],
                style: TextStyle(fontSize: 12),
                maxLines: 1,
              )
            ],
          )),
    );
  }
}
