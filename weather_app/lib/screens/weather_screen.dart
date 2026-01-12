import 'package:flutter/material.dart';
// Import Google Fonts kung gusto mo ng mas magandang font style.
// Para sa example na ito, gagamit tayo ng standard system font pero may better weights at spacing.
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  late Future<Weather> weatherFuture;
  bool isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    weatherFuture = WeatherService.getWeather('Manila');
  }

  void _searchWeather() {
    final String city = _cityController.text.trim();
    if (city.isEmpty) {
      _showSnackBar('Please enter a city name', Colors.redAccent);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      weatherFuture = WeatherService.getWeather(city);
      isFirstLoad = false;
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'sans-serif')),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating, // Mas modernong tingnan
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CUSTOM COLOR THEME
    const primaryColor = Color(0xFF1A237E); // Deep Indigo
    const accentColor = Color(0xFF00B0FF); // Light Blue

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Background
      appBar: AppBar(
        title: const Text(
          'WEATHER FORECAST',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // SEARCH BOX - Modern Style
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search city...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.search, color: accentColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      onSubmitted: (_) => _searchWeather(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      onPressed: _searchWeather,
                      icon: const Icon(Icons.arrow_forward_ios, color: accentColor, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // WEATHER DATA DISPLAY
            FutureBuilder<Weather>(
              future: weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: CircularProgressIndicator(color: accentColor),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                if (snapshot.hasData) {
                  final weather = snapshot.data!;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          weather.city.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          '${weather.temperature.toStringAsFixed(1)}°',
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.w200, // Light weight para sa modern look
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          weather.description.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white54,
                            letterSpacing: 4.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              WeatherInfoCard(
                                icon: Icons.water_drop_outlined,
                                label: 'HUMIDITY',
                                value: '${weather.humidity}%',
                                iconColor: Colors.blueAccent,
                              ),
                              Container(width: 1, height: 40, color: Colors.white10),
                              WeatherInfoCard(
                                icon: Icons.air_rounded,
                                label: 'WIND',
                                value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                                iconColor: Colors.greenAccent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('Search for a city', style: TextStyle(color: Colors.white)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white24, size: 80),
          const SizedBox(height: 16),
          Text(
            error.replaceFirst('Exception: ', ''),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WeatherInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const WeatherInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 10),
        Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5)
        ),
        const SizedBox(height: 5),
        Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
        ),
      ],
    );
  }
}
