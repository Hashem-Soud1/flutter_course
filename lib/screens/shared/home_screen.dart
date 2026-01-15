import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/hotel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/hotel.dart';
import '../../widgets/hotel_card.dart';
import 'details_screen.dart';
import '../admin/admin_edit_hotel_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _deleteHotel(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hotel'),
        content: const Text('Are you sure you want to delete this hotel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      context.read<HotelProvider>().deleteHotel(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotelProvider = context.watch<HotelProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;

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
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminEditHotelScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: hotelProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : hotelProvider.error != null
          ? Center(child: Text(hotelProvider.error!))
          : hotelProvider.hotels.isEmpty
          ? const Center(child: Text("No hotels found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: hotelProvider.hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotelProvider.hotels[index];
                return HotelCard(
                  hotel: hotel,
                  isAdmin: isAdmin,
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdminEditHotelScreen(hotel: hotel),
                      ),
                    );
                  },
                  onDelete: () => _deleteHotel(context, hotel.id),
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
            ),
    );
  }
}
