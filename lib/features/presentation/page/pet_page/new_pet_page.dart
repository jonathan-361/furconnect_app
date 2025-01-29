import 'package:flutter/material.dart';
import 'package:furconnect/features/data/services/pet_service.dart';
import 'package:go_router/go_router.dart';

class PetFormScreen extends StatelessWidget {
  const PetFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final List<String> sizes = ['pequeño', 'mediano', 'grande'];
    final List<String> genders = ['macho', 'hembra'];

    final TextEditingController nameController = TextEditingController();
    final TextEditingController breedController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    final TextEditingController colorController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController temperamentController = TextEditingController();
    final TextEditingController vaccinesController = TextEditingController();

    String? selectedSize;
    String? selectedGender;
    bool pedigree = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Mascota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el nombre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: breedController,
                  decoration: const InputDecoration(labelText: 'Raza'),
                ),
                TextFormField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                ),
                TextFormField(
                  controller: colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedSize,
                  decoration: const InputDecoration(labelText: 'Tamaño'),
                  items: sizes
                      .map((size) => DropdownMenuItem(
                            value: size,
                            child: Text(size),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedSize = value;
                  },
                  validator: (value) =>
                      value == null ? 'Selecciona un tamaño' : null,
                ),
                TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Edad'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa la edad';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(labelText: 'Sexo'),
                  items: genders
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedGender = value;
                  },
                  validator: (value) =>
                      value == null ? 'Selecciona el sexo' : null,
                ),
                TextFormField(
                  controller: temperamentController,
                  decoration: const InputDecoration(labelText: 'Temperamento'),
                ),
                TextFormField(
                  controller: vaccinesController,
                  decoration: const InputDecoration(labelText: 'Vacunas'),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: pedigree,
                      onChanged: (value) {
                        pedigree = value ?? false;
                      },
                    ),
                    const Text('Pedigree')
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final petData = {
                          'nombre': nameController.text,
                          'raza': breedController.text,
                          'tipo': typeController.text,
                          'color': colorController.text,
                          'tamaño': selectedSize,
                          'edad': int.tryParse(ageController.text),
                          'sexo': selectedGender,
                          'pedigree': pedigree,
                          'vacunas': vaccinesController.text.split(','),
                          'temperamento': temperamentController.text,
                          'usuario_id':
                              '6792d6953205c4fe3159071f', // Usuario actual
                        };

                        // Llamada al servicio para registrar la mascota
                        PetService().postPet(petData).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mascota registrada')),
                          );
                          context.pop('/home');
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $error')),
                          );
                        });
                      }
                    },
                    child: const Text('Registrar Mascota'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
