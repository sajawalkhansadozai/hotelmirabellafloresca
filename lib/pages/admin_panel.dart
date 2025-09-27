// lib/pages/admin_panel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const _gold = Color(0xFFD4AF37);
const _lightGold = Color(0xFFF4E8C7);
const _dark = Color(0xFF333333);
const _lightGray = Color(0xFFF6F4EF);
const _cardBg = Color(0xFFFFFFFF);
const _loginRoute = '/admin-login';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});
  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final _search = TextEditingController();
  String _status = 'all';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    final confirmed = await _showConfirmDialog(
      'Sign Out',
      'Are you sure you want to sign out?',
      'Sign Out',
      Colors.orange,
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(_loginRoute, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: _lightGray,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_gold),
              ),
            ),
          );
        }

        final user = snap.data;

        if (user == null || user.isAnonymous) {
          Future.microtask(() {
            if (!mounted) return;
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(_loginRoute, (r) => false);
          });
          return const SizedBox.shrink();
        }

        return Scaffold(
          backgroundColor: _lightGray,
          appBar: _buildAppBar(user),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _Toolbar(
                  search: _search,
                  status: _status,
                  onStatusChanged: (s) => setState(() => _status = s),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildReservationsList()),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(User user) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 640;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;

    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: _gold,
              size: isMobile ? 16 : 20,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              isMobile ? 'Admin' : 'Admin Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 16 : 20,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: _dark,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: _buildAppBarActions(user, isMobile, isTablet),
    );
  }

  List<Widget> _buildAppBarActions(User user, bool isMobile, bool isTablet) {
    if (isMobile) {
      return [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'logout') {
              _signOut();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'user',
              enabled: false,
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      user.email ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sign Out', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ];
    }

    return [
      if (!isTablet) ...[
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  user.email ?? '',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
      Container(
        margin: const EdgeInsets.only(right: 16),
        child: IconButton(
          tooltip: 'Sign out',
          onPressed: _signOut,
          icon: Icon(Icons.logout_rounded, size: isTablet ? 20 : 24),
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.1),
            foregroundColor: Colors.red.shade300,
          ),
        ),
      ),
    ];
  }

  Widget _buildHeader() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('reservations').snapshots(),
      builder: (_, snap) {
        final docs = snap.data?.docs ?? [];
        final newCount = docs
            .where((d) => (d.data()['status'] ?? 'new') == 'new')
            .length;
        final confirmedCount = docs
            .where((d) => (d.data()['status'] ?? 'new') == 'confirmed')
            .length;
        final totalCount = docs.length;

        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 640;
        final isTablet = screenWidth >= 640 && screenWidth < 1024;

        return Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_gold.withOpacity(0.1), _lightGold.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _gold.withOpacity(0.3)),
          ),
          child: isMobile
              ? _buildMobileHeader(totalCount, newCount, confirmedCount)
              : isTablet
              ? _buildTabletHeader(totalCount, newCount, confirmedCount)
              : _buildDesktopHeader(totalCount, newCount, confirmedCount),
        );
      },
    );
  }

  Widget _buildMobileHeader(int totalCount, int newCount, int confirmedCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reservation Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _dark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage hotel reservations',
          style: TextStyle(fontSize: 14, color: _dark.withOpacity(0.7)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _StatCard('Total', totalCount, Colors.blue)),
            const SizedBox(width: 8),
            Expanded(child: _StatCard('New', newCount, Colors.orange)),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard('Confirmed', confirmedCount, Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletHeader(int totalCount, int newCount, int confirmedCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reservation Management',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _dark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage and track all hotel reservations',
          style: TextStyle(fontSize: 15, color: _dark.withOpacity(0.7)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatCard('Total', totalCount, Colors.blue),
            const SizedBox(width: 16),
            _StatCard('New', newCount, Colors.orange),
            const SizedBox(width: 16),
            _StatCard('Confirmed', confirmedCount, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(int totalCount, int newCount, int confirmedCount) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reservation Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage and track all hotel reservations',
                style: TextStyle(fontSize: 16, color: _dark.withOpacity(0.7)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            _StatCard('Total', totalCount, Colors.blue),
            const SizedBox(width: 12),
            _StatCard('New', newCount, Colors.orange),
            const SizedBox(width: 12),
            _StatCard('Confirmed', confirmedCount, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildReservationsList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reservations')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_gold),
            ),
          );
        }

        if (snap.hasError) {
          return _buildErrorState(snap.error.toString());
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return _buildEmptyState();
        }

        final filtered = _filterReservations(docs);
        final width = MediaQuery.of(context).size.width;
        final isMobile = width < 768;
        final isTablet = width >= 768 && width < 1200;

        if (isMobile) {
          return _buildMobileView(filtered);
        } else if (isTablet) {
          return _buildTabletView(filtered);
        } else {
          return _buildDesktopView(filtered, width);
        }
      },
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterReservations(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final q = _search.text.trim().toLowerCase();
    return docs.where((d) {
      final m = d.data();
      final status = (m['status'] ?? '').toString().toLowerCase();
      if (_status != 'all' && status != _status) return false;
      if (q.isEmpty) return true;
      final searchText = [
        m['firstName'],
        m['lastName'],
        m['email'],
        m['phone'],
        m['roomLabel'],
        m['purpose'],
        m['roomKey'],
      ].whereType<String>().join(' ').toLowerCase();
      return searchText.contains(q);
    }).toList();
  }

  Widget _buildMobileView(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> filtered,
  ) {
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ReservationCard(
        doc: filtered[i],
        onStatusUpdate: _updateStatus,
        onDelete: _delete,
      ),
    );
  }

  Widget _buildTabletView(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> filtered,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _ReservationCard(
        doc: filtered[i],
        onStatusUpdate: _updateStatus,
        onDelete: _delete,
        isCompact: true,
      ),
    );
  }

  Widget _buildDesktopView(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> filtered,
    double width,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: width - 32),
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  _gold.withOpacity(0.1),
                ),
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _dark,
                ),
                dataRowHeight: 72,
                columns: const [
                  DataColumn(label: Text('Created')),
                  DataColumn(label: Text('Guest')),
                  DataColumn(label: Text('Contact')),
                  DataColumn(label: Text('Stay Period')),
                  DataColumn(label: Text('Room')),
                  DataColumn(label: Text('Details')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [for (final d in filtered) _buildDataRow(d, context)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: _dark.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No Reservations Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _dark.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reservations will appear here when guests make bookings',
            style: TextStyle(fontSize: 14, color: _dark.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.red.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: _dark.withOpacity(0.5)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(
    QueryDocumentSnapshot<Map<String, dynamic>> d,
    BuildContext context,
  ) {
    final m = d.data();
    final created = (m['createdAt'] as Timestamp?)?.toDate();
    final inDate = (m['checkIn'] as Timestamp?)?.toDate();
    final outDate = (m['checkOut'] as Timestamp?)?.toDate();

    return DataRow(
      cells: [
        DataCell(Text(created != null ? _fmtDT(created) : '—')),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'.trim(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                m['purpose'] ?? '',
                style: TextStyle(fontSize: 12, color: _dark.withOpacity(0.6)),
              ),
            ],
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ellips(m['email'] ?? '', 150),
              _ellips(m['phone'] ?? '', 150),
            ],
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${_fmtD(inDate)} → ${_fmtD(outDate)}'),
              Text(
                '${m['nights'] ?? ''} nights',
                style: TextStyle(fontSize: 12, color: _dark.withOpacity(0.6)),
              ),
            ],
          ),
        ),
        DataCell(_ellips(m['roomLabel'] ?? '', 120)),
        DataCell(Text('${m['guests'] ?? ''} guests')),
        DataCell(
          Text(
            _fmtPKR(m['estimatePKR'] ?? 0),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(_StatusChip(status: (m['status'] ?? 'new').toString())),
        DataCell(
          _Actions(
            onSet: (status) => _updateStatus(d.id, status),
            onDelete: () => _delete(d.id),
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(id)
          .update({'status': status});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${status.toUpperCase()}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _delete(String id) async {
    final confirmed = await _showConfirmDialog(
      'Delete Reservation',
      'Are you sure you want to delete this reservation? This action cannot be undone.',
      'Delete',
      Colors.red,
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('reservations')
            .doc(id)
            .delete();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete reservation: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool?> _showConfirmDialog(
    String title,
    String content,
    String actionText,
    Color actionColor,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: Colors.white,
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ Widgets -------------------------------- */

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatCard(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final TextEditingController search;
  final String status;
  final ValueChanged<String> onStatusChanged;

  const _Toolbar({
    required this.search,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: _gold),
              const SizedBox(width: 8),
              Text(
                'Filter & Search',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isMobile) ...[
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildStatusFilter(),
          ] else
            Row(
              children: [
                Expanded(flex: 2, child: _buildSearchField()),
                const SizedBox(width: 16),
                Expanded(child: _buildStatusFilter()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: search,
      onChanged: (_) => {},
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: _gold),
        hintText: 'Search by name, email, phone, room...',
        filled: true,
        fillColor: _lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _gold, width: 2),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      value: status,
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Statuses')),
        DropdownMenuItem(value: 'new', child: Text('New')),
        DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
        DropdownMenuItem(value: 'done', child: Text('Completed')),
      ],
      onChanged: (v) => onStatusChanged(v ?? 'all'),
      decoration: InputDecoration(
        labelText: 'Status Filter',
        prefixIcon: Icon(Icons.tune, color: _gold),
        filled: true,
        fillColor: _lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _gold, width: 2),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final Function(String, String) onStatusUpdate;
  final Function(String) onDelete;
  final bool isCompact;

  const _ReservationCard({
    required this.doc,
    required this.onStatusUpdate,
    required this.onDelete,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final m = doc.data();
    final created = (m['createdAt'] as Timestamp?)?.toDate();
    final inDate = (m['checkIn'] as Timestamp?)?.toDate();
    final outDate = (m['checkOut'] as Timestamp?)?.toDate();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _gold.withOpacity(0.2)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [_cardBg, _lightGold.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(m),
              const SizedBox(height: 12),
              if (!isCompact) ...[
                _buildCardDetails(m, created, inDate, outDate),
                const SizedBox(height: 16),
              ],
              _buildCardActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(Map<String, dynamic> m) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.person, color: _gold, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'.trim(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _dark,
                ),
              ),
              Text(
                m['email'] ?? '',
                style: TextStyle(fontSize: 14, color: _dark.withOpacity(0.6)),
              ),
            ],
          ),
        ),
        _StatusChip(status: (m['status'] ?? 'new').toString()),
      ],
    );
  }

  Widget _buildCardDetails(
    Map<String, dynamic> m,
    DateTime? created,
    DateTime? inDate,
    DateTime? outDate,
  ) {
    return Column(
      children: [
        _DetailRow(
          icon: Icons.access_time,
          label: 'Created',
          value: created != null ? _fmtDT(created) : '—',
        ),
        _DetailRow(icon: Icons.phone, label: 'Phone', value: m['phone'] ?? ''),
        _DetailRow(
          icon: Icons.calendar_today,
          label: 'Stay',
          value: '${_fmtD(inDate)} → ${_fmtD(outDate)}',
        ),
        _DetailRow(
          icon: Icons.hotel,
          label: 'Room',
          value: m['roomLabel'] ?? '',
        ),
        _DetailRow(
          icon: Icons.group,
          label: 'Guests',
          value: '${m['guests'] ?? ''} guests, ${m['nights'] ?? ''} nights',
        ),
        _DetailRow(
          icon: Icons.attach_money,
          label: 'Amount',
          value: _fmtPKR(m['estimatePKR'] ?? 0),
        ),
        _DetailRow(
          icon: Icons.note,
          label: 'Purpose',
          value: m['purpose'] ?? '',
        ),
      ],
    );
  }

  Widget _buildCardActions() {
    return _Actions(
      onSet: (status) => onStatusUpdate(doc.id, status),
      onDelete: () => onDelete(doc.id),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _gold),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: _dark.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final ValueChanged<String> onSet;
  final VoidCallback onDelete;

  const _Actions({required this.onSet, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ActionButton(
          'Confirm',
          Icons.check_circle,
          Colors.green,
          () => onSet('confirmed'),
        ),
        _ActionButton(
          'Cancel',
          Icons.cancel,
          Colors.orange,
          () => onSet('cancelled'),
        ),
        _ActionButton(
          'Complete',
          Icons.done_all,
          Colors.blue,
          () => onSet('done'),
        ),
        _ActionButton(
          'Delete',
          Icons.delete_forever,
          Colors.red,
          onDelete,
          isDanger: true,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionButton(
    this.label,
    this.icon,
    this.color,
    this.onTap, {
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'done':
        return Colors.blue;
      default:
        return Colors.orange; // new
    }
  }

  String get _displayText {
    switch (status.toLowerCase()) {
      case 'new':
        return 'NEW';
      case 'confirmed':
        return 'CONFIRMED';
      case 'cancelled':
        return 'CANCELLED';
      case 'done':
        return 'COMPLETED';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _displayText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/* ------------------------------ Helper Functions -------------------------------- */

String _fmtPKR(dynamic value) {
  int amount = 0;
  if (value is int) amount = value;
  if (value is double) amount = value.toInt();

  final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String result = amount.toString().replaceAllMapped(
    formatter,
    (Match m) => '${m[1]},',
  );

  return 'PKR $result';
}

String _fmtD(DateTime? date) {
  if (date == null) return '—';
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _fmtDT(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.year}-$month-$day $hour:$minute';
}

Widget _ellips(String text, [double width = 180]) {
  return SizedBox(
    width: width,
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 13),
    ),
  );
}
