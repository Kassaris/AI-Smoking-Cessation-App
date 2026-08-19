import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:smoking_app/providers/home_screen_provider.dart';
import 'package:smoking_app/providers/notification_provider.dart';
import 'package:smoking_app/providers/user_provider.dart';
import 'package:smoking_app/screens/goals_screen.dart';
import 'package:smoking_app/widgets/action_button.dart';
import 'package:smoking_app/widgets/health_progress_section.dart';
import 'package:smoking_app/widgets/info_column.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final _firestoreService = FirestoreService();

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late HomeScreenProvider _homeProvider;
  bool _isInit = false;
  bool _userDataLoaded = false;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _homeProvider = Provider.of<HomeScreenProvider>(context, listen: false);
      _homeProvider.init(this);
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    // Wait for user data to be initialized
    while (!userProvider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Force immediate stats update
    userProvider.updateMinuteStats();

    final user = userProvider.user;
    if (user != null) {
      notificationProvider.scheduleUserNotifications(user);
      notificationProvider.checkAttributeNotifications(user);
    } else {
      // Handle the null case if needed, e.g. log or retry
      print('User data is null, cannot schedule notifications.');
    }

    // Start update timer
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) return;
      userProvider.notifyListeners();
    });

    setState(() {
      _userDataLoaded = true;
    });
  }

  @override
  void dispose() {
    _homeProvider.disposeController();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (!_userDataLoaded || !userProvider.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Positioned.fill(
            child:
                Image.asset('assets/images/background1.jpg', fit: BoxFit.cover),
          ),
          _buildMainContent(context),
          if (context.watch<HomeScreenProvider>().isDrawerOpen)
            GestureDetector(
              onTap: () => context.read<HomeScreenProvider>().toggleDrawer(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
          _DrawerSlide(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green[800],
      leading: Transform.translate(
        offset: const Offset(15, 0),
        child: IconButton(
          icon: const Icon(Icons.account_circle, size: 32),
          color: Colors.white,
          onPressed: () => context.read<HomeScreenProvider>().toggleDrawer(),
        ),
      ),
      title: Text(
        'QuIT',
        textAlign: TextAlign.center,
        style: GoogleFonts.juliusSansOne(
          textStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          fontSize: 35,
        ),
      ),
      actions: [
        Transform.translate(
          offset: const Offset(-15, 0),
          child: IconButton(
            icon: const Icon(Icons.settings, size: 32),
            color: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const SizedBox(height: 5),
          _UserStatsCard(),
          const SizedBox(height: 50),
          _QuickStatsCard(),
          const NumberScrollButtons(),
          const SizedBox(height: 10),
          _HealthProgressCard(),
          const SizedBox(height: 12),
          ActionButton(
            context: context,
            icon: Icons.favorite,
            label: 'Beat Cravings',
            route: '/beat_cravings',
            description: 'Tips and techniques to help manage cravings',
          ),
          ActionButton(
            context: context,
            icon: Icons.forum,
            label: 'Talk to Someone',
            route: '/talk_screen',
            description: 'Share your experience with others in this journey',
          ),
          ActionButton(
            context: context,
            icon: Icons.emoji_events,
            label: 'Achievements',
            route: '/achievements',
            description: 'See what you have achieved so far and set new goals',
          ),
          ActionButton(
            context: context,
            icon: Icons.event,
            label: 'Documents',
            route: '/documents',
            description:
                'Track your cravings and how you beat them for future reference.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _UserStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, userProvider, __) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 125, 55).withOpacity(0.95),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            ' ${userProvider.formattedSmokeFreeTime}\nSmoke-Free',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, userProvider, __) => GestureDetector(
        onTap: () {
          // Navigate to your stats screen
          Navigator.pushNamed(
              context, '/stats'); // Or use your actual stats screen route
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(5, 5))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InfoColumn(
                  icon: Icons.smoke_free,
                  label: 'Avoided',
                  value: '${userProvider.cigarettesAvoided}'),
              InfoColumn(
                  icon: Icons.attach_money,
                  label: 'Saved',
                  value: '€${userProvider.moneySaved.toStringAsFixed(2)}'),
              InfoColumn(
                  icon: Icons.favorite,
                  label: 'Gained',
                  value: '${userProvider.minutesOfLifeGained}m'),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => Navigator.pushNamed(context, '/progress'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(5, 5))
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monitor_heart, color: Colors.green[800]),
                  const SizedBox(width: 8),
                  Text('Health Progress',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800])),
                ],
              ),
              const SizedBox(height: 12),
              const HealthProgressSection(),
              const SizedBox(height: 5),
              const Text('Tap to see more',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerSlide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: context.watch<HomeScreenProvider>().drawerSlideAnimation,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        color: Colors.white.withOpacity(0.95),
        padding: const EdgeInsets.all(20),
        child: Consumer<UserProvider>(
          builder: (_, userProvider, __) => ListView(
            children: [
              const SizedBox(height: 30),
              Text(userProvider.username,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800]),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage(
                      '${userProvider.getRankBadge(userProvider.rank)}')),
              const SizedBox(height: 20),
              Text(userProvider.ranktitle,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Rank: ',
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                  children: [
                    TextSpan(
                        text: '${userProvider.rank}',
                        style: const TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('XP Progress',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: userProvider.currentXP / userProvider.xpToLevelUp,
                color: Colors.green[800],
                backgroundColor: Colors.green[100],
                minHeight: 12,
              ),
              const SizedBox(height: 10),
              Text('${userProvider.currentXP} / ${userProvider.xpToLevelUp} XP',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/friends'),
                child: Row(
                  children: [
                    Icon(Icons.people, color: Colors.green[800]),
                    SizedBox(width: 13),
                    Text('Friends',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                child: Row(
                  children: [
                    Icon(Icons.leaderboard, color: Colors.green[800]),
                    SizedBox(width: 13),
                    Text('View Leaderboard',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
