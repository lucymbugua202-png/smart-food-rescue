import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../utils/constants.dart';
import '../../services/food_service.dart';
import '../../services/user_service.dart';
import '../../models/food_model.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _selectedCategory = 'Vegetables';
  String _selectedUnit = 'kg';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;
  
  final List<String> _categories = [
    'Vegetables', 'Fruits', 'Grains', 'Dairy', 
    'Meat', 'Baked Goods', 'Prepared Meals', 'Other'
  ];
  
  final List<String> _units = ['kg', 'lbs', 'pcs', 'boxes', 'bags', 'liters'];

  Future<void> _submitDonation() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final user = FirebaseAuth.instance.currentUser;
      final userData = await UserService.getUser(user!.uid);
      
      final food = FoodModel(
        id: const Uuid().v4(),
        donorId: user.uid,
        donorName: userData?.name ?? user.email ?? 'Anonymous',
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        expiryDate: _expiryDate,
        createdAt: DateTime.now(),
        pickupAddress: _addressController.text,
        status: 'available',
      );
      
      await FoodService.addFood(food);
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food donation added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Donation'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.add_business,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              
              // Food Name
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Food Name *',
                  prefixIcon: Icon(Icons.food_bank),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter food name' : null,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              
              // Category Dropdown
              DropdownButtonFormField(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              
              // Quantity Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity *',
                        prefixIcon: Icon(Icons.scale),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter quantity' : null,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedUnit = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              
              // Expiry Date
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Expiry Date *'),
                subtitle: Text('${_expiryDate.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _expiryDate = date);
                  }
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              
              // Pickup Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Address *',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) => value!.isEmpty ? 'Enter pickup address' : null,
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              
              // Submit Button
              SizedBox(
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Text('Add Donation', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
