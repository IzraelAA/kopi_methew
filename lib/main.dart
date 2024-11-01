import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';

// Google Sheets credentials
const _credentials = r'''
{
  "type": "service_account",
  "project_id": "",
  "private_key_id": "",
  "private_key": "",
  "client_email": "",
  "client_id": "",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": ""
}
''';

// Google Sheets ID
const _spreadsheetId = '';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Form',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OrderForm(),
    );
  }
}

class OrderForm extends StatefulWidget {
  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _kopiController = TextEditingController();
  final _machaController = TextEditingController();
  final _coklatController = TextEditingController();

  late GSheets _gsheets;
  Worksheet? _sheet;

  @override
  void initState() {
    super.initState();
    _initializeGSheets();
  }

  Future<void> _initializeGSheets() async {
    _gsheets = GSheets(_credentials);
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _sheet = await ss.worksheetByTitle('Orders') ?? await ss.addWorksheet('Orders');
    await _sheet?.values.insertRow(1, ['Kopi', 'Macha', 'Coklat']);
  }

  Future<void> _submitOrder() async {
    if (_sheet != null) {
      await _sheet?.values.appendRow([
        _kopiController.text,
        _machaController.text,
        _coklatController.text,
      ]);
      _kopiController.clear();
      _machaController.clear();
      _coklatController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order submitted!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to Google Sheets')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _kopiController,
              decoration: InputDecoration(labelText: 'Kopi'),
            ),
            TextField(
              controller: _machaController,
              decoration: InputDecoration(labelText: 'Macha'),
            ),
            TextField(
              controller: _coklatController,
              decoration: InputDecoration(labelText: 'Coklat'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitOrder,
              child: Text('Submit Order'),
            ),
          ],
        ),
      ),
    );
  }
}
