import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // Importa el paquete image_picker

class NewPet extends StatefulWidget {
  const NewPet({super.key});

  @override
  _NewPetState createState() => _NewPetState();
}

class _NewPetState extends State<NewPet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _typeController = TextEditingController();
  final _colorController = TextEditingController();
  final _ageController = TextEditingController();
  final _temperamentController = TextEditingController();
  bool _hasPedigree = false;

  final List<String> sizes = ['Pequeño', 'Mediano', 'Grande'];
  final List<String> genders = ['Macho', 'Hembra'];
  String? selectedSize;
  String? selectedGender;

  List<String> vaccines = [];
  final _vacuumController = TextEditingController();

  File? _image;

  Future<void> _pickImage() async {
    // Usa FilePicker para seleccionar una imagen
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Solo selecciona imágenes
    );

    if (result != null) {
      setState(() {
        _image = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar mascota"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 300,
                  width: 300,
                  color: Colors.grey[300],
                  child: _image == null
                      ? const Center(child: Text('Seleccionar imagen'))
                      : Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  counterText: '',
                ),
                maxLength: 18,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa un nombre";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _breedController,
                decoration:
                    const InputDecoration(labelText: "Raza", counterText: ''),
                maxLength: 18,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa una raza";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: "Tipo",
                  counterText: '',
                ),
                maxLength: 18,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa un tipo";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _colorController,
                decoration:
                    const InputDecoration(labelText: "Color", counterText: ''),
                maxLength: 15,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa un color";
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedSize,
                decoration: const InputDecoration(
                  labelText: 'Tamaño',
                ),
                items: sizes.map((String size) {
                  return DropdownMenuItem<String>(
                    value: size,
                    child: Text(size),
                  );
                }).toList(),
                onChanged: (String? newSize) {
                  setState(() {
                    selectedSize = newSize;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor selecciona un tamaño";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: "Edad"),
                keyboardType: TextInputType.number, // Solo números
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa una edad";
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Sexo',
                ),
                items: genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newGender) {
                  setState(() {
                    selectedGender = newGender;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor selecciona el sexo";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _temperamentController,
                decoration: const InputDecoration(
                  labelText: "Temperamento",
                  counterText: '',
                ),
                maxLength: 15,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa un temperamento";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _vacuumController,
                decoration: const InputDecoration(
                  labelText: "Vacunas",
                ),
                onChanged: (value) {
                  // Si el usuario presiona espacio, agregar el valor a la lista
                  if (value.contains(' ')) {
                    setState(() {
                      vaccines.add(value.trim());
                      _vacuumController
                          .clear(); // Limpiar el campo después de agregar la vacuna
                    });
                  }
                },
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: vaccines.map((vaccine) {
                  return Chip(
                    label: Text(vaccine),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        vaccines.remove(vaccine);
                      });
                    },
                  );
                }).toList(),
              ),
              Row(
                children: [
                  const Text("Pedigree:"),
                  Checkbox(
                    value: _hasPedigree,
                    onChanged: (bool? value) {
                      setState(() {
                        _hasPedigree = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (_image == null) {
                      final snackBar = SnackBar(
                        content: const Text("Por favor selecciona una imagen"),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                    }

                    final snackBar = SnackBar(
                      content: const Text("Datos correctos"),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: const Text("Agregar mascota"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
