// lib/pages/about.dart
import 'package:flutter/material.dart';
import '../appbar.dart';
import '../footer.dart'; // footer

/* ---------------------------- File-level colors ---------------------------- */
// (Using the brochure’s gold/charcoal palette)
const Color _brandGold = Color(0xFFD4AF37);
const Color _textDark = Color(0xFF333333);

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MirabellaAppBar(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            _HeroAbout(), // uses assets/about1.jpeg
            _AboutIntro(), // responsive fix applied here
            _HighlightsGrid(), // 6 highlights from brochure
            _ProjectGlance(), // quick fact chips instead of date timeline
            _ValuesSection(), // values aligned to brochure themes
            _CTASection(),

            // Footer (responsive & overflow-proof)
            MirabellaFooter(),
          ],
        ),
      ),
    );
  }
}

/* --------------------------------- Hero --------------------------------- */

class _HeroAbout extends StatelessWidget {
  const _HeroAbout();

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(
      context,
    ).size.height.clamp(420.0, 560.0).toDouble();

    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image from assets
          Image.asset(
            'assets/about1.jpeg', // ensure this matches your asset name
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          // Scrim for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.35),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Text content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: const _HeroText(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'About Mirabella Floresca',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'A four-storey, ~10,000 sq-ft lifestyle hotel where life meets luxury —'
          ' thoughtfully placed in Islamabad’s E-18 (Gulshan-e-Sehat) for easy airport access and city connectivity.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.92),
            fontSize: 16.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ Intro Split ----------------------------- */

class _AboutIntro extends StatelessWidget {
  const _AboutIntro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42.0, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 900;

              // Wide: Row + Expanded (bounded height)
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.only(right: 28),
                        child: _AboutCopy(),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(flex: 2, child: _AboutImagePanel()),
                  ],
                );
              }

              // Narrow: Column WITHOUT Expanded (shrink-wrap to content)
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AboutCopy(),
                  SizedBox(height: 18),
                  _AboutImagePanel(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Extracted left-side text so we can reuse it cleanly above
class _AboutCopy extends StatelessWidget {
  const _AboutCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Our Story',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Conceived as a serene, international-standard escape within Islamabad,'
          ' Mirabella Floresca brings together hospitality, wellness, dining, and business support — all under one roof.',
          style: TextStyle(
            color: _textDark.withOpacity(0.85),
            height: 1.6,
            fontSize: 15.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'The upper three levels house 59 residential suites (Presidential, Executive, Deluxe),'
          ' each with a private balcony, spacious en-suite, sitting area and king bed;'
          ' the ground floor focuses on services and entertainment including a multi-level restaurant footprint and a fully-equipped Business Centre.',
          style: TextStyle(
            color: _textDark.withOpacity(0.85),
            height: 1.6,
            fontSize: 15.5,
          ),
        ),
      ],
    );
  }
}

/* --------------------------- Right Image Panel --------------------------- */

class _AboutImagePanel extends StatelessWidget {
  const _AboutImagePanel();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/about2.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              // very light overlay for premium feel (optional)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.black.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ----------------------------- Highlights Grid -------------------------- */

class _HighlightsGrid extends StatelessWidget {
  const _HighlightsGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      const _Highlight(
        icon: '📍',
        title: 'Prime E-18 Location',
        blurb:
            'Gulshan-e-Sehat (E-18), ~20-min from Islamabad International Airport; easy via airport highway & near CPEC corridor.',
      ),
      const _Highlight(
        icon: '🏨',
        title: '59 Suites Across 3 Levels',
        blurb:
            'Presidential, Executive & Deluxe — all with private balconies, spacious en-suites, seating and king beds.',
      ),
      const _Highlight(
        icon: '🍽️',
        title: 'Dining on Multiple Floors',
        blurb:
            'Food-court style at ground with views of the green; larger dining areas with own kitchens on 1st & 2nd floors.',
      ),
      const _Highlight(
        icon: '🏊',
        title: 'Pool & Wellness',
        blurb:
            '45-ft pool, kids’ pool, Jacuzzi, steam & sauna — a 2,600 sq-ft poolside experience for guests & members.',
      ),
      const _Highlight(
        icon: '💼',
        title: 'Business Centre',
        blurb:
            'Conference hall, meeting room, furnished offices, internet café, printers/scanners — daily/weekly rentals.',
      ),
      const _Highlight(
        icon: '🛡️',
        title: 'Smart & Secure',
        blurb:
            'Solar-backed power, IoT-enabled, 24/7 security & CCTV, Wi-Fi with backup, and complete fire-fighting system.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Wrap(
            spacing: 18,
            runSpacing: 18,
            children: items
                .map(
                  (e) => ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 260,
                      maxWidth: 520,
                    ),
                    child: _HighlightCard(item: e),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _Highlight {
  final String icon;
  final String title;
  final String blurb;
  const _Highlight({
    required this.icon,
    required this.title,
    required this.blurb,
  });
}

class _HighlightCard extends StatelessWidget {
  final _Highlight item;
  const _HighlightCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.blurb,
                    style: TextStyle(
                      color: _textDark.withOpacity(0.75),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------- Project At A Glance -------------------------- */

class _ProjectGlance extends StatelessWidget {
  const _ProjectGlance();

  @override
  Widget build(BuildContext context) {
    final chips = const [
      _FactChip('4 storeys'),
      _FactChip('~10,000 sq-ft footprint'),
      _FactChip('Ground: services & dining'),
      _FactChip('Upper 3: 59 suites'),
      _FactChip('Pool • Jacuzzi • Steam • Sauna'),
      _FactChip('Business Centre & Offices'),
      _FactChip('Family: Kids area & Gaming'),
      _FactChip('Solar + IoT • 24/7 Security'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const Text(
                'Project at a Glance',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: chips,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  final String text;
  const _FactChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: _textDark, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/* ------------------------------ Values Section -------------------------- */

class _ValuesSection extends StatelessWidget {
  const _ValuesSection();

  @override
  Widget build(BuildContext context) {
    final values = const [
      _ValuePill(
        title: 'Service & Comfort',
        desc: 'Thoughtful, international-level hospitality shaped around you.',
      ),
      _ValuePill(
        title: 'Design & Wellbeing',
        desc: 'Spaces for rest and rejuvenation — pool, sauna, steam, jacuzzi.',
      ),
      _ValuePill(
        title: 'Culinary Everywhere',
        desc: 'Ground food-court + expanded dining on upper floors.',
      ),
      _ValuePill(
        title: 'Business Ready',
        desc: 'Conference hall, meeting room and offices with full tech.',
      ),
      _ValuePill(
        title: 'Smart & Secure',
        desc: 'Solar backup, IoT, Wi-Fi redundancy, CCTV & fire safety.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: values
                .map(
                  (v) => ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 220,
                      maxWidth: 340,
                    ),
                    child: _ValueCard(v: v),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _ValuePill {
  final String title;
  final String desc;
  const _ValuePill({required this.title, required this.desc});
}

class _ValueCard extends StatelessWidget {
  final _ValuePill v;
  const _ValueCard({required this.v});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              v.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              v.desc,
              style: TextStyle(color: _textDark.withOpacity(0.75), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

/* --------------------------------- CTA ---------------------------------- */

class _CTASection extends StatelessWidget {
  const _CTASection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const Text(
                'Ready to experience Mirabella?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Explore rooms or reach out — our team will take care of the rest.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textDark.withOpacity(0.8)),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandGold,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/rooms'),
                    child: const Text(
                      'Explore Rooms',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _brandGold),
                      foregroundColor: _brandGold,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/contact'),
                    child: const Text('Book Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
