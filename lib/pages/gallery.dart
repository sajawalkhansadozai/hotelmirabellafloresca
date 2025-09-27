// lib/pages/gallery.dart
import 'package:flutter/material.dart';
import '../appbar.dart';
import '../footer.dart'; // <-- added

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  static const Color _brandGold = Color(0xFFD4AF37);
  static const Color _textDark = Color(0xFF333333);

  final TextEditingController _search = TextEditingController();

  // TIP: Make sure these assets exist & are added in pubspec.yaml under "assets:"
  final List<_GalleryItem> _allItems = const [
    _GalleryItem(
      title: 'Grand Lobby',
      desc: 'Elegant entrance with marble finishes.',
      tag: 'Lobby',
      assetPath: 'assets/gallery/lobby.png',
    ),
    _GalleryItem(
      title: 'Deluxe Room',
      desc: 'Luxurious accommodations with city views.',
      tag: 'Rooms',
      assetPath: 'assets/gallery/deluxe_room.jpg',
    ),
    _GalleryItem(
      title: 'Fine Dining',
      desc: 'Exquisite culinary experiences.',
      tag: 'Dining',
      assetPath: 'assets/gallery/dining.jpg',
    ),
    _GalleryItem(
      title: 'Spa & Wellness',
      desc: 'Rejuvenating treatments and relaxation.',
      tag: 'Wellness',
      assetPath: 'assets/gallery/spa.jpeg',
    ),
    _GalleryItem(
      title: 'In-door Pool',
      desc: 'In-door pool with panoramic views.',
      tag: 'Leisure',
      assetPath: 'assets/gallery/pool.jpeg',
    ),
    _GalleryItem(
      title: 'Event Spaces',
      desc: 'Professional meeting & event facilities.',
      tag: 'Events',
      assetPath: 'assets/gallery/events.jpeg',
    ),
  ];

  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered();

    return Scaffold(
      appBar: const MirabellaAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _HeroGallery(),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 22.0,
                horizontal: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SearchBar(
                        controller: _search,
                        onChanged: (v) => setState(() => _query = v.trim()),
                        onClear: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Flexible(
                            child: Text(
                              'Hotel Gallery',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _brandGold.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${items.length} item${items.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: _textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, c) {
                          // Responsive columns: aim for ~260px min tile width
                          final int cols = (c.maxWidth / 260).floor().clamp(
                            1,
                            5,
                          );
                          // Slightly taller cards on narrow screens for better legibility
                          final double aspect = cols <= 2 ? (16 / 11) : (4 / 3);

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: aspect,
                                ),
                            itemCount: items.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (_, i) => _GalleryCard(
                              item: items[i],
                              onTap: () => _openLightbox(items[i]),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _brandGold),
                            foregroundColor: _brandGold,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 14,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/contact'),
                          child: const Text(
                            'Plan a Photoshoot / Event Inquiry',
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),

            // ==== Footer at the very end ====
            const MirabellaFooter(),
          ],
        ),
      ),
    );
  }

  List<_GalleryItem> _filtered() {
    if (_query.isEmpty) return _allItems;
    final q = _query.toLowerCase();
    return _allItems
        .where(
          (e) =>
              e.title.toLowerCase().contains(q) ||
              e.desc.toLowerCase().contains(q) ||
              e.tag.toLowerCase().contains(q),
        )
        .toList();
  }

  void _openLightbox(_GalleryItem item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) {
        return LayoutBuilder(
          builder: (context, c) {
            final bool wide = c.maxWidth >= 700;
            final aspect = wide ? (16 / 9) : (4 / 3);
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 40,
              ),
              backgroundColor: Colors.transparent,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: aspect,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _GalleryImage(
                            item: item,
                            fit: BoxFit.cover,
                            // If image missing, show classy placeholder
                            fallback: _FancyImagePlaceholder(
                              title: item.title,
                              subtitle: item.desc,
                              big: true,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/* --------------------------------- Hero --------------------------------- */

class _HeroGallery extends StatelessWidget {
  const _HeroGallery();

  static const String HERO_ASSET = 'assets/gallery/hero.jpeg';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Clamp height for small phones & large desktops to avoid overflow
    final double h = size.height.clamp(380.0, 560.0).toDouble();

    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with graceful fallback if asset missing
          Image.asset(
            HERO_ASSET,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => const _HeroFallbackGradient(),
          ),
          // Dark scrim to keep text readable on bright images
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.30),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Text content (safe & responsive)
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final bool tight = c.maxWidth < 420;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hotel Gallery',
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: tight ? 32 : 40,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'A glimpse of our spaces — from grand arrivals to serene retreats.',
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.92),
                              fontSize: tight ? 14.5 : 16.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFallbackGradient extends StatelessWidget {
  const _HeroFallbackGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0F0F), Color(0xFF1C1C1C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

/* ------------------------------- Search Bar ----------------------------- */

class _SearchBar extends StatelessWidget {
  static const Color _textDark = Color(0xFF333333);

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: _textDark),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: 'Search (e.g., Lobby, Dining, Spa, Events)…',
                  border: InputBorder.none,
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: onClear,
              ),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------ Gallery Card ---------------------------- */

class _GalleryItem {
  final String title;
  final String desc;
  final String tag;
  final String? assetPath; // Prefer local asset if provided
  final String? imageUrl; // Or network URL
  const _GalleryItem({
    required this.title,
    required this.desc,
    required this.tag,
    this.assetPath,
    this.imageUrl,
  });

  bool get hasImage =>
      (assetPath != null && assetPath!.isNotEmpty) ||
      (imageUrl != null && imageUrl!.isNotEmpty);
}

class _GalleryCard extends StatefulWidget {
  final _GalleryItem item;
  final VoidCallback onTap;
  const _GalleryCard({required this.item, required this.onTap});

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _hover ? 1.02 : 1.0,
        child: Material(
          color: Colors.white,
          elevation: _hover ? 10 : 6,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Actual image (asset or network), with graceful fallback
                  _GalleryImage(
                    item: widget.item,
                    fit: BoxFit.cover,
                    fallback: _FancyImagePlaceholder(
                      title: widget.item.title,
                      subtitle: widget.item.tag,
                    ),
                  ),
                  // Overlay gradient + captions
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(_hover ? 0.55 : 0.35),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.desc,
                          maxLines: _hover ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.2,
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

/* ----------------------- Image loader (asset/network) ------------------- */

class _GalleryImage extends StatelessWidget {
  final _GalleryItem item;
  final BoxFit fit;
  final Widget fallback;

  const _GalleryImage({
    required this.item,
    required this.fit,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (item.assetPath != null && item.assetPath!.isNotEmpty) {
      return Image.asset(
        item.assetPath!,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return Image.network(
        item.imageUrl!,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return fallback;
  }
}

/* ------------------------- Fancy Placeholder (No IMG) ------------------- */

class _FancyImagePlaceholder extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool big;
  const _FancyImagePlaceholder({
    required this.title,
    this.subtitle,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w800,
      fontSize: big ? 26 : 18,
      letterSpacing: 0.2,
    );
    final subStyle = TextStyle(
      color: Colors.black87.withOpacity(0.85),
      fontWeight: FontWeight.w600,
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFD4AF37),
            Color(0xFFF4E4BC),
            Color(0xFFE6D8A3),
            Color(0xFFC9A96E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // subtle diagonals
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: CustomPaint(painter: _DiagonalPainter()),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, textAlign: TextAlign.center, style: titleStyle),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(subtitle!, textAlign: TextAlign.center, style: subStyle),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final step = size.height / 8;
    for (double y = 0; y < size.height; y += step) {
      final path = Path()
        ..moveTo(0, y)
        ..lineTo(size.width, y + step / 2)
        ..lineTo(size.width, y + step)
        ..lineTo(0, y + step / 2)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
