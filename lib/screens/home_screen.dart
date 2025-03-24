import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/restaurant_model.dart';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/reservation_provider.dart';
import 'restaurant_detail_screen.dart';
import 'your_reservations_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Load restaurants
    await restaurantProvider.fetchRestaurants();
    
    // Load user reservations if logged in
    if (authProvider.isLoggedIn && authProvider.user != null) {
      await reservationProvider.fetchUserReservations(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Taste'),
        actions: [
          // User reservations button
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const YourReservationsScreen(),
                ),
              );
            },
          ),
          // Menu button with sign out option
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'signOut') {
                await Provider.of<AuthProvider>(context, listen: false).signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'signOut',
                child: Text('Sign Out'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<RestaurantProvider>(
          builder: (context, restaurantProvider, child) {
            if (restaurantProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (restaurantProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${restaurantProvider.error}',
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (restaurantProvider.restaurants.isEmpty) {
              return const Center(
                child: Text(
                  'No restaurants available',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Text(
                        'Welcome${authProvider.user != null ? ', ${authProvider.user!.name}' : ''}!',
                        style: Theme.of(context).textTheme.displayMedium,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find your favorite restaurant and reserve your table',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Featured restaurants
                  Text(
                    'Featured Restaurants',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: restaurantProvider.restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurantProvider.restaurants[index];
                        return _buildFeaturedRestaurantCard(restaurant);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // All restaurants
                  Text(
                    'All Restaurants',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: restaurantProvider.restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurantProvider.restaurants[index];
                      return _buildRestaurantListItem(restaurant);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedRestaurantCard(RestaurantModel restaurant) {
    return GestureDetector(
      onTap: () => _navigateToRestaurantDetail(restaurant.id),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: restaurant.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 40),
                ),
              ),
            ),
            // Restaurant info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildRestaurantListItem(RestaurantModel restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToRestaurantDetail(restaurant.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Restaurant image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: restaurant.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Restaurant info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFF666666),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.averageRating != null
                              ? restaurant.averageRating!.toStringAsFixed(1)
                              : 'No ratings',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRestaurantDetail(String restaurantId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(restaurantId: restaurantId),
      ),
    );
  }
} 