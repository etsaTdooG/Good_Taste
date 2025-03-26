import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../models/reservation_model.dart';
import '../models/user_model.dart';
import 'reservation_screens/reservation_detail_screen.dart';

class YourReservationsScreen extends StatefulWidget {
  const YourReservationsScreen({super.key});

  @override
  State<YourReservationsScreen> createState() => _YourReservationsScreenState();
}

class _YourReservationsScreenState extends State<YourReservationsScreen> {
  bool _isLoading = true;
  List<Reservation> _reservations = [];
  List<Reservation> _filteredReservations = [];
  String? _errorMessage;
  
  // Filter options
  ReservationStatus? _statusFilter;
  bool _showPastReservations = false;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      final reservationsData = await supabaseService.getUserReservations();
      
      setState(() {
        _reservations = reservationsData.map((json) {
          // Extract restaurant data from nested object
          final restaurantName = json['restaurants']?['name'] as String?;
          final restaurantImageUrl = json['restaurants']?['image_url'] as String?;
          
          // Create Reservation with restaurant data
          return Reservation.fromJson({
            ...json,
            'restaurant_name': restaurantName,
            'restaurant_image_url': restaurantImageUrl,
          });
        }).toList();
        _isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách đặt bàn: $e';
        _isLoading = false;
      });
    }
  }
  
  void _applyFilters() {
    setState(() {
      _filteredReservations = _reservations.where((reservation) {
        // Status filter
        if (_statusFilter != null && reservation.status != _statusFilter) {
          return false;
        }
        
        // Past reservations filter
        if (!_showPastReservations) {
          final now = DateTime.now();
          final reservationDateTime = DateTime(
            reservation.date.year,
            reservation.date.month,
            reservation.date.day,
            int.parse(reservation.time.split(':')[0]),
            int.parse(reservation.time.split(':')[1]),
          );
          
          if (reservationDateTime.isBefore(now) && 
              reservation.status != ReservationStatus.confirmed) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      // Sort: upcoming first, then by date
      _filteredReservations.sort((a, b) {
        final aDateTime = DateTime(
          a.date.year, a.date.month, a.date.day,
          int.parse(a.time.split(':')[0]),
          int.parse(a.time.split(':')[1]),
        );
        
        final bDateTime = DateTime(
          b.date.year, b.date.month, b.date.day,
          int.parse(b.time.split(':')[0]),
          int.parse(b.time.split(':')[1]),
        );
        
        // First by status priority
        final aIsActive = a.status == ReservationStatus.confirmed || 
                         a.status == ReservationStatus.pending;
        final bIsActive = b.status == ReservationStatus.confirmed || 
                         b.status == ReservationStatus.pending;
        
        if (aIsActive && !bIsActive) return -1;
        if (!aIsActive && bIsActive) return 1;
        
        // Then by date
        return aDateTime.compareTo(bDateTime);
      });
    });
  }

  Future<void> _cancelReservation(String reservationId) async {
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      final success = await supabaseService.cancelReservation(reservationId);
      
      if (success) {
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy đặt bàn thành công'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload reservations
        await _loadReservations();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể hủy đặt bàn. Vui lòng thử lại sau.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return Colors.green;
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.completed:
        return Colors.blue;
    }
  }

  Widget _buildReservationCard(Reservation reservation) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final formattedDate = dateFormatter.format(reservation.date);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            // Navigate to reservation detail screen
            final supabaseService = Provider.of<SupabaseService>(context, listen: false);
            final user = supabaseService.currentUser;
            
            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationDetailScreen(
                    reservation: reservation,
                    user: user,
                  ),
                ),
              ).then((_) {
                // Refresh list when returning from detail screen
                _loadReservations();
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant info with image
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Restaurant image
                    reservation.restaurantImageUrl != null 
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            reservation.restaurantImageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, error, _) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.restaurant, color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.restaurant, color: Colors.grey),
                        ),
                    const SizedBox(width: 16),
                    // Restaurant info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reservation.restaurantName ?? 'Nhà hàng',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(formattedDate),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(reservation.time),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.people, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${reservation.numberOfPeople} người'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Status and actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(reservation.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        reservation.getStatusDisplay(),
                        style: TextStyle(
                          color: _getStatusColor(reservation.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Cancel button - only show for pending/confirmed reservations
                    if (reservation.status == ReservationStatus.pending)
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác nhận hủy đặt bàn'),
                              content: const Text('Bạn có chắc chắn muốn hủy đặt bàn này không?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Không'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _cancelReservation(reservation.id);
                                  },
                                  child: const Text('Có, hủy đặt bàn'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cancel, size: 16),
                            const SizedBox(width: 4),
                            const Text('Hủy đặt bàn'),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Bạn chưa có đặt bàn nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Các đặt bàn của bạn sẽ hiển thị tại đây',
            style: TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.restaurant),
            label: const Text('Khám phá nhà hàng'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Không thể tải danh sách đặt bàn',
            style: const TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadReservations,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt bàn của bạn'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReservations,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorState()
                : _filteredReservations.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filteredReservations.length,
                        itemBuilder: (context, index) {
                          return _buildReservationCard(
                            _filteredReservations[index],
                          );
                        },
                      ),
      ),
    );
  }
  
  // Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Lọc đặt bàn'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trạng thái:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Tất cả'),
                      selected: _statusFilter == null,
                      onSelected: (selected) {
                        setState(() {
                          _statusFilter = null;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Đã xác nhận'),
                      selected: _statusFilter == ReservationStatus.confirmed,
                      onSelected: (selected) {
                        setState(() {
                          _statusFilter = selected ? ReservationStatus.confirmed : null;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.green.withValues(alpha: 0.2),
                    ),
                    FilterChip(
                      label: const Text('Chờ xác nhận'),
                      selected: _statusFilter == ReservationStatus.pending,
                      onSelected: (selected) {
                        setState(() {
                          _statusFilter = selected ? ReservationStatus.pending : null;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.orange.withValues(alpha: 0.2),
                    ),
                    FilterChip(
                      label: const Text('Đã hủy'),
                      selected: _statusFilter == ReservationStatus.cancelled,
                      onSelected: (selected) {
                        setState(() {
                          _statusFilter = selected ? ReservationStatus.cancelled : null;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.red.withValues(alpha: 0.2),
                    ),
                    FilterChip(
                      label: const Text('Hoàn thành'),
                      selected: _statusFilter == ReservationStatus.completed,
                      onSelected: (selected) {
                        setState(() {
                          _statusFilter = selected ? ReservationStatus.completed : null;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Hiển thị đặt bàn đã qua:'),
                    const Spacer(),
                    Switch(
                      value: _showPastReservations,
                      onChanged: (value) {
                        setState(() {
                          _showPastReservations = value;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Áp dụng'),
              ),
            ],
          );
        },
      ),
    );
  }
} 