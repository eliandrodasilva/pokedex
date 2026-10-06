import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/favorites_service.dart';
import '../utils/app_colors.dart';
import '../widgets/loading_widget.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<void> _removeFavorite(BuildContext context, Pokemon pokemon) async {
    final favoritesService = FavoritesService();
    try {
      await favoritesService.removeFavorite(pokemon.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite_border, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('${pokemon.formattedName} removido dos favoritos.'),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryRed,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
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

  void _openDetail(BuildContext context, Pokemon pokemon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PokemonDetailScreen(pokemon: pokemon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Meus Favoritos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<Pokemon>>(
        stream: favoritesService.getFavoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Carregando favoritos...');
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Erro ao carregar favoritos: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.primaryRed),
                ),
              ),
            );
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: 72,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum favorito ainda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toque no ícone de coração nos Pokémon da Pokédex para salvá-los aqui.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.82,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final pokemon = favorites[index];
              return PokemonCard(
                pokemon: pokemon,
                isFavorite: true,
                onFavoriteToggle: () => _removeFavorite(context, pokemon),
                onTap: () => _openDetail(context, pokemon),
              );
            },
          );
        },
      ),
    );
  }
}
