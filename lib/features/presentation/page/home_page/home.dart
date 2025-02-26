import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/user_service.dart';
import 'package:furconnect/features/data/services/pet_service.dart';
import 'package:furconnect/features/presentation/page/home_page/side_bar.dart';
import 'package:furconnect/features/presentation/widget/overlay.dart';
import 'package:furconnect/features/presentation/page/home_page//app_bar.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final apiService = ApiService();
  final loginService = LoginService(ApiService());
  final userService = UserService(ApiService(), LoginService(ApiService()));
  final petService = PetService(ApiService(), LoginService(ApiService()));

  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: SideBar(),
      body: _HomePageBody(petService: petService),
    );
  }
}

class _HomePageBody extends StatefulWidget {
  final PetService petService;

  const _HomePageBody({required this.petService});

  @override
  __HomePageBodyState createState() => __HomePageBodyState();
}

class __HomePageBodyState extends State<_HomePageBody> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> pets = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadPets() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final newPets = await widget.petService.getPets(currentPage, 10);
      setState(() {
        pets.addAll(newPets);
        isLoading = false;
        if (newPets.length < 10) {
          hasMore = false;
        } else {
          currentPage++;
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      AppOverlay.showOverlay(
          context, Colors.red, "Error al registrar la mascota: $e");
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadPets();
    }
  }

  Future<void> _refreshPets() async {
    setState(() {
      pets.clear();
      currentPage = 1;
      hasMore = true;
    });
    _loadPets();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color.fromRGBO(0, 0, 0, 0.2),
                          ],
                          stops: [0.8, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8.0,
                          children: [
                            FilterChip(
                              label: Text('Macho'),
                              onSelected: (bool value) {},
                            ),
                            FilterChip(
                              label: Text('Hembra'),
                              onSelected: (bool value) {},
                            ),
                            FilterChip(
                              label: Text('Pug'),
                              onSelected: (bool value) {},
                            ),
                            FilterChip(
                              label: Text('Dalmata'),
                              onSelected: (bool value) {},
                            ),
                            FilterChip(
                              label: Text('Husky'),
                              onSelected: (bool value) {},
                            ),
                            FilterChip(
                              label: Text('Chihuahua'),
                              onSelected: (bool value) {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ActionChip(
                    avatar: Icon(Icons.filter_list),
                    label: Text('Filtros'),
                    onPressed: () => _showFilterModal(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPets,
                child: GridView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: pets.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < pets.length) {
                      final petData = pets[index];
                      return _buildPetCard(
                        imageUrl: petData['media']?.isNotEmpty ?? false
                            ? petData['media'][0]
                            : null,
                        name: petData['nombre'],
                        onTap: () =>
                            context.pushNamed('petCardHome', extra: petData),
                      );
                    } else {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              _scrollController.animateTo(
                0.0,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPetCard({
    required String? imageUrl,
    required String name,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Imagen no válida');
                          return Image.asset(
                            'assets/images/placeholder/pet_placeholder.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/placeholder/pet_placeholder.jpg',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filtros',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              CheckboxListTile(
                title: Text('Solo mascotas vacunadas'),
                value: false,
                onChanged: (value) {},
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Aplicar filtros'),
              ),
            ],
          ),
        );
      },
    );
  }
}
