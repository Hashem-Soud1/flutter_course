import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/home_service.dart';

class HotelProvider extends ChangeNotifier {
  final HomeService _homeService = HomeService();
  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _error;

  List<Hotel> get hotels => _hotels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHotels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _hotels = await _homeService.getHotels();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHotel(Hotel hotel) async {
    await _homeService.addHotel(hotel);
    await fetchHotels();
  }

  Future<void> updateHotel(Hotel hotel) async {
    await _homeService.updateHotel(hotel);
    await fetchHotels();
  }

  Future<void> deleteHotel(String id) async {
    await _homeService.deleteHotel(id);
    await fetchHotels();
  }
}
