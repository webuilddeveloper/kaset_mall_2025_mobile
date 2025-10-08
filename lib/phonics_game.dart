import 'package:flutter/material.dart';

class PhonicsGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phonics Game')),
      body: PhonicsGamePage(),
    );
  }
}

class PhonicsGamePage extends StatefulWidget {
  @override
  _PhonicsGamePageState createState() => _PhonicsGamePageState();
}

class _PhonicsGamePageState extends State<PhonicsGamePage> {
  String targetWord = "CAT"; // คำเป้าหมาย
  List<String> letters = ["C", "A", "T", "D", "O", "G"]; // ตัวเลือก

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Create the word: $targetWord',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        DragTarget<String>(
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: 200,
              height: 50,
              color: Colors.grey[300],
              child: Center(child: Text("Drop here")),
            );
          },
          onAccept: (data) {
            print("Dropped: $data");
          },
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 10,
          children: letters.map((letter) {
            return Draggable<String>(
              data: letter,
              feedback: Material(
                child: Text(
                  letter,
                  style: TextStyle(fontSize: 32, color: Colors.blue),
                ),
              ),
              childWhenDragging: Text(
                letter,
                style: TextStyle(fontSize: 32, color: Colors.grey),
              ),
              child: Text(
                letter,
                style: TextStyle(fontSize: 32, color: Colors.black),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
