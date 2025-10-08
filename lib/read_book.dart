import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String? pdfUrl;
  final String? title;

  PdfViewerScreen({this.title, this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        flexibleSpace: Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios, color: Color(0xFFfd3131)),
                    SizedBox(width: 5),
                    Text(
                      title ?? "PDF Viewer",
                      style: TextStyle(
                        color: Color(0xFFfd3131),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: pdfUrl == null
          ? Center(
              child: Text(
                "No PDF URL provided",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : SfPdfViewer.network(
              pdfUrl!,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              enableDoubleTapZooming: true,
            ),
    );
  }
}
