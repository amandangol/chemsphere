import 'package:chem_explore/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'aqi/screen/city_search_screen.dart';
import 'home/home_screen.dart';
import 'aqi/provider/aqi_provider.dart';
import 'elements/screens/periodic_tablescreen/periodic_table_screen.dart';
import 'compounds/compound_searhc_screen.dart';
import 'chemistryguide/chemistry_guide_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _greetingAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _greetingOpacityAnimation;
  String _username = '';
  bool _loadingUsername = true;
  final List<String> _chemistryFacts = [
    'Water is the only substance that exists naturally in all three states of matter on Earth.',
    'Gold is the most malleable metal and can be hammered into sheets so thin that light can pass through them.',
    'Diamonds are not rare at all—they are actually one of the most common gems found on Earth.',
    'The human body contains enough carbon to fill about 9,000 pencils.',
    'The only letter not appearing on the periodic table is J.',
  ];
  int _currentFactIndex = 0;
  late PageController _pageController;
  late int _currentIndex;

  DateTime? _lastBackPressTime;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _locationPermissionChecked = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadUsername();

    // Header animation
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Greeting animation
    _greetingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _greetingOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _greetingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _headerAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _greetingAnimationController.forward();
    });

    // Cycle through facts
    Future.delayed(const Duration(seconds: 15), _cycleToNextFact);

    // If the initial index is the Air Quality tab, check location permissions
    if (_currentIndex == 2) {
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    if (_locationPermissionChecked) return;

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show dialog to enable location services
        if (mounted) {
          _showLocationServiceDisabledDialog();
        }
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          // User denied the permission, show a snackbar
          if (mounted) {
            SnackbarUtil.showCustomSnackBar(
              context,
              message: 'Location permission is needed for air quality data',
              backgroundColor: Colors.orange,
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // User denied permission forever, show a dialog with app settings option
        if (mounted) {
          _showPermissionDeniedForeverDialog();
        }
        return;
      }

      // If we get here, we have permission - initialize AQI data if we're on the AQI tab
      if (_currentIndex == 2 && mounted) {
        final provider = Provider.of<AqiProvider>(context, listen: false);
        await provider.fetchAqiData();
      }

      setState(() {
        _locationPermissionChecked = true;
      });
    } catch (e) {
      debugPrint('Error checking location permission: $e');
    }
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
              'Please enable location services to get air quality data for your area.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
              'Location permission is required for air quality data. Please enable it in app settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _cycleToNextFact() {
    if (!mounted) return;
    setState(() {
      _currentFactIndex = (_currentFactIndex + 1) % _chemistryFacts.length;
    });
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        _cycleToNextFact();
      }
    });
  }

  Future<void> _loadUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      setState(() {
        _username = username;
        _loadingUsername = false;
      });
    } catch (e) {
      setState(() {
        _loadingUsername = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      SnackbarUtil.showCustomSnackBar(
        context,
        message: 'Press back again to exit',
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _greetingAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            // Home Screen - Dashboard with quick access to popular features
            HomeScreen(),

            // Explore Screen - Direct access to periodic table
            PeriodicTableScreen(),

            // City Search Screen - Air Quality Map
            CitySearchScreen(),

            // Compounds Screen - Search and explore chemical compounds
            CompoundSearchScreen(),

            // Learn content
            ChemistryGuideScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, -3),
                blurRadius: 10,
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background elements - subtle molecule patterns
                Positioned(
                  left: 40,
                  bottom: 8,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(
                      Icons.science,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Positioned(
                  right: 60,
                  bottom: 12,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(
                      Icons.hub,
                      size: 24,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                // Actual bottom navigation bar
                BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: theme.colorScheme.primary,
                  unselectedItemColor:
                      theme.colorScheme.onSurface.withOpacity(0.6),
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  items: [
                    _buildNavItem(Icons.home_rounded, 'Home'),
                    _buildNavItem(Icons.table_chart_rounded, 'Elements'),
                    _buildNavItem(Icons.air_rounded, 'Air Quality'),
                    _buildNavItem(Icons.science_rounded, 'Compounds'),
                    _buildNavItem(Icons.school_rounded, 'Learn'),
                  ],
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });

                    // Check location permission when navigating to Air Quality tab
                    if (index == 2) {
                      _checkLocationPermission();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getIconColor(label).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getIconColor(label).withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: _getIconColor(label).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }

  Color _getIconColor(String label) {
    final theme = Theme.of(context);
    switch (label) {
      case 'Home':
        return theme.colorScheme.primary;
      case 'Elements':
        return Colors.indigo;
      case 'Air Quality':
        return Colors.blue;
      case 'Compounds':
        return Colors.teal;
      case '3D Viewer':
        return Colors.purple;
      case 'Saved':
        return Colors.green;
      default:
        return theme.colorScheme.primary;
    }
  }
}
