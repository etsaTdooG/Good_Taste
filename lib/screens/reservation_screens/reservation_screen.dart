import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/supabase_service.dart';
import '../../models/restaurant_model.dart';
import '../../models/reservation_model.dart';
import 'package:uuid/uuid.dart';

class ReservationScreen extends StatefulWidget {
  final Restaurant restaurant;

  const ReservationScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;
  int _numberOfPeople = 2;
  bool _isLoading = false;
  
  final List<String> _timeSlots = [
    '11:30', '12:00', '12:30', '13:00', '13:30',
    '18:00', '18:30', '19:00', '19:30', '20:00', '20:30',
  ];

  @override
  void initState() {
    super.initState();
    // Set default time slot
    _selectedTimeSlot = _timeSlots[4]; // Default to 13:30
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _makeReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn thời gian'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    
    // Check if user is authenticated
    if (!supabaseService.isAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để đặt bàn'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Generate a unique ID for the reservation
    final String reservationId = const Uuid().v4();
    
    // Create reservation object
    final reservation = Reservation(
      id: reservationId,
      restaurantId: widget.restaurant.id,
      userId: supabaseService.currentUser!.id,
      date: _selectedDate,
      time: _selectedTimeSlot!,
      numberOfPeople: _numberOfPeople,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      status: ReservationStatus.pending,
      createdAt: DateTime.now(),
    );
    
    // Show payment confirmation dialog
    final paymentConfirmed = await _showPaymentConfirmationDialog(reservation);
    
    if (!paymentConfirmed) return; // User cancelled payment
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Insert reservation into database
      await supabaseService.client
          .from('reservations')
          .insert(reservation.toJson());
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt bàn thành công! Chúng tôi sẽ xác nhận sớm.'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Return to previous screen
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Payment confirmation dialog
  Future<bool> _showPaymentConfirmationDialog(Reservation reservation) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đặt bàn'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.restaurant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _buildInfoRow('Ngày:', DateFormat('dd/MM/yyyy').format(reservation.date)),
                _buildInfoRow('Giờ:', reservation.time),
                _buildInfoRow('Số người:', '${reservation.numberOfPeople} người'),
                if (reservation.notes != null && reservation.notes!.isNotEmpty)
                  _buildInfoRow('Ghi chú:', reservation.notes!),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Phương thức thanh toán',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPaymentMethodButton(
                  icon: Icons.account_balance_wallet,
                  title: 'Thanh toán khi đến nhà hàng',
                  subtitle: 'Thanh toán trực tiếp tại nhà hàng',
                  onTap: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: 8),
                _buildPaymentMethodButton(
                  icon: Icons.payments_outlined,
                  title: 'Thanh toán qua Momo',
                  subtitle: 'Thanh toán đặt cọc 20% qua Momo',
                  onTap: () => _processPayment(context, reservation),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 28, color: Colors.orange),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Process payment using Momo payment service
  Future<void> _processPayment(BuildContext context, Reservation reservation) async {
    // This would normally integrate with the Momo payment service
    // For demo purposes, we'll show a successful payment dialog
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang xử lý thanh toán...'),
            ],
          ),
        );
      },
    );
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Close loading dialog
    if (!mounted) return;
    // Store context reference before async gap
    final scaffoldContext = context;
    Navigator.pop(scaffoldContext);
    
    // Show success dialog
    if (!mounted) return;
    final result = await showDialog<bool>(
      context: scaffoldContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Thanh toán thành công'),
            ],
          ),
          content: const Text(
            'Bạn đã thanh toán đặt cọc thành công. Nhà hàng sẽ xác nhận đặt bàn của bạn trong thời gian sớm nhất.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Hoàn tất đặt bàn'),
            ),
          ],
        );
      },
    );
    
    if (result == true) {
      // Close payment confirmation dialog with success result
      if (!mounted) return;
      Navigator.of(scaffoldContext).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt bàn'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Restaurant info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.restaurant.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (widget.restaurant.address != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.restaurant.address!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Date selection
            const Text(
              'Ngày đặt bàn',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormatter.format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Time slot selection
            const Text(
              'Thời gian',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((timeSlot) {
                final isSelected = timeSlot == _selectedTimeSlot;
                return ChoiceChip(
                  label: Text(timeSlot),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTimeSlot = timeSlot;
                      });
                    }
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Number of people
            const Text(
              'Số người',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_numberOfPeople > 1) {
                      setState(() {
                        _numberOfPeople--;
                      });
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Expanded(
                  child: Text(
                    '$_numberOfPeople người',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_numberOfPeople < 20) {
                      setState(() {
                        _numberOfPeople++;
                      });
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notes
            const Text(
              'Ghi chú (không bắt buộc)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Bàn ngoài trời, có trẻ em,...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _makeReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Xác nhận đặt bàn',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 