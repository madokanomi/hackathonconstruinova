import 'package:flutter/material.dart';
import 'dart:developer'; // Para usar o log
import 'package:racaton_ead/src/presentation/rotas_page.dart'; // Assumindo que seu caminho está correto

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
  late TextEditingController _searchController;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Adiciona o "ouvinte" para a busca em tempo real
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Remove o "ouvinte" para evitar vazamento de memória
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Chamado toda vez que o texto na barra de busca muda
  void _onSearchChanged() {
    // Notifica o Flutter para reconstruir o widget
    // Isso passa o novo `_searchController.text` para a RotasPage
    setState(() {});
  }

  // --- FUNÇÃO DE LOCALIZAÇÃO ---
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
          'Permissão de localização negada permanentemente. Abra as configurações.',
        );
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
        String city =
            place.locality ?? place.subAdministrativeArea ?? "Localização";
        _searchController.text = city; // Coloca a cidade no campo de busca
      }
    } catch (e) {
      log('Erro ao obter localização: $e');
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
          // Coluna principal
          children: [
            // --- Conteúdo Superior (Header, Busca) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildHeader(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildSearchBar(), // Widget atualizado
            ),
            // const SizedBox(height: 20), // <-- CORREÇÃO: Removido espaço estático daqui

            // --- Conteúdo da Página (Ocupa todo o espaço restante) ---
            // Adicionado AnimatedSwitcher para a transição entre as páginas
            Expanded(
              child: SizedBox(
                height: double.infinity,
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 300,
                  ), // Duração da transição
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        ); // Transição de fade
                      },
                  child: _getPageWidget(
                    _mainPageIndex,
                  ), // Seleciona o widget da página atual
                ),
              ),
            ),

            // --- NOVA NAVBAR CUSTOMIZADA ---
            _buildCustomBottomNavBar(),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para obter o widget da página com base no índice
  Widget _getPageWidget(int index) {
    switch (index) {
      case 0:
        return _buildAtrativosPage();
      case 1:
        return _buildEventosPage();
      case 2:
        return RotasPage(searchQuery: _searchController.text);
      default:
        return Container(); // Fallback
    }
  }

  // --- Widgets Auxiliares ---

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('lib/src/assets/user.jpg'),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bom dia, Felipe',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              'Turistando!',
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

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController, // Conectado ao controlador
      decoration: InputDecoration(
        hintText: 'Busque por sua localização',
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
            // Condição de Loading
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
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        key: const PageStorageKey(
          'atrativosPage',
        ), // Importante para manter o estado da página
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ), // <-- CORREÇÃO: Adicionado espaço aqui dentro da rolagem
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
                imagePath: 'lib/src/assets/praia_peruibe.jpg',
                title: 'Praia do Guaraú',
                location: 'Peruíbe',
                price: '150',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventosPage() {
    return Container(
      key: const PageStorageKey(
        'eventosPage',
      ), // Importante para manter o estado da página
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

  // --- Widgets de SUPORTE ---

  Widget _buildAtrativosFilterChips() {
    final List<String> categories = [
      'Todas',
      'Praias',
      'Trilhas',
      'Restaurantes',
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
            style: const TextStyle(color: Colors.grey, fontSize: 14),
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
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
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
                  child: const Icon(Icons.bookmark_border, color: Colors.black),
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
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF0052FF),
                          size: 16,
                        ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
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

  // --- NOVOS WIDGETS DA NAVBAR CUSTOMIZADA ---

  /// Constrói a barra de navegação flutuante customizada
  Widget _buildCustomBottomNavBar() {
    return Padding(
      // Padding para criar o efeito "flutuante"
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Fundo cinza claro
          borderRadius: BorderRadius.circular(50.0), // Bordas bem arredondadas
        ),
        child: Row(
          children: [
            // Cada item agora é "Expanded" para preencher 1/3 do espaço
            Expanded(
              child: _buildNavItem(
                unselectedIcon: Icons.star_outline,
                selectedIcon: Icons.star, // Ícone preenchido
                label: 'Atrativos',
                index: 0,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                unselectedIcon: Icons.calendar_month_outlined,
                selectedIcon: Icons.calendar_month, // Ícone preenchido
                label: 'Eventos',
                index: 1,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                unselectedIcon: Icons.route_outlined,
                selectedIcon: Icons.route, // Ícone preenchido
                label: 'Rotas',
                index: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói cada item individual da navegação
  Widget _buildNavItem({
    required IconData unselectedIcon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = (_mainPageIndex == index);
    final Color selectedColor = const Color(0xFF4D22A1); // Cor roxa da pílula
    final Color unselectedColor =
        Colors.black87; // Cor do ícone e texto não selecionado

    return GestureDetector(
      onTap: () {
        setState(() {
          _mainPageIndex = index;
        });
      },
      // Faz a área transparente do GestureDetector ser clicável
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // Animação do fundo
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          // Define a cor da "pílula" roxa ou a deixa transparente
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30.0),
        ),
        // Anima a mudança de estilo do texto (cor e peso)
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          style: TextStyle(
            color: isSelected ? Colors.white : unselectedColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centraliza o ícone e texto
            children: [
              // Icone animado
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  ); // Animação de escala para o ícone
                },
                child: Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  key: ValueKey<bool>(
                    isSelected,
                  ), // Chave para AnimatedSwitcher
                  color: isSelected ? Colors.white : unselectedColor,
                  size: 22,
                ),
              ),
              // Adiciona um espaço
              const SizedBox(width: 4), // <-- Alterado de 6 para 4
              // O texto agora herda o estilo do AnimatedDefaultTextStyle
              Text(
                label,
                // Removido 'const' daqui
              ),
            ],
          ),
        ),
      ),
    );
  }
}
