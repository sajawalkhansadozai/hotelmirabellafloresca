// lib/pages/rooms.dart
import 'package:flutter/material.dart';
import '../appbar.dart';
import '../footer.dart'; // <-- add this

/* ---------------------------- File-level colors ---------------------------- */
// Make colors available to ALL widgets in this file (fixes scope errors)
const Color _brandGold = Color(0xFFD4AF37);
const Color _textDark = Color(0xFF333333);

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  // Six room types (PKR 8,000 – 12,000) + image paths + descriptions
  final _rooms = <_RoomType>[
    _RoomType(
      keyName: 'basic',
      title: 'Basic Room',
      pricePKR: 8000,
      size: 'Approx. 24–28 sqm',
      image: 'assets/hero1.jpg', // updated
      description:
          'A calm, well-appointed space designed for effortless stays. Thoughtful touches, quality linens, and a smart layout make it ideal for solo travelers or couples who want comfort at great value.',
      features: const [
        'King/Queen bed • premium linens',
        'Dedicated workspace',
        'Spacious en-suite (rain shower)',
        'High-speed Wi-Fi',
        'Smart TV (streaming)',
      ],
    ),
    _RoomType(
      keyName: 'superior',
      title: 'Superior Room',
      pricePKR: 9000,
      size: 'Approx. 28–32 sqm',
      image: 'assets/hero2.png', // updated
      description:
          'A brighter, roomier upgrade with refined finishes. Many Superior Rooms offer pleasant outlooks, creating a relaxed atmosphere for short city breaks and business trips alike.',
      features: const [
        'King bed • premium amenities',
        'City / garden view',
        'Private balcony (select rooms)',
        'Tea/coffee station • Mini bar',
        '24/7 room service',
      ],
    ),
    _RoomType(
      keyName: 'deluxe',
      title: 'Deluxe Room',
      pricePKR: 10000,
      size: 'Approx. 35–40 sqm',
      image: 'assets/hero3.png', // updated
      description:
          'Generous space with a private balcony and an inviting seating area. Perfect for longer stays, pairing modern comforts with a restful ambiance to recharge in style.',
      features: const [
        'King bed • premium linens',
        'Private balcony',
        'Spacious en-suite (rain shower)',
        'Sitting area & work desk',
        'Smart TV • High-speed Wi-Fi',
      ],
    ),
    _RoomType(
      keyName: 'executive',
      title: 'Executive Room',
      pricePKR: 11000,
      size: 'Approx. 40–45 sqm',
      image: 'assets/hero4.png', // updated
      description:
          'Tailored for business and discerning travelers. A refined, quiet environment with elevated amenities—ideal for productivity by day and comfort by night.',
      features: const [
        'Oversized king bed',
        'Larger en-suite • double vanity',
        'Exclusive floor access',
        'In-room espresso machine',
        'Priority reservations',
      ],
    ),
    _RoomType(
      keyName: 'junior_suite',
      title: 'Junior Suite',
      pricePKR: 11500,
      size: 'Approx. 50–55 sqm',
      image: 'assets/hero5.png', // updated
      description:
          'A graceful suite with a separate sitting area—more room to unwind, host a chat, or simply enjoy a quiet coffee with a view.',
      features: const [
        'Separate sitting area',
        'Private balcony with view',
        'Enhanced bathroom amenities',
        'Evening turndown service',
        'Welcome refreshments',
      ],
    ),
    _RoomType(
      keyName: 'family_suite',
      title: 'Family Suite',
      pricePKR: 12000,
      size: 'Approx. 60–70 sqm',
      image: 'assets/hero6.png', // updated
      description:
          'Smartly planned for families, with two sleeping zones and a cozy dining nook. Everyone gets their space—without losing the together-time feel.',
      features: const [
        'Two sleeping zones',
        'Kid-friendly amenities',
        'Kitchenette & dining nook',
        'Baby crib on request',
        'Complimentary games & toys',
      ],
    ),
  ];

  // Booking state
  _RoomType? _selectedRoom;
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 2;

  @override
  void initState() {
    super.initState();
    _selectedRoom = _rooms.first;
    final now = DateTime.now();
    _checkIn = DateTime(now.year, now.month, now.day);
    _checkOut = _checkIn!.add(const Duration(days: 1));
  }

  int get _nights {
    if (_checkIn == null || _checkOut == null) return 0;
    final days = _checkOut!.difference(_checkIn!).inDays;
    return days.clamp(0, 365).toInt();
  }

  int get _estimatedTotalPKR {
    final price = _selectedRoom?.pricePKR ?? 0;
    return price * (_nights == 0 ? 1 : _nights); // min 1 night
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final initial = isCheckIn ? _checkIn : _checkOut;
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isCheckIn ? 'Select check-in date' : 'Select check-out date',
    );
    if (picked == null) return;

    setState(() {
      if (isCheckIn) {
        _checkIn = DateTime(picked.year, picked.month, picked.day);
        if (_checkOut == null || !_checkOut!.isAfter(_checkIn!)) {
          _checkOut = _checkIn!.add(const Duration(days: 1));
        }
      } else {
        if (_checkIn != null && !picked.isAfter(_checkIn!)) {
          _checkOut = _checkIn!.add(const Duration(days: 1));
        } else {
          _checkOut = DateTime(picked.year, picked.month, picked.day);
        }
      }
    });
  }

  void _goToContactWithContext() {
    Navigator.pushNamed(context, '/contact');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reservation inquiry: ${_selectedRoom?.title} • ${_nights == 0 ? 1 : _nights} night(s) • $_guests guest(s) • ~${_fmtPKR(_estimatedTotalPKR)}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: _textDark,
    );

    return Scaffold(
      appBar: const MirabellaAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _HeroRooms(), // stretchable, responsive, overflow-proof
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
                      const _RoomsGlanceStrip(),
                      const SizedBox(height: 16),
                      const Text('Find your perfect stay', style: titleStyle),
                      const SizedBox(height: 10),
                      _BookingBar(
                        rooms: _rooms,
                        selected: _selectedRoom!,
                        checkIn: _checkIn!,
                        checkOut: _checkOut!,
                        guests: _guests,
                        onRoomChanged: (r) => setState(() => _selectedRoom = r),
                        onPickCheckIn: () => _pickDate(isCheckIn: true),
                        onPickCheckOut: () => _pickDate(isCheckIn: false),
                        onGuestsChanged: (g) => setState(() => _guests = g),
                        nights: _nights == 0 ? 1 : _nights,
                        estTotalPKR: _estimatedTotalPKR,
                        onReserve: _goToContactWithContext,
                      ),
                      const SizedBox(height: 20),

                      // ===== Responsive 1/2/3 column layout (always 3 on wide) =====
                      LayoutBuilder(
                        builder: (context, c) {
                          final double w = c.maxWidth;
                          final int cols = w >= 1000 ? 3 : (w >= 680 ? 2 : 1);
                          final double gap = 18;
                          final double itemW = (w - (cols - 1) * gap) / cols;

                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: _rooms
                                .map(
                                  (r) => SizedBox(
                                    width: itemW,
                                    child: _RoomCard(
                                      room: r,
                                      isSelected:
                                          r.keyName == _selectedRoom?.keyName,
                                      onSelect: () =>
                                          setState(() => _selectedRoom = r),
                                      onBook: () {
                                        setState(() => _selectedRoom = r);
                                        _goToContactWithContext();
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 28),
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
                          onPressed: _goToContactWithContext,
                          child: const Text(
                            'Need help choosing? Talk to Reservations',
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),

            // === Footer at the very end of the page ===
            const MirabellaFooter(),
          ],
        ),
      ),
    );
  }
}

/* --------------------------------- Hero --------------------------------- */

class _HeroRooms extends StatefulWidget {
  const _HeroRooms();

  @override
  State<_HeroRooms> createState() => _HeroRoomsState();
}

class _HeroRoomsState extends State<_HeroRooms> {
  // Intrinsic aspect ratio of hero image (width / height).
  double? _aspect;
  ImageStream? _stream;
  late final ImageStreamListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = ImageStreamListener(
      (info, _) {
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        if (mounted) setState(() => _aspect = w / h);
      },
      onError: (_, __) {
        // If asset missing or fails, keep default ratio.
        if (mounted) setState(() => _aspect = _aspect ?? (16 / 9));
      },
    );

    final provider = const AssetImage('assets/rooms/hero.png');
    _stream = provider.resolve(const ImageConfiguration());
    _stream!.addListener(_listener);
  }

  @override
  void dispose() {
    if (_stream != null) {
      _stream!.removeListener(_listener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _aspect ?? (16 / 9); // fallback till image resolves
    final size = MediaQuery.of(context).size;
    final width = size.width;
    // Height follows image aspect and is clamped for overflow safety.
    final idealHeight = width / ratio;
    final height = idealHeight.clamp(320.0, size.height * 0.95);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Use contain so the full image is visible; any extra area shows gradient bg.
          Container(color: const Color(0xFF0F0F0F)),
          Image.asset(
            'assets/rooms/hero.png',
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
          // Scrim for text readability even if image is bright
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
          // Centered text content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Rooms & Suites',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'From comfort-focused Basic Rooms to spacious Family Suites — all thoughtfully designed for modern travel.',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 16.5,
                          height: 1.35,
                        ),
                      ),
                    ],
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

/* ------------------------------ Brochure chips --------------------------- */

class _RoomsGlanceStrip extends StatelessWidget {
  const _RoomsGlanceStrip();

  @override
  Widget build(BuildContext context) {
    final chips = const [
      _FactChip('Upper three levels'),
      _FactChip('59 residential suites'),
      _FactChip('All with private balconies'),
      _FactChip('Spacious en-suites'),
      _FactChip('Sitting area & king bed'),
    ];
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}

/// Small pill used in the glance strip (const-friendly)
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

/* ------------------------------- Data Model ----------------------------- */

class _RoomType {
  final String keyName;
  final String title;
  final int pricePKR;
  final String size;
  final String image; // asset path (used on card header only)
  final String description; // paragraph for details popup
  final List<String> features;
  const _RoomType({
    required this.keyName,
    required this.title,
    required this.pricePKR,
    required this.size,
    required this.image,
    required this.description,
    required this.features,
  });
}

/* ------------------------------- Booking Bar ---------------------------- */

class _BookingBar extends StatelessWidget {
  final List<_RoomType> rooms;
  final _RoomType selected;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int nights;
  final int estTotalPKR;

  final VoidCallback onPickCheckIn;
  final VoidCallback onPickCheckOut;
  final ValueChanged<_RoomType> onRoomChanged;
  final ValueChanged<int> onGuestsChanged;
  final VoidCallback onReserve;

  const _BookingBar({
    required this.rooms,
    required this.selected,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.nights,
    required this.estTotalPKR,
    required this.onPickCheckIn,
    required this.onPickCheckOut,
    required this.onRoomChanged,
    required this.onGuestsChanged,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final dateStyle = TextStyle(color: _textDark.withOpacity(0.85));

    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _FieldShell(
              label: 'Check-in',
              child: InkWell(
                onTap: onPickCheckIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(_fmtDate(checkIn), style: dateStyle),
                    ],
                  ),
                ),
              ),
            ),
            _FieldShell(
              label: 'Check-out',
              child: InkWell(
                onTap: onPickCheckOut,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(_fmtDate(checkOut), style: dateStyle),
                    ],
                  ),
                ),
              ),
            ),
            _FieldShell(
              label: 'Guests',
              child: DropdownButton<int>(
                value: guests,
                underline: const SizedBox.shrink(),
                onChanged: (v) => onGuestsChanged(v ?? guests),
                items: const [1, 2, 3, 4, 5, 6]
                    .map((g) => DropdownMenuItem(value: g, child: Text('$g')))
                    .toList(),
              ),
            ),
            _FieldShell(
              label: 'Room Type',
              child: DropdownButton<String>(
                value: selected.keyName,
                underline: const SizedBox.shrink(),
                onChanged: (v) {
                  final r = rooms.firstWhere((e) => e.keyName == v);
                  onRoomChanged(r);
                },
                items: rooms
                    .map(
                      (r) => DropdownMenuItem(
                        value: r.keyName,
                        child: Text(
                          '${r.title} — ${_fmtPKR(r.pricePKR)}/night',
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            _TotalPill(nights: nights, totalPKR: estTotalPKR),
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
              onPressed: onReserve,
              child: const Text('Reserve / Contact'),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}

class _FieldShell extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldShell({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF9F9F9),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _TotalPill extends StatelessWidget {
  final int nights;
  final int totalPKR;
  const _TotalPill({required this.nights, required this.totalPKR});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _brandGold,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Estimated: ${_fmtPKR(totalPKR)} • $nights night${nights > 1 ? 's' : ''}',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/* -------------------------------- Room Card ----------------------------- */

class _RoomCard extends StatelessWidget {
  final _RoomType room;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onBook;

  const _RoomCard({
    required this.room,
    required this.isSelected,
    required this.onSelect,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: isSelected ? 10 : 6,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onSelect,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE HEADER (card only; no image in details sheet)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                room.image,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    height: 160,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFE6D8A3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        room.title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${room.size} • ${_fmtPKR(room.pricePKR)}/night',
                    style: TextStyle(
                      color: _textDark.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...room.features.take(6).map((f) => _FeatureBullet(text: f)),
                  if (room.features.length > 6)
                    Text(
                      '+ ${room.features.length - 6} more…',
                      style: TextStyle(
                        color: _textDark.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _brandGold),
                          foregroundColor: _brandGold,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => _showDetails(context, room, onBook),
                        child: const Text('View Details'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandGold,
                          foregroundColor: Colors.black87,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: onBook,
                        child: const Text('Book Now'),
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

  // Bottom-sheet popup WITHOUT image: title, size/price, paragraph, tick list
  static void _showDetails(
    BuildContext context,
    _RoomType room,
    VoidCallback onBook,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 900),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                room.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${room.size} • ${_fmtPKR(room.pricePKR)}/night',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textDark.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                room.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textDark.withOpacity(0.85),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: room.features.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.check_rounded, color: _brandGold),
                    title: Text(room.features[i]),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGold,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onBook();
                  },
                  child: const Text('Reserve / Contact'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final String text;
  const _FeatureBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, size: 18, color: _brandGold),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _textDark, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------- Helpers -------------------------------- */

String _fmtPKR(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    buf.write(s[i]);
    count++;
    if (i > 0 && count % 3 == 0) buf.write(',');
  }
  return 'PKR ${buf.toString().split('').reversed.join()}';
}
