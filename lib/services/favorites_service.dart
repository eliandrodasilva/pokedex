import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pokemon.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _favoritesRef() {
    final uid = _currentUserId;
    if (uid == null) {
      throw 'Usuário não autenticado. Faça login para gerenciar favoritos.';
    }
    return _firestore.collection('users').doc(uid).collection('favorites');
  }

  Stream<List<Pokemon>> getFavoritesStream() {
    final uid = _currentUserId;
    if (uid == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Pokemon.fromFirestoreMap(doc.data())).toList();
    });
  }

  Stream<Set<int>> getFavoriteIdsStream() {
    final uid = _currentUserId;
    if (uid == null) {
      return Stream.value({});
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return (data['pokemonId'] as num?)?.toInt() ?? int.tryParse(doc.id) ?? 0;
      }).toSet();
    });
  }

  Future<bool> isFavorite(int pokemonId) async {
    try {
      final doc = await _favoritesRef().doc(pokemonId.toString()).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  Future<void> addFavorite(Pokemon pokemon) async {
    try {
      await _favoritesRef().doc(pokemon.id.toString()).set(pokemon.toFirestoreMap());
    } catch (e) {
      throw 'Erro ao adicionar aos favoritos no Cloud Firestore: $e';
    }
  }

  Future<void> removeFavorite(int pokemonId) async {
    try {
      await _favoritesRef().doc(pokemonId.toString()).delete();
    } catch (e) {
      throw 'Erro ao remover dos favoritos no Cloud Firestore: $e';
    }
  }

  Future<bool> toggleFavorite(Pokemon pokemon) async {
    final bool currentlyFavorite = await isFavorite(pokemon.id);
    if (currentlyFavorite) {
      await removeFavorite(pokemon.id);
      return false;
    } else {
      await addFavorite(pokemon);
      return true;
    }
  }
}
