import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/hotel_card.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking.dart';
import 'details_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAdmin) {
        context.read<BookingProvider>().loadAllBookings();
      } else if (auth.user != null) {
        context.read<BookingProvider>().loadUserBookings(auth.user!.uid);
      }
    });
  }

  Future<void> _cancelBooking(Booking booking) async {
    final auth = context.read<AuthProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Booking?"),
        content: const Text(
          "Are you sure you want to cancel this reservation?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) {
        await context.read<BookingProvider>().cancelBooking(
          booking.userId,
          booking.bookingId,
          auth.isAdmin,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Booking cancelled successfully.")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? "All Bookings (Admin)" : "My Bookings"),
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingProvider.bookings.isEmpty
          ? _buildEmptyState()
          : _buildBookingsList(bookingProvider.bookings, isAdmin),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, bool isAdmin) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];

        return Column(
          children: [
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      booking.userName ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      booking.bookedAt != null
                          ? "${booking.bookedAt!.day}/${booking.bookedAt!.month}"
                          : "",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            Stack(
              children: [
                HotelCard(
                  hotel: booking.hotel,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailsScreen(hotel: booking.hotel),
                      ),
                    );
                  },
                ),
                if (!isAdmin)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _cancelBooking(booking),
                      ),
                    ),
                  ),
              ],
            ),
            if (!isAdmin)
              Transform.translate(
                offset: const Offset(0, -25),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Text(
                    "Confirmed ✅",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.airplane_ticket_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          const Text(
            "No existing bookings",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
