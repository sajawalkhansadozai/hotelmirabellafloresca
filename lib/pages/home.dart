// lib/pages/home.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../appbar.dart';
import '../footer.dart'; // <-- add this

/* ---------------------------- Brand Color Palette ---------------------------- */
const Color kCharcoal = Color(0xFF0F0F0F);
const Color kCharcoalSoft = Color(0xFF1C1C1C);
const Color kTextDark = Color(0xFF333333);
const Color kGold = Color(0xFFD4AF37);
const Color kChampagne = Color(0xFFF4E4BC);
const Color kLightGold = Color(0xFFE6D8A3);
const Color kWarmGold = Color(0xFFC9A96E);

/* --------------------------------- PAGE --------------------------------- */

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MirabellaAppBar(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(), // 3-image auto slider + CTAs
            _StatsSection(), // Numbers
            _TeaserSection(), // Key feature teasers
            _ServicesSection(), // 4 services with top images
            // Footer (responsive & overflow-proof)
            MirabellaFooter(), // <-- added
          ],
        ),
      ),
    );
  }
}

/* --------------------------------- HERO --------------------------------- */

class _HeroSection extends StatefulWidget {
  const _HeroSection();
  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  final _controller = PageController();
  int _index = 0;
  Timer? _timer;

  final _images = const [
    'assets/hero1.jpg',
    'assets/hero2.png',
    'assets/hero3.png',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      _index = (_index + 1) % _images.length;
      _controller.animateToPage(
        _index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double h = size.height.clamp(480.0, 760.0).toDouble();

    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _HeroSlide(imagePath: _images[i]),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kCharcoal.withOpacity(0.55), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hotel Mirabella Floresca',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Where life meets luxury — E-18 Islamabad • 20 minutes from the Airport',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 16.5,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGold,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 14,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/rooms'),
                          child: const Text(
                            'Explore Rooms',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kGold),
                            foregroundColor: kGold,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 14,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/contact'),
                          child: const Text('Book Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_images.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 7,
                  width: active ? 20 : 7,
                  decoration: BoxDecoration(
                    color: active ? kGold : Colors.white70,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final String imagePath;
  const _HeroSlide({required this.imagePath});
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kGold, kChampagne, kLightGold, kWarmGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'Mirabella Floresca',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.25), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ],
    );
  }
}

/* --------------------------------- STATS -------------------------------- */

class _StatsSection extends StatelessWidget {
  const _StatsSection();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kGold,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Wrap(
            spacing: 20,
            runSpacing: 18,
            alignment: WrapAlignment.spaceBetween,
            children: const [
              _StatTile(
                value: 59,
                suffix: ' suites',
                label: 'Residential (3 floors)',
              ),
              _StatTile(value: 4, suffix: ' floors', label: 'Hotel Storeys'),
              _StatTile(
                value: 10,
                suffix: 'k sq-ft',
                label: 'Project Footprint',
              ),
              _StatTile(
                value: 20,
                suffix: ' min',
                label: 'From Islamabad Airport',
              ),
              _StatTile(
                value: 45,
                suffix: ' ft',
                label: 'Main Pool + Jacuzzi/Steam/Sauna',
              ),
              _StatTile(
                value: 24,
                suffix: '/7 Wi-Fi',
                label: 'Broadband + Backup',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final double value;
  final String label;
  final String prefix;
  final String suffix;
  final int decimals;
  const _StatTile({
    required this.value,
    required this.label,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AnimatedCounter(
            value: value,
            prefix: prefix,
            suffix: suffix,
            decimals: decimals,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14.5),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCounter extends StatelessWidget {
  final double value;
  final String prefix;
  final String suffix;
  final int decimals;
  const _AnimatedCounter({
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        final formatted = decimals == 0
            ? val.toInt().toString()
            : val.toStringAsFixed(decimals);
        return Text(
          '$prefix$formatted$suffix',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        );
      },
    );
  }
}

/* ------------------------------ TEASERS --------------------------------- */

class _TeaserSection extends StatelessWidget {
  const _TeaserSection();

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: kTextDark,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const Text('Discover Mirabella Luxury', style: titleStyle),
              const SizedBox(height: 8),
              Text(
                'International-level services in E-18 Islamabad — serenity, connectivity and convenience under one roof.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextDark.withOpacity(0.75),
                  fontSize: 15.5,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  _TeaserCard(
                    title: 'Multi-Level Dining',
                    body:
                        'Ground-floor food court + expansive dining across upper levels — expert chefs, views and variety.',
                    cta: 'Explore Dining',
                    onTap: () => Navigator.pushNamed(context, '/dining'),
                  ),
                  _TeaserCard(
                    title: 'Business Centre',
                    body:
                        'Conference hall, meeting room, furnished offices, printers & internet café — ready daily/weekly.',
                    cta: 'View Services',
                    onTap: () => Navigator.pushNamed(context, '/services'),
                  ),
                  _TeaserCard(
                    title: 'Pool & Wellness',
                    body:
                        '45-ft pool, kids pool, Jacuzzi, steam & sauna — perfect for members and guests.',
                    cta: 'See Amenities',
                    onTap: () => Navigator.pushNamed(context, '/services'),
                  ),
                  _TeaserCard(
                    title: 'Secure & Smart',
                    body:
                        'Solar-backed power, IoT monitoring, CCTV and fire-fighting systems for peace of mind.',
                    cta: 'Learn More',
                    onTap: () => Navigator.pushNamed(context, '/about'),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kGold),
                  foregroundColor: kGold,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => Navigator.pushNamed(context, '/about'),
                child: const Text('Learn More About Us'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeaserCard extends StatelessWidget {
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;
  const _TeaserCard({
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 360),
      child: Material(
        color: Colors.white,
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18.5,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: TextStyle(
                    color: kTextDark.withOpacity(0.75),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Learn more',
                      style: TextStyle(
                        color: kGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: kGold),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ----------------------------- SERVICES (4) ------------------------------ */

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  // 4 services with images (landscape headers)
  static const List<_Service> _services = [
    _Service(
      title: 'Indoor Pool & Spa',
      icon: Icons.pool_rounded,
      assetPath: 'assets/services/pool.jpeg',
      blurb:
          'Indoor heated pool at ground level with sauna, steam & signature spa treatments.',
      bullets: [
        'Indoor heated pool',
        'Sauna & steam rooms',
        'Private couple suites',
        'Signature therapies',
      ],
    ),
    _Service(
      title: 'Fitness & Wellness',
      icon: Icons.fitness_center_rounded,
      assetPath: 'assets/services/gym.jpg',
      blurb:
          '24/7 fitness studio, yoga sessions, and personal training on request.',
      bullets: [
        'State-of-the-art equipment',
        'Yoga & wellness programs',
        'Personal trainers',
        'Hydration bar',
      ],
    ),
    _Service(
      title: 'Event & Meeting Spaces',
      icon: Icons.event_seat_rounded,
      assetPath: 'assets/services/ballroom.png',
      blurb:
          'Weddings, galas, and board meetings with full AV & banquet support.',
      bullets: [
        'Grand Ballroom (300 pax)',
        'Executive Boardroom',
        'On-site AV & staging',
        'Custom catering menus',
      ],
    ),
    _Service(
      title: 'Shopping & Retail',
      icon: Icons.shopping_bag_rounded,
      assetPath: 'assets/services/retail.jpg',
      blurb:
          'Luxury boutiques, gifts, and personal shopping without leaving the hotel.',
      bullets: [
        'Curated luxury brands',
        'Gift wrapping',
        'Personal shopper',
        'In-room delivery',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Amenities & Services',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kGold.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_services.length} services',
                      style: const TextStyle(
                        color: kTextDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, c) {
                  final cols = (c.maxWidth / 360).floor().clamp(1, 4);
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      // Taller to accommodate larger 16:9 image header
                      childAspectRatio: 3 / 4.0,
                    ),
                    itemCount: _services.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, i) => _ServiceCard(
                      s: _services[i],
                      onDetails: () => _showDetails(context, _services[i]),
                      onAction: () => Navigator.pushNamed(context, '/contact'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kGold),
                        foregroundColor: kGold,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/events'),
                      child: const Text('Plan an Event'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGold,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/contact'),
                      child: const Text('Contact Concierge'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showDetails(BuildContext context, _Service s) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 900),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(s.icon, size: 28, color: kGold),
              const SizedBox(height: 6),
              Text(
                s.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.blurb,
                textAlign: TextAlign.center,
                style: TextStyle(color: kTextDark.withOpacity(0.8)),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: s.bullets.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.check_rounded, color: kGold),
                    title: Text(s.bullets[i]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGold,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/contact');
                  },
                  child: const Text('Request This Service'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ----------------------- SERVICE MODELS & CARD --------------------------- */

class _Service {
  final String title;
  final String blurb;
  final List<String> bullets;
  final IconData icon;
  final String? assetPath; // local image (preferred)
  final String? imageUrl; // optional network image
  const _Service({
    required this.title,
    required this.blurb,
    required this.bullets,
    required this.icon,
    this.assetPath,
    this.imageUrl,
  });
}

class _ServiceCard extends StatelessWidget {
  final _Service s;
  final VoidCallback onAction;
  final VoidCallback onDetails;

  const _ServiceCard({
    required this.s,
    required this.onAction,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Landscape image header (16:9)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _ServiceHeaderImage(service: s),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: kTextDark,
                        fontSize: 17.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.blurb,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: kTextDark.withOpacity(0.82),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...s.bullets
                        .take(3)
                        .map(
                          (b) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: kGold,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    b,
                                    style: const TextStyle(
                                      color: kTextDark,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    const Spacer(),
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kGold),
                            foregroundColor: kGold,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: onDetails,
                          child: const Text('Details'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGold,
                            foregroundColor: Colors.black87,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: onAction,
                          child: const Text('Request'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------------- Image header helper widget ---------------------- */

class _ServiceHeaderImage extends StatelessWidget {
  final _Service service;
  const _ServiceHeaderImage({required this.service});

  @override
  Widget build(BuildContext context) {
    // Try asset first
    if (service.assetPath != null && service.assetPath!.isNotEmpty) {
      return Image.asset(
        service.assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    // Then network
    if (service.imageUrl != null && service.imageUrl!.isNotEmpty) {
      return Image.network(
        service.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    // Fallback gradient + icon
    return _fallback();
  }

  Widget _fallback() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kGold, kChampagne, kLightGold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Center(child: Icon(service.icon, size: 36, color: Colors.black87)),
      ],
    );
  }
}
