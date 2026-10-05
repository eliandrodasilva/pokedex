import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/favorites_service.dart';
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
  final FavoritesService _favoritesService = FavoritesService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  late final Stream<Set<int>> _favoriteIdsStream;

  final List<Pokemon> _pokemonList = [];
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  static const int _limit = 20;

  String? _errorMessage;

  bool _isSearching = false;
  bool _isLoadingSearch = false;
  Pokemon? _searchedPokemon;
  String? _searchErrorMessage;

  @override
  void initState() {
    super.initState();
    _favoriteIdsStream = _favoritesService.getFavoriteIdsStream();
    _loadInitialPokemon();

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
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _executeSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      _clearSearch();
      return;
    }

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

  Future<void> _toggleFavorite(Pokemon pokemon) async {
    try {
      final newStatus = await _favoritesService.toggleFavorite(pokemon);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  newStatus ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    newStatus
                        ? '${pokemon.formattedName} adicionado aos favoritos!'
                        : '${pokemon.formattedName} removido dos favoritos.',
                  ),
                ),
              ],
            ),
            backgroundColor: newStatus ? Colors.green.shade700 : AppColors.primaryRed,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.primaryRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
      body: StreamBuilder<Set<int>>(
        stream: _favoriteIdsStream,
        builder: (context, favSnapshot) {
          final favoriteIds = favSnapshot.data ?? {};

          return Column(
            children: [
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
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: _buildBody(favoriteIds),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(Set<int> favoriteIds) {
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
        final isFav = favoriteIds.contains(_searchedPokemon!.id);
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
                isFavorite: isFav,
                onFavoriteToggle: () => _toggleFavorite(_searchedPokemon!),
                onTap: () => _openDetail(_searchedPokemon!),
              ),
            ],
          ),
        );
      }
    }

    if (_isLoadingInitial) {
      return const LoadingWidget(message: 'Carregando Pokédex via PokéAPI...');
    }

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
                final isFav = favoriteIds.contains(pokemon.id);
                return PokemonCard(
                  pokemon: pokemon,
                  isFavorite: isFav,
                  onFavoriteToggle: () => _toggleFavorite(pokemon),
                  onTap: () => _openDetail(pokemon),
                );
              },
              childCount: _pokemonList.length,
            ),
          ),
        ),
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
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }
}
