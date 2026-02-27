import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/models.dart';
import '../auth/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final user = prov.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            expandedHeight: 220,
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
                child: Stack(children: [
                  Positioned(top: 0, left: 0, right: 0,
                    child: Container(height: 3, decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.chinaRed, AppColors.gold])))),
                  Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const SizedBox(height: 50),
                    // Avatar
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.chinaRed, Color(0xFF8B0000)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 3),
                        boxShadow: [BoxShadow(color: AppColors.chinaRed.withOpacity(0.4), blurRadius: 20)],
                      ),
                      child: Center(child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                      )),
                    ),
                    const SizedBox(height: 10),
                    Text(user.name, style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    if (user.company.isNotEmpty)
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.business_outlined, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(user.company, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('🌍', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text('${user.city}, ${user.country}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ]),
                  ])),
                ]),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                onPressed: () => _showEditDialog(context, prov, user),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Stats
                Row(children: [
                  _StatBox('${prov.totalShipments}', 'Mizigo Yote', AppColors.cargo, Icons.all_inbox_rounded),
                  const SizedBox(width: 10),
                  _StatBox('${prov.activeShipments.length}', 'Inayoendelea', AppColors.statusInTransit, Icons.directions_boat),
                  const SizedBox(width: 10),
                  _StatBox('${prov.completedShipments.length}', 'Zilizofika', AppColors.statusCleared, Icons.check_circle_outline),
                  const SizedBox(width: 10),
                  _StatBox('\$${prov.totalSpentUSD.toStringAsFixed(0)}', 'Jumla', AppColors.gold, Icons.attach_money),
                ]),
                const SizedBox(height: 20),

                // Account info section
                _SectionTitle('Taarifa za Akaunti'),
                const SizedBox(height: 10),
                _InfoCard(children: [
                  _InfoRow(Icons.person_outline, 'Jina Kamili', user.name),
                  _InfoRow(Icons.email_outlined, 'Barua Pepe', user.email),
                  if (user.phone.isNotEmpty) _InfoRow(Icons.phone_outlined, 'Simu', user.phone),
                  if (user.company.isNotEmpty) _InfoRow(Icons.business_outlined, 'Kampuni', user.company),
                  _InfoRow(Icons.location_on_outlined, 'Mahali', '${user.city}, ${user.country}'),
                ]),
                const SizedBox(height: 20),

                // Shipping summary
                _SectionTitle('Muhtasari wa Mizigo'),
                const SizedBox(height: 10),
                _ShippingModeSummary(prov: prov),
                const SizedBox(height: 20),

                // App info
                _SectionTitle('Programu'),
                const SizedBox(height: 10),
                _InfoCard(children: [
                  _InfoRow(Icons.info_outline, 'Toleo', 'China Freight v1.0'),
                  _InfoRow(Icons.language, 'Lugha', 'Kiswahili'),
                  _InfoRow(Icons.support_agent, 'Msaada', '+86 400-XXX-XXXX'),
                  _InfoRow(Icons.email, 'Barua', 'support@chinafreight.co'),
                ]),
                const SizedBox(height: 20),

                // Contacts
                _SectionTitle('Wasiliana Nasi'),
                const SizedBox(height: 10),
                Row(children: [
                  _ContactCard('🇨🇳', 'China\nOfisi', '+86 20-XXXX'),
                  const SizedBox(width: 10),
                  _ContactCard('🇰🇪', 'Kenya\nMombasa', '+254 700 XXX'),
                  const SizedBox(width: 10),
                  _ContactCard('📱', 'WhatsApp\nBusiness', 'Chat sasa'),
                ]),
                const SizedBox(height: 20),

                // Logout
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, prov),
                    icon: const Icon(Icons.logout, color: AppColors.chinaRed),
                    label: const Text('Toka kwenye Akaunti',
                      style: TextStyle(color: AppColors.chinaRed, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.chinaRed.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Flag decoration
                const Center(child: Column(children: [
                  Text('🇨🇳 ✈️ 🚢 🌍', style: TextStyle(fontSize: 20, letterSpacing: 4)),
                  SizedBox(height: 6),
                  Text('China → Dunia · Kwa Usalama na Haraka',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted, letterSpacing: 0.5)),
                ])),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext ctx, AppProvider prov) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      title: const Text('Toka', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('Una uhakika unataka kutoka?', style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text('Hapana', style: TextStyle(color: AppColors.textMuted))),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await prov.logout();
            if (ctx.mounted) Navigator.pushAndRemoveUntil(ctx,
              MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.chinaRed),
          child: const Text('Ndiyo, Toka'),
        ),
      ],
    ));
  }

  void _showEditDialog(BuildContext ctx, AppProvider prov, AppUser user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final companyCtrl = TextEditingController(text: user.company);
    final cityCtrl = TextEditingController(text: user.city);
    final countryCtrl = TextEditingController(text: user.country);

    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      title: const Text('Hariri Taarifa', style: TextStyle(color: AppColors.textPrimary)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _EditField(nameCtrl, 'Jina Kamili'),
          const SizedBox(height: 10),
          _EditField(phoneCtrl, 'Simu'),
          const SizedBox(height: 10),
          _EditField(companyCtrl, 'Kampuni'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _EditField(cityCtrl, 'Mji')),
            const SizedBox(width: 8),
            Expanded(child: _EditField(countryCtrl, 'Nchi')),
          ]),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text('Ghairi', style: TextStyle(color: AppColors.textMuted))),
        ElevatedButton(
          onPressed: () async {
            final updated = AppUser(
              id: user.id, email: user.email, joinedAt: user.joinedAt,
              name: nameCtrl.text.trim(), phone: phoneCtrl.text.trim(),
              company: companyCtrl.text.trim(), city: cityCtrl.text.trim(),
              country: countryCtrl.text.trim(),
            );
            await prov.updateProfile(updated);
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text('Hifadhi'),
        ),
      ],
    ));
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color;
  final IconData icon;
  const _StatBox(this.value, this.label, this.color, this.icon);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textMuted, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1));
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF1E3A5F)),
    ),
    child: Column(children: children),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label, value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, size: 15, color: AppColors.textMuted),
      const SizedBox(width: 10),
      SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
    ]),
  );
}

class _ShippingModeSummary extends StatelessWidget {
  final AppProvider prov;
  const _ShippingModeSummary({required this.prov});
  @override
  Widget build(BuildContext context) {
    final all = [...prov.shipments, ...prov.completedShipments];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Row(children: ShippingMode.values.map((m) {
        final count = all.where((s) => s.mode == m).length;
        return Expanded(child: Column(children: [
          Text(m.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text('$count', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          Text(m.label.split(' ').first, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        ]));
      }).toList()),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String emoji, label, value;
  const _ContactCard(this.emoji, this.label, this.value);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, color: AppColors.textMuted, height: 1.3)),
        Text(value, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, color: AppColors.gold, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class _EditField extends StatelessWidget {
  final TextEditingController ctrl; final String label;
  const _EditField(this.ctrl, this.label);
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
  );
}
