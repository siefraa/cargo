import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/models.dart';
import 'new_shipment_screen.dart';
import 'shipment_detail_screen.dart';
import 'package:intl/intl.dart';

class ShipmentListScreen extends StatefulWidget {
  const ShipmentListScreen({super.key});
  @override State<ShipmentListScreen> createState() => _ShipmentListState();
}

class _ShipmentListState extends State<ShipmentListScreen> with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late TabController _tabs;
  @override void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); }
  @override void dispose() { _searchCtrl.dispose(); _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mizigo Yangu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.navyMid,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1E3A5F)),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: prov.setSearch,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Tafuta kwa namba, jina, mji...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                            onPressed: () { _searchCtrl.clear(); prov.setSearch(''); })
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    fillColor: Colors.transparent, filled: false,
                  ),
                ),
              ),
            ),
            TabBar(
              controller: _tabs,
              labelColor: AppColors.chinaRed,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.chinaRed,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Yote'),
                Tab(text: 'Inayoendelea'),
                Tab(text: 'Zilizofika'),
              ],
            ),
          ]),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ShipmentTab(shipments: prov.shipments),
          _ShipmentTab(shipments: prov.activeShipments),
          _ShipmentTab(shipments: prov.completedShipments),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewShipmentScreen())),
        backgroundColor: AppColors.chinaRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Mzigo Mpya', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ShipmentTab extends StatelessWidget {
  final List<Shipment> shipments;
  const _ShipmentTab({required this.shipments});

  @override
  Widget build(BuildContext context) {
    if (shipments.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('📦', style: TextStyle(fontSize: 52)),
          SizedBox(height: 12),
          Text('Hakuna mizigo', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Text('Ongeza mzigo wako wa kwanza', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: shipments.length,
      itemBuilder: (_, i) => _FullShipmentCard(shipment: shipments[i]),
    );
  }
}

class _FullShipmentCard extends StatelessWidget {
  final Shipment shipment;
  const _FullShipmentCard({required this.shipment});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AppProvider>();
    final fmt = DateFormat('d MMM yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ShipmentDetailScreen(shipmentId: shipment.id))),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(shipment.cargoType.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(shipment.description,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(shipment.trackingNumber,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.5)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: shipment.status.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: shipment.status.color.withOpacity(0.3)),
                      ),
                      child: Text('${shipment.status.emoji} ${shipment.status.label}',
                        style: TextStyle(fontSize: 10, color: shipment.status.color, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 4),
                    Text('\$${shipment.costUSD.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w800)),
                  ]),
                ]),
                const SizedBox(height: 10),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: shipment.progressPercent,
                    backgroundColor: AppColors.navyLight,
                    valueColor: AlwaysStoppedAnimation(shipment.status.color),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 10),
                // Info row
                Row(children: [
                  _InfoChip(Icons.location_on_outlined, '${shipment.originCity} → ${shipment.destinationCity}'),
                  const Spacer(),
                  _InfoChip(Icons.scale_outlined, '${shipment.weightKg.toStringAsFixed(0)}kg'),
                  const SizedBox(width: 8),
                  if (shipment.estimatedArrival != null && shipment.status != ShipmentStatus.delivered)
                    _InfoChip(Icons.calendar_today_outlined, fmt.format(shipment.estimatedArrival!), color: AppColors.gold),
                ]),
              ]),
            ),
          ),
          // Actions
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1E3A5F))),
            ),
            child: Row(children: [
              _CardAction(Icons.location_on_outlined, 'Fuatilia', AppColors.statusInTransit,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ShipmentDetailScreen(shipmentId: shipment.id)))),
              _CardDivider(),
              _CardAction(Icons.edit_outlined, 'Hariri', AppColors.textSecondary,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ShipmentDetailScreen(shipmentId: shipment.id)))),
              _CardDivider(),
              _CardAction(Icons.delete_outline, 'Futa', AppColors.chinaRed,
                () => showDialog(context: context, builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surfaceCard,
                  title: const Text('Futa Mzigo', style: TextStyle(color: AppColors.textPrimary)),
                  content: Text('Futa ${shipment.trackingNumber}?',
                    style: const TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hapana')),
                    ElevatedButton(
                      onPressed: () { Navigator.pop(context); prov.deleteShipment(shipment.id); },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.chinaRed),
                      child: const Text('Futa'),
                    ),
                  ],
                ))),
            ]),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String label; final Color? color;
  const _InfoChip(this.icon, this.label, {this.color});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: color ?? AppColors.textMuted),
    const SizedBox(width: 3),
    Text(label, style: TextStyle(fontSize: 10, color: color ?? AppColors.textMuted)),
  ]);
}

class _CardAction extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _CardAction(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    ),
  );
}

class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    Container(width: 1, height: 30, color: const Color(0xFF1E3A5F));
}
