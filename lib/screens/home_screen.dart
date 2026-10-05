import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/pokemon_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/loading_widget.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PokemonApiService _apiService = PokemonApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<Pokemon> _pokemonList = [];
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  static const int _limit = 20;

  String? _errorMessage;

  // Estados de busca
  bool _isSearching = false;
  bool _isLoadingSearch = false;
  Pokemon? _searchedPokemon;
  String? _searchErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialPokemon();

    // Listener para carregamento incremental (scroll infinito)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 250 &&
          !_isLoadingMore &&
          _hasMore &&
          !_isSearching) {
        _loadMorePokemon();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Carregamento inicial da lista
  Future<void> _loadInitialPokemon() async {
    setState(() {
      _isLoadingInitial = true;
      _errorMessage = null;
    });

    try {
      final list = await _apiService.fetchPokemonList(offset: 0, limit: _limit);
      setState(() {
        _pokemonList.clear();
        _pokemonList.addAll(list);
        _offset = list.length;
        _isLoadingInitial = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingInitial = false;
      });
    }
  }

  // Carregamento incremental ao rolar a tela
  Future<void> _loadMorePokemon() async {
    setState(() => _isLoadingMore = true);

    try {
      final nextList = await _apiService.fetchPokemonList(offset: _offset, limit: _limit);

      setState(() {
        if (nextList.isEmpty) {
          _hasMore = false;
        } else {
          _pokemonList.addAll(nextList);
          _offset += nextList.length;
        }
        _isLoadingMore = false;
      });
    } catch (_) {
      // Falha silenciosa no carregamento incremental, permite tentar de novo ao rolar
      setState(() => _isLoadingMore = false);
    }
  }

  // Executar pesquisa por nome ou ID
  Future<void> _executeSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      _clearSearch();
      return;
    }

    // Fecha o teclado
    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _isLoadingSearch = true;
      _searchErrorMessage = null;
      _searchedPokemon = null;
    });

    try {
      final result = await _apiService.fetchPokemonByNameOrId(cleanQuery);
      setState(() {
        _searchedPokemon = result;
        _isLoadingSearch = false;
      });
    } catch (e) {
      setState(() {
        _searchErrorMessage = e.toString();
        _isLoadingSearch = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _isLoadingSearch = false;
      _searchedPokemon = null;
      _searchErrorMessage = null;
    });
  }

  void _openDetail(Pokemon pokemon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PokemonDetailScreen(pokemon: pokemon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Row(
          children: [
            Icon(Icons.catching_pokemon, color: AppColors.primaryRed, size: 28),
            SizedBox(width: 8),
            Text(
              'Pokédex',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de Pesquisa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _executeSearch,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome ou ID...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty || _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
          ),

          // Conteúdo da Tela (Lista ou Resultados da Busca)
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Modo de Busca ativo
    if (_isSearching) {
      if (_isLoadingSearch) {
        return const LoadingWidget(message: 'Pesquisando na Pokédex...');
      }

      if (_searchErrorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  _searchErrorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar à lista'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (_searchedPokemon != null) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.82,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            children: [
              PokemonCard(
                pokemon: _searchedPokemon!,
                onTap: () => _openDetail(_searchedPokemon!),
              ),
            ],
          ),
        );
      }
    }

    // Carregamento inicial da lista
    if (_isLoadingInitial) {
      return const LoadingWidget(message: 'Carregando Pokédex via PokéAPI...');
    }

    // Erro ao carregar da API
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: AppColors.primaryRed),
              const SizedBox(height: 16),
              const Text(
                'Falha de Conexão',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadInitialPokemon,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Grid com lista de Pokémon e paginação incremental
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.82,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final pokemon = _pokemonList[index];
                return PokemonCard(
                  pokemon: pokemon,
                  onTap: () => _openDetail(pokemon),
                );
              },
              childCount: _pokemonList.length,
            ),
          ),
        ),

        // Indicador de carregamento no rodapé ao rolar
        if (_isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                  ),
                ),
              ),
            ),
          ),

        // Espaço final
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }
}
