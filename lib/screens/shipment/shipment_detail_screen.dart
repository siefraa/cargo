import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/models.dart';

class ShipmentDetailScreen extends StatelessWidget {
  final String shipmentId;
  const ShipmentDetailScreen({super.key, required this.shipmentId});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final s = prov.shipments.where((x) => x.id == shipmentId).firstOrNull
        ?? prov.completedShipments.where((x) => x.id == shipmentId).firstOrNull;

    if (s == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mzigo')),
        body: const Center(child: Text('Mzigo haukupatikana', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: CustomScrollView(
        slivers: [
          // Hero app bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.navyMid,
            actions: [
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                tooltip: 'Nakili namba',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: s.trackingNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Namba imenakiliwa!'),
                      backgroundColor: AppColors.statusCleared, behavior: SnackBarBehavior.floating));
                },
              ),
              PopupMenuButton<String>(
                color: AppColors.surfaceCard,
                itemBuilder: (_) => ShipmentStatus.values
                    .where((st) => st != s.status && st != ShipmentStatus.cancelled)
                    .map((st) => PopupMenuItem(
                  value: st.name,
                  child: Row(children: [
                    Text(st.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(st.label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  ]),
                )).toList(),
                onSelected: (v) {
                  final st = ShipmentStatus.values.byName(v);
                  prov.updateShipmentStatus(s.id, st);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Hali imebadilishwa: ${st.label}'),
                    backgroundColor: st.color, behavior: SnackBarBehavior.floating));
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.chinaRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.chinaRed.withOpacity(0.4)),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.edit_outlined, size: 14, color: AppColors.chinaRed),
                    SizedBox(width: 4),
                    Text('Badilisha Hali', style: TextStyle(color: AppColors.chinaRed, fontSize: 11, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppColors.navyMid, AppColors.navyLight],
                  ),
                ),
                child: Stack(children: [
                  Positioned(top: 0, left: 0, right: 0,
                    child: Container(height: 3, decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.chinaRed, AppColors.gold])))),
                  Positioned(bottom: 20, left: 20, right: 20, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: s.status.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: s.status.color.withOpacity(0.3)),
                          ),
                          child: Text(s.cargoType.emoji, style: const TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s.description,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(children: [
                            Text(s.trackingNumber,
                              style: const TextStyle(fontSize: 12, color: AppColors.gold,
                                fontWeight: FontWeight.w600, letterSpacing: 1)),
                            const SizedBox(width: 8),
                            Text('· ${s.mode.emoji} ${s.mode.label.split(" ").first}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ]),
                        ])),
                      ]),
                      const SizedBox(height: 12),
                      // Progress bar
                      Row(children: [
                        Expanded(child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: s.progressPercent,
                            backgroundColor: AppColors.navyLight,
                            valueColor: AlwaysStoppedAnimation(s.status.color),
                            minHeight: 5,
                          ),
                        )),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: s.status.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: s.status.color.withOpacity(0.3)),
                          ),
                          child: Text('${s.status.emoji} ${s.status.label}',
                            style: TextStyle(fontSize: 10, color: s.status.color, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    ],
                  )),
                ]),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Key info cards
                Row(children: [
                  _InfoBox('💰 Gharama', '\$${s.costUSD.toStringAsFixed(0)}', AppColors.gold),
                  const SizedBox(width: 10),
                  _InfoBox('⚖️ Uzito', '${s.weightKg.toStringAsFixed(0)} kg', AppColors.statusInTransit),
                  const SizedBox(width: 10),
                  _InfoBox('📦 CBM', s.volumeCbm.toStringAsFixed(2), AppColors.statusCleared),
                  const SizedBox(width: 10),
                  _InfoBox('🔢 Idadi', '${s.quantity}', AppColors.statusPending),
                ]),
                const SizedBox(height: 16),

                // Route card
                _Card(
                  child: Column(children: [
                    _SectionHeader('🗺️ Njia ya Safari'),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: Column(children: [
                        const Text('🇨🇳', style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(s.originCity, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                        const Text('China', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      ])),
                      Expanded(child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(Icons.arrow_forward, size: 10,
                              color: i < (s.progressPercent * 5).round()
                                  ? s.status.color : AppColors.textMuted),
                          ))),
                        const SizedBox(height: 4),
                        Text(s.mode.emoji, style: const TextStyle(fontSize: 16)),
                        Text('${s.daysRemaining} siku',
                          style: TextStyle(color: s.daysRemaining > 0 ? AppColors.gold : AppColors.statusCleared,
                            fontSize: 10, fontWeight: FontWeight.w700)),
                      ])),
                      Expanded(child: Column(children: [
                        Text('🌍', style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(s.destinationCity, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(s.destinationCountry, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      ])),
                    ]),
                    if (s.estimatedArrival != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.navyMid,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.calendar_today, size: 13, color: AppColors.gold),
                          const SizedBox(width: 6),
                          Text('Itafika tarehe: ${DateFormat('d MMM yyyy').format(s.estimatedArrival!)}',
                            style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: 12),

                // Shipment details
                _Card(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _SectionHeader('📋 Maelezo ya Mzigo'),
                    const SizedBox(height: 12),
                    if (s.supplierName?.isNotEmpty == true)
                      _DetailRow(Icons.factory_outlined, 'Muuzaji', s.supplierName!),
                    if (s.receiverName?.isNotEmpty == true)
                      _DetailRow(Icons.person_outline, 'Mpokeaji', s.receiverName!),
                    _DetailRow(Icons.category_outlined, 'Aina ya Bidhaa', '${s.cargoType.emoji} ${s.cargoType.label}'),
                    _DetailRow(Icons.calendar_today_outlined, 'Tarehe ya Kusajili',
                      DateFormat('d MMMM yyyy, HH:mm').format(s.createdAt)),
                    if (s.actualArrival != null)
                      _DetailRow(Icons.check_circle_outline, 'Ilifika',
                        DateFormat('d MMMM yyyy').format(s.actualArrival!), color: AppColors.statusCleared),
                    if (s.notes?.isNotEmpty == true)
                      _DetailRow(Icons.notes, 'Maelezo', s.notes!),
                  ]),
                ),
                const SizedBox(height: 12),

                // Tracking timeline
                _Card(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _SectionHeader('📍 Matukio ya Safari'),
                    const SizedBox(height: 12),
                    if (s.events.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Hakuna matukio bado', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      )
                    else
                      ...s.events.reversed.toList().asMap().entries.map((e) {
                        final idx = e.key;
                        final ev = e.value;
                        final isFirst = idx == 0;
                        return _TimelineEvent(event: ev, isFirst: isFirst, isLast: idx == s.events.length - 1);
                      }),
                  ]),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _InfoBox(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
      ]),
    ),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF1E3A5F)),
    ),
    child: child,
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Text(title,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5));
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? color;
  const _DetailRow(this.icon, this.label, this.value, {this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: AppColors.textMuted),
      const SizedBox(width: 10),
      SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
      Expanded(child: Text(value,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary))),
    ]),
  );
}

class _TimelineEvent extends StatelessWidget {
  final TrackingEvent event;
  final bool isFirst, isLast;
  const _TimelineEvent({required this.event, required this.isFirst, required this.isLast});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFirst ? AppColors.chinaRed : AppColors.navyLight,
            border: Border.all(color: isFirst ? AppColors.chinaRed : AppColors.textMuted, width: 2),
          ),
        ),
        if (!isLast)
          Container(width: 2, height: 40, color: const Color(0xFF1E3A5F)),
      ]),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(event.description,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: isFirst ? AppColors.textPrimary : AppColors.textSecondary))),
            ]),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 10, color: AppColors.textMuted),
              const SizedBox(width: 3),
              Text(event.location, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              const Spacer(),
              Text(DateFormat('d MMM, HH:mm').format(event.time),
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ]),
          ]),
        ),
      ),
    ],
  );
}
