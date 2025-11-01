import 'package:flutter/material.dart';

// --- NOVO: Modelo de Dados para as Paradas da Rota ---
class RotaStop {
  final String imagePath;
  final String title;
  final String category;
  final String description;
  final String km; // Distância (ex: "Início", "14.85KM")

  RotaStop({
    required this.imagePath,
    required this.title,
    required this.category,
    required this.description,
    required this.km,
  });
}

// --- NOVO: Modelo de Dados para Disponibilidade (Datas/Vagas) ---
// --- ATUALIZADO: Adicionados detalhes do tour, preço e carro ---
class TourAvailability {
  final DateTime date;
  final String timeOfDay;
  final int availableSlots;
  final double basePricePerPerson; // Preço para este slot
  final String driverName;
  final String agencyName;
  final String instructorName;
  final String carImageUrl;
  final String carModel;
  final String carLicensePlate;

  TourAvailability({
    required this.date,
    required this.timeOfDay,
    required this.availableSlots,
    required this.basePricePerPerson,
    required this.driverName,
    required this.agencyName,
    required this.instructorName,
    required this.carImageUrl,
    required this.carModel,
    required this.carLicensePlate,
  });
}

class RotaDetalhesPage extends StatefulWidget {
  // --- NOVO: ID da Rota adicionado ---
  final String id;
  final String imagePath;
  final String title;
  final String? location;
  final double? price; // Preço "inicial"
  final String? description;
  final String? duracao;

  const RotaDetalhesPage({
    super.key,
    required this.id, // ID é obrigatório
    required this.imagePath,
    required this.title,
    this.location,
    this.price,
    this.description,
    this.duracao,
  });

  @override
  State<RotaDetalhesPage> createState() => _RotaDetalhesPageState();
}

class _RotaDetalhesPageState extends State<RotaDetalhesPage> {
  int _personCount = 2;
  double _basePrice = 0.0; // Fallback price
  List<RotaStop> _paradasDaRota = [];
  List<TourAvailability> _disponibilidade = [];

  // --- NOVO: Guarda o slot (data/hora/preço) selecionado no bottom sheet ---
  TourAvailability? _selectedSlot;

  // --- NOVO: Dados Fictícios das Paradas ---
  final Map<String, List<RotaStop>> _dadosDasParadas = {
    // Paradas para o Roteiro da home_page
    'rec_guarau': [
      RotaStop(
        km: 'Início',
        title: 'Mirante do Guaraú',
        category: 'Mirante',
        description: 'Ponto de partida com vista panorâmica da praia e do rio.',
        imagePath: 'lib/src/assets/rota_guarau_1.jpg', // Adicione esta imagem
      ),
      RotaStop(
        km: '2.5KM',
        title: 'Trilha do Índio',
        category: 'Trilha',
        description: 'Pequena trilha que leva a uma cachoeira escondida.',
        imagePath: 'lib/src/assets/rota_guarau_2.jpg', // Adicione esta imagem
      ),
      RotaStop(
        km: '4.0KM',
        title: 'Restaurante Caiçara',
        category: 'Restaurante',
        description: 'Parada para almoço com pratos típicos à beira-mar.',
        imagePath: 'lib/src/assets/rota_guarau_3.jpg', // Adicione esta imagem
      ),
    ],
    // Paradas para o Roteiro '1' da rotas_page
    '1': [
      RotaStop(
        km: 'Início',
        title: 'Marco Zero',
        category: 'Monumento',
        description:
            'O ponto inicial de fundação da cidade, localizado na praça central.',
        imagePath: 'lib/src/assets/rota_centro_1.jpg', // Adicione esta imagem
      ),
      RotaStop(
        km: '0.8KM',
        title: 'Catedral Metropolitana',
        category: 'Igreja',
        description:
            'Visite a principal igreja da cidade, com seus vitrais impressionantes.',
        imagePath: 'lib/src/assets/rota_centro_2.jpg', // Adicione esta imagem
      ),
      RotaStop(
        km: '1.5KM',
        title: 'Museu Histórico',
        category: 'Museu',
        description:
            'Conheça a história local através de artefatos e exposições.',
        imagePath: 'lib/src/assets/rota_centro_3.jpg', // Adicione esta imagem
      ),
    ],
  };

  // --- NOVO: Dados Fictícios de Disponibilidade ---
  // --- ATUALIZADO: Incluindo novos dados ---
  final Map<String, List<TourAvailability>> _dadosDeDisponibilidade = {
    'rec_guarau': [
      TourAvailability(
        date: DateTime.now().add(const Duration(days: 2)),
        timeOfDay: 'Manhã (09:00)',
        availableSlots: 8,
        basePricePerPerson: 150.0,
        driverName: 'Carlos Silva',
        agencyName: 'Guaraú EcoTur',
        instructorName: 'Mariana Costa',
        carImageUrl: 'https://placehold.co/100x100/grey/white?text=Sedan',
        carModel: 'Toyota Corolla',
        carLicensePlate: 'BRA-1A23',
      ),
      TourAvailability(
        date: DateTime.now().add(const Duration(days: 2)),
        timeOfDay: 'Tarde (14:00)',
        availableSlots: 5,
        basePricePerPerson: 145.0,
        driverName: 'João Almeida',
        agencyName: 'Aventura Caiçara',
        instructorName: 'Ricardo Lopes',
        carImageUrl: 'https://placehold.co/100x100/grey/white?text=SUV',
        carModel: 'Jeep Renegade',
        carLicensePlate: 'MER-4B56',
      ),
      TourAvailability(
        date: DateTime.now().add(const Duration(days: 3)),
        timeOfDay: 'Manhã (09:00)',
        availableSlots: 10,
        basePricePerPerson: 150.0,
        driverName: 'Carlos Silva',
        agencyName: 'Guaraú EcoTur',
        instructorName: 'Mariana Costa',
        carImageUrl: 'https://placehold.co/100x100/grey/white?text=Sedan',
        carModel: 'Toyota Corolla',
        carLicensePlate: 'BRA-1A23',
      ),
    ],
    '1': [
      TourAvailability(
        date: DateTime.now().add(const Duration(days: 5)),
        timeOfDay: 'Tour Completo (10:00)',
        availableSlots: 3,
        basePricePerPerson: 95.0,
        driverName: 'Ana Pereira',
        agencyName: 'Centro Histórico Tours',
        instructorName: 'Felipe Martins',
        carImageUrl: 'https://placehold.co/100x100/grey/white?text=Hatch',
        carModel: 'Hyundai HB20',
        carLicensePlate: 'SUL-7C89',
      ),
      TourAvailability(
        date: DateTime.now().add(const Duration(days: 7)),
        timeOfDay: 'Tour Completo (10:00)',
        availableSlots: 12,
        basePricePerPerson: 90.0,
        driverName: 'Lucas Ferraz',
        agencyName: 'Descubra a Cidade',
        instructorName: 'Júlia Sampaio',
        carImageUrl: 'https://placehold.co/100x100/grey/white?text=Minivan',
        carModel: 'Chevrolet Spin',
        carLicensePlate: 'PAZ-1D23',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    // --- CORRIGIDO: Garantir que o fallback seja double (0.0) ---
    _basePrice = widget.price ?? 0.0;

    // --- NOVO: Carrega as paradas com base no ID da rota ---
    _carregarParadasDaRota();
    // --- NOVO: Carrega as datas/vagas disponíveis ---
    _carregarDisponibilidade();
  }

  void _carregarParadasDaRota() {
    // Verifica se existem paradas cadastradas para o ID desta rota
    if (_dadosDasParadas.containsKey(widget.id)) {
      setState(() {
        _paradasDaRota = _dadosDasParadas[widget.id]!;
      });
    }
  }

  // --- NOVO: Método para carregar datas/vagas ---
  void _carregarDisponibilidade() {
    if (_dadosDeDisponibilidade.containsKey(widget.id)) {
      setState(() {
        _disponibilidade = _dadosDeDisponibilidade[widget.id]!;
      });
    }
  }

  void _incrementCount() {
    setState(() {
      _personCount++;
    });
  }

  void _decrementCount() {
    setState(() {
      if (_personCount > 1) {
        _personCount--;
      }
    });
  }

  // --- ATUALIZADO: Calcula o preço com base no slot selecionado ou no preço base ---
  String _calculateTotalPrice() {
    // Usa o preço do slot selecionado, ou o preço base da página (fallback)
    final double priceToUse = _selectedSlot?.basePricePerPerson ?? _basePrice;
    if (priceToUse == 0) return "N/A";
    return (priceToUse * _personCount).toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [_buildHeaderImage(context), _buildContentSheet(context)],
        ),
      ),
      bottomNavigationBar: _buildBookingBar(context),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        image: DecorationImage(
          image: AssetImage(widget.imagePath),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => const Center(
            child: Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.location != null)
                  _buildLocationTag(widget.location!),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 5.0, color: Colors.black54)],
                  ),
                ),
                const SizedBox(height: 10),
                if (widget.price != null && _basePrice > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Starting at',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          // --- ATUALIZADO: Moeda R$ ---
                          'R\$ ${widget.price}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildLocationTag(String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white54, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            location,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Constrói a "folha" de conteúdo branca que sobrepõe a imagem
  // --- TRECHO ATUALIZADO DO _buildContentSheet ---
  Widget _buildContentSheet(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(0, -30, 0),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sobre o Roteiro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.description ?? 'Nenhuma descrição disponível.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(context),
            const SizedBox(height: 24),
            // --- ATUALIZADO: Adicionado texto ao lado dos avatares ---
            Row(
              children: [
                _buildAvatars(),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Já participaram desse roteiro!',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ),
              ],
            ),

            // --- NOVO: Seção da Linha do Tempo ---
            if (_paradasDaRota.isNotEmpty) ...[
              const SizedBox(
                height: 32,
              ), // Espaçamento entre Avatars e o Título
              const Text(
                'O Caminho da Rota',
                style: TextStyle(
                  fontSize: 20, // Ajustei o tamanho para 20
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16), // Ajustei o espaçamento
              _buildRoutePath(), // Constrói a linha do tempo
            ],
          ],
        ),
      ),
    );
  }

  /// Constrói a linha de Duração e Contador de Pessoas
  // --- MÉTODO CORRIGIDO ---
  Widget _buildInfoRow(BuildContext context) {
    const Color iconColor = Color(0xFF0052FF);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- COLUNA DA DURAÇÃO (CORRIGIDA) ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duração',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.hourglass_bottom, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.duracao ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        // --- COLUNA DO CONTADOR DE PESSOAS (CORRIGIDA) ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quantidade de Pessoas', // Traduzido
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            _buildPersonCounter(
              // Chamada corrigida
              iconColor,
              onIncrement: _incrementCount,
              onDecrement: _decrementCount,
            ),
          ],
        ),
      ],
    );
  }

  // --- ATUALIZADO: Aceita callbacks para o contador ---
  Widget _buildPersonCounter(
    Color iconColor, {
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Row(
      children: [
        Icon(Icons.people_outline, color: iconColor, size: 20),
        const SizedBox(width: 8),
        _buildCounterButton(
          icon: Icons.remove,
          onPressed: onDecrement, // Usa o callback
        ),
        SizedBox(
          width: 40,
          child: Text(
            _personCount.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildCounterButton(
          icon: Icons.add,
          onPressed: onIncrement, // Usa o callback
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  Widget _buildAvatars() {
    const List<Color> colors = [
      Colors.orange,
      Colors.blueGrey,
      Colors.teal,
      Color(0xFF0052FF),
    ];
    const List<String> initials = ["S", "M", "J", "+23"];

    return Row(
      children: List.generate(4, (index) {
        return Align(
          widthFactor: 0.75,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: colors[index],
              child: Text(
                initials[index],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // --- NOVO: Widget que constrói a lista da linha do tempo ---
  Widget _buildRoutePath() {
    // Usamos um ListView.builder para criar os itens
    // O `shrinkWrap` e `physics` são necessários por estar dentro de um SingleChildScrollView
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _paradasDaRota.length,
      itemBuilder: (context, index) {
        final stop = _paradasDaRota[index];
        final bool isLast = index == _paradasDaRota.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coluna da Linha do Tempo (Ponto e Linha)
              _buildTimelineConnector(isLast, stop.km),
              // Card da Parada
              Expanded(child: _buildStopCard(stop)),
            ],
          ),
        );
      },
    );
  }

  // --- MÉTODO ATUALIZADO: Alinhamento da Timeline ---
  Widget _buildTimelineConnector(bool isLast, String km) {
    const Color timelineColor = Color(0xFF0052FF); // Cor azul

    return SizedBox(
      width: 80, // Largura fixa para o KM e a linha
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- NOVO PADDING PARA ALINHAMENTO ---
          // Isso alinha o centro do ponto (8px) com o centro da imagem (40px)
          // (80px_imagem / 2) - (16px_ponto / 2) = 40 - 8 = 32px
          // Ajustei para 32, que é o cálculo correto (40 - 8 = 32)
          // E 32 - 8 (metade do ponto) = 24... vamos testar com 32
          // O padding top anterior de 10 parecia funcionar bem, vamos manter.
          // O alinhamento é visual, o '10' parece alinhar o topo da bola com o topo da imagem
          const Padding(padding: EdgeInsets.only(top: 10)),

          // Ponto (Círculo)
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: timelineColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: timelineColor.withValues(alpha: 0.5),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          // Texto do KM (posicionado abaixo do ponto)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              km,
              style: const TextStyle(
                color: timelineColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          // Linha Vertical (só aparece se não for o último item)
          if (!isLast)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 8.0),
                width: 2,
                color: timelineColor,
              ),
            ),
        ],
      ),
    );
  }

  // --- MÉTODO ATUALIZADO: Sem Card, Imagem Circular ---
  Widget _buildStopCard(RotaStop stop) {
    return Container(
      // Removemos a decoração do card, deixando só a margem
      margin: const EdgeInsets.only(left: 4, right: 0, bottom: 20),
      child: Row(
        // Alinha o topo da imagem com o topo do bloco de texto
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem da Parada (agora circular)
          ClipOval(
            child: Image.asset(
              stop.imagePath,
              width: 80, // Largura e altura iguais para um círculo
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          // Conteúdo do Card
          Expanded(
            child: Padding(
              // Adiciona espaçamento apenas à esquerda da imagem
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 8,
              ), //Pequeno ajuste no top
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    stop.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Categoria
                  Text(
                    stop.category,
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Descrição
                  Text(
                    stop.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MÉTODO ATUALIZADO: _buildBookingBar ---
  // A barra de reserva agora abre o BottomSheet
  Widget _buildBookingBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // O valor aqui agora é dinâmico baseado no _selectedSlot
                // --- ATUALIZADO: Moeda R$ ---
                'R\$ ${_calculateTotalPrice()}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '($_personCount Pessoas)',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          ElevatedButton(
            // --- ATUALIZADO: Chama o BottomSheet ---
            onPressed: _showBookingSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3E50),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
            ),
            child: const Text(
              'Buscar Reserva',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MÉTODO ATUALIZADO: Exibe o BottomSheet para selecionar data/hora ---
  void _showBookingSheet() {
    // --- ATUALIZADO: Esta variável é local do sheet, para UI (expansão) ---
    // Ela é inicializada com o valor do estado da página
    TourAvailability? _selectedSlotInSheet = _selectedSlot;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o sheet seja mais alto
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        // Usamos StatefulBuilder para que o sheet possa gerenciar seu próprio estado
        // (no caso, qual card está selecionado)
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateInSheet) {
            // --- NOVO: Funções locais para o contador no sheet ---
            void incrementInSheet() {
              _incrementCount(); // Chama a função principal (que tem setState)
              setStateInSheet(() {}); // Atualiza a UI do sheet
            }

            void decrementInSheet() {
              _decrementCount(); // Chama a função principal (que tem setState)
              setStateInSheet(() {}); // Atualiza a UI do sheet
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecione Data e Hora',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Lista de datas disponíveis
                  _buildAvailabilityList(_selectedSlotInSheet, (
                    TourAvailability selected,
                  ) {
                    // 1. Atualiza a UI do BottomSheet (expansão do card)
                    setStateInSheet(() {
                      if (_selectedSlotInSheet == selected) {
                        _selectedSlotInSheet = null;
                      } else {
                        _selectedSlotInSheet = selected;
                      }
                    });

                    // 2. Atualiza a UI da Página (preço na barra inferior)
                    setState(() {
                      _selectedSlot = _selectedSlotInSheet;
                    });
                  }),

                  // --- NOVO: Seção de Quantidade e Preço Total ---
                  const Divider(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Quantidade de Pessoas:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      _buildPersonCounter(
                        const Color(0xFF0052FF),
                        onIncrement: incrementInSheet,
                        onDecrement: decrementInSheet,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Valor Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'R\$ ${_calculateTotalPrice()}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // --- Fim da Nova Seção ---
                  const SizedBox(height: 24),

                  // Botão de Confirmação
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // O botão é desabilitado se nenhuma data for selecionada
                      onPressed: _selectedSlotInSheet == null
                          ? null
                          : () {
                              // 1. Fecha o bottom sheet
                              Navigator.pop(ctx);

                              // 2. Define o estado final da página (caso não tenha sido definido)
                              setState(() {
                                _selectedSlot = _selectedSlotInSheet;
                              });

                              // 3. Mostra o SnackBar de confirmação
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    // --- ATUALIZADO: Moeda R$ ---
                                    'Reservado para $_personCount pessoa(s) em ${_selectedSlot!.date.day}/${_selectedSlot!.date.month} (${_selectedSlot!.timeOfDay})! Preço: R\$ ${_calculateTotalPrice()}',
                                  ), // Fechamento do Text
                                  backgroundColor: Colors.green, // Cor de fundo
                                ), // Fechamento do SnackBar
                              ); // Fechamento do showSnackBar
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: const Text(
                        'Confirmar Reserva',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- NOVO MÉTODO: Constrói a lista de datas roláveis ---
  Widget _buildAvailabilityList(
    TourAvailability? selectedSlot,
    Function(TourAvailability) onSlotSelected,
  ) {
    if (_disponibilidade.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Nenhuma data disponível no momento.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Usamos um Flexible dentro da Column para limitar a altura do ListView
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _disponibilidade.length,
        itemBuilder: (context, index) {
          final availability = _disponibilidade[index];
          final bool isSelected = selectedSlot == availability;

          return _buildAvailabilityCard(
            availability: availability,
            isSelected: isSelected,
            onSelected: onSlotSelected,
          );
        },
      ),
    );
  }

  // --- NOVO MÉTODO: O card de seleção de data ---
  // --- ATUALIZADO: para ser expansível ---
  Widget _buildAvailabilityCard({
    required TourAvailability availability,
    required bool isSelected,
    required Function(TourAvailability) onSelected,
  }) {
    // Formata a data de forma simples (ex: 25/12/2025)
    String formattedDate =
        "${availability.date.day}/${availability.date.month}/${availability.date.year}";
    Color tileColor = isSelected
        ? Colors.blue.withValues(alpha: 0.05)
        : Colors.transparent;
    Color borderColor = isSelected ? Colors.blue[800]! : Colors.grey[300]!;

    return Card(
      elevation: isSelected ? 2 : 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
      ),
      clipBehavior:
          Clip.antiAlias, // Garante que o conteúdo interno respeite o radius
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            tileColor: tileColor,
            onTap: () => onSelected(availability),
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: isSelected ? Colors.blue[800] : Colors.grey[700],
                ),
              ],
            ),
            title: Text(
              formattedDate,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              availability.timeOfDay,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            trailing: Text(
              '${availability.availableSlots} vagas',
              style: TextStyle(
                color: availability.availableSlots < 5
                    ? Colors.red
                    : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // --- NOVO: Conteúdo Expansível ---
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              color: tileColor, // Mantém o fundo azul claro quando expandido
              width: double.infinity,
              child: isSelected
                  ? _buildExpandedDetails(availability)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  // --- ATUALIZADO: Widget para os detalhes expandidos ---
  Widget _buildExpandedDetails(TourAvailability availability) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          // --- NOVO: Preço por Pessoa ---
          _buildDetailRow(
            Icons.attach_money,
            'Preço',
            // --- ATUALIZADO: Moeda R$ ---
            'R\$ ${availability.basePricePerPerson.toStringAsFixed(0)} por pessoa',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.person_outline,
            'Instrutor',
            availability.instructorName,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.business_center_outlined,
            'Agência',
            availability.agencyName,
          ),
          // --- NOVO: Card do Motorista ---
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildDriverCard(availability),
        ],
      ),
    );
  }

  // --- NOVO: Widget para o card do motorista (estilo Uber) ---
  Widget _buildDriverCard(TourAvailability availability) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Foto do Carro
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            availability.carImageUrl,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 70,
              height: 70,
              color: Colors.grey[200],
              child: const Icon(Icons.directions_car, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Detalhes
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                availability.driverName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${availability.carModel} • ${availability.carLicensePlate}',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- NOVO: Widget helper para as linhas de detalhe ---
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text(
          '$title: ',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
