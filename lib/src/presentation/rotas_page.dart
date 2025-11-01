import 'package:flutter/material.dart';

// --- 1. MODELO DE DADOS ---
// Define a estrutura de um roteiro de passeio
class Rota {
  final String id;
  final String titulo;
  final String descricao;
  final String imagemPath; // Caminho para a imagem em assets/
  final String duracao;
  final int paradas; // Número de paradas no roteiro

  Rota({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.imagemPath,
    required this.duracao,
    required this.paradas,
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
      imagemPath: 'assets/rota_centro.jpg', // ADICIONE ESSA IMAGEM
      duracao: '3h',
      paradas: 6,
    ),
    Rota(
      id: '2',
      titulo: 'Trilha das Praias Selvagens',
      descricao: 'Uma aventura por paisagens naturais intocadas e vistas de tirar o fôlego.',
      imagemPath: 'assets/rota_praias.jpg', // ADICIONE ESSA IMAGEM
      duracao: '5h',
      paradas: 4,
    ),
    Rota(
      id: '3',
      titulo: 'Tour Gastronômico Noturno',
      descricao: 'Experimente os melhores sabores locais nos restaurantes mais badalados.',
      imagemPath: 'assets/rota_gastro.jpg', // ADICIONE ESSA IMAGEM
      duracao: '4h',
      paradas: 5,
    ),
    Rota(
      id: '4',
      titulo: 'Caminho das Artes Urbanas',
      descricao: 'Explore o vibrante cenário de arte de rua e grafite da cidade.',
      imagemPath: 'assets/rota_arte.jpg', // ADICIONE ESSA IMAGEM
      duracao: '2h 30m',
      paradas: 8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filtrarRotas(); // Carrega os dados iniciais
  }

  // Este método é chamado sempre que o widget "pai" (HomePage) é reconstruído
  // e o searchQuery muda.
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
        // Se houver busca, filtra pelo título (lógica simples de exemplo)
        // Em um app real, a 'widget.searchQuery' iria para uma API
        rotasFiltradas = _todasAsRotas
            .where((rota) =>
                rota.titulo.toLowerCase().contains(widget.searchQuery.toLowerCase()))
            .toList();
      }

      // Garante que o widget ainda está "montado" antes de atualizar o estado
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
      // Tela de Loading
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_rotasEncontradas.isEmpty) {
      // Tela de "Nenhum resultado"
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
            // Mostra a busca atual
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
    // Exibe a lista de rotas encontradas
    return ListView.builder(
      // Adiciona um padding em volta da lista inteira
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      itemCount: _rotasEncontradas.length,
      itemBuilder: (context, index) {
        final rota = _rotasEncontradas[index];
        // Retorna o widget do card
        return _buildRotaCard(rota);
      },
    );
  }

  // --- 4. WIDGET DO CARD ---
  // Constrói o card de um roteiro
  Widget _buildRotaCard(Rota rota) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20.0), // Espaçamento entre os cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias, // Para a imagem respeitar as bordas
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do Card
          Image.asset(
            rota.imagemPath,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            // Mostra um erro caso a imagem não seja encontrada
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              color: Colors.grey[300],
              // --- CORREÇÃO AQUI ---
              // Removido o 'const' de Center e Column
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image_not_supported, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text('Adicione a imagem:'),
                    // Este Text não pode estar em uma Column 'const'
                    Text(rota.imagemPath, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),

          // Conteúdo de texto do Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  rota.titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Descrição
                Text(
                  rota.descricao,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),

                // Informações (Duração e Paradas)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildInfoChip(Icons.timer_outlined, rota.duracao),
                    const SizedBox(width: 10),
                    _buildInfoChip(
                        Icons.location_on_outlined, '${rota.paradas} paradas'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget auxiliar para criar os "chips" de informação (duração, paradas)
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
