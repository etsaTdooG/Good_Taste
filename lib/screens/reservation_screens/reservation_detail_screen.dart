import 'package:flutter/material.dart';
import '../../models/reservation_model.dart';
import '../../models/user_model.dart';
import '../../config/app_colors.dart';

class ReservationDetailScreen extends StatelessWidget {
  final Reservation reservation;
  final UserModel user;
  
  const ReservationDetailScreen({
    Key? key, 
    required this.reservation,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${reservation.id.substring(0, 6)}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildReservationHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildReservationTimeline(),
                  const SizedBox(height: 20),
                  _buildRestaurantInfo(),
                  const SizedBox(height: 16),
                  _buildReservationDetails(),
                  const SizedBox(height: 16),
                  _buildUserInfo(),
                  const SizedBox(height: 16),
                  _buildAdditionalInfo(),
                  const SizedBox(height: 24),
                  _buildReReservationButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.primary.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Đặt bàn chi tiết',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mã đặt bàn: #${reservation.id.substring(0, 6).toUpperCase()}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(reservation.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              reservation.getStatusDisplay(),
              style: TextStyle(
                color: _getStatusColor(reservation.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationTimeline() {
    // Get reservation history status
    final List<Map<String, dynamic>> statuses = [
      {
        'status': 'Hoàn thành',
        'time': '17:00, Thứ Tư 24/09/2021',
        'completed': reservation.status == ReservationStatus.completed,
      },
      {
        'status': 'Xác nhận',
        'time': '16:00, Thứ Tư 24/09/2021',
        'completed': reservation.status == ReservationStatus.confirmed || 
                    reservation.status == ReservationStatus.completed,
      },
      {
        'status': 'Đã đặt cọc',
        'time': '09:50, Thứ Hai 22/09/2021',
        'completed': reservation.paymentId != null,
      },
      {
        'status': 'Đang chờ',
        'time': '09:45, Thứ Hai 22/09/2021',
        'completed': true,  // Always completed since reservation exists
      },
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trạng thái đặt bàn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < statuses.length; i++)
              _buildTimelineItem(
                status: statuses[i]['status'],
                time: statuses[i]['time'],
                isCompleted: statuses[i]['completed'],
                isFirst: i == 0,
                isLast: i == statuses.length - 1,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String status,
    required String time,
    required bool isCompleted,
    required bool isFirst,
    required bool isLast,
  }) {
    Color dotColor = isCompleted ? AppColors.success : Colors.grey.shade300;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: isCompleted ? [
                  BoxShadow(
                    color: dotColor.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ] : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: isCompleted ? AppColors.success : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isCompleted ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: isCompleted ? Colors.grey.shade700 : Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: isLast ? 0 : 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Địa điểm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.restaurantName ?? 'Ann BBQ Su Van Hanh',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'No. 716 Su Van Hanh, Ward 12, Dist 10, HCM',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationDetails() {
    final dateFormatter = DateTime.now().year == reservation.date.year
        ? '${reservation.date.day} ${_getMonthName(reservation.date.month)} ${reservation.date.year}'
        : '${reservation.date.day}/${reservation.date.month}/${reservation.date.year}';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết đặt bàn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.calendar_today,
              text: 'Thứ Tư, $dateFormatter',
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.access_time,
              text: '${reservation.time} - ${_getEndTime(reservation.time)}',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.people,
              text: '${reservation.numberOfPeople} người',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin người đặt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: NetworkImage(
                    'https://ui-avatars.com/api/?name=${user.name ?? "User"}&background=random',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? 'Mary Nguyen',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            user.phoneNumber ?? '0987657992',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            user.email ?? 'mary.nguyen@gmail.com',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin thêm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.event_seat,
              text: 'Vị trí bàn: Bàn bên cửa sổ',
              color: Colors.teal,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.attach_money,
              text: 'Tiền đặt cọc: 200.000 VND',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReReservationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Implement re-reservation logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 3,
        ),
        child: const Text(
          'ĐẶT BÀN LẠI',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return AppColors.statusConfirmed;
      case ReservationStatus.pending:
        return AppColors.statusPending;
      case ReservationStatus.cancelled:
        return AppColors.statusCancelled;
      case ReservationStatus.completed:
        return AppColors.statusCompleted;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return months[month - 1];
  }

  String _getEndTime(String startTime) {
    try {
      final parts = startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Assume 30 minute duration
      var endHour = hour;
      var endMinute = minute + 30;
      
      if (endMinute >= 60) {
        endHour += 1;
        endMinute -= 60;
      }
      
      return '$endHour:${endMinute.toString().padLeft(2, '0')}';
    } catch (e) {
      return startTime;
    }
  }
} 