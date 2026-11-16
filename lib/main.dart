import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'learning_hub.dart';
import 'sitemap_screen.dart';
import 'demo_login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'register_screen.dart';
import 'admin_portal.dart';
import 'chatbot_widget.dart';
import 'team_emotional_weather.dart';
import 'auth_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MTAlchemyApp());
}

// ============================================================
// 1. DESIGN SYSTEM
// ============================================================

const navy = Color(0xFF202B48);
const oat = Color(0xFFF4F0E8);
const lilac = Color(0xFFDCD5EA);
const purple = Color(0xFF7664A5);
const gold = Color(0xFFF0D977);
const sage = Color(0xFFB9C8B8);
const ink = Color(0xFF292C35);
const muted = Color(0xFF72727B);
const white = Color(0xFFFFFFFF);

class MTAlchemyApp extends StatelessWidget {
  const MTAlchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MT Alchemy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: oat,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navy,
          primary: navy,
          secondary: purple,
        ),
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// 2. HOME PAGE
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void navigate(BuildContext context, String page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContentScreen(title: page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 1100;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HEADER
                    SiteHeader(
                      mobile: mobile,
                      onNavigate: (page) => navigate(context, page),
                    ),

                    // HERO
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        mobile ? 16 : 48,
                        20,
                        mobile ? 16 : 48,
                        0,
                      ),
                      child: mobile
                          ? const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HeroCopy(),
                          SizedBox(height: 16),
                          HeroArtwork(height: 300),
                        ],
                      )
                          : const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: HeroCopy(),
                          ),
                          SizedBox(width: 22),
                          Expanded(
                            flex: 4,
                            child: HeroArtwork(height: 470),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 70),

                    // ALCHEMY CYCLE
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: mobile ? 20 : 65,
                      ),
                      child: const AlchemyCycle(),
                    ),

                    const SizedBox(height: 75),

                    // DEVELOPMENT PATHWAYS
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: mobile ? 20 : 65,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeading(
                            eyebrow: 'FIND YOUR PATH',
                            title: 'Growth looks different for everyone.',
                            description:
                            'Explore a pathway that meets you where you are '
                                'and helps you move towards where you want to be.',
                          ),
                          const SizedBox(height: 28),
                          LayoutBuilder(
                            builder: (context, box) {
                              final columns =
                              box.maxWidth > 850 ? 3 : 1;

                              return GridView.count(
                                crossAxisCount: columns,
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                childAspectRatio:
                                columns == 3 ? 0.78 : (box.maxWidth < 500 ? 0.72 : 1.25),
                                children: [
                                  PathwayCard(
                                    number: '01',
                                    icon: Icons.psychology_outlined,
                                    title: 'Understand yourself.',
                                    description:
                                    'Develop emotional intelligence, '
                                        'self-awareness and mindful habits.',
                                    category: 'INDIVIDUAL GROWTH',
                                    color: lilac,
                                    imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=900&q=80',
                                    button: 'Explore learning',
                                    onTap: () =>
                                        navigate(context, 'Upskilling'),
                                  ),
                                  PathwayCard(
                                    number: '02',
                                    icon: Icons.groups_2_outlined,
                                    title: 'Grow together.',
                                    description:
                                    'Build authentic leadership, trust '
                                        'and stronger team relationships.',
                                    category: 'TEAM DEVELOPMENT',
                                    color: sage,
                                    imageUrl: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=900&q=80',
                                    button: 'Explore services',
                                    onTap: () =>
                                        navigate(context, 'Services'),
                                  ),
                                  PathwayCard(
                                    number: '03',
                                    icon: Icons.auto_stories_outlined,
                                    title: 'Put growth into practice.',
                                    description:
                                    'Explore workbooks, journals and '
                                        'resources for everyday learning.',
                                    category: 'PRACTICAL RESOURCES',
                                    color: gold,
                                    imageUrl: 'https://images.unsplash.com/photo-1517842645767-c639042777db?auto=format&fit=crop&w=900&q=80',
                                    button: 'Visit the store',
                                    onTap: () => navigate(context, 'Store'),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 75),

                    // IMPACT SECTION
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: mobile ? 16 : 48,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(mobile ? 25 : 48),
                        decoration: BoxDecoration(
                          color: navy,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'THE DIFFERENCE WE WANT TO MAKE',
                              style: TextStyle(
                                color: gold,
                                fontSize: 11,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Personal growth should create collective change.',
                              style: TextStyle(
                                color: white,
                                fontSize: mobile ? 32 : 46,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                                letterSpacing: -1.4,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'From individual insight to healthier teams, '
                                  'we believe meaningful development changes '
                                  'the way people work, connect and lead.',
                              style: TextStyle(
                                color: Color(0xFFDADCE7),
                                fontSize: 15,
                                height: 1.8,
                              ),
                            ),
                            const SizedBox(height: 35),
                            Wrap(
                              spacing: 35,
                              runSpacing: 25,
                              children: const [
                                ImpactStat(
                                  value: '1,100+',
                                  label: 'Participants impacted',
                                ),
                                ImpactStat(
                                  value: '120+',
                                  label: 'Organisations',
                                ),
                                ImpactStat(
                                  value: '95%',
                                  label: 'Positive feedback',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 70),

                    // EMPLOYER CALL TO ACTION
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: mobile ? 20 : 65,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(mobile ? 25 : 40),
                        decoration: BoxDecoration(
                          color: lilac,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: mobile
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const EmployerCopy(),
                            const SizedBox(height: 25),
                            EmployerButton(
                              onTap: () =>
                                  navigate(context, 'Employers'),
                            ),
                          ],
                        )
                            : Row(
                          children: [
                            const Expanded(child: EmployerCopy()),
                            const SizedBox(width: 25),
                            EmployerButton(
                              onTap: () =>
                                  navigate(context, 'Employers'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 65),

                    // FOOTER
                    Container(
                      color: const Color(0xFFE9E3D8),
                      padding: EdgeInsets.all(mobile ? 24 : 48),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 20,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MT / ALCHEMY',
                                style: TextStyle(
                                  color: navy,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'A studio for human potential.',
                                style: TextStyle(color: muted),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    navigate(context, 'About'),
                                child: const Text('About'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    navigate(context, 'Contact'),
                                child: const Text('Contact'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    navigate(context, 'Login'),
                                child: const Text('Learning login'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const ChatbotWidget(),
        ],
      ),

    );
  }
}


// ============================================================
// 3. HEADER AND NAVIGATION
// ============================================================


class SiteHeader extends StatelessWidget {
  final bool mobile;
  final ValueChanged<String> onNavigate;

  const SiteHeader({
    super.key,
    required this.mobile,
    required this.onNavigate,
  });

  final List<String> links = const [
    'About',
    'Services',
    'Store',
    'Contact',
  ];

  Future<String?> _currentUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return profile.data()?['role']?.toString();
    } catch (e) {
      debugPrint('Unable to load account role: $e');
      return null;
    }
  }

  String _destinationForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'employer':
        return 'Employers';
      case 'admin':
      case 'super admin':
        return 'Admin Portal';
      default:
        return 'Learning Hub';
    }
  }

  String _labelForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'employer':
        return 'Employer Portal';
      case 'admin':
      case 'super admin':
        return 'Admin Portal';
      default:
        return 'Learning Hub';
    }
  }

  IconData _iconForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'employer':
        return Icons.business_center_outlined;
      case 'admin':
      case 'super admin':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.school_outlined;
    }
  }

  void _openNavigationDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Navigation menu',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: oat,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: SizedBox(
                  width: MediaQuery.sizeOf(dialogContext).width * 0.86,
                  height: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DRAWER HEADER
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: purple,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MT / ALCHEMY',
                                    style: TextStyle(
                                      color: navy,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Text(
                                    'A STUDIO FOR HUMAN POTENTIAL',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 8,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext),
                              icon: const Icon(
                                Icons.close,
                                color: navy,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: Color(0xFFE2DDD4)),

                      // NAVIGATION LINKS
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          children: [
                            for (final link in [
                              'About',
                              'Services',
                              'Store',
                              'Contact',
                              'Sitemap',
                            ])
                              ListTile(
                                leading: Icon(
                                  _getNavigationIcon(link),
                                  color: purple,
                                ),
                                title: Text(
                                  link,
                                  style: const TextStyle(
                                    color: navy,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: muted,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onTap: () {
                                  Navigator.pop(dialogContext);
                                  onNavigate(link);
                                },
                              ),
                          ],
                        ),
                      ),

                      // ACCOUNT ACTIONS
                      FutureBuilder<String?>(
                        future: _currentUserRole(),
                        builder: (context, snapshot) {
                          final user = FirebaseAuth.instance.currentUser;
                          final role = snapshot.data;
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (user != null) ...[
                                  FilledButton.tonalIcon(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                      onNavigate(_destinationForRole(role));
                                    },
                                    icon: Icon(_iconForRole(role)),
                                    label: Text(_labelForRole(role)),
                                  ),
                                  if (role?.toLowerCase() == 'employer') ...[
                                    const SizedBox(height: 10),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        Navigator.pop(dialogContext);
                                        await confirmAndSignOut(context);
                                      },
                                      icon: const Icon(Icons.logout),
                                      label: const Text('Sign out'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: navy,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                ],
                                if (user == null) ...[
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                      onNavigate('Login');
                                    },
                                    icon: const Icon(Icons.login),
                                    label: const Text('Sign in'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: navy,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      side: const BorderSide(color: navy),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                FilledButton.icon(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                    onNavigate('Register');
                                  },
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Get started'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: navy,
                                    foregroundColor: white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        return SlideTransition(
          position: slide,
          child: child,
        );
      },
    );
  }

  IconData _getNavigationIcon(String link) {
    switch (link) {
      case 'About':
        return Icons.info_outline;
      case 'Services':
        return Icons.groups_outlined;
      case 'Store':
        return Icons.shopping_bag_outlined;
      case 'Contact':
        return Icons.mail_outline;
      case 'Sitemap':
        return Icons.account_tree_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Switch to compact navigation when horizontal space is limited.
        final compact = mobile || constraints.maxWidth < 1400;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 20 : 48,
            vertical: 18,
          ),
          child: Row(
            children: [
              // ALWAYS VISIBLE NAVIGATION MENU
              IconButton(
                tooltip: 'Open navigation menu',
                onPressed: () => _openNavigationDrawer(context),
                icon: const Icon(
                  Icons.menu,
                  color: navy,
                  size: 27,
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.auto_awesome,
                color: purple,
                size: 29,
              ),
              const SizedBox(width: 10),

              const Expanded(
                flex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MT / ALCHEMY',
                      style: TextStyle(
                        color: navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'A STUDIO FOR HUMAN POTENTIAL',
                      style: TextStyle(
                        color: muted,
                        fontSize: 8,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              if (!compact) ...[
                ...links.map(
                      (link) => TextButton(
                    onPressed: () => onNavigate(link),
                    child: Text(
                      link,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () => onNavigate('Sitemap'),
                  child: const Text('Sitemap'),
                ),
              ],

              if (FirebaseAuth.instance.currentUser != null)
                FutureBuilder<String?>(
                  future: _currentUserRole(),
                  builder: (context, snapshot) {
                    final role = snapshot.data;
                    return TextButton.icon(
                      onPressed: snapshot.connectionState == ConnectionState.waiting
                          ? null
                          : () => onNavigate(_destinationForRole(role)),
                      icon: Icon(_iconForRole(role), size: 18),
                      label: Text(_labelForRole(role)),
                      style: TextButton.styleFrom(foregroundColor: navy),
                    );
                  },
                ),
              if (FirebaseAuth.instance.currentUser != null)
                FutureBuilder<String?>(
                  future: _currentUserRole(),
                  builder: (context, snapshot) {
                    if (snapshot.data?.toLowerCase() != 'employer') {
                      return const SizedBox.shrink();
                    }
                    return TextButton.icon(
                      onPressed: () => confirmAndSignOut(context),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Sign out'),
                      style: TextButton.styleFrom(foregroundColor: navy),
                    );
                  },
                ),

              IconButton(
                tooltip: 'Open cart',
                onPressed: () => onNavigate('Cart'),
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: navy,
                  size: 25,
                ),
              ),

              if (!compact) ...[
                const SizedBox(width: 8),
                if (FirebaseAuth.instance.currentUser == null) ...[
                  OutlinedButton(
                    onPressed: () => onNavigate('Login'),
                    child: const Text('Sign in'),
                  ),
                  const SizedBox(width: 8),
                ],
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: white,
                  ),
                  onPressed: () => onNavigate('Register'),
                  child: const Text('Get started ↗'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// 4. HERO COPY
// ============================================================

class HeroCopy extends StatelessWidget {
  const HeroCopy({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 470),
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E2F1),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'A STUDIO FOR HUMAN POTENTIAL',
            style: TextStyle(
              color: purple,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Change begins within.\nImpact moves outward.',
            style: TextStyle(
              color: navy,
              fontSize: 43,
              fontWeight: FontWeight.w800,
              height: 1.13,
              letterSpacing: -1.8,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Discover a more human way to learn, lead and '
                'grow through experiences designed to turn insight '
                'into meaningful change.',
            style: TextStyle(
              color: Color(0xFF555563),
              fontSize: 15,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: navy,
              foregroundColor: white,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 18,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const ContentScreen(title: 'Upskilling'),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward, size: 17),
            label: const Text('Find your pathway'),
          ),
          const SizedBox(height: 15),
          const Text(
            'FOR INDIVIDUALS  ·  TEAMS  ·  ORGANISATIONS',
            style: TextStyle(
              color: muted,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 5. ABSTRACT HERO ARTWORK
// ============================================================

class HeroArtwork extends StatelessWidget {
  final double height;

  const HeroArtwork({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1100&q=85',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: navy);
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  navy.withValues(alpha: 0.85),
                  navy.withValues(alpha: 0.08),
                ],
              ),
            ),
          ),
          Positioned(
            top: 25,
            right: 25,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: navy,
                size: 32,
              ),
            ),
          ),
          const Positioned(
            bottom: 25,
            left: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE ALCHEMY PRINCIPLE',
                  style: TextStyle(
                    color: gold,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Small shifts.\nLasting change.',
                  style: TextStyle(
                    color: white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 6. ALCHEMY CYCLE
// ============================================================

class AlchemyCycle extends StatelessWidget {
  const AlchemyCycle({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('01', 'Discover', Icons.lightbulb_outline),
      ('02', 'Practice', Icons.edit_note),
      ('03', 'Transform', Icons.change_circle_outlined),
      ('04', 'Impact', Icons.public_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7E2E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OUR APPROACH',
            style: TextStyle(
              color: purple,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'From insight to impact.',
            style: TextStyle(
              color: navy,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 20,
            runSpacing: 20,
            children: steps.map((step) {
              return SizedBox(
                width: 135,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: step.$1 == '03' ? purple : lilac,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(
                        step.$3,
                        color: step.$1 == '03' ? white : navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      step.$1,
                      style: const TextStyle(
                        color: purple,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.$2,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 7. REUSABLE SECTION HEADING
// ============================================================

class SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;

  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: purple,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: navy,
            fontSize: 34,
            fontWeight: FontWeight.bold,
            height: 1.2,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            color: muted,
            fontSize: 15,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 8. DEVELOPMENT PATHWAY CARD
// ============================================================

class PathwayCard extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;
  final String category;
  final Color color;
  final String imageUrl;
  final String button;
  final VoidCallback onTap;

  const PathwayCard({
    super.key,
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.category,
    required this.color,
    required this.imageUrl,
    required this.button,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 142,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: color,
                alignment: Alignment.center,
                child: Icon(icon, size: 42, color: navy),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, size: 31, color: navy),
                    Text(
                      number,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  category,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF4F5360),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: navy,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text('$button ↗'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 9. IMPACT STATISTICS
// ============================================================

class ImpactStat extends StatelessWidget {
  final String value;
  final String label;

  const ImpactStat({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: gold,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFDADCE7),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 10. EMPLOYER SECTION
// ============================================================

class EmployerCopy extends StatelessWidget {
  const EmployerCopy({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FOR ORGANISATIONS',
          style: TextStyle(
            color: purple,
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        Text(
          'Develop people.\nTransform culture.',
          style: TextStyle(
            color: navy,
            fontSize: 33,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        SizedBox(height: 15),
        Text(
          'Bring learning, course assignments and employee '
              'development together in one connected experience.',
          style: TextStyle(
            color: muted,
            fontSize: 14,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

class EmployerButton extends StatelessWidget {
  final VoidCallback onTap;

  const EmployerButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: navy,
        foregroundColor: white,
        padding: const EdgeInsets.all(20),
      ),
      onPressed: onTap,
      icon: const Icon(Icons.arrow_forward),
      label: const Text('Explore employer portal'),
    );
  }
}


// ============================================================
// 11. SHOP AND CART (SAMPLE DATA FOR CHECKPOINT 1)
// ============================================================

class ShopProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String type;

  const ShopProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.type,
  });
}

const shopProducts = <ShopProduct>[
  ShopProduct(
    id: 'journal',
    name: 'The Reflection Journal',
    description: 'Guided prompts for self-awareness and everyday reflection.',
    price: 29.00,
    imageUrl: 'https://images.unsplash.com/photo-1517842645767-c639042777db?auto=format&fit=crop&w=900&q=80',
    type: 'DIGITAL WORKBOOK',
  ),
  ShopProduct(
    id: 'leadership',
    name: 'Leadership Workbook',
    description: 'Practical exercises for intentional, people-centred leadership.',
    price: 39.00,
    imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=900&q=80',
    type: 'DIGITAL WORKBOOK',
  ),
  ShopProduct(
    id: 'conversation',
    name: 'Better Conversations Toolkit',
    description: 'Prompts and tools to strengthen communication and trust.',
    price: 19.00,
    imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=900&q=80',
    type: 'DIGITAL TOOLKIT',
  ),
  ShopProduct(
    id: 'team',
    name: 'Team Reflection Cards',
    description: 'A facilitation resource for group discussion and team learning.',
    price: 45.00,
    imageUrl: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&w=900&q=80',
    type: 'TEAM RESOURCE',
  ),
  ShopProduct(
    id: 'printed_journal',
    name: 'Printed Reflection Journal',
    description: 'A beautifully printed journal with guided prompts for self-awareness and everyday reflection.',
    price: 49.00,
    imageUrl: 'https://images.unsplash.com/photo-1517842645767-c639042777db?auto=format&fit=crop&w=900&q=80',
    type: 'PHYSICAL PRODUCT',
  ),
  ShopProduct(
    id: 'printed_leadership',
    name: 'Printed Leadership Workbook',
    description: 'A printed workbook of practical exercises for intentional, people-centred leadership.',
    price: 59.00,
    imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=900&q=80',
    type: 'PHYSICAL PRODUCT',
  ),
  ShopProduct(
    id: 'physical_team_cards',
    name: 'Team Reflection Cards – Printed Set',
    description: 'A physical card set for facilitating group discussion, reflection and team learning.',
    price: 45.00,
    imageUrl: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&w=900&q=80',
    type: 'PHYSICAL PRODUCT',
  ),
];

class CartLine {
  final ShopProduct product;
  int quantity;

  CartLine({required this.product, this.quantity = 1});
}

final List<CartLine> sampleCart = [];
final ValueNotifier<int> sampleCartCount = ValueNotifier<int>(0);

void refreshSampleCartCount() {
  sampleCartCount.value =
      sampleCart.fold<int>(0, (sum, line) => sum + line.quantity);
}

void addProductToCart(ShopProduct product) {
  final index = sampleCart.indexWhere((line) => line.product.id == product.id);
  if (index >= 0) {
    sampleCart[index].quantity++;
  } else {
    sampleCart.add(CartLine(product: product));
  }
  refreshSampleCartCount();
}

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final digitalProducts = shopProducts
        .where((product) => product.type != 'PHYSICAL PRODUCT')
        .toList();
    final physicalProducts = shopProducts
        .where((product) => product.type == 'PHYSICAL PRODUCT')
        .toList();

    return Scaffold(
      backgroundColor: oat,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: oat,
        foregroundColor: navy,
        elevation: 0,
        title: const Text('THE ALCHEMY STORE'),
        leading: IconButton(
          tooltip: 'Return to Home',
          icon: const Icon(Icons.home_outlined),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          },
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyDigitalProductsScreen(),
              ),
            ),
            icon: const Icon(Icons.download_outlined),
            label: const Text('My Digital Products'),
          ),
          if (FirebaseAuth.instance.currentUser != null)
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyPhysicalOrdersScreen(),
                ),
              ),
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('My Physical Orders'),
            ),
          if (FirebaseAuth.instance.currentUser != null)
            IconButton(
              tooltip: 'Sign out',
              onPressed: () => confirmAndSignOut(context),
              icon: const Icon(Icons.logout),
            ),
          ValueListenableBuilder<int>(
            valueListenable: sampleCartCount,
            builder: (context, count, _) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text('Cart ($count)'),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: navy,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOOLS FOR YOUR NEXT CHAPTER',
                        style: TextStyle(
                          color: gold,
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Make the insight last.',
                        style: TextStyle(
                          color: white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Explore thoughtful resources designed to bring self-awareness, '
                            'leadership and better conversations into everyday life.',
                        style: TextStyle(color: Color(0xFFE0E1E8), height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'THE RESOURCE COLLECTION',
                  style: TextStyle(
                    color: purple,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Practical tools. Meaningful change.',
                  style: TextStyle(
                    color: navy,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(Icons.filter_list, color: navy),
                    const SizedBox(width: 8),
                    const Text(
                      'Filter products',
                      style: TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    PopupMenuButton<String>(
                      tooltip: 'Filter by product type',
                      initialValue: _selectedFilter,
                      onSelected: (value) {
                        setState(() => _selectedFilter = value);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'ALL', child: Text('All products')),
                        PopupMenuItem(value: 'DIGITAL', child: Text('Digital products')),
                        PopupMenuItem(value: 'PHYSICAL', child: Text('Physical products')),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: lilac,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: purple.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedFilter == 'ALL'
                                  ? 'All products'
                                  : _selectedFilter == 'DIGITAL'
                                  ? 'Digital products'
                                  : 'Physical products',
                              style: const TextStyle(
                                color: navy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.keyboard_arrow_down, color: navy),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_selectedFilter == 'ALL' || _selectedFilter == 'DIGITAL')
                  _StoreProductSection(
                    title: 'DIGITAL PRODUCTS',
                    subtitle: 'Instant-access workbooks, toolkits and downloadable resources.',
                    icon: Icons.download_for_offline_outlined,
                    products: digitalProducts,
                  ),
                if (_selectedFilter == 'ALL') const SizedBox(height: 30),
                if (_selectedFilter == 'ALL' || _selectedFilter == 'PHYSICAL')
                  _StoreProductSection(
                    title: 'PHYSICAL PRODUCTS',
                    subtitle: 'Printed journals, workbooks and card sets delivered to your address.',
                    icon: Icons.local_shipping_outlined,
                    products: physicalProducts,
                  ),
                const SizedBox(height: 22),
                const Text(
                  'Prototype store: products and prices are illustrative. No payment is processed.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreProductSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<ShopProduct> products;

  const _StoreProductSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: lilac,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: purple,
                      fontSize: 12,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: muted, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 850
                ? 3
                : constraints.maxWidth >= 540
                ? 2
                : 1;
            final width =
                (constraints.maxWidth - (columns - 1) * 18) / columns;
            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: products.map((product) {
                return SizedBox(
                  width: width,
                  child: _StoreProductCard(product: product),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _StoreProductCard extends StatelessWidget {
  final ShopProduct product;

  const _StoreProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5DFD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 190,
            width: double.infinity,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: lilac,
                child: const Icon(Icons.auto_stories_outlined, size: 48, color: navy),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.type,
                  style: const TextStyle(
                    color: purple,
                    fontSize: 10,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(color: muted, height: 1.5, fontSize: 13),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RM ${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: navy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: white,
                      ),
                      onPressed: () {
                        addProductToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Add to cart'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// 11B. MY PHYSICAL ORDERS AND DELIVERY STATUS
// ============================================================

class MyPhysicalOrdersScreen extends StatelessWidget {
  const MyPhysicalOrdersScreen({super.key});

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }
    return 'Date unavailable';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF3D7954);
      case 'shipped':
        return const Color(0xFF9A6A16);
      default:
        return purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: oat,
      appBar: AppBar(
        backgroundColor: oat,
        foregroundColor: navy,
        elevation: 0,
        title: const Text('MY PHYSICAL ORDERS'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: user == null ? null : () => confirmAndSignOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: user == null
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Please sign in to view your physical orders.',
            textAlign: TextAlign.center,
            style: TextStyle(color: navy, fontSize: 16),
          ),
        ),
      )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('physicalOrders')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load your physical orders. ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: navy),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: purple),
            );
          }

          final orders = [...?snapshot.data?.docs];
          orders.sort((a, b) {
            final aDate = a.data()['createdAt'];
            final bDate = b.data()['createdAt'];
            final aMillis = aDate is Timestamp
                ? aDate.millisecondsSinceEpoch
                : 0;
            final bMillis = bDate is Timestamp
                ? bDate.millisecondsSinceEpoch
                : 0;
            return bMillis.compareTo(aMillis);
          });

          if (orders.isEmpty) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 58,
                      color: purple,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No physical orders yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: navy,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Physical products you purchase will appear here, '
                          'along with their delivery status.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: white,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StoreScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.storefront_outlined),
                      label: const Text('Explore the Store'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR PURCHASES',
                      style: TextStyle(
                        color: purple,
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Track your deliveries.',
                      style: TextStyle(
                        color: navy,
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your physical orders and their latest delivery '
                          'statuses are shown below.',
                      style: TextStyle(color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 22),
                    ...orders.map((orderDoc) {
                      final order = orderDoc.data();
                      final rawItems = order['items'];
                      final items = rawItems is List ? rawItems : <dynamic>[];
                      final deliveryStatus =
                      (order['deliveryStatus'] ??
                          order['orderStatus'] ??
                          'processing')
                          .toString()
                          .toLowerCase();
                      final addressRaw = order['shippingAddress'];
                      final address = addressRaw is Map
                          ? Map<String, dynamic>.from(addressRaw)
                          : <String, dynamic>{};
                      final addressText = [
                        address['address'],
                        address['city'],
                        address['state'],
                        address['postcode'],
                        address['country'],
                      ]
                          .where((part) =>
                      part != null &&
                          part.toString().trim().isNotEmpty)
                          .join(', ');
                      final total = (order['total'] as num?)?.toDouble() ??
                          (order['subtotal'] as num?)?.toDouble() ??
                          0.0;
                      final orderId =
                      (order['orderId'] ?? orderDoc.id).toString();

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE5DFD5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 10,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ORDER',
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 10,
                                        letterSpacing: 1.4,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      orderId,
                                      style: const TextStyle(
                                        color: navy,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Placed: ${_formatDate(order['createdAt'])}',
                                      style: const TextStyle(
                                        color: muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(deliveryStatus)
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                    BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    deliveryStatus.toUpperCase(),
                                    style: TextStyle(
                                      color: _statusColor(deliveryStatus),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 28),
                            const Text(
                              'ITEMS',
                              style: TextStyle(
                                color: purple,
                                fontSize: 10,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...items.map((rawItem) {
                              if (rawItem is! Map) {
                                return const SizedBox.shrink();
                              }
                              final item =
                              Map<String, dynamic>.from(rawItem);
                              final name =
                              (item['productName'] ?? 'Product')
                                  .toString();
                              final quantity =
                                  (item['quantity'] as num?)?.toInt() ?? 1;
                              final lineTotal =
                                  (item['lineTotal'] as num?)?.toDouble() ??
                                      0.0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 7),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '$name × $quantity',
                                        style: const TextStyle(
                                          color: navy,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'RM ${lineTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: navy,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Order total',
                                  style: TextStyle(
                                    color: navy,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'RM ${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: navy,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (addressText.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'DELIVERY ADDRESS',
                                style: TextStyle(
                                  color: purple,
                                  fontSize: 10,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                addressText,
                                style: const TextStyle(
                                  color: muted,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


// ============================================================
// 11A. MY DIGITAL PRODUCTS
// ============================================================

class MyDigitalProductsScreen extends StatelessWidget {
  const MyDigitalProductsScreen({super.key});

  static const Map<String, String> _downloadFiles = {
    'journal': 'digital_journal_sample.pdf',
    'leadership': 'leadership_guide_sample.pdf',
    'conversation': 'conversation_skills_sample.pdf',
    'team': 'team_building_activities_sample.pdf',
  };

  void _downloadProduct(BuildContext context, String productId) {
    final fileName = _downloadFiles[productId];
    if (fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A download file is not available for this product yet.')),
      );
      return;
    }

    // Uri.base.resolve keeps the GitHub Pages repository sub-path intact.
    final downloadUrl = Uri.base.resolve('downloads/$fileName').toString();
    html.AnchorElement(href: downloadUrl)
      ..download = fileName
      ..target = '_blank'
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: oat,
      appBar: AppBar(
        backgroundColor: oat,
        foregroundColor: navy,
        elevation: 0,
        title: const Text('MY DIGITAL PRODUCTS'),
        actions: [
          if (user != null)
            IconButton(
              tooltip: 'Sign out',
              onPressed: () => confirmAndSignOut(context),
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: user == null
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Please sign in to view your purchased digital products.',
            textAlign: TextAlign.center,
            style: TextStyle(color: navy, fontSize: 16),
          ),
        ),
      )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('digitalOrders')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load your purchases. ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: navy),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: purple),
            );
          }

          final purchasedItems = <Map<String, dynamic>>[];
          for (final orderDoc in snapshot.data?.docs ?? []) {
            final order = orderDoc.data();
            if (order['orderType'] != 'digital' ||
                order['paymentStatus'] != 'demo_completed' ||
                order['orderStatus'] != 'completed') {
              continue;
            }

            final items = order['items'];
            if (items is! List) continue;

            for (final rawItem in items) {
              if (rawItem is! Map) continue;
              purchasedItems.add({
                ...Map<String, dynamic>.from(rawItem),
                'orderId': order['orderId'] ?? orderDoc.id,
                'createdAt': order['createdAt'],
              });
            }
          }

          if (purchasedItems.isEmpty) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_stories_outlined, size: 56, color: purple),
                    const SizedBox(height: 16),
                    const Text(
                      'Your library is waiting.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: navy, fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Digital products you purchase from the Store will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: navy, foregroundColor: white),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StoreScreen()),
                      ),
                      icon: const Icon(Icons.storefront_outlined),
                      label: const Text('Explore the Store'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR RESOURCE LIBRARY',
                      style: TextStyle(color: purple, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Resources you own.',
                      style: TextStyle(color: navy, fontSize: 29, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your completed demo purchases are listed below. Select Download to open the corresponding PDF.',
                      style: TextStyle(color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 22),
                    ...purchasedItems.map((item) {
                      final productId = (item['productId'] ?? '').toString();
                      final productName = (item['productName'] ?? 'Digital product').toString();
                      final description = (item['description'] ?? '').toString();
                      final orderId = (item['orderId'] ?? '').toString();
                      final canDownload = _downloadFiles.containsKey(productId);
                      final timestamp = item['createdAt'];
                      final dateText = timestamp is Timestamp
                          ? '${timestamp.toDate().day.toString().padLeft(2, '0')}/${timestamp.toDate().month.toString().padLeft(2, '0')}/${timestamp.toDate().year}'
                          : 'Date unavailable';

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5DFD5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 58,
                              height: 68,
                              decoration: BoxDecoration(color: lilac, borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.picture_as_pdf_outlined, color: navy, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(productName, style: const TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.bold)),
                                  if (description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(description, style: const TextStyle(color: muted, fontSize: 12, height: 1.4)),
                                  ],
                                  const SizedBox(height: 7),
                                  Text('Purchased: $dateText', style: const TextStyle(color: muted, fontSize: 11)),
                                  Text('Order: $orderId', style: const TextStyle(color: purple, fontSize: 10)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(backgroundColor: navy, foregroundColor: white),
                              onPressed: canDownload ? () => _downloadProduct(context, productId) : null,
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Download'),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    const Text(
                      'Demo note: these sample PDF files are hosted with the website and their URLs are publicly accessible. This page checks your signed-in account’s Firestore purchase records before showing the download links; it is not production-grade file protection.',
                      style: TextStyle(color: muted, fontSize: 11, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postcodeController = TextEditingController();

  String _paymentMethod = 'Online banking (demo)';
  bool _orderCompleted = false;
  bool _isPlacingOrder = false;
  String? _orderId;
  double _completedTotal = 0;

  bool get _isPhysicalCart => sampleCart.isNotEmpty &&
      sampleCart.every((line) => line.product.type == 'PHYSICAL PRODUCT');

  bool get _isDigitalCart => sampleCart.isNotEmpty &&
      sampleCart.every((line) => line.product.type != 'PHYSICAL PRODUCT');

  bool get _hasMixedCart => sampleCart.isNotEmpty &&
      !_isPhysicalCart && !_isDigitalCart;

  double get subtotal => sampleCart.fold<double>(
    0,
        (sum, line) => sum + line.product.price * line.quantity,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _shippingAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (sampleCart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty. Please add an item first.'),
        ),
      );
      return;
    }

    if (_hasMixedCart) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please checkout digital and physical products separately.',
          ),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in before completing your purchase.'),
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final orderCollection = _isPhysicalCart
          ? 'physicalOrders'
          : 'digitalOrders';
      final orderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(orderCollection)
          .doc();

      final orderTotal = subtotal;
      final orderItems = sampleCart.map((line) {
        return <String, dynamic>{
          'productId': line.product.id,
          'productName': line.product.name,
          'description': line.product.description,
          'productType': line.product.type,
          'unitPrice': line.product.price,
          'quantity': line.quantity,
          'lineTotal': line.product.price * line.quantity,
          'imageUrl': line.product.imageUrl,
        };
      }).toList();

      await orderRef.set({
        'orderId': orderRef.id,
        'userId': user.uid,
        'customerName': _nameController.text.trim(),
        'customerEmail': _emailController.text.trim(),
        'billingAddress': _addressController.text.trim(),
        if (_isPhysicalCart) ...{
          'customerPhone': _phoneController.text.trim(),
          'shippingAddress': {
            'address': _shippingAddressController.text.trim(),
            'city': _cityController.text.trim(),
            'state': _stateController.text.trim(),
            'postcode': _postcodeController.text.trim(),
            'country': 'Malaysia',
          },
        },
        'items': orderItems,
        'itemCount': sampleCart.fold<int>(
          0,
              (total, line) => total + line.quantity,
        ),
        'subtotal': orderTotal,
        'total': orderTotal,
        'currency': 'MYR',
        'paymentMethod': _paymentMethod,
        'paymentStatus': 'demo_completed',
        'orderStatus': _isPhysicalCart ? 'processing' : 'completed',
        'orderType': _isPhysicalCart ? 'physical' : 'digital',
        if (_isPhysicalCart) 'deliveryStatus': 'processing',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _completedTotal = orderTotal;
        _orderId = orderRef.id;
        _orderCompleted = true;
        _isPlacingOrder = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save your order: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: oat,
      appBar: AppBar(
        backgroundColor: oat,
        foregroundColor: navy,
        elevation: 0,
        title: const Text('CHECKOUT'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: _orderCompleted
                ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: purple,
                    size: 72,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isPhysicalCart
                        ? 'Your physical order is confirmed!'
                        : 'Thank you for your order!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: navy,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isPhysicalCart
                        ? 'Your physical order has been saved. Its current status is Processing. '
                        'No real payment was processed.'
                        : 'Your demo order has been saved to your account. '
                        'No real payment was processed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, height: 1.6),
                  ),
                  if (_orderId != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Order reference: $_orderId',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Order total: RM ${_completedTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: navy,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    onPressed: () {
                      sampleCart.clear();
                      refreshSampleCartCount();
                      Navigator.popUntil(
                        context,
                            (route) => route.isFirst,
                      );
                    },
                    child: const Text('Continue shopping'),
                  ),
                ],
              ),
            )
                : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ALMOST THERE.',
                    style: TextStyle(
                      color: purple,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete your order.',
                    style: TextStyle(
                      color: navy,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPhysicalCart
                        ? 'Enter your details and delivery address below.'
                        : 'Enter your details and review your order below.',
                    style: TextStyle(color: muted, height: 1.6),
                  ),
                  const SizedBox(height: 24),

                  // Customer details
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR DETAILS',
                          style: TextStyle(
                            color: navy,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter your name.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null ||
                                !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                    .hasMatch(value.trim())) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Billing address',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter your address.';
                            }
                            return null;
                          },
                        ),
                        if (_isPhysicalCart) ...[
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          const Text(
                            'DELIVERY DETAILS',
                            style: TextStyle(
                              color: navy,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Contact number',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (value) {
                              if (_isPhysicalCart &&
                                  (value == null ||
                                      !RegExp(r'^[0-9+()\-\s]{7,20}$')
                                          .hasMatch(value.trim()))) {
                                return 'Enter a valid contact number.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _shippingAddressController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Delivery street address',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.local_shipping_outlined),
                            ),
                            validator: (value) {
                              if (_isPhysicalCart &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Please enter the delivery address.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (_isPhysicalCart &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Please enter the city.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _stateController,
                            decoration: const InputDecoration(
                              labelText: 'State',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (_isPhysicalCart &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Please enter the state.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _postcodeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Postcode',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (_isPhysicalCart &&
                                  (value == null ||
                                      !RegExp(r'^\d{5}$')
                                          .hasMatch(value.trim()))) {
                                return 'Enter a valid 5-digit postcode.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Delivery is currently a coursework simulation. No courier booking is made.',
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment selection
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PAYMENT METHOD',
                          style: TextStyle(
                            color: navy,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          value: 'Online banking (demo)',
                          groupValue: _paymentMethod,
                          activeColor: purple,
                          title: const Text('Online banking'),
                          subtitle: const Text(
                            'Demo selection only — no payment is taken.',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _paymentMethod = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          value: 'PayPal (demo)',
                          groupValue: _paymentMethod,
                          activeColor: purple,
                          title: const Text('PayPal'),
                          subtitle: const Text(
                            'Preview only — not connected to PayPal.',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _paymentMethod = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Order summary
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ORDER SUMMARY',
                          style: TextStyle(
                            color: navy,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (sampleCart.isEmpty)
                          const Text(
                            'Your cart is empty.',
                            style: TextStyle(color: muted),
                          )
                        else
                          ...sampleCart.map(
                                (line) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${line.product.name} × ${line.quantity}',
                                      style: const TextStyle(
                                        color: navy,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'RM ${(line.product.price * line.quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: navy,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const Divider(height: 28),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: navy,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'RM ${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: purple,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This is a coursework checkout prototype. '
                              'No real payment details are collected or processed.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: navy,
                              foregroundColor: white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                              ),
                            ),
                            onPressed: sampleCart.isEmpty || _isPlacingOrder
                                ? null
                                : _placeOrder,
                            icon: _isPlacingOrder
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: white,
                              ),
                            )
                                : const Icon(Icons.lock_outline),
                            label: Text(
                              _isPlacingOrder
                                  ? 'Saving order...'
                                  : _isPhysicalCart
                                  ? 'Place physical order'
                                  : 'Place demo order',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartScreenState extends State<CartScreen> {
  double get subtotal => sampleCart.fold<double>(
    0,
        (sum, line) => sum + line.product.price * line.quantity,
  );

  void updateCart() {
    refreshSampleCartCount();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: oat,
      appBar: AppBar(
        backgroundColor: oat,
        foregroundColor: navy,
        elevation: 0,
        title: const Text('YOUR CART'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StoreScreen()),
            ),
            child: const Text('CONTINUE SHOPPING'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: sampleCart.isEmpty
                ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 55,
              ),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 56,
                    color: purple,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Your cart is taking a little breather.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: navy,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Explore the store to find a resource for your next step.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, height: 1.6),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StoreScreen(),
                      ),
                    ),
                    child: const Text('Explore the store'),
                  ),
                ],
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A GOOD PLACE TO BEGIN.',
                  style: TextStyle(
                    color: purple,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Review your resources.',
                  style: TextStyle(
                    color: navy,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 760;
                    final items = Column(
                      children: sampleCart.map((line) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  line.product.imageUrl,
                                  width: 88,
                                  height: 88,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 88,
                                        height: 88,
                                        color: lilac,
                                        child: const Icon(Icons.auto_stories),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.product.name,
                                      style: const TextStyle(
                                        color: navy,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'RM ${line.product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(color: muted),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        sampleCart.remove(line);
                                        updateCart();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: purple,
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Decrease quantity',
                                    onPressed: () {
                                      if (line.quantity > 1) {
                                        line.quantity--;
                                      } else {
                                        sampleCart.remove(line);
                                      }
                                      updateCart();
                                    },
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text(
                                    '${line.quantity}',
                                    style: const TextStyle(
                                      color: navy,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Increase quantity',
                                    onPressed: () {
                                      line.quantity++;
                                      updateCart();
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );

                    final summary = Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ORDER SUMMARY',
                            style: TextStyle(
                              color: purple,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal', style: TextStyle(color: muted)),
                              Text(
                                'RM ${subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Digital prototype checkout. No payment will be taken.',
                            style: TextStyle(color: muted, fontSize: 12, height: 1.5),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: navy,
                                foregroundColor: white,
                                padding: const EdgeInsets.symmetric(vertical: 17),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CheckoutScreen(),
                                  ),
                                );
                              },
                              child: const Text('Proceed to checkout'),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: items),
                          const SizedBox(width: 20),
                          Expanded(flex: 4, child: summary),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        items,
                        const SizedBox(height: 8),
                        summary,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EMPLOYER PORTAL — interactive checkpoint prototype
// ============================================================

class EmployerRecord {
  final String id;
  String name;
  String email;
  String role;
  String course;
  double progress;

  EmployerRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.course = 'Not assigned',
    this.progress = 0.0,
  });

  factory EmployerRecord.fromDocument(
      QueryDocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();
    return EmployerRecord(
      id: document.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? '',
      course: data['course'] as String? ?? 'Not assigned',
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EmployerPortalScreen extends StatefulWidget {
  const EmployerPortalScreen({super.key});

  @override
  State<EmployerPortalScreen> createState() => _EmployerPortalScreenState();
}

class _EmployerPortalScreenState extends State<EmployerPortalScreen> {
  final organizationController = TextEditingController(text: 'Alchemy Studio');
  final employeeNameController = TextEditingController();
  final employeeEmailController = TextEditingController();
  final employeeRoleController = TextEditingController();
  final employeeFormKey = GlobalKey<FormState>();
  String organizationName = 'Alchemy Studio';
  String selectedCourse = 'Emotional Intelligence';
  final Set<int> selectedEmployees = {0};
  final List<EmployerRecord> employees = [];
  bool employeesLoading = true;
  bool employeesSaving = false;

  final List<String> courses = const [
    'Emotional Intelligence',
    'Leadership Essentials',
    'Mindful Communication',
    'Building Team Trust',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrganization();
    _loadEmployees();
  }

  CollectionReference<Map<String, dynamic>> _employeeCollection(String uid) {
    return FirebaseFirestore.instance
        .collection('organizations')
        .doc(uid)
        .collection('employees');
  }

  Future<void> _loadEmployees() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => employeesLoading = false);
      return;
    }

    try {
      final collection = _employeeCollection(user.uid);
      var snapshot = await collection.get();

      // Keep the three demonstration employees, but seed them only once.
      if (snapshot.docs.isEmpty) {
        final sampleEmployees = [
          {
            'name': 'Avery Chen',
            'email': 'avery.chen@example.com',
            'role': 'Team Lead',
            'course': 'Emotional Intelligence',
            'progress': 0.72,
          },
          {
            'name': 'Jordan Patel',
            'email': 'jordan.patel@example.com',
            'role': 'People & Culture',
            'course': 'Leadership Essentials',
            'progress': 0.45,
          },
          {
            'name': 'Sam Rivera',
            'email': 'sam.rivera@example.com',
            'role': 'Project Manager',
            'course': 'Not assigned',
            'progress': 0.18,
          },
        ];

        final batch = FirebaseFirestore.instance.batch();
        for (final employee in sampleEmployees) {
          final ref = collection.doc();
          batch.set(ref, {
            ...employee,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        snapshot = await collection.get();
      }

      if (!mounted) return;
      setState(() {
        employees
          ..clear()
          ..addAll(snapshot.docs.map(EmployerRecord.fromDocument));
        selectedEmployees
          ..clear()
          ..add(0);
        employeesLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading employees: $e');
      if (!mounted) return;
      setState(() => employeesLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load team members. Check Firestore permissions.')),
      );
    }
  }

  Future<void> _loadOrganization() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          organizationName = data['name'] as String? ?? 'Alchemy Studio';
          organizationController.text = organizationName;
        });
      }
    } catch (e) {
      debugPrint('Error loading organization: $e');
    }
  }

  @override
  void dispose() {
    organizationController.dispose();
    employeeNameController.dispose();
    employeeEmailController.dispose();
    employeeRoleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assignedCount = employees.where((e) => e.course != 'Not assigned').length;
    final averageProgress = employees.isEmpty
        ? 0.0
        : employees.fold<double>(0, (sum, e) => sum + e.progress) / employees.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: oat,
        foregroundColor: navy,
        title: const Text('MT / ALCHEMY  ·  EMPLOYER PORTAL'),
        actions: [
          IconButton(
            tooltip: 'Return home',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.home_outlined),
          ),
          TextButton.icon(
            onPressed: () => confirmAndSignOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text('ORGANISATION WORKSPACE', style: TextStyle(color: purple, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Help your people grow.', style: TextStyle(color: navy, fontSize: 34, height: 1.15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                const Text(
                  'Manage your team, assign learning pathways and see progress in one place.',
                  style: TextStyle(color: muted, fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 24),

// TEAM EMOTIONAL WEATHER CARD
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TeamEmotionalWeatherScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAE5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.cloud_outlined,
                          color: Color(0xFF7655A6),
                          size: 40,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TEAM EMOTIONAL WEATHER',
                                style: TextStyle(
                                  color: Color(0xFF7655A6),
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Check in with your team.',
                                style: TextStyle(
                                  color: Color(0xFF24213D),
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Explore team mood trends and wellbeing activities.',
                                style: TextStyle(
                                  color: Color(0xFF777386),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF7655A6),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                _portalPanel(
                  child: LayoutBuilder(builder: (context, box) {
                    final compact = box.maxWidth < 650;
                    final organizationField = TextField(
                      controller: organizationController,
                      decoration: const InputDecoration(labelText: 'Organisation name', hintText: 'Enter your organisation', border: OutlineInputBorder(), isDense: true),
                      onSubmitted: (_) => _saveOrganization(),
                    );
                    final saveButton = FilledButton.icon(
                      onPressed: _saveOrganization,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Save workspace'),
                      style: FilledButton.styleFrom(backgroundColor: navy, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17)),
                    );
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('01  ·  ORGANISATION SETUP', style: TextStyle(color: purple, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(organizationName, style: const TextStyle(color: navy, fontSize: 21, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      if (compact) ...[organizationField, const SizedBox(height: 10), Align(alignment: Alignment.centerLeft, child: saveButton)]
                      else Row(children: [Expanded(child: organizationField), const SizedBox(width: 12), saveButton]),
                    ]);
                  }),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(builder: (context, box) {
                  final columns = box.maxWidth > 750 ? 4 : (box.maxWidth > 450 ? 2 : 1);
                  final width = (box.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(spacing: 12, runSpacing: 12, children: [
                    SizedBox(width: width, child: _statCard('TEAM MEMBERS', '${employees.length}', Icons.groups_2_outlined, lilac)),
                    SizedBox(width: width, child: _statCard('COURSES ASSIGNED', '$assignedCount', Icons.menu_book_outlined, sage)),
                    SizedBox(width: width, child: _statCard('AVERAGE PROGRESS', '${(averageProgress * 100).round()}%', Icons.trending_up, gold)),
                    SizedBox(width: width, child: _statCard('LEARNING PATHS', '${courses.length}', Icons.route_outlined, const Color(0xFFE7E1D7))),
                  ]);
                }),
                const SizedBox(height: 24),
                LayoutBuilder(builder: (context, box) {
                  final narrow = box.maxWidth < 780;
                  final team = _teamPanel();
                  final assignment = _assignmentPanel();
                  if (narrow) return Column(children: [team, const SizedBox(height: 16), assignment]);
                  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: team), const SizedBox(width: 16), Expanded(flex: 2, child: assignment)]);
                }),
                const SizedBox(height: 20),
                _portalPanel(
                  color: navy,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.insights_outlined, color: gold, size: 28),
                    const SizedBox(width: 14),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('A note on your dashboard', style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text('This is a working prototype with sample team data. Employee records and course assignments are held in memory and are not saved to a live database.', style: TextStyle(color: Color(0xFFE5E1ED), height: 1.5, fontSize: 13)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _teamPanel() {
    return _portalPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Text('02  ·  YOUR PEOPLE', style: TextStyle(color: purple, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.bold))),
        FilledButton.icon(onPressed: _showAddEmployeeDialog, style: FilledButton.styleFrom(backgroundColor: navy), icon: const Icon(Icons.person_add_alt_1, size: 17), label: const Text('Add employee')),
      ]),
      const SizedBox(height: 8),
      const Text('Select team members to assign a learning pathway.', style: TextStyle(color: muted, fontSize: 13, height: 1.5)),
      const SizedBox(height: 14),
      if (employeesLoading)
        const Padding(
          padding: EdgeInsets.all(18),
          child: Center(child: CircularProgressIndicator()),
        ),
      if (!employeesLoading && employees.isEmpty)
        const Padding(
          padding: EdgeInsets.all(18),
          child: Text('No employees yet. Add your first team member to get started.'),
        ),
      ...employees.asMap().entries.map((entry) {
        final index = entry.key;
        final employee = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: oat, borderRadius: BorderRadius.circular(15)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Checkbox(value: selectedEmployees.contains(index), activeColor: purple, onChanged: (checked) => setState(() { if (checked == true) { selectedEmployees.add(index); } else { selectedEmployees.remove(index); } })),
            CircleAvatar(backgroundColor: lilac, foregroundColor: navy, child: Text(employee.name.split(' ').map((part) => part.isNotEmpty ? part[0] : '').take(2).join())),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(employee.name, style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 3),
              Text(employee.role, style: const TextStyle(color: muted, fontSize: 11)),
              const SizedBox(height: 8),
              Text(employee.course, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: employee.progress, minHeight: 6, backgroundColor: const Color(0xFFE2DED6), color: purple)),
              const SizedBox(height: 4),
              Text('${(employee.progress * 100).round()}% complete', style: const TextStyle(color: muted, fontSize: 10)),
            ])),
          ]),
        );
      }),
    ]));
  }

  Widget _assignmentPanel() {
    return _portalPanel(color: lilac, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('03  ·  ASSIGN LEARNING', style: TextStyle(color: purple, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      const Text('Make growth practical.', style: TextStyle(color: navy, fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Choose a pathway and assign it to the selected people.', style: TextStyle(color: muted, fontSize: 13, height: 1.5)),
      const SizedBox(height: 18),
      DropdownButtonFormField<String>(
        value: selectedCourse,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Learning pathway', border: OutlineInputBorder(), filled: true, fillColor: white),
        items: courses.map((course) => DropdownMenuItem(value: course, child: Text(course, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (value) { if (value != null) setState(() => selectedCourse = value); },
      ),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: selectedEmployees.isEmpty || employeesSaving ? null : _assignCourse,
        style: FilledButton.styleFrom(backgroundColor: navy, padding: const EdgeInsets.symmetric(vertical: 16)),
        icon: const Icon(Icons.send_outlined),
        label: Text(employeesSaving
            ? 'Saving assignments...'
            : 'Assign to ${selectedEmployees.length} selected'),
      )),
      const SizedBox(height: 18),
      const Divider(),
      const SizedBox(height: 8),
      const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.visibility_outlined, color: purple), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Progress at a glance', style: TextStyle(color: navy, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Open a progress report to review the current recorded course progress for your team.', style: TextStyle(color: muted, fontSize: 12, height: 1.5))]))]),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: employeesLoading ? null : _showProgressReports,
          icon: const Icon(Icons.assessment_outlined),
          label: const Text('View Progress Reports'),
          style: OutlinedButton.styleFrom(
            foregroundColor: navy,
            side: const BorderSide(color: purple),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    ]));
  }

  Future<void> _showProgressReports() async {
    final assigned = employees.where((employee) => employee.course != 'Not assigned').length;
    final completed = employees.where((employee) => employee.progress >= 1.0).length;
    final average = employees.isEmpty
        ? 0.0
        : employees.fold<double>(0, (total, employee) => total + employee.progress) / employees.length;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Employee Progress Reports'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(organizationName, style: const TextStyle(color: navy, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'Organisation learning overview based on the progress values currently saved in the Employer Portal.',
                  style: TextStyle(color: muted, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _reportSummaryChip('Employees', '${employees.length}'),
                    _reportSummaryChip('Assigned courses', '$assigned'),
                    _reportSummaryChip('Completed', '$completed'),
                    _reportSummaryChip('Average progress', '${(average * 100).round()}%'),
                  ],
                ),
                const SizedBox(height: 18),
                if (employees.isEmpty)
                  const Text('No employee records are available yet.')
                else
                  ...employees.map((employee) {
                    final percent = (employee.progress.clamp(0.0, 1.0) * 100).round();
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: oat,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(employee.name, style: const TextStyle(color: navy, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text(employee.email, style: const TextStyle(color: muted, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Text('$percent%', style: const TextStyle(color: navy, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Course: ${employee.course}', style: const TextStyle(color: ink, fontSize: 12)),
                          const SizedBox(height: 7),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: employee.progress.clamp(0.0, 1.0),
                              minHeight: 7,
                              backgroundColor: const Color(0xFFE2DED6),
                              color: purple,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            employee.course == 'Not assigned'
                                ? 'No course assigned'
                                : (employee.progress >= 1.0 ? 'Completed' : 'In progress'),
                            style: const TextStyle(color: muted, fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _reportSummaryChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: lilac,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: muted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _portalPanel({required Widget child, Color color = white}) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0x14000000))), child: child);
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: navy, size: 22), const SizedBox(height: 15), Text(value, style: const TextStyle(color: navy, fontSize: 27, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: navy, fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.bold))]));
  }

  Future<void> _saveOrganization() async {
    final value = organizationController.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an organisation name.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again.')),
      );
      return;
    }

    try {
      final organizationRef = FirebaseFirestore.instance
          .collection('organizations')
          .doc(user.uid);
      final existingDocument = await organizationRef.get();

      await organizationRef.set({
        'name': value,
        'ownerUid': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!existingDocument.exists)
          'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() => organizationName = value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Organisation workspace saved successfully.'),
        ),
      );
    } catch (e) {
      debugPrint('Error saving organization: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save organisation. Please try again.'),
        ),
      );
    }
  }

  Future<void> _assignCourse() async {
    if (selectedEmployees.isEmpty || employeesSaving) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final indexes = selectedEmployees
        .where((index) => index >= 0 && index < employees.length)
        .toList();
    if (indexes.isEmpty) return;

    setState(() => employeesSaving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final index in indexes) {
        final employee = employees[index];
        batch.update(_employeeCollection(user.uid).doc(employee.id), {
          'course': selectedCourse,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      if (!mounted) return;
      setState(() {
        for (final index in indexes) {
          employees[index].course = selectedCourse;
        }
        employeesSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$selectedCourse assigned to ${indexes.length} team member(s).')),
      );
    } catch (e) {
      debugPrint('Error assigning course: $e');
      if (!mounted) return;
      setState(() => employeesSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save course assignments. Check Firestore permissions.')),
      );
    }
  }

  Future<void> _showAddEmployeeDialog() async {
    employeeNameController.clear();
    employeeEmailController.clear();
    employeeRoleController.clear();
    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a team member'),
        content: SizedBox(width: 420, child: Form(key: employeeFormKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: employeeNameController, decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder()), validator: (value) => value == null || value.trim().isEmpty ? 'Enter a name' : null),
          const SizedBox(height: 12),
          TextFormField(controller: employeeEmailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Work email', border: OutlineInputBorder()), validator: (value) => value == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim()) ? 'Enter a valid email' : null),
          const SizedBox(height: 12),
          TextFormField(controller: employeeRoleController, decoration: const InputDecoration(labelText: 'Role / department', border: OutlineInputBorder()), validator: (value) => value == null || value.trim().isEmpty ? 'Enter a role' : null),
        ]))),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), FilledButton(onPressed: () { if (employeeFormKey.currentState!.validate()) Navigator.pop(dialogContext, true); }, child: const Text('Add employee'))],
      ),
    );
    if (added == true && mounted) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      try {
        final newEmployee = {
          'name': employeeNameController.text.trim(),
          'email': employeeEmailController.text.trim(),
          'role': employeeRoleController.text.trim(),
          'course': 'Not assigned',
          'progress': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        };
        final document = await _employeeCollection(user.uid).add(newEmployee);
        if (!mounted) return;

        setState(() {
          employees.add(EmployerRecord(
            id: document.id,
            name: newEmployee['name'] as String,
            email: newEmployee['email'] as String,
            role: newEmployee['role'] as String,
          ));
          selectedEmployees
            ..clear()
            ..add(employees.length - 1);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team member saved successfully.')),
        );
      } catch (e) {
        debugPrint('Error adding employee: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to add employee. Check Firestore permissions.')),
        );
      }
    }
  }
}

// ============================================================
// 12. SECONDARY SCREENS AND VALIDATED FORM
// ============================================================

class ContentScreen extends StatefulWidget {
  final String title;

  const ContentScreen({
    super.key,
    required this.title,
  });

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (widget.title == 'Register') {
      return RegisterScreen(
        onRegistered: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ContentScreen(title: 'Login'),
            ),
          );
        },
      );
      if (widget.title == 'Admin Portal') {
        return const AdminPortalScreen();
      }
    }if (widget.title == 'Login') {
      return DemoLoginScreen(
        onLogin: (role) {
          String destination;

          switch (role) {
            case 'Individual':
            case 'Learner':
              destination = 'Learning Hub';
              break;

            case 'Employer':
              destination = 'Employers';
              break;

            case 'Admin':
            case 'Super Admin':
              destination = 'Admin Portal';
              break;

            default:
              destination = 'Home';
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ContentScreen(title: destination),
            ),
          );
        },
      );
    }
    if (widget.title == 'Sitemap') {
      return SitemapScreen(
        onNavigate: (page) {
          if (page == 'Home') {
            Navigator.popUntil(
              context,
                  (route) => route.isFirst,
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ContentScreen(title: page),
            ),
          );
        },
      );
    }

    // Public Upskilling is a sample overview page. The personal Learning Hub
    // is opened only after a learner signs in.
    if (widget.title == 'Learning Hub') {
      return const LearningHubScreen();
    }
    if (widget.title == 'Store') {
      return const StoreScreen();
    }
    if (widget.title == 'My Digital Products') {
      return const MyDigitalProductsScreen();
    }
    if (widget.title == 'My Physical Orders') {
      return const MyPhysicalOrdersScreen();
    }
    if (widget.title == 'Cart') {
      return const CartScreen();
    }
    if (widget.title == 'Employers') {
      return const EmployerPortalScreen();
    }
    if (widget.title == 'Admin Portal') {
      return const AdminPortalScreen();
    }
    if (widget.title == 'About') {
      return const AboutScreen();
    }
    if (widget.title == 'Services') {
      return const ServicesScreen();
    }
    if (widget.title == 'Insights') {
      return const InsightsScreen();
    }

    final isFormPage = [
      'Contact',
      'Register',
      'Login',
    ].contains(widget.title);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: oat,
        foregroundColor: navy,
        title: const Text('MT / ALCHEMY'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 760),
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title.toUpperCase(),
                  style: const TextStyle(
                    color: purple,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  heading,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  description,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 25),
                if (isFormPage) ...[
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                !RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                ).hasMatch(value.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: navy,
                              padding: const EdgeInsets.all(18),
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Form validated successfully.',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Continue'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ContentDetails(title: widget.title),
                  const SizedBox(height: 25),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: navy,
                      padding: const EdgeInsets.all(18),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ContentScreen(title: 'Register'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Get started'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get heading {
    switch (widget.title) {
      case 'Services':
        return 'Development that makes a difference.';
      case 'Upskilling':
        return 'Your next chapter starts here.';
      case 'Store':
        return 'Resources for everyday growth.';
      case 'Employers':
        return 'Build stronger teams.';
      case 'Insights':
        return 'Ideas that move people forward.';
      case 'About':
        return 'People are at the heart of change.';
      case 'Login':
        return 'Welcome back.';
      case 'Register':
        return 'Begin your transformation.';
      default:
        return 'Let’s start a conversation.';
    }
  }

  String get description {
    switch (widget.title) {
      case 'Services':
        return 'Build self-awareness, leadership, communication '
            'and healthier team cultures through practical development.';
      case 'Upskilling':
        return 'Explore learning pathways in emotional intelligence, '
            'mindfulness, leadership and effective communication.';
      case 'Store':
        return 'Discover practical workbooks, reflection journals '
            'and resources that bring learning into everyday life.';
      case 'Employers':
        return 'Organise employees, assign courses and review learning '
            'progress through a connected employer experience.';
      case 'Insights':
        return 'Discover perspectives on human development, '
            'workplace wellbeing and sustainable leadership.';
      case 'About':
        return 'MT Alchemy brings people-centred learning and '
            'development to individuals, teams and organisations.';
      case 'Login':
        return 'Continue your learning journey.';
      case 'Register':
        return 'Create your account and discover your learning pathway.';
      default:
        return 'Tell us how we can support your learning or '
            'organisational development goals.';
    }
  }
}

class ContentDetails extends StatelessWidget {
  final String title;

  const ContentDetails({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final entries = switch (title) {
      'Services' => [
        ('Emotional intelligence', 'Awareness, reflection and resilience.'),
        ('Leadership development', 'Authentic leadership and decision-making.'),
        ('Communication', 'Trust, clarity and collaboration.'),
        ('Team engagement', 'Connected and resilient workplace cultures.'),
      ],
      'Upskilling' => [
        ('Discover', 'Understand your strengths and learning goals.'),
        ('Practice', 'Build practical skills through structured lessons.'),
        ('Transform', 'Apply your learning to everyday situations.'),
        ('Impact', 'Reflect on progress and celebrate completion.'),
      ],
      'Store' => [
        ('Reflection journal', 'Prompts for everyday self-awareness.'),
        ('Leadership workbook', 'Exercises for developing leadership skills.'),
        ('Communication toolkit', 'Practical tools for stronger conversations.'),
      ],
      'Employers' => [
        ('Employee management', 'View sample team members.'),
        ('Course assignment', 'Assign learning pathways to employees.'),
        ('Progress overview', 'Review sample completion indicators.'),
      ],
      _ => [
        ('Discover', 'Explore your learning goals.'),
        ('Practice', 'Build new habits and capabilities.'),
        ('Reflect', 'Identify progress and next steps.'),
      ],
    };

    return Column(
      children: entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: oat,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                color: purple,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.$1,
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.$2,
                      style: const TextStyle(
                        color: muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================
// 13. DEDICATED ABOUT, SERVICES AND INSIGHTS PAGES
// ============================================================

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _open(BuildContext context, String page) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ContentScreen(title: page),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: oat,
      appBar: AppBar(
        backgroundColor: oat,
        foregroundColor: navy,
        title: const Text('MT / ALCHEMY'),
        actions: [
          TextButton(onPressed: () => _open(context, 'Services'), child: const Text('Our services')),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 64, vertical: 34),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const _Eyebrow('OUR STORY'),
              const SizedBox(height: 14),
              Text('People are at the heart of change.', style: TextStyle(color: navy, fontSize: mobile ? 34 : 48, height: 1.12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              const Text('MT Alchemy helps individuals, teams and organisations build the self-awareness, emotional intelligence and leadership habits that create lasting change.', style: TextStyle(color: muted, fontSize: 17, height: 1.75)),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(mobile ? 22 : 36),
                decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(28)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('OUR BELIEF', style: TextStyle(color: gold, letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('We don’t just run activities. We shift mindsets, behaviours, and team culture.', style: TextStyle(color: white, fontSize: mobile ? 25 : 34, height: 1.25, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  const Text('Growth becomes meaningful when insight turns into everyday practice.', style: TextStyle(color: Color(0xFFE5E5EB), height: 1.7, fontSize: 15)),
                ]),
              ),
              const SizedBox(height: 36),
              const Text('The Alchemy Cycle', style: TextStyle(color: navy, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('A simple path from understanding to sustained impact.', style: TextStyle(color: muted, height: 1.6)),
              const SizedBox(height: 20),
              LayoutBuilder(builder: (context, constraints) {
                final cols = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 440 ? 2 : 1);
                final stages = [
                  ('01', 'Discover', 'Build awareness of strengths, emotions and patterns.', lilac),
                  ('02', 'Practise', 'Try tools and skills in real situations.', sage),
                  ('03', 'Transform', 'Turn new insights into everyday habits.', gold),
                  ('04', 'Impact', 'Strengthen relationships and team culture.', const Color(0xFFE7E4DC)),
                ];
                return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: cols, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: cols == 1 ? 1.7 : (mobile ? 1.15 : 1.1), children: stages.map((stage) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: stage.$4, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(stage.$1, style: const TextStyle(color: navy, fontWeight: FontWeight.bold)), const Spacer(), Text(stage.$2, style: const TextStyle(color: navy, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 7), Text(stage.$3, style: const TextStyle(color: ink, height: 1.45, fontSize: 13))]))).toList());
              }),
              const SizedBox(height: 32),
              _CallToAction(title: 'Ready to grow with intention?', buttonText: 'Explore our services', onPressed: () => _open(context, 'Services')),
            ]),
          ),
        ),
      ),
    );
  }
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  void _contact(BuildContext context, String service) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceEnquiryScreen(service: service)));
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    final services = [
      ('Emotional intelligence', 'Build self-awareness, emotional regulation and empathy.', Icons.psychology_outlined, lilac),
      ('Leadership development', 'Develop authentic leadership, confidence and better decisions.', Icons.emoji_people_outlined, gold),
      ('Team engagement', 'Create stronger trust, communication and collaboration.', Icons.groups_2_outlined, sage),
      ('Workplace well-being', 'Support reflection, resilience and healthier working habits.', Icons.spa_outlined, const Color(0xFFE7E4DC)),
    ];
    return Scaffold(
      backgroundColor: oat,
      appBar: AppBar(backgroundColor: oat, foregroundColor: navy, title: const Text('MT / ALCHEMY')),
      body: SingleChildScrollView(padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 64, vertical: 34), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Eyebrow('HOW WE WORK'),
        const SizedBox(height: 14),
        Text('Development that makes a difference.', style: TextStyle(color: navy, fontSize: mobile ? 34 : 48, height: 1.12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        const Text('Practical, people-centred programmes help turn understanding into behaviours that make work and relationships better.', style: TextStyle(color: muted, fontSize: 17, height: 1.7)),
        const SizedBox(height: 30),
        LayoutBuilder(builder: (context, constraints) {
          final cols = constraints.maxWidth > 800 ? 2 : 1;
          return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: cols, crossAxisSpacing: 18, mainAxisSpacing: 18, childAspectRatio: cols == 2 ? 1.55 : 1.25, children: services.map((service) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: service.$4, borderRadius: BorderRadius.circular(15)), child: Icon(service.$3, color: navy)), const Spacer(), Text(service.$1, style: const TextStyle(color: navy, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(service.$2, style: const TextStyle(color: muted, height: 1.5)), const SizedBox(height: 12), Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () => _contact(context, service.$1), icon: const Icon(Icons.arrow_forward, size: 16), label: const Text('Enquire about this service')))]))).toList());
        }),
        const SizedBox(height: 30),
        Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: lilac, borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('A tailored approach', style: TextStyle(color: navy, fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(height: 8), Text('Programmes can be shaped around your team’s goals, context and desired outcomes. Send an enquiry and tell us what you want to change.', style: TextStyle(color: ink, height: 1.6))])),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () => _contact(context, 'Customized corporate programme'),
            icon: const Icon(Icons.business_outlined),
            label: const Text('Submit corporate enquiry'),
            style: FilledButton.styleFrom(
              backgroundColor: navy,
              foregroundColor: white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ])))),
    );
  }
}

class ServiceEnquiryScreen extends StatefulWidget {
  final String service;
  const ServiceEnquiryScreen({super.key, required this.service});

  @override
  State<ServiceEnquiryScreen> createState() => _ServiceEnquiryScreenState();
}

class _ServiceEnquiryScreenState extends State<ServiceEnquiryScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _organisation = TextEditingController();
  final _phone = TextEditingController();
  final _employeeCount = TextEditingController();
  final _requirements = TextEditingController();
  final _comments = TextEditingController();

  static const _programmes = [
    'Emotional Intelligence',
    'Leadership Development',
    'Communication',
    'Team Engagement',
    'Workplace Well-being',
    'Customized Programme',
  ];

  String _selectedProgramme = 'Customized Programme';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _organisation.dispose();
    _phone.dispose();
    _employeeCount.dispose();
    _requirements.dispose();
    _comments.dispose();
    super.dispose();
  }

  Future<void> _submitEnquiry() async {
    if (!_key.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('corporateEnquiries').add({
        'organizationName': _organisation.text.trim(),
        'contactName': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'employeeCount': int.parse(_employeeCount.text.trim()),
        'preferredProgramme': _selectedProgramme,
        'trainingRequirements': _requirements.text.trim(),
        'additionalComments': _comments.text.trim(),
        'status': 'Pending',
        'proposedProgramme': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Enquiry submitted'),
          content: const Text(
            'Thank you. Your corporate enquiry has been submitted successfully. '
                'Our team can review the details and prepare a suitable programme.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Corporate enquiry submission failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to submit your enquiry. Please check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: oat,
      appBar: AppBar(
        backgroundColor: oat,
        foregroundColor: navy,
        title: const Text('Corporate enquiry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Eyebrow('LET’S BUILD A PROGRAMME'),
                  const SizedBox(height: 12),
                  Text(
                    widget.service,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tell us about your organisation and training goals. '
                        'We will use these details to understand your needs and shape a suitable programme.',
                    style: TextStyle(color: muted, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _organisation,
                    decoration: _fieldDecoration('Organisation name'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter your organisation name'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _name,
                    decoration: _fieldDecoration('Contact person name'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter the contact person’s name'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _fieldDecoration('Business email'),
                    validator: (v) => v == null ||
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(v.trim())
                        ? 'Enter a valid email address'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: _fieldDecoration('Phone number'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter a contact phone number'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _employeeCount,
                    keyboardType: TextInputType.number,
                    decoration: _fieldDecoration(
                      'Number of employees',
                      hint: 'e.g. 25',
                    ),
                    validator: (v) {
                      final count = int.tryParse((v ?? '').trim());
                      if (count == null || count < 1) {
                        return 'Enter a valid number of employees';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _selectedProgramme,
                    decoration: _fieldDecoration('Preferred training programme'),
                    items: _programmes
                        .map((programme) => DropdownMenuItem(
                      value: programme,
                      child: Text(programme),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedProgramme = value);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _requirements,
                    maxLines: 4,
                    decoration: _fieldDecoration(
                      'Training requirements',
                      hint: 'Describe the skills, challenges or outcomes you want to focus on.',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Describe your training requirements'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _comments,
                    maxLines: 3,
                    decoration: _fieldDecoration(
                      'Additional comments (optional)',
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSubmitting ? null : _submitEnquiry,
                      icon: _isSubmitting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.send_outlined),
                      label: Text(
                        _isSubmitting ? 'Submitting...' : 'Submit corporate enquiry',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: white,
                        padding: const EdgeInsets.all(18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  static const articles = <(String, String, String, String, Color)>[
    (
    'EMOTIONAL INTELLIGENCE',
    'Self-awareness: the starting point for change',
    'A short reflection on noticing emotions, patterns and the choices available to us.',
    'Try a simple pause: name what you are feeling, notice what triggered it, and decide what response would serve you best. Self-awareness is not about judging yourself; it is about creating enough space to choose your next step.',
    lilac,
    ),
    (
    'LEADERSHIP',
    'Small habits that build trust in teams',
    'How consistent everyday behaviours can shape stronger working relationships.',
    'Trust is built through repeated signals: listening without rushing, following through on commitments, making expectations clear and acknowledging when something has gone wrong. Small behaviours, practised consistently, shape team culture.',
    sage,
    ),
    (
    'WORKPLACE WELL-BEING',
    'Reflection as a practical work skill',
    'Make reflection a useful part of the working week rather than another task.',
    'A short reflection at the end of a meeting or week can help turn experience into learning. Ask: What went well? What felt difficult? What did I learn? What will I try next time? Keep the next step small enough to practise.',
    gold,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: oat,
      appBar: AppBar(backgroundColor: oat, foregroundColor: navy, title: const Text('MT / ALCHEMY')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 64, vertical: 34),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Eyebrow('THE JOURNAL'),
                const SizedBox(height: 14),
                Text('Ideas that move people forward.', style: TextStyle(color: navy, fontSize: mobile ? 34 : 48, height: 1.12, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                const Text('Thoughts and practical prompts for emotional intelligence, leadership and healthier working relationships.', style: TextStyle(color: muted, fontSize: 17, height: 1.7)),
                const SizedBox(height: 30),
                ...articles.map((article) => Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: EdgeInsets.all(mobile ? 20 : 28),
                  decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(color: article.$5, borderRadius: BorderRadius.circular(30)),
                        child: Text(article.$1, style: const TextStyle(color: navy, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 15),
                      Text(article.$2, style: const TextStyle(color: navy, fontSize: 24, height: 1.25, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 9),
                      Text(article.$3, style: const TextStyle(color: muted, fontSize: 15, height: 1.6)),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => InsightArticleScreen(
                              category: article.$1,
                              title: article.$2,
                              summary: article.$3,
                              body: article.$4,
                              accent: article.$5,
                            ),
                          )),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Read article'),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InsightArticleScreen extends StatelessWidget {
  final String category;
  final String title;
  final String summary;
  final String body;
  final Color accent;

  const InsightArticleScreen({super.key, required this.category, required this.title, required this.summary, required this.body, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: oat,
      appBar: AppBar(backgroundColor: oat, foregroundColor: navy, title: const Text('MT / ALCHEMY')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 820),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(24)),
                  child: Text(category, style: const TextStyle(color: navy, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 18),
                Text(title, style: const TextStyle(color: navy, fontSize: 34, height: 1.2, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Text(summary, style: const TextStyle(color: muted, fontSize: 17, height: 1.65)),
                const Divider(height: 36),
                Text(body, style: const TextStyle(color: ink, fontSize: 16, height: 1.9)),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: oat, borderRadius: BorderRadius.circular(18)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('A moment to reflect', style: TextStyle(color: navy, fontSize: 19, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('What is one small action you could practise this week?', style: TextStyle(color: muted, height: 1.6)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: purple, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold));
}

class _CallToAction extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onPressed;
  const _CallToAction({required this.title, required this.buttonText, required this.onPressed});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(22)),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Text(title, style: const TextStyle(color: navy, fontSize: 22, fontWeight: FontWeight.bold)),
        FilledButton(onPressed: onPressed, style: FilledButton.styleFrom(backgroundColor: navy, foregroundColor: white), child: Text(buttonText)),
      ],
    ),
  );
}

