import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';
  final http.Client _client;

  PokemonApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Pokemon>> fetchPokemonList({int offset = 0, int limit = 20}) async {
    try {
      final url = Uri.parse('$_baseUrl?offset=$offset&limit=$limit');
      final response = await _client.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw 'Erro ao carregar lista de Pokémon da API (Código: ${response.statusCode})';
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      final futures = results.map((item) async {
        final detailUrl = Uri.parse(item['url'].toString());
        final detailResponse = await _client.get(detailUrl).timeout(const Duration(seconds: 10));
        if (detailResponse.statusCode == 200) {
          final detailJson = jsonDecode(detailResponse.body) as Map<String, dynamic>;
          return Pokemon.fromJson(detailJson);
        }
        return null;
      });

      final detailedResults = await Future.wait(futures);
      return detailedResults.whereType<Pokemon>().toList();
    } on SocketException {
      throw 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
    } catch (e) {
      if (e is String) rethrow;
      throw 'Não foi possível carregar os dados da PokéAPI. Tente novamente mais tarde.';
    }
  }

  Future<Pokemon> fetchPokemonByNameOrId(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      throw 'Digite o nome ou ID de um Pokémon para pesquisar.';
    }

    try {
      final url = Uri.parse('$_baseUrl/$cleanQuery');
      final response = await _client.get(url).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Pokemon.fromJson(data);
      } else if (response.statusCode == 404) {
        throw 'Pokémon "$query" não foi encontrado na Pokédex.';
      } else {
        throw 'Erro ao pesquisar Pokémon (Código: ${response.statusCode})';
      }
    } on SocketException {
      throw 'Sem conexão com a internet. Verifique sua rede.';
    } catch (e) {
      if (e is String) rethrow;
      throw 'Erro ao buscar o Pokémon "$query". Verifique os dados e tente novamente.';
    }
  }
}
