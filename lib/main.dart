// lib/main.dart

import 'package:flutter/material.dart';
import 'stroke_predictor.dart';

void main() {
  runApp(StrokePredictorApp());
}

class StrokePredictorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PredictorScreen(),
    );
  }
}

class PredictorScreen extends StatefulWidget {
  @override
  _PredictorScreenState createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _inputData = {
    'age': 0,
    'bp': 0,
    'diabetes': 0,
    'history_stroke': 0,
    'facial_droop': 0,
    'arm_weakness': 0,
    'speech_difficulty': 0,
    'pulse': 0,
  };

  String? _result;

  void _predictStroke() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        bool isHemorrhagicResult = isHemorrhagic(_inputData);
        setState(() {
          _result = isHemorrhagicResult
              ? "Gemorragik insult ehtimoli yuqori!"
              : "Ishemik insult ehtimoli yuqori!";
        });
      } catch (e) {
        setState(() {
          _result = "Xatolik yuz berdi. Ma'lumotlarni tekshiring.";
        });
      }
    }
  }

  Widget _buildNumberInput(String label, String key) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Iltimos, qiymat kiriting';
        }
        if (int.tryParse(value) == null) {
          return 'Iltimos, raqam kiriting';
        }
        final number = int.parse(value);
        if (key == 'age' && (number < 0 || number > 120)) {
          return 'Noto\'g\'ri yosh kiritildi';
        }
        if (key == 'bp' && (number < 50 || number > 300)) {
          return 'Noto\'g\'ri qon bosimi kiritildi';
        }
        if (key == 'pulse' && (number < 30 || number > 200)) {
          return 'Noto\'g\'ri puls kiritildi';
        }
        return null;
      },
      onSaved: (value) {
        _inputData[key] = int.tryParse(value ?? '0') ?? 0;
      },
    );
  }

  Widget _buildToggleInput(String label, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: RadioListTile(
                title: Text('Yo\'q'),
                value: 0,
                groupValue: _inputData[key],
                onChanged: (value) {
                  setState(() {
                    _inputData[key] = value;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile(
                title: Text('Ha'),
                value: 1,
                groupValue: _inputData[key],
                onChanged: (value) {
                  setState(() {
                    _inputData[key] = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stroke Predictor - MVP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildNumberInput('Yosh', 'age'),
              _buildNumberInput('Qon bosimi', 'bp'),
              _buildNumberInput('Puls', 'pulse'),
              _buildToggleInput('Diabet bormi?', 'diabetes'),
              _buildToggleInput('Oldin insult bo\'lganmi?', 'history_stroke'),
              _buildToggleInput('FAST: Yuz asimmetriyasi', 'facial_droop'),
              _buildToggleInput('FAST: Qo\'l kuchsizligi', 'arm_weakness'),
              _buildToggleInput('FAST: Nutq buzilishi', 'speech_difficulty'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _predictStroke,
                child: Text('Diagnostika qilish'),
              ),
              if (_result != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _result!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
