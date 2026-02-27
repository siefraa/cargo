import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/models.dart';
import '../shipment/shipment_list_screen.dart';
import '../shipment/new_shipment_screen.dart';
import '../shipment/shipment_detail_screen.dart';
import '../tracking/tracking_screen.dart';
import '../quotes/quote_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _DashboardPage(),
      const ShipmentListScreen(),
      const TrackingScreen(),
      const QuoteScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        height: 62,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Nyumbani'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Mizigo'),
          NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: 'Fuatilia'),
          NavigationDestination(icon: Icon(Icons.request_quote_outlined), selectedIcon: Icon(Icons.request_quote), label: 'Bei'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Akaunti'),
        ],
      ),
    );
  }
}

// ── DASHBOARD ──
class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: CustomScrollView(
        slivers: [
          // ── App bar with greeting ──
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.navyMid,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppColors.navyMid, AppColors.navyLight],
                  ),
                ),
                child: Stack(
                  children: [
                    // Red top accent
                    Positioned(top: 0, left: 0, right: 0,
                      child: Container(height: 3,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.chinaRed, AppColors.gold]),
                        ))),
                    // Content
                    Positioned(bottom: 20, left: 20, right: 20,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.chinaRed,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: AppColors.chinaRed.withOpacity(0.4), blurRadius: 12)],
                            ),
                            child: const Center(child: Text('🚢', style: TextStyle(fontSize: 22))),
                          ),
                          const SizedBox(width: 12),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Habari, ${prov.user?.name.split(' ').first ?? ""}! 👋',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            Text(prov.user?.company.isNotEmpty == true ? prov.user!.company : 'SJ TRACKING SOLUTION',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ]),
                          const Spacer(),
                          // China flag badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.chinaRed.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.chinaRed.withOpacity(0.4)),
                            ),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Text('🇨🇳', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 4),
                              Text('→', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              SizedBox(width: 4),
                              Text('🌍', style: TextStyle(fontSize: 14)),
                            ]),
                          ),
                        ]),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats row ──
                  Row(children: [
                    Expanded(child: _StatCard('${prov.totalShipments}', 'Mizigo Yote', Icons.all_inbox_rounded, AppColors.cargo)),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard('${prov.inTransitCount}', 'Njiani', Icons.directions_boat, AppColors.statusInTransit)),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard('${prov.customsCount}', 'Forodha', Icons.gavel, AppColors.statusPending)),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard('\$${prov.totalSpentUSD.toStringAsFixed(0)}', 'Jumla', Icons.attach_money, AppColors.gold)),
                  ]),
                  const SizedBox(height: 20),

                  // ── Quick actions ──
                  const Text('Hatua za Haraka', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Row(children: [
                    _QuickAction('📦', 'Ongeza\nMzigo', AppColors.chinaRed, () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NewShipmentScreen()))),
                    const SizedBox(width: 10),
                    _QuickAction('🔍', 'Fuatilia\nMzigo', AppColors.statusInTransit, () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const TrackingScreen()))),
                    const SizedBox(width: 10),
                    _QuickAction('💰', 'Omba\nBei', AppColors.gold, () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const QuoteScreen()))),
                    const SizedBox(width: 10),
                    _QuickAction('📊', 'Ripoti\nYangu', AppColors.statusDelivered, () {}),
                  ]),
                  const SizedBox(height: 20),

                  // ── Active shipments ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mizigo Inayoendelea', style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ona Yote →', style: TextStyle(color: AppColors.chinaRed, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (prov.activeShipments.isEmpty)
                    _EmptyState()
                  else
                    ...prov.activeShipments.take(3).map((s) => _ShipmentCard(shipment: s)),

                  // ── Shipping modes ──
                  const SizedBox(height: 20),
                  const Text('Njia za Usafirishaji', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Row(children: ShippingMode.values.map((m) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _ModeCard(mode: m),
                    ),
                  )).toList()),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewShipmentScreen())),
        backgroundColor: AppColors.chinaRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ongeza Mzigo', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(this.emoji, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, height: 1.2)),
          ]),
        ),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final Shipment shipment;
  const _ShipmentCard({required this.shipment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => ShipmentDetailScreen(shipmentId: shipment.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E3A5F)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: shipment.status.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(shipment.cargoType.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(shipment.description,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${shipment.trackingNumber} · ${shipment.mode.emoji} ${shipment.mode.label.split(' ').first}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: shipment.progressPercent,
              backgroundColor: AppColors.navyLight,
              valueColor: AlwaysStoppedAnimation(shipment.status.color),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textMuted),
            const SizedBox(width: 3),
            Text('${shipment.originCity} → ${shipment.destinationCity}',
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            const Spacer(),
            if (shipment.daysRemaining > 0)
              Row(children: [
                const Icon(Icons.schedule, size: 11, color: AppColors.gold),
                const SizedBox(width: 3),
                Text('${shipment.daysRemaining} siku', style: const TextStyle(fontSize: 10, color: AppColors.gold)),
              ]),
          ]),
        ]),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final ShippingMode mode;
  const _ModeCard({required this.mode});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(mode.emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(mode.label.split(' ').first, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        Text('${mode.daysMin}-${mode.daysMax}d', style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(children: [
        const Text('🚢', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        const Text('Hakuna mizigo inayoendelea', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('Ongeza mzigo wako wa kwanza kutoka China', style: TextStyle(color: AppColors.textMuted, fontSize: 12), textAlign: TextAlign.center),
      ]),
    );
  }
}
