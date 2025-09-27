import 'dart:async';
import 'package:flutter/material.dart';

const Color kAppBarBg = Color(0xFF0F0F0F);
const Color kBrandGold = Color(0xFFD4AF37);

// Tunable logo sizes
const double _kLogoSizeMobile = 125; // when < 800px wide
const double _kLogoSizeDesktop = 150; // when >= 800px wide

class MirabellaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBookNow;
  const MirabellaAppBar({super.key, this.showBookNow = false});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  bool _isActive(String? current, String route) {
    return current == route || (current == null && route == '/');
  }

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.of(context)?.settings.name;
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 800;

    const items = <_MenuAction>[
      _MenuAction(label: 'Home', routeName: '/', icon: Icons.home_rounded),
      _MenuAction(
        label: 'About',
        routeName: '/about',
        icon: Icons.info_rounded,
      ),
      _MenuAction(
        label: 'Rooms',
        routeName: '/rooms',
        icon: Icons.hotel_rounded,
      ),
      _MenuAction(
        label: 'Gallery',
        routeName: '/gallery',
        icon: Icons.photo_library_rounded,
      ),
      _MenuAction(
        label: 'Contact',
        routeName: '/contact',
        icon: Icons.call_rounded,
      ),
    ];

    return AppBar(
      backgroundColor: kAppBarBg,
      elevation: 0,
      titleSpacing: isMobile ? 0 : 12,
      iconTheme: const IconThemeData(color: Colors.white),
      title: _LogoTitle(
        compact: isMobile,
        logoSize: isMobile ? _kLogoSizeMobile : _kLogoSizeDesktop,
      ),
      leading: isMobile
          ? _MobileMenuButton(
              items: items,
              current: current,
              includeBookNow: showBookNow,
            )
          : null,
      actions: isMobile
          ? const [SizedBox(width: 8)]
          : [
              for (final m in items)
                _NavLink(label: m.label, routeName: m.routeName),
              if (showBookNow) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandGold,
                      foregroundColor: Colors.black87,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      if (!_isActive(current, '/contact')) {
                        Navigator.pushNamed(context, '/contact');
                      }
                    },
                    child: const Text('Book Now'),
                  ),
                ),
              ],
              const SizedBox(width: 8),
            ],
    );
  }
}

/* ----------------------------- Mobile Menu ------------------------------ */

class _MobileMenuButton extends StatelessWidget {
  final List<_MenuAction> items;
  final String? current;
  final bool includeBookNow;

  const _MobileMenuButton({
    required this.items,
    required this.current,
    required this.includeBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      tooltip: 'Menu',
      icon: const Icon(Icons.menu_rounded),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (ctx) {
        final list = <PopupMenuEntry<_MenuAction>>[];

        for (final m in items) {
          final active =
              current == m.routeName || (current == null && m.routeName == '/');
          list.add(
            PopupMenuItem<_MenuAction>(
              value: m,
              child: Row(
                children: [
                  Icon(
                    m.icon,
                    size: 20,
                    color: active ? kBrandGold : Colors.black87,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      m.label,
                      style: TextStyle(
                        fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                        color: active ? kBrandGold : Colors.black87,
                      ),
                    ),
                  ),
                  if (active)
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: kBrandGold,
                    ),
                ],
              ),
            ),
          );
        }

        if (includeBookNow) {
          list.add(const PopupMenuDivider(height: 6));
          list.add(
            PopupMenuItem<_MenuAction>(
              value: const _MenuAction(
                label: 'Book Now',
                routeName: '/contact',
                icon: Icons.event_available_rounded,
                prominent: true,
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.event_available_rounded,
                    size: 20,
                    color: kBrandGold,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: kBrandGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return list;
      },
      onSelected: (m) {
        final route = m.routeName;
        final cur = ModalRoute.of(context)?.settings.name;
        final isActive = cur == route || (cur == null && route == '/');
        if (!isActive) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}

class _MenuAction {
  final String label;
  final String routeName;
  final IconData icon;
  final bool prominent;
  const _MenuAction({
    required this.label,
    required this.routeName,
    required this.icon,
    this.prominent = false,
  });
}

/* ----------------------- Brand Title (logo + name) ----------------------- */

class _LogoTitle extends StatefulWidget {
  final bool compact; // tighter for small screens
  final double logoSize;
  const _LogoTitle({this.compact = false, this.logoSize = _kLogoSizeMobile});

  @override
  State<_LogoTitle> createState() => _LogoTitleState();
}

class _LogoTitleState extends State<_LogoTitle> {
  int _tapCount = 0;
  Timer? _window;

  static const _unlockTaps = 5;
  static const _windowMs = 1200; // 5 taps within 1.2 seconds

  void _handleTap() {
    _tapCount++;
    _window?.cancel();
    _window = Timer(const Duration(milliseconds: _windowMs), () {
      // Window ended → treat as normal single tap (go home)
      if (_tapCount < _unlockTaps) _goHome();
      _tapCount = 0;
    });

    if (_tapCount >= _unlockTaps) {
      _window?.cancel();
      _tapCount = 0;
      Navigator.pushNamed(context, '/admin-login');
    }
  }

  void _goHome() {
    final current = ModalRoute.of(context)?.settings.name;
    if (current != '/' && current != null) {
      Navigator.pushNamed(context, '/');
    }
  }

  @override
  void dispose() {
    _window?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/logomf.png',
              height: widget.logoSize,
              width: widget.logoSize,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.apartment_rounded,
                color: kBrandGold,
                size: widget.logoSize,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.compact ? 200 : 280),
            child: const Text(
              'Mirabella Floresca',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ----------------------------- Desktop Nav Link -------------------------- */

class _NavLink extends StatelessWidget {
  final String label;
  final String routeName;
  const _NavLink({required this.label, required this.routeName});

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.of(context)?.settings.name;
    final bool isActive =
        current == routeName || (current == null && routeName == '/');

    return TextButton(
      onPressed: () {
        if (!isActive) Navigator.pushNamed(context, routeName);
      },
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? kBrandGold : Colors.white,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
