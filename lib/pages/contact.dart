// lib/pages/contact.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../appbar.dart';
import '../footer.dart';

/* ---------------------------- File-level colors ---------------------------- */
const Color _brandGold = Color(0xFFD4AF37);
const Color _textDark = Color(0xFF333333);

/* ------------------------ Compact contact card model ----------------------- */
class _ContactCardData {
  final IconData icon;
  final String title;
  final List<String> lines;
  const _ContactCardData({
    required this.icon,
    required this.title,
    required this.lines,
  });
}

/* ----------------------- Contact details (from brochure) ------------------- */
// The brochure lists project location in E-18 (Gulshan-e-Sehat) Islamabad and
// mentions ~20 mins from Islamabad International Airport.
// Phone / Email were NOT in the PDF → placeholders used below.
const List<_ContactCardData> _kContactCards = [
  _ContactCardData(
    icon: Icons.place_rounded,
    title: 'Address',
    lines: [
      'Gulshan-e-Sehat (Sector E-18)',
      'Islamabad, Pakistan',
      '≈ 20 mins from Islamabad Intl. Airport',
    ],
  ),
  _ContactCardData(
    icon: Icons.call_rounded,
    title: 'Phone',
    lines: [
      'Not listed in brochure',
      // TODO: Replace with your real numbers, e.g. +92 … / +1 …
    ],
  ),
  _ContactCardData(
    icon: Icons.email_rounded,
    title: 'Email',
    lines: [
      'Not listed in brochure',
      // TODO: Replace with your real emails, e.g. reservations@… / events@…
    ],
  ),
  _ContactCardData(
    icon: Icons.schedule_rounded,
    title: 'Hours',
    lines: [
      'Reception: 24/7',
      'Concierge: 24/7',
      'Reservations: 06:00–23:00',
      'Events: Mon–Fri 09:00–18:00',
    ],
  ),
];

/* --------------------------------- Page --------------------------------- */

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});
  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _requests = TextEditingController();

  // Reservation state (matches Rooms page)
  DateTime _checkIn = _today();
  DateTime _checkOut = _today().add(const Duration(days: 1));
  String _roomKey = 'deluxe';
  int _guests = 2;
  _Purpose _purpose = _Purpose.business;
  bool _submitting = false;

  // Prices PKR / night (matches rooms.dart)
  final Map<String, int> _roomPricesPKR = const {
    'basic': 8000,
    'superior': 9000,
    'deluxe': 10000,
    'executive': 11000,
    'junior_suite': 11500,
    'family_suite': 12000,
  };

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  int get _nights {
    final days = _checkOut.difference(_checkIn).inDays;
    return days <= 0 ? 1 : days;
  }

  int get _estimatePKR {
    final nightly = _roomPricesPKR[_roomKey] ?? 0;
    return nightly * _nights;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _requests.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkIn : _checkOut,
      firstDate: _today(),
      lastDate: _today().add(const Duration(days: 365)),
      helpText: isCheckIn ? 'Select check-in date' : 'Select check-out date',
    );
    if (picked == null) return;

    setState(() {
      if (isCheckIn) {
        _checkIn = DateTime(picked.year, picked.month, picked.day);
        if (!_checkOut.isAfter(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
      } else {
        if (!picked.isAfter(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        } else {
          _checkOut = DateTime(picked.year, picked.month, picked.day);
        }
      }
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final name = '${_firstName.text} ${_lastName.text}'.trim();
    final roomLabel = _roomTitle(_roomKey);

    try {
      // Direct write to Firestore (ensure your rules allow public create)
      await FirebaseFirestore.instance.collection('reservations').add({
        'createdAt': FieldValue.serverTimestamp(),
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'requests': _requests.text.trim(),
        'checkIn': Timestamp.fromDate(_checkIn),
        'checkOut': Timestamp.fromDate(_checkOut),
        'nights': _nights,
        'roomKey': _roomKey,
        'roomLabel': roomLabel,
        'guests': _guests,
        'purpose': _purpose.name,
        'estimatePKR': _estimatePKR,
        'status': 'new',
      });

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Reservation Request Submitted'),
          content: Text(
            'Thank you, $name!\n\n'
            'Room: $roomLabel\n'
            'Guests: $_guests\n'
            'Stay: ${_fmtDate(_checkIn)} → ${_fmtDate(_checkOut)} '
            '($_nights night${_nights > 1 ? 's' : ''})\n'
            'Estimated Total: ${_fmtPKR(_estimatePKR)} (before taxes & fees)\n\n'
            'You’ll receive a confirmation email shortly.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Reset form
      _formKey.currentState!.reset();
      _firstName.clear();
      _lastName.clear();
      _email.clear();
      _phone.clear();
      _requests.clear();
      setState(() {
        _checkIn = _today();
        _checkOut = _today().add(const Duration(days: 1));
        _roomKey = 'deluxe';
        _guests = 2;
        _purpose = _Purpose.business;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission blocked (rules or network): $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _roomTitle(String key) {
    switch (key) {
      case 'basic':
        return 'Basic Room';
      case 'superior':
        return 'Superior Room';
      case 'deluxe':
        return 'Deluxe Room';
      case 'executive':
        return 'Executive Room';
      case 'junior_suite':
        return 'Junior Suite';
      case 'family_suite':
        return 'Family Suite';
      default:
        return 'Room';
    }
  }

  static String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MirabellaAppBar(),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 980;

                  final contactCards = _CompactCardsStrip(data: _kContactCards);
                  final map = const _MapCard();

                  final form = _ReservationForm(
                    formKey: _formKey,
                    firstName: _firstName,
                    lastName: _lastName,
                    email: _email,
                    phone: _phone,
                    requests: _requests,
                    checkIn: _checkIn,
                    checkOut: _checkOut,
                    onPickCheckIn: () => _pickDate(isCheckIn: true),
                    onPickCheckOut: () => _pickDate(isCheckIn: false),
                    roomKey: _roomKey,
                    onRoomChanged: (v) => setState(() => _roomKey = v),
                    guests: _guests,
                    onGuestsChanged: (g) => setState(() => _guests = g),
                    purpose: _purpose,
                    onPurposeChanged: (p) => setState(() => _purpose = p),
                    nights: _nights,
                    estimatePKR: _estimatePKR,
                    onSubmit: _submit,
                    submitting: _submitting,
                  );

                  if (wide) {
                    return Column(
                      children: [
                        contactCards,
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: Column(children: [map])),
                            const SizedBox(width: 12),
                            Expanded(flex: 6, child: form),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const MirabellaFooter(),
                      ],
                    );
                  }

                  // Narrow layout
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      contactCards,
                      const SizedBox(height: 8),
                      map,
                      const SizedBox(height: 12),
                      form,
                      const SizedBox(height: 12),
                      const MirabellaFooter(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------------- Compact cards (top) -------------------------- */

class _CompactCardsStrip extends StatelessWidget {
  final List<_ContactCardData> data;
  const _CompactCardsStrip({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = (c.maxWidth / 260).floor().clamp(1, 4);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3 / 1.2,
          ),
          itemBuilder: (_, i) => _CompactInfoCard(item: data[i]),
        );
      },
    );
  }
}

class _CompactInfoCard extends StatelessWidget {
  final _ContactCardData item;
  const _CompactInfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      color: Colors.white,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10), // ✅ fixed
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _brandGold.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: _brandGold, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DefaultTextStyle(
                style: const TextStyle(color: _textDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    ...item.lines.map(
                      (l) => Text(
                        l,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _textDark.withOpacity(0.82),
                          height: 1.25,
                          fontSize: 13.5,
                        ),
                      ),
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

/* ------------------------------ Map (compact) ---------------------------- */

class _MapCard extends StatelessWidget {
  const _MapCard();
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Container(
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
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      '📍 Gulshan-e-Sehat (Sector E-18), Islamabad',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '≈ 20 mins from Islamabad Intl. Airport',
                      style: TextStyle(color: Colors.black87),
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
}

/* ----------------------------- Reservation Form ------------------------- */

enum _Purpose { business, leisure, event, meeting, wedding, anniversary, other }

class _ReservationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController requests;

  final DateTime checkIn;
  final DateTime checkOut;
  final VoidCallback onPickCheckIn;
  final VoidCallback onPickCheckOut;

  final String roomKey;
  final ValueChanged<String> onRoomChanged;

  final int guests;
  final ValueChanged<int> onGuestsChanged;

  final _Purpose purpose;
  final ValueChanged<_Purpose> onPurposeChanged;

  final int nights;
  final int estimatePKR;

  final VoidCallback onSubmit;
  final bool submitting;

  const _ReservationForm({
    required this.formKey,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.requests,
    required this.checkIn,
    required this.checkOut,
    required this.onPickCheckIn,
    required this.onPickCheckOut,
    required this.roomKey,
    required this.onRoomChanged,
    required this.guests,
    required this.onGuestsChanged,
    required this.purpose,
    required this.onPurposeChanged,
    required this.nights,
    required this.estimatePKR,
    required this.onSubmit,
    required this.submitting,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      color: Colors.white,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Make a Reservation',
                style: TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _TextField(
                    controller: firstName,
                    label: 'First Name',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                    width: 220,
                  ),
                  _TextField(
                    controller: lastName,
                    label: 'Last Name',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                    width: 220,
                  ),
                  _TextField(
                    controller: email,
                    label: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final ok = RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                      ).hasMatch(v);
                      return ok ? null : 'Enter a valid email';
                    },
                    width: 300,
                  ),
                  _TextField(
                    controller: phone,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                    width: 200,
                  ),

                  _PickerField(
                    label: 'Check-in Date',
                    value: _fmtDate(checkIn),
                    onTap: onPickCheckIn,
                  ),
                  _PickerField(
                    label: 'Check-out Date',
                    value: _fmtDate(checkOut),
                    onTap: onPickCheckOut,
                  ),

                  _DropdownField<String>(
                    label: 'Room Type',
                    value: roomKey,
                    items: const [
                      DropdownMenuItem(
                        value: 'basic',
                        child: Text('Basic Room — PKR 8,000/night'),
                      ),
                      DropdownMenuItem(
                        value: 'superior',
                        child: Text('Superior Room — PKR 9,000/night'),
                      ),
                      DropdownMenuItem(
                        value: 'deluxe',
                        child: Text('Deluxe Room — PKR 10,000/night'),
                      ),
                      DropdownMenuItem(
                        value: 'executive',
                        child: Text('Executive Room — PKR 11,000/night'),
                      ),
                      DropdownMenuItem(
                        value: 'junior_suite',
                        child: Text('Junior Suite — PKR 11,500/night'),
                      ),
                      DropdownMenuItem(
                        value: 'family_suite',
                        child: Text('Family Suite — PKR 12,000/night'),
                      ),
                    ],
                    onChanged: (v) => onRoomChanged(v ?? roomKey),
                  ),

                  _DropdownField<int>(
                    label: 'Guests',
                    value: guests,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1')),
                      DropdownMenuItem(value: 2, child: Text('2')),
                      DropdownMenuItem(value: 3, child: Text('3')),
                      DropdownMenuItem(value: 4, child: Text('4')),
                      DropdownMenuItem(value: 5, child: Text('5')),
                      DropdownMenuItem(value: 6, child: Text('6+')),
                    ],
                    onChanged: (v) => onGuestsChanged(v ?? guests),
                  ),

                  _DropdownField<_Purpose>(
                    label: 'Purpose',
                    value: purpose,
                    items: const [
                      DropdownMenuItem(
                        value: _Purpose.business,
                        child: Text('Business Travel'),
                      ),
                      DropdownMenuItem(
                        value: _Purpose.leisure,
                        child: Text('Leisure / Vacation'),
                      ),
                      DropdownMenuItem(
                        value: _Purpose.event,
                        child: Text('Special Event'),
                      ),
                      DropdownMenuItem(
                        value: _Purpose.meeting,
                        child: Text('Conference / Meeting'),
                      ),
                      DropdownMenuItem(
                        value: _Purpose.wedding,
                        child: Text('Wedding'),
                      ),
                      DropdownMenuItem(
                        value: _Purpose.anniversary,
                        child: Text('Anniversary'),
                      ),
                      DropdownMenuItem(
                        value: _Purpose.other,
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (v) => onPurposeChanged(v ?? purpose),
                  ),

                  _TextArea(
                    controller: requests,
                    label: 'Special Requests / Preferences',
                    hint:
                        'Airport transfer, dietary requirements, room preferences, celebration arrangements, etc.',
                  ),
                ],
              ),

              const SizedBox(height: 10),
              _EstimatePill(nights: nights, totalPKR: estimatePKR),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGold,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: submitting ? null : onSubmit,
                  child: submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Reservation Request',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
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

/* --------------------------- Small Form Widgets ------------------------- */

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final double? width;
  const _TextField({
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      scrollPadding: const EdgeInsets.only(bottom: 120),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _brandGold, width: 2),
        ),
      ),
    );
    return width != null ? SizedBox(width: width, child: field) : field;
  }
}

class _TextArea extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  const _TextArea({required this.controller, required this.label, this.hint});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: 3,
      maxLines: 5,
      textInputAction: TextInputAction.newline,
      scrollPadding: const EdgeInsets.only(bottom: 140),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _brandGold, width: 2),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _brandGold, width: 2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 18),
              const SizedBox(width: 8),
              Text(value),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _brandGold, width: 2),
          ),
        ),
      ),
    );
  }
}

class _EstimatePill extends StatelessWidget {
  final int nights;
  final int totalPKR;
  const _EstimatePill({required this.nights, required this.totalPKR});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: _brandGold,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Estimated Total: ${_fmtPKR(totalPKR)} for $nights night${nights > 1 ? 's' : ''}',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
        ),
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
