import 'package:flutter/material.dart';
import 'package:kaset_mall/cart.dart';
import 'package:kaset_mall/math_game/match_game.dart';
import 'package:kaset_mall/math_game/matching_game/matching_game_main.dart';
import 'package:kaset_mall/math_game/math_game_main.dart';

class GameSelectionPage extends StatelessWidget {
  get profileCode => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFeffffc),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // พื้นหลัง GIF ที่ครอบพื้นที่ทั้งหมด (ไม่ล้น)
          // Positioned.fill(
          //   child: Image.asset(
          //     'assets/Game Competition.gif',
          //     fit: BoxFit.fill, // ปรับภาพให้ครอบพื้นที่หน้าจอ
          //   ),
          // ),

          Positioned.fill(
            // bottom: 50,
            bottom: AdaptiveTextSize().getadaptiveTextSize(
                context, 35 + MediaQuery.of(context).padding.top),
            child: Image.asset(
              'assets/Game_Competition.gif',
              fit: BoxFit.fill, // ปรับภาพให้ครอบพื้นที่หน้าจอ
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.37,
            left: MediaQuery.of(context).size.width * 0.085,
            child: Container(
              width: 100,
              height: 145,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MathGameMain(),
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.37,
            child: Container(
              width: 100,
              height: 145,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchGamePage(
                        profileCode: profileCode ?? 'guest',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.37,
            right: MediaQuery.of(context).size.width * 0.085,
            child: Container(
              width: 100,
              height: 145,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Maching_Main(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );

    // Scaffold(
    //   // backgroundColor: Color(0xFFecacc5),
    //   // appBar: AppBar(
    //   //   title: Text('เลือกเกมที่ต้องการเล่น'),
    //   //   backgroundColor: Colors.transparent,
    //   //   elevation: 0,
    //   // ),
    //   body: Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: ListView(
    //       children: [
    //         GameButton(
    //           title: 'เกมคณิตคิดไว',
    //           icon: Icons.calculate,
    //           onTap: () => _navigateToGame(context, 'Math Game'),
    //         ),
    //         GameButton(
    //           title: 'เกมเติมคำสะกด',
    //           icon: Icons.spellcheck,
    //           onTap: () => _navigateToGame(context, 'Word Game'),
    //         ),
    //         GameButton(
    //           title: 'เกมจับคู่รูปภาพกับคำศัพท์',
    //           icon: Icons.image_search,
    //           onTap: () => _navigateToGame(context, 'Matching Game'),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  void _navigateToGame(BuildContext context, String gameName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('คุณเลือก $gameName')),
    );
  }
}

class GameButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const GameButton({
    required this.title,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 30),
        label: Text(
          title,
          style: TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        onPressed: onTap,
      ),
    );
  }
}
