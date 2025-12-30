import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  PdfControllerPinch? _pdfController;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final response = await http.get(Uri.parse(widget.url));

    _pdfController = PdfControllerPinch(
      document: PdfDocument.openData(response.bodyBytes),
    );

    setState(() {});
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _pdfController == null
          ? const Center(child: CircularProgressIndicator())
          : PdfViewPinch(controller: _pdfController!),
    );
  }
}
