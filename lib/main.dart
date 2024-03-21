import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Yield Prediction Per Country',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PredictionForm(),
    );
  }
}

class PredictionForm extends StatefulWidget {
  const PredictionForm({Key? key}) : super(key: key);

  @override
  _PredictionFormState createState() => _PredictionFormState();
}

class _PredictionFormState extends State<PredictionForm> {
  late TextEditingController _yearController;
  late TextEditingController _rainfallController;
  late TextEditingController _pesticidesController;
  late TextEditingController _tempController;
  late TextEditingController _areaController;
  late TextEditingController _itemController;
  String _prediction = '';

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController();
    _rainfallController = TextEditingController();
    _pesticidesController = TextEditingController();
    _tempController = TextEditingController();
    _areaController = TextEditingController();
    _itemController = TextEditingController();
  }

  @override
  void dispose() {
    _yearController.dispose();
    _rainfallController.dispose();
    _pesticidesController.dispose();
    _tempController.dispose();
    _areaController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  Future<void> _submitPrediction() async {
    final Uri uri = Uri.parse('http://127.0.0.1:5000/predict');
    final Map<String, dynamic> requestBody = {
      'Year': _yearController.text,
      'average_rain_fall_mm_per_year': _rainfallController.text,
      'pesticides_tonnes': _pesticidesController.text,
      'avg_temp': _tempController.text,
      'Area': _areaController.text,
      'Item': _itemController.text,
    };

    final String requestBodyJson = json.encode(requestBody);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBodyJson,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _prediction = data['prediction'].toString();
      });
    } else {
      setState(() {
        _prediction = 'Failed to get prediction. Status code: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input All Features Here'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _yearController,
              decoration: InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _rainfallController,
              decoration: InputDecoration(labelText: 'Average Rainfall (mm)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _pesticidesController,
              decoration: InputDecoration(labelText: 'Pesticides (tonnes)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _tempController,
              decoration: InputDecoration(labelText: 'Average Temperature'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _areaController,
              decoration: InputDecoration(labelText: 'Area'),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _itemController,
              decoration: InputDecoration(labelText: 'Item'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _submitPrediction,
              child: Text('Predict'),
            ),
            SizedBox(height: 20.0),
            if (_prediction.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Prediction: $_prediction',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
