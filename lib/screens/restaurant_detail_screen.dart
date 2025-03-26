import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/restaurant_model.dart';
import '../models/dish_model.dart';
import '../models/review_model.dart';
import '../services/supabase_service.dart';
import 'reservation_screens/reservation_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Dish> _dishes = [];
  List<Review> _reviews = [];
  bool _isLoading = true;
  double _averageRating = 0.0;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      
      // Load dishes
      final dishesResponse = await supabaseService.client
          .from('dishes')
          .select()
          .eq('restaurant_id', widget.restaurant.id)
          .order('name');
      
      final List<Dish> dishes = (dishesResponse as List)
          .map((json) => Dish.fromJson(json))
          .toList();
      
      // Load reviews
      final reviewsResponse = await supabaseService.client
          .from('reviews')
          .select()
          .eq('restaurant_id', widget.restaurant.id)
          .order('created_at', ascending: false);
      
      final List<Review> reviews = (reviewsResponse as List).map((json) {
        return Review.fromJson(json);
      }).toList();
      
      // Calculate average rating manually
      double sumRating = 0;
      for (final review in reviews) {
        sumRating += review.rating;
      }
      final double avgRating = reviews.isNotEmpty ? sumRating / reviews.length : 0.0;
      final int reviewCount = reviews.length;
      
      // Update restaurant rating in the database
      try {
        await supabaseService.client
            .from('restaurants')
            .update({
              'average_rating': avgRating,
              'total_reviews': reviewCount
            })
            .eq('id', widget.restaurant.id);
      } catch (e) {
        debugPrint('Error updating restaurant rating: $e');
        // Continue even if this fails as we'll display the correct value locally
      }
      
      if (mounted) {
        setState(() {
          _dishes = dishes;
          _reviews = reviews;
          _averageRating = avgRating;
          _reviewCount = reviewCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadRestaurantDetails() async {
    try {
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải lại dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with restaurant image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.restaurant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: widget.restaurant.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.restaurant.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant, size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Không thể tải hình ảnh',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.restaurant, size: 50),
                      ),
                    ),
            ),
          ),
          
          // Restaurant info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating and address row
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _averageRating > 0 ? _averageRating.toStringAsFixed(1) : "0.0",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ' (${_reviewCount} đánh giá)',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (widget.restaurant.address != null) ...[
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.restaurant.address!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Contact info
                  if (widget.restaurant.phone != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.restaurant.phone!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // Description
                  if (widget.restaurant.description != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Giới thiệu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.restaurant.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Tab bar
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Thực đơn'),
                  Tab(text: 'Đánh giá'),
                  Tab(text: 'Đặt bàn'),
                ],
              ),
            ),
            pinned: true,
          ),
          
          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Menu tab
                _buildMenuTab(),
                
                // Reviews tab
                _buildReviewsTab(),
                
                // Reservation tab
                _buildReservationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_dishes.isEmpty) {
      return const Center(
        child: Text('Nhà hàng này chưa có menu.'),
      );
    }
    
    // Group dishes by category
    final Map<String, List<Dish>> dishesByCategory = {};
    for (var dish in _dishes) {
      if (dish.categories.isNotEmpty) {
        for (var category in dish.categories) {
          dishesByCategory.putIfAbsent(category, () => []);
          dishesByCategory[category]!.add(dish);
        }
      } else {
        dishesByCategory.putIfAbsent('Khác', () => []);
        dishesByCategory['Khác']!.add(dish);
      }
    }
    
    final categories = dishesByCategory.keys.toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final dishesInCategory = dishesByCategory[category]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 24),
            Text(
              category,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...dishesInCategory.map((dish) => _buildDishCard(dish)),
          ],
        );
      },
    );
  }
  
  Widget _buildDishCard(Dish dish) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dish image
            if (dish.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CachedNetworkImage(
                    imageUrl: dish.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              
            if (dish.imageUrl != null) const SizedBox(width: 12),
            
            // Dish info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (dish.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      dish.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormatter.format(dish.price),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (dish.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber[800],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Phổ biến',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đánh giá từ khách hàng',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddReviewDialog,
                icon: const Icon(Icons.rate_review),
                label: const Text('Viết đánh giá'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (_reviews.isEmpty) 
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('Chưa có đánh giá nào cho nhà hàng này.'),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                final dateFormat = DateFormat('dd/MM/yyyy');
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review.userName ?? 'Khách hàng',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              dateFormat.format(review.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < review.rating ? Icons.star : Icons.star_border,
                              color: i < review.rating ? Colors.amber : Colors.grey,
                              size: 18,
                            );
                          }),
                        ),
                        if (review.comment != null && review.comment!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            review.comment!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildReservationTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Đặt bàn tại nhà hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => ReservationScreen(restaurant: widget.restaurant),
                )
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Đặt bàn ngay'),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Thông tin đặt bàn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Giờ mở cửa: ${widget.restaurant.openingHours ?? '9:00 - 22:00'}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hãy đặt bàn ít nhất 1 giờ trước khi đến để đảm bảo có chỗ.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add review dialog
  void _showAddReviewDialog() async {
    if (Supabase.instance.client.auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để đánh giá nhà hàng.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    int rating = 5;
    final commentController = TextEditingController();
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Đánh giá nhà hàng'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Xếp hạng:'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: index < rating ? Colors.amber : Colors.grey,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text('Nhận xét:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Chia sẻ trải nghiệm của bạn...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'rating': rating,
                      'comment': commentController.text,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Gửi đánh giá'),
                ),
              ],
            );
          },
        );
      },
    );
    
    if (result != null) {
      _submitReview(result['rating'], result['comment']);
    }
  }

  // Submit review to Supabase
  Future<void> _submitReview(int rating, String comment) async {
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    final currentUser = supabaseService.client.auth.currentUser;
    final scaffoldContext = context;
    
    if (currentUser == null) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // First get user profile to get the name
      final profileResponse = await supabaseService.client
          .from('profiles')
          .select('name')
          .eq('id', currentUser.id)
          .single();
      
      final String? userName = profileResponse['name'] as String?;
      
      // Check if user already reviewed this restaurant
      final existingReviews = await supabaseService.client
          .from('reviews')
          .select()
          .eq('user_id', currentUser.id)
          .eq('restaurant_id', widget.restaurant.id);
      
      if ((existingReviews as List).isNotEmpty) {
        // Update existing review
        final existingReview = existingReviews[0];
        await supabaseService.client
            .from('reviews')
            .update({
              'rating': rating,
              'comment': comment,
              'user_name': userName
              // Let the database trigger handle updated_at
            })
            .eq('id', existingReview['id']);
        
        if (!mounted) return;
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá của bạn đã được cập nhật!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Create new review
        await supabaseService.client.from('reviews').insert({
          'restaurant_id': widget.restaurant.id,
          'user_id': currentUser.id,
          'rating': rating,
          'comment': comment,
          'user_name': userName
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          const SnackBar(
            content: Text('Cảm ơn bạn đã đánh giá!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Refresh reviews and recalculate ratings
      if (!mounted) return;
      await _loadRestaurantDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  
  _SliverAppBarDelegate(this._tabBar);
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  
  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
} 