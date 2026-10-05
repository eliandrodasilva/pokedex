class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;
  final List<String> abilities;
  final Map<String, int> stats;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats,
  });

  String get formattedNumber => '#${id.toString().padLeft(3, '0')}';

  String get formattedName {
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }

  double get heightInMeters => height / 10.0;

  double get weightInKg => weight / 10.0;

  String get primaryType => types.isNotEmpty ? types.first : 'normal';

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] as int;

    final String artworkUrl = json['sprites']?['other']?['official-artwork']?['front_default'] ??
        json['sprites']?['front_default'] ??
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    final typesList = (json['types'] as List<dynamic>?)
            ?.map((item) => item['type']['name'].toString())
            .toList() ??
        ['normal'];

    final abilitiesList = (json['abilities'] as List<dynamic>?)
            ?.map((item) => item['ability']['name'].toString())
            .toList() ??
        [];

    final Map<String, int> statsMap = {};
    if (json['stats'] != null) {
      for (final statItem in json['stats'] as List<dynamic>) {
        final statName = statItem['stat']['name'].toString();
        final baseStat = statItem['base_stat'] as int;
        statsMap[statName] = baseStat;
      }
    }

    return Pokemon(
      id: id,
      name: json['name'].toString(),
      imageUrl: artworkUrl,
      types: typesList,
      height: (json['height'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toInt() ?? 0,
      abilities: abilitiesList,
      stats: statsMap,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'pokemonId': id,
      'name': name,
      'imageUrl': imageUrl,
      'types': types,
      'height': height,
      'weight': weight,
      'abilities': abilities,
      'stats': stats,
      'favoritedAt': DateTime.now().toIso8601String(),
    };
  }

  factory Pokemon.fromFirestoreMap(Map<String, dynamic> map) {
    return Pokemon(
      id: (map['pokemonId'] as num?)?.toInt() ?? 0,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      types: (map['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['normal'],
      height: (map['height'] as num?)?.toInt() ?? 0,
      weight: (map['weight'] as num?)?.toInt() ?? 0,
      abilities: (map['abilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      stats: (map['stats'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ??
          {},
    );
  }
}
