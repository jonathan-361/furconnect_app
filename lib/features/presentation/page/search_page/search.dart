import 'package:flutter/material.dart';
import 'package:furconnect/features/presentation/widget/item_pet.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 241, 241, 241),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                          counterText: '',
                        ),
                        maxLength: 30,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 236, 236, 236),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.sort),
                  ),
                ],
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
