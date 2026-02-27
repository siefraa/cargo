import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/models.dart';
import '../shipment/shipment_detail_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});
  @override State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _ctrl = TextEditingController();
  Shipment? _found;
  bool _searched = false;

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _search(AppProvider prov) {
    final q = _ctrl.text.trim().toUpperCase();
    if (q.isEmpty) return;
    setState(() {
      _searched = true;
      final all = [...prov.shipments, ...prov.completedShipments];
      _found = all.cast<Shipment?>().firstWhere(
        (s) => s!.trackingNumber.toUpperCase() == q ||
               s.trackingNumber.toUpperCase().contains(q),
        orElse: () => null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Fuatilia Mzigo')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search area
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.navyMid, AppColors.navyLight],
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Fuatilia kwa Namba', style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontFamily: 'Georgia')),
                const SizedBox(height: 4),
                const Text('Ingiza namba ya ufuatiliaji (Tracking Number)',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, letterSpacing: 1),
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _search(prov),
                      decoration: InputDecoration(
                        hintText: 'mfano: CS202401001',
                        hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 0.5),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                        suffixIcon: _ctrl.text.isNotEmpty
                            ? IconButton(icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                                onPressed: () { _ctrl.clear(); setState(() { _found = null; _searched = false; }); })
                            : null,
                        filled: true,
                        fillColor: AppColors.navy,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.chinaRed, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _search(prov),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.chinaRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      child: const Text('Tafuta', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ]),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Search result
                if (_searched)
                  _found != null
                      ? _TrackingResult(shipment: _found!)
                      : _NotFound(query: _ctrl.text),

                if (!_searched || _found != null) ...[
                  const SizedBox(height: 20),
                  // All active shipments
                  if (prov.activeShipments.isNotEmpty) ...[
                    const Text('Mizigo Inayoendelea', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary, letterSpacing: 1)),
                    const SizedBox(height: 10),
                    ...prov.activeShipments.map((s) => _ActiveShipmentTile(shipment: s)),
                  ],

                  // Status guide
                  const SizedBox(height: 20),
                  const Text('Maana ya Hali', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  _StatusGuide(),
                ],
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingResult extends StatelessWidget {
  final Shipment shipment;
  const _TrackingResult({required this.shipment});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: shipment.status.color.withOpacity(0.4)),
        ),
        child: Column(children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: shipment.status.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(shipment.cargoType.emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(shipment.description,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(shipment.trackingNumber,
                style: const TextStyle(fontSize: 11, color: AppColors.gold, letterSpacing: 1, fontWeight: FontWeight.w600)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: shipment.status.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: shipment.status.color.withOpacity(0.3)),
              ),
              child: Text('${shipment.status.emoji} ${shipment.status.label}',
                style: TextStyle(fontSize: 10, color: shipment.status.color, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 14),
          // Progress steps
          _ProgressSteps(status: shipment.status),
          const SizedBox(height: 14),
          // Route
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🇨🇳 Kutoka', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text(shipment.originCity, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
            ]),
            const Icon(Icons.arrow_forward, color: AppColors.textMuted, size: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('🌍 Kwenda', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('${shipment.destinationCity}, ${shipment.destinationCountry}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
            ]),
          ]),
          if (shipment.estimatedArrival != null && shipment.status != ShipmentStatus.delivered) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gold.withOpacity(0.2)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.schedule, size: 12, color: AppColors.gold),
                const SizedBox(width: 6),
                Text('Inatarajiwa: ${DateFormat('d MMMM yyyy').format(shipment.estimatedArrival!)} · ${shipment.daysRemaining} siku',
                  style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ShipmentDetailScreen(shipmentId: shipment.id))),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.chinaRed,
                side: const BorderSide(color: AppColors.chinaRed),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Maelezo Kamili', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),

      // Latest events
      if (shipment.events.isNotEmpty) ...[
        const SizedBox(height: 16),
        const Text('Matukio ya Hivi Karibuni', style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 10),
        ...shipment.events.reversed.take(3).map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1E3A5F)),
          ),
          child: Row(children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: shipment.status.color),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('📍 ${e.location} · ${DateFormat('d MMM, HH:mm').format(e.time)}',
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ])),
          ]),
        )),
      ],
    ]);
  }
}

class _ProgressSteps extends StatelessWidget {
  final ShipmentStatus status;
  const _ProgressSteps({required this.status});

  static const _steps = [
    ShipmentStatus.pending,
    ShipmentStatus.pickedUp,
    ShipmentStatus.inTransit,
    ShipmentStatus.customsClearing,
    ShipmentStatus.cleared,
    ShipmentStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _steps.indexOf(status);
    return Row(
      children: _steps.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final done = currentIdx >= i;
        final current = currentIdx == i;
        return Expanded(child: Row(children: [
          Expanded(child: Column(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: current ? 28 : 20,
              height: current ? 28 : 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? s.color.withOpacity(0.2) : AppColors.navyLight,
                border: Border.all(
                  color: done ? s.color : AppColors.navyLight,
                  width: current ? 2 : 1,
                ),
                boxShadow: current ? [BoxShadow(color: s.color.withOpacity(0.4), blurRadius: 8)] : null,
              ),
              child: Center(child: Text(s.emoji, style: TextStyle(fontSize: current ? 12 : 9))),
            ),
            const SizedBox(height: 3),
            Text(s.label, style: TextStyle(
              fontSize: 7, fontWeight: FontWeight.w600,
              color: done ? s.color : AppColors.textMuted),
              textAlign: TextAlign.center),
          ])),
          if (i < _steps.length - 1)
            Expanded(child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 14),
              color: currentIdx > i ? _steps[i + 1].color.withOpacity(0.5) : AppColors.navyLight,
            )),
        ]));
      }).toList(),
    );
  }
}

class _NotFound extends StatelessWidget {
  final String query;
  const _NotFound({required this.query});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.chinaRed.withOpacity(0.3)),
    ),
    child: Column(children: [
      const Text('🔍', style: TextStyle(fontSize: 40)),
      const SizedBox(height: 10),
      Text('Namba "$query" haikupatikana', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      const Text('Hakikisha namba ni sahihi', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
    ]),
  );
}

class _ActiveShipmentTile extends StatelessWidget {
  final Shipment shipment;
  const _ActiveShipmentTile({required this.shipment});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(
      builder: (_) => ShipmentDetailScreen(shipmentId: shipment.id))),
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Row(children: [
        Text(shipment.cargoType.emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(shipment.description,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(shipment.trackingNumber,
            style: const TextStyle(fontSize: 10, color: AppColors.gold, letterSpacing: 0.5)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: shipment.status.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${shipment.status.emoji} ${shipment.status.label}',
              style: TextStyle(fontSize: 9, color: shipment.status.color, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 3),
          if (shipment.daysRemaining > 0)
            Text('${shipment.daysRemaining} siku', style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        ]),
      ]),
    ),
  );
}

class _StatusGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF1E3A5F)),
    ),
    child: Column(
      children: ShipmentStatus.values.map((s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: s.color.withOpacity(0.12),
            ),
            child: Center(child: Text(s.emoji, style: const TextStyle(fontSize: 13))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(s.label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: s.color))),
          Text(_desc(s), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ]),
      )).toList(),
    ),
  );

  String _desc(ShipmentStatus s) {
    switch (s) {
      case ShipmentStatus.pending:          return 'Inasubiri uthibitisho';
      case ShipmentStatus.confirmed:        return 'Imethibitishwa';
      case ShipmentStatus.pickedUp:         return 'Imechukuliwa China';
      case ShipmentStatus.inTransit:        return 'Njiani baharini/angani';
      case ShipmentStatus.customsClearing:  return 'Forodhani - inachunguzwa';
      case ShipmentStatus.cleared:          return 'Imepita forodha';
      case ShipmentStatus.outForDelivery:   return 'Gari linakuja';
      case ShipmentStatus.delivered:        return 'Imefikia salama';
      case ShipmentStatus.held:             return 'Imesimamishwa';
      case ShipmentStatus.cancelled:        return 'Imefutwa';
    }
  }
}
