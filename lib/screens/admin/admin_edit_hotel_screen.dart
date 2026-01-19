import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hotel.dart';
import '../../providers/hotel_provider.dart';

class AdminEditHotelScreen extends StatefulWidget {
  final Hotel? hotel;

  const AdminEditHotelScreen({super.key, this.hotel});

  @override
  State<AdminEditHotelScreen> createState() => _AdminEditHotelScreenState();
}

class _AdminEditHotelScreenState extends State<AdminEditHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _ratingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.hotel != null) {
      _nameController.text = widget.hotel!.name;
      _descriptionController.text = widget.hotel!.description;
      _imageUrlController.text = widget.hotel!.imageUrl;
      _priceController.text = widget.hotel!.price.toString();
      _addressController.text = widget.hotel!.address;
      _ratingController.text = widget.hotel!.rating.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.hotel != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Hotel' : 'Add New Hotel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Hotel Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(
                        labelText: 'Rating (0-5)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    isEditing ? 'Update Hotel' : 'Add Hotel',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final hotel = Hotel(
      id: widget.hotel?.id ?? '',
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: _imageUrlController.text,
      price: double.parse(_priceController.text),
      address: _addressController.text,
      rating: double.parse(_ratingController.text),
    );

    final hotelProvider = Provider.of<HotelProvider>(context);

    if (widget.hotel == null) {
      await hotelProvider.addHotel(hotel);
    } else {
      await hotelProvider.updateHotel(hotel);
    }

    Navigator.pop(context);
  }
}
