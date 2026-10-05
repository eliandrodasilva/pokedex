import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../utils/app_colors.dart';

class PokemonDetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({
    super.key,
    required this.pokemon,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;
    final typeColor = AppColors.getColorForType(pokemon.primaryType);

    return Scaffold(
      backgroundColor: typeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite
                        ? '${pokemon.formattedName} adicionado aos favoritos!'
                        : '${pokemon.formattedName} removido dos favoritos.',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Cabeçalho: Nome, Número e Tipos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pokemon.formattedName,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: pokemon.types.map((type) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Text(
                  pokemon.formattedNumber,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Imagem Grande com Hero
          Center(
            child: Hero(
              tag: 'pokemon-image-${pokemon.id}',
              child: SizedBox(
                height: 180,
                width: 180,
                child: CachedNetworkImage(
                  imageUrl: pokemon.imageUrl,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const Icon(
                    Icons.catching_pokemon,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Painel inferior com Informações Físicas, Habilidades e Estatísticas
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 28, left: 24, right: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Peso e Altura
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPhysicalStat('Altura', '${pokemon.heightInMeters} m', Icons.height),
                        Container(height: 40, width: 1, color: Colors.grey.shade300),
                        _buildPhysicalStat('Peso', '${pokemon.weightInKg} kg', Icons.scale_outlined),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Habilidades
                    const Text(
                      'Habilidades',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: pokemon.abilities.map((ability) {
                        return Chip(
                          label: Text(
                            ability.replaceAll('-', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Estatísticas Base
                    const Text(
                      'Estatísticas Base',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...pokemon.stats.entries.map((entry) {
                      return _buildStatRow(entry.key, entry.value, typeColor);
                    }),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String statName, int statValue, Color typeColor) {
    final formattedStatName = _formatStatName(statName);
    final double percentage = (statValue / 200.0).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              formattedStatName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 38,
            child: Text(
              statValue.toString(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  statValue >= 100 ? Colors.green : (statValue >= 60 ? typeColor : Colors.orange),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatName(String rawName) {
    switch (rawName) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'ATK';
      case 'defense':
        return 'DEF';
      case 'special-attack':
        return 'SP. ATK';
      case 'special-defense':
        return 'SP. DEF';
      case 'speed':
        return 'SPD';
      default:
        return rawName.toUpperCase();
    }
  }
}
