import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/hotel.dart';
import '../widgets/hotel_card.dart';
import 'details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  late Future<List<Hotel>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _refreshFavorites();
  }

  // Reload favorites list
  void _refreshFavorites() {
    setState(() {
      _favoritesFuture = _fetchFavoriteHotels();
    });
  }

  // Fetch hotels based on favorite IDs
  Future<List<Hotel>> _fetchFavoriteHotels() async {
    if (userId == null) return [];

    // 1. Get Favorite IDs
    final favSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    final favIds = favSnapshot.docs.map((doc) => doc.id).toList();

    if (favIds.isEmpty) return [];

    // 2. Fetch Hotels Details (in chunks of 10 due to Firestore 'whereIn' limit)
    List<Hotel> hotels = [];

    // Simple loop for chunks (if > 10 favorites)
    for (var i = 0; i < favIds.length; i += 10) {
      var end = (i + 10 < favIds.length) ? i + 10 : favIds.length;
      var chunk = favIds.sublist(i, end);

      final hotelSnapshot = await FirebaseFirestore.instance
          .collection('hotels')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      hotels.addAll(
        hotelSnapshot.docs
            .map((doc) => Hotel.fromMap(doc.data(), doc.id))
            .toList(),
      );
    }
    return hotels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Favorites")),
      body: FutureBuilder<List<Hotel>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No favorites yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final hotels = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              return HotelCard(
                hotel: hotel,
                onTap: () async {
                  // Navigate to details and refresh list on return
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(hotel: hotel),
                    ),
                  );
                  _refreshFavorites(); // Refresh list to remove unfavorited items
                },
              );
            },
          );
        },
      ),
    );
  }
}
