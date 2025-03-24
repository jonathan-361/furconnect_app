import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

  Map<String, dynamic>? _countryData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String response =
        await rootBundle.loadString('assets/json/countries/countries.json');
    final Map<String, dynamic> data = jsonDecode(response);

    setState(() {
      _countryData = data['country'];
      // Inicialmente no seleccionamos ningún país, estado o ciudad
      _selectedCountry = null;
      _selectedState = null;
      _selectedCity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_countryData != null) ...[
              // Dropdown para País
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'País'),
                value: _selectedCountry,
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('Selecciona un país...'),
                  ),
                  DropdownMenuItem<String>(
                    value: _countryData!['name'],
                    child: Text(_countryData!['name']),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                    _selectedState = null; // Resetear estado al cambiar país
                    _selectedCity = null; // Resetear ciudad al cambiar país
                  });
                },
              ),
              SizedBox(height: 16),
              // Dropdown para Estado
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Estado'),
                value: _selectedState,
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('Selecciona un estado...'),
                  ),
                  ...(_countryData?['states'] as List).map((state) {
                    return DropdownMenuItem<String>(
                      value: state['name'],
                      child: Text(state['name']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                    _selectedCity = null; // Resetear ciudad al cambiar estado
                  });
                },
              ),
              SizedBox(height: 16),
              // Dropdown para Ciudad
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Localidad'),
                value: _selectedCity,
                items: _selectedState == null
                    ? [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Selecciona una ciudad...'),
                        ),
                      ]
                    : [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Selecciona una ciudad...'),
                        ),
                        ...(_countryData?['states'] as List)
                            .firstWhere((state) =>
                                state['name'] == _selectedState)['cities']
                            .map<DropdownMenuItem<String>>((city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                      ],
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
              ),
            ] else ...[
              CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
