import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';
import '../widgets/hotel_card.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<QuerySnapshot> _hotelsFuture;

  @override
  void initState() {
    super.initState();
    // جلب الفنادق مرة واحدة عند الفتح
    _hotelsFuture = FirebaseFirestore.instance.collection('hotels').get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Find your perfect stay',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _hotelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading hotels"));
          }

          final hotels =
              snapshot.data?.docs
                  .map(
                    (doc) => Hotel.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList() ??
              [];

          if (hotels.isEmpty) {
            return const Center(child: Text("No hotels found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              return HotelCard(
                hotel: hotel,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(hotel: hotel),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
