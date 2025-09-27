// lib/footer.dart
import 'package:flutter/material.dart';
import 'appbar.dart' show kAppBarBg, kBrandGold;

/// Mirabella Footer - responsive & overflow-proof
class MirabellaFooter extends StatelessWidget {
  const MirabellaFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;

    return Container(
      width: double.infinity,
      color: kAppBarBg,
      child: Column(
        children: [
          // Top thin divider glow
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kBrandGold.withOpacity(0.0),
                  kBrandGold,
                  kBrandGold.withOpacity(0.0),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: LayoutBuilder(
                  builder: (context, c) {
                    // Simple responsive breakpoints
                    final w = c.maxWidth;
                    final int cols = w >= 1024
                        ? 4
                        : (w >= 760 ? 3 : (w >= 520 ? 2 : 1));
                    final double gap = 16;
                    final double itemW = (w - (gap * (cols - 1))) / cols;

                    return Wrap(
                      spacing: gap,
                      runSpacing: 18,
                      children: [
                        SizedBox(width: itemW, child: const _BrandBlock()),
                        SizedBox(width: itemW, child: const _AtAGlanceBlock()),
                        SizedBox(width: itemW, child: const _AmenitiesBlock()),
                        SizedBox(width: itemW, child: const _QuickLinksBlock()),
                        // If you prefer a newsletter instead of Quick Links, swap the line above:
                        // SizedBox(width: itemW, child: const _NewsletterBlock()),
                        SizedBox(width: itemW, child: const _PartnersBlock()),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          const Divider(height: 1, color: Colors.white24),

          // Bottom bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final isNarrow = c.maxWidth < 700;
                    final textStyle = TextStyle(
                      color: Colors.white.withOpacity(0.78),
                    );

                    final left = Text(
                      '© $year Mirabella Floresca. All rights reserved.',
                      style: textStyle,
                    );

                    final right = Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _LegalLink(
                          label: 'Privacy Policy',
                          onTap: () => _safePush(context, '/privacy'),
                        ),
                        _Dot(),
                        _LegalLink(
                          label: 'Terms of Service',
                          onTap: () => _safePush(context, '/terms'),
                        ),
                        _Dot(),
                        _LegalLink(
                          label: 'Sitemap',
                          onTap: () => _safePush(context, '/sitemap'),
                        ),
                      ],
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [left, const SizedBox(height: 10), right],
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(child: left),
                          right,
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ Blocks ---------------------------------- */

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    final sub = TextStyle(color: Colors.white.withOpacity(0.82), height: 1.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo + Name
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/logomf.png',
                height: 40,
                width: 40,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.apartment_rounded,
                  color: kBrandGold,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Mirabella Floresca',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Where life meets luxury — E-18 (Gulshan-e-Sehat), Islamabad • ~20 minutes from the Airport',
          style: sub,
        ),
        const SizedBox(height: 12),
        // Key facts chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _Pill('4 storeys'),
            _Pill('~10,000 sq-ft footprint'),
            _Pill('59 suites (upper 3 levels)'),
          ],
        ),
      ],
    );
  }
}

class _AtAGlanceBlock extends StatelessWidget {
  const _AtAGlanceBlock();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'At a Glance',
      children: const [
        _Line(
          icon: Icons.place_rounded,
          text:
              'Project location: Gulshan-e-Sehat (E-18), Islamabad — easily accessible via Airport Highway / CPEC corridor.',
        ),
        _Line(
          icon: Icons.map_rounded,
          text: 'Proximity: ~20 minutes to Islamabad International Airport.',
        ),
        SizedBox(height: 8),
        _MiniTitle('Facilities in the Building'),
        _Bullet('Multi-level dining footprint (ground + upper floors)'),
        _Bullet('Business Centre: conference hall, meeting room, offices'),
        _Bullet('Indoor pool, kids’ pool, Jacuzzi, steam & sauna'),
        _Bullet('Health & Fitness Centre (men & women)'),
        _Bullet('Grocery store (~1,300 sq-ft / 9 sections)'),
        _Bullet('Beauty salon (men & women)'),
        _Bullet('Kids play area & gaming zone'),
        _Bullet('Public activity lawn with stage'),
        _Bullet('Library (ground floor)'),
      ],
    );
  }
}

class _AmenitiesBlock extends StatelessWidget {
  const _AmenitiesBlock();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Core Amenities',
      children: const [
        _Bullet('Backup electricity (Solar) & IoT-enabled'),
        _Bullet('24/7 Wi-Fi broadband (with backup)'),
        _Bullet('Open parking around the building'),
        _Bullet('24/7 on-site security & CCTV'),
        _Bullet('Fire-fighting system & marked fire exits'),
      ],
    );
  }
}

class _PartnersBlock extends StatelessWidget {
  const _PartnersBlock();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Partners & Registration',
      children: const [
        _Line(
          icon: Icons.group_rounded,
          text: 'Joint venture: Mirabella Ventures × Aks & Mac Inc. (USA).',
        ),
        _Line(
          icon: Icons.handshake_rounded,
          text: 'Partner: ECO ARC CONSULTANCIES (Pvt) LTD, Islamabad.',
        ),
        _Line(
          icon: Icons.badge_rounded,
          text: 'SECP Registration: A067698 • CUI: 0144129.',
        ),
        _Line(
          icon: Icons.stacked_line_chart_rounded,
          text: 'Projected construction capacity ~PKR 255.460 million.',
        ),
      ],
    );
  }
}

class _QuickLinksBlock extends StatelessWidget {
  const _QuickLinksBlock();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Quick Links',
      children: [
        _Link('Home', '/'),
        _Link('About', '/about'),
        _Link('Rooms', '/rooms'),
        _Link('Gallery', '/gallery'),
        // Removed Dining / Services / Events as requested
        _Link('Contact', '/contact'),
      ],
    );
  }
}

/* ------------------------------ Optional Newsletter ---------------------- */

class _NewsletterBlock extends StatefulWidget {
  const _NewsletterBlock();

  @override
  State<_NewsletterBlock> createState() => _NewsletterBlockState();
}

class _NewsletterBlockState extends State<_NewsletterBlock> {
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hintStyle = TextStyle(color: Colors.white.withOpacity(0.6));

    return _Section(
      title: 'Newsletter',
      children: [
        Text(
          'Get offers, project news & updates.',
          style: TextStyle(color: Colors.white.withOpacity(0.82), height: 1.4),
        ),
        const SizedBox(height: 10),
        Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _email,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final ok = RegExp(
                      r'^[^@]+@[^@]+\.[^@]+$',
                    ).hasMatch(v.trim());
                    return ok ? null : 'Invalid email';
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'you@example.com',
                    hintStyle: hintStyle,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kBrandGold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandGold,
                  foregroundColor: Colors.black87,
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subscribed! Thank you.')),
                  );
                  _email.clear();
                },
                child: const Text('Subscribe'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'By subscribing, you agree to our Privacy Policy.',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
      ],
    );
  }
}

/* ------------------------------ Bits ------------------------------------ */

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_MiniTitle(title), const SizedBox(height: 10), ...children],
      ),
    );
  }
}

class _MiniTitle extends StatelessWidget {
  final String text;
  const _MiniTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: kBrandGold,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Line({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: kBrandGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.88),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, top: 2),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: kBrandGold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white.withOpacity(0.88)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _Link extends StatelessWidget {
  final String label;
  final String route;
  const _Link(this.label, this.route);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: Colors.white,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => _safePush(context, route),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LegalLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('•', style: TextStyle(color: Colors.white.withOpacity(0.6)));
  }
}

/* ---------------------------- Helpers ----------------------------------- */

void _safePush(BuildContext context, String route) {
  final current = ModalRoute.of(context)?.settings.name;
  if (current == route) return;
  try {
    Navigator.pushNamed(context, route);
  } catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Route $route is not available yet.')),
    );
  }
}
