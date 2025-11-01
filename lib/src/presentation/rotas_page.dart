import 'package:flutter/material.dart';
// --- CORREÇÃO: IMPORT ADICIONADO ---
import 'package:racaton_ead/src/presentation/rota_detalhes_page.dart';

// --- 1. MODELO DE DADOS ---
// Define a estrutura de um roteiro de passeio
class Rota {
  final String id;
  final String titulo;
  final String descricao;
  final String imagemPath; // Caminho para a imagem em assets/
  final String duracao;
  final int paradas; // Número de paradas no roteiro
  final double price;

  Rota({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.imagemPath,
    required this.duracao,
    required this.paradas,
    required this.price,
  });
}

// --- 2. O WIDGET DA PÁGINA ---
// Usamos StatefulWidget para poder carregar e filtrar os dados
class RotasPage extends StatefulWidget {
  // Recebe o texto da busca da HomePage
  final String searchQuery;

  const RotasPage({super.key, required this.searchQuery});

  @override
  State<RotasPage> createState() => _RotasPageState();
}

class _RotasPageState extends State<RotasPage> {
  bool _isLoading = true;
  List<Rota> _rotasEncontradas = []; // Lista de rotas filtradas

  // --- DADOS MOCKADOS ---
  // Em um app real, isso viria de uma API
  final List<Rota> _todasAsRotas = [
    Rota(
      id: '1',
      titulo: 'Roteiro Centro Histórico',
      descricao: 'Descubra os monumentos e a arquitetura do coração da cidade.',
      imagemPath: 'lib/src/assets/rota_centro.jpg', // ADICIONE ESSA IMAGEM
      duracao: '3h',
      paradas: 3,
      price: 100,
    ),
    Rota(
      id: '2',
      titulo: 'Trilha das Praias Selvagens',
      descricao:
          'Uma aventura por paisagens naturais intocadas e vistas de tirar o fôlego.',
      imagemPath: 'lib/src/assets/rota_praias.jpg', // ADICIONE ESSA IMAGEM
      duracao: '5h',
      paradas: 4,
      price: 150,
    ),
    Rota(
      id: '3',
      titulo: 'Tour Gastronômico Noturno',
      descricao:
          'Experimente os melhores sabores locais nos restaurantes mais badalados.',
      imagemPath: 'lib/src/assets/rota_gastro.jpg', // ADICIONE ESSA IMAGEM
      duracao: '4h',
      paradas: 5,
      price: 120.00,
    ),
    Rota(
      id: '4',
      titulo: 'Caminho das Artes Urbanas',
      descricao:
          'Explore o vibrante cenário de arte de rua e grafite da cidade.',
      imagemPath: 'lib/src/assets/rota_arte.jpg', // ADICIONE ESSA IMAGEM
      duracao: '2h 30m',
      paradas: 8,
      price: 80.00,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filtrarRotas(); // Carrega os dados iniciais
  }

  @override
  void didUpdateWidget(covariant RotasPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filtrarRotas();
    }
  }

  /// Simula uma busca ou filtro de rotas
  void _filtrarRotas() {
    setState(() {
      _isLoading = true;
    });

    // Simula um delay de API
    Future.delayed(const Duration(milliseconds: 300), () {
      List<Rota> rotasFiltradas;

      if (widget.searchQuery.isEmpty) {
        // Se a busca for vazia, mostra todas as rotas
        rotasFiltradas = _todasAsRotas;
      } else {
        // Se houver busca, filtra pelo título
        rotasFiltradas = _todasAsRotas
            .where(
              (rota) => rota.titulo.toLowerCase().contains(
                widget.searchQuery.toLowerCase(),
              ),
            )
            .toList();
      }

      if (mounted) {
        setState(() {
          _rotasEncontradas = rotasFiltradas;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_rotasEncontradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma rota encontrada',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Tente buscar por "${widget.searchQuery}" em outro local.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // --- 3. A LISTA DE CARDS ---
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      itemCount: _rotasEncontradas.length,
      itemBuilder: (context, index) {
        final rota = _rotasEncontradas[index];

        // --- CORREÇÃO APLICADA AQUI ---
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RotaDetalhesPage(
                  // Passa o ID da rota
                  id: rota.id,
                  imagePath: rota.imagemPath,
                  title: rota.titulo,
                  description: rota.descricao,
                  location: null,
                  price: rota.price,
                  // Passa a duração da rota
                  duracao: rota.duracao,
                ),
              ),
            );
          },
          child: _buildRotaCard(rota),
        );
      },
    );
  }

  // --- 4. WIDGET DO CARD ---
  Widget _buildRotaCard(Rota rota) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            rota.imagemPath,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image_not_supported, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text('Adicione a imagem:'),
                    Text(rota.imagemPath, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rota.titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rota.descricao,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildInfoChip(Icons.timer_outlined, rota.duracao),
                    const SizedBox(width: 10),
                    _buildInfoChip(
                      Icons.location_on_outlined,
                      '${rota.paradas} paradas',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
