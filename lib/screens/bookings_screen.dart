import 'package:flutter/material.dart';

import '../widgets/hotel_card.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import 'details_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final userId = AuthService().currentUser?.uid;

  bool isLoading = true;
  List<BookingItem> myBookings = []; // استخدام القائمة الجديدة

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    if (userId == null) return;

    try {
      final loadedBookings = await BookingService().getUserBookings(userId!);
      if (mounted) {
        setState(() {
          myBookings = loadedBookings;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading bookings: $e')));
      }
    }
  }

  // دالة إلغاء الحجز
  Future<void> _cancelBooking(String bookingId) async {
    // تأكيد الحذف
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

    if (confirm != true) return;

    setState(() => isLoading = true); // إظهار لودينج خفيف

    try {
      // 1. حذف من فايربيس
      if (userId != null) {
        await BookingService().cancelBooking(userId!, bookingId);
      }

      // 2. تحديث القائمة
      await _getData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking cancelled successfully.")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : myBookings.isEmpty
          ? _buildEmptyState()
          : _buildBookingsList(),
    );
  }

  Widget _buildBookingsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myBookings.length,
      itemBuilder: (context, index) {
        final booking = myBookings[index];

        return Column(
          children: [
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
                // زر الإلغاء (فوق الكرت)
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
                      tooltip: "Cancel Booking",
                      onPressed: () => _cancelBooking(booking.bookingId),
                    ),
                  ),
                ),
              ],
            ),

            // شارة الحالة
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
          Text("No existing bookings", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
