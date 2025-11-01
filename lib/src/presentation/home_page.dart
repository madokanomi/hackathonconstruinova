import 'package:flutter/material.dart';
import 'dart:developer'; // Para usar o log

// Imports para localização
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- VARIÁVEIS DE ESTADO ---

  int _mainPageIndex = 0;
  int _atrativoChipIndex = 0;

  // NOVO: Controlador para a barra de busca
  late TextEditingController _searchController;

  // NOVO: Estado de loading para o botão de localização
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    // Inicializa o controlador da barra de busca
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    // Limpa o controlador quando o widget é removido
    _searchController.dispose();
    super.dispose();
  }

  // --- NOVA FUNÇÃO DE LOCALIZAÇÃO ---

  /// Tenta obter a localização atual e preenche a barra de busca
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true; // Mostra o loading
    });

    try {
      // 1. Verifica se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desabilitado.');
      }

      // 2. Verifica as permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Permissão de localização negada permanentemente. Abra as configurações.');
      }

      // 3. Obtém a posição atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Converte coordenadas em nome de local (Reverse Geocoding)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // 5. Atualiza a barra de busca
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.locality ?? place.subAdministrativeArea ?? "Localização";
        _searchController.text = city; // Coloca a cidade no campo de busca
      }
    } catch (e) {
      log('Erro ao obter localização: $e');
      // Mostra um feedback de erro para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao obter localização: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false; // Esconde o loading
      });
    }
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildHeader(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildSearchBar(), // Widget atualizado
            ),
            const SizedBox(height: 20),
            Expanded(
              child: IndexedStack(
                index: _mainPageIndex,
                children: [
                  _buildAtrativosPage(),
                  _buildEventosPage(),
                  _buildRotasPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildHeader() {
    // ... (código do header sem alterações)
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blueGrey,
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Shakir',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Text(
              'Good Morning.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, size: 28),
          color: Colors.grey[700],
          onPressed: () {},
        ),
      ],
    );
  }

  // --- WIDGET ATUALIZADO ---
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController, // Conectado ao controlador
      decoration: InputDecoration(
        hintText: 'Search Destination',
        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // NOVO: Condição de Loading
            _isLoadingLocation
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.my_location, color: Colors.grey[600]),
                    onPressed: _getCurrentLocation, // Chama a nova função
                  ),
            // Botão de Filtro existente
            Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0052FF),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () {
                  // Ação do filtro
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets de CONTEÚDO DE PÁGINA ---

  Widget _buildAtrativosPage() {
    // ... (código da página sem alterações)
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAtrativosFilterChips(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildSectionTitle("Recomendado", "Todas"),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildRecommendationCard(
              imagePath: 'assets/praia_peruibe.jpg',
              title: 'Praia do Guaraú',
              location: 'Peruíbe',
              price: '150',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventosPage() {
    // ... (código da página sem alterações)
    return Container(
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 50, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhum evento encontrado',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'Aqui aparecerá a lista de eventos.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRotasPage() {
    // ... (código da página sem alterações)
    return Container(
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route, size: 50, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhuma rota cadastrada',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'Aqui aparecerá a lista de rotas turísticas.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- Widgets de SUPORTE ---

  Widget _buildAtrativosFilterChips() {
    // ... (código dos chips sem alterações)
    final List<String> categories = [
      'Todas',
      'Praias',
      'Trilhas',
      'Restaurantes'
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          bool isSelected = _atrativoChipIndex == index;
          return ChoiceChip(
            label: Text(categories[index]),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _atrativoChipIndex = index;
              });
            },
            backgroundColor: Colors.grey[100],
            selectedColor: const Color(0xFF0052FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide.none,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, String actionText) {
    // ... (código do título sem alterações)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            actionText,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required String imagePath,
    required String title,
    required String location,
    required String price,
  }) {
    // ... (código do card sem alterações)
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: Image.asset(
                  imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey)),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(
                    Icons.bookmark_border,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Color(0xFF0052FF), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    '\$$price',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    // ... (código da navbar sem alterações)
    return BottomNavigationBar(
      onTap: (index) {
        setState(() {
          _mainPageIndex = index;
        });
      },
      currentIndex: _mainPageIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4D22A1),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.star_outline),
          activeIcon: Icon(Icons.star),
          label: 'Atrativos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
          label: 'Eventos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.route_outlined),
          activeIcon: Icon(Icons.route),
          label: 'Rotas',
        ),
      ],
    );
  }
}
