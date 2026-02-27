import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/models.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});
  @override State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bei ya Usafirishaji'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.chinaRed,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.chinaRed,
          dividerColor: Colors.transparent,
          tabs: const [Tab(text: '🧮 Hesabu Bei'), Tab(text: '📋 Maombi Yangu')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_CalculatorTab(tabs: _tabs), const _QuoteHistoryTab()],
      ),
    );
  }
}

class _CalculatorTab extends StatefulWidget {
  final TabController tabs;
  const _CalculatorTab({required this.tabs});
  @override State<_CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<_CalculatorTab> {
  final _weight = TextEditingController();
  final _volume = TextEditingController();
  final _dest = TextEditingController();
  final _destCountry = TextEditingController(text: 'Kenya');
  final _qty = TextEditingController(text: '1');
  CargoType _cargo = CargoType.electronics;
  String _origin = 'Guangzhou';
  bool _calculated = false;
  bool _busy = false;

  static const _origins = ['Guangzhou', 'Shenzhen', 'Shanghai', 'Yiwu', 'Ningbo', 'Foshan'];

  @override void dispose() { _weight.dispose(); _volume.dispose(); _dest.dispose(); _destCountry.dispose(); _qty.dispose(); super.dispose(); }

  double _cost(ShippingMode m) {
    final w = double.tryParse(_weight.text) ?? 0;
    final v = double.tryParse(_volume.text) ?? 0;
    const rates = {ShippingMode.sea: 3.5, ShippingMode.air: 8.0, ShippingMode.express: 15.0, ShippingMode.rail: 5.0};
    final chargeable = v * 167 > w ? v * 167 : w;
    return (chargeable * (rates[m] ?? 3.5) + 120).clamp(120, 99999);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Intro banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A3E), Color(0xFF0A1628)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          ),
          child: Row(children: [
            const Text('💰', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Hesabu Bei Mara Moja', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('Weka uzito na ujazo kupata bei ya tahmini ya njia zote',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4)),
            ])),
          ]),
        ),
        const SizedBox(height: 20),

        // Inputs
        _Label('Aina ya Bidhaa'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: CargoType.values.map((c) => GestureDetector(
              onTap: () => setState(() => _cargo = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _cargo == c ? AppColors.chinaRed.withOpacity(0.15) : AppColors.navyMid,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _cargo == c ? AppColors.chinaRed : const Color(0xFF1E3A5F)),
                ),
                child: Column(children: [
                  Text(c.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(c.label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                    color: _cargo == c ? AppColors.chinaRed : AppColors.textMuted)),
                ]),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),

        Row(children: [
          Expanded(child: _InputField(_weight, 'Uzito (kg)', Icons.scale_outlined, onChanged: (_) => setState(() => _calculated = false))),
          const SizedBox(width: 12),
          Expanded(child: _InputField(_volume, 'Ujazo (CBM)', Icons.view_in_ar_outlined, onChanged: (_) => setState(() => _calculated = false))),
          const SizedBox(width: 12),
          Expanded(child: _InputField(_qty, 'Idadi', Icons.numbers)),
        ]),
        const SizedBox(height: 14),

        _Label('Mji wa Asili'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _origins.map((o) => GestureDetector(
            onTap: () => setState(() => _origin = o),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _origin == o ? AppColors.gold.withOpacity(0.1) : AppColors.navyMid,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _origin == o ? AppColors.gold : const Color(0xFF1E3A5F)),
              ),
              child: Text(o, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: _origin == o ? AppColors.gold : AppColors.textSecondary)),
            ),
          )).toList()),
        ),
        const SizedBox(height: 14),

        Row(children: [
          Expanded(child: _InputField(_dest, 'Mji wa Kufika', Icons.location_on_outlined)),
          const SizedBox(width: 12),
          Expanded(child: _InputField(_destCountry, 'Nchi', Icons.flag_outlined)),
        ]),
        const SizedBox(height: 20),

        // Calculate button
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_weight.text.isEmpty && _volume.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Weka uzito au ujazo wa bidhaa'),
                  backgroundColor: AppColors.chinaRed, behavior: SnackBarBehavior.floating));
                return;
              }
              setState(() => _calculated = true);
            },
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('HESABU BEI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
        ),

        // Results
        if (_calculated) ...[
          const SizedBox(height: 20),
          const Text('Matokeo ya Bei', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
          const SizedBox(height: 10),
          ...ShippingMode.values.map((m) => _QuoteResultCard(
            mode: m, cost: _cost(m),
            onAccept: () async {
              setState(() => _busy = true);
              await prov.addQuote(
                cargoType: _cargo, mode: m,
                weightKg: double.tryParse(_weight.text) ?? 0,
                volumeCbm: double.tryParse(_volume.text) ?? 0,
                quantity: int.tryParse(_qty.text) ?? 1,
                originCity: _origin,
                destinationCity: _dest.text.trim().isEmpty ? 'Nairobi' : _dest.text.trim(),
                destinationCountry: _destCountry.text.trim().isEmpty ? 'Kenya' : _destCountry.text.trim(),
              );
              setState(() => _busy = false);
              widget.tabs.animateTo(1);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('✅ Ombi la bei limehifadhiwa!'),
                backgroundColor: AppColors.statusCleared, behavior: SnackBarBehavior.floating));
            },
          )),
          // Notes
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.navyMid,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold.withOpacity(0.2)),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.info_outline, size: 13, color: AppColors.gold),
                SizedBox(width: 6),
                Text('Maelezo', style: TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w700)),
              ]),
              SizedBox(height: 6),
              Text('• Bei ni tahmini pekee — inaweza kubadilika\n• Uzito wa awamu (chargeable weight) unahesabiwa\n• Gharama za forodha na VAT hazijaingizwa\n• Wasiliana nasi kwa bei kamili',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted, height: 1.6)),
            ]),
          ),
        ],
        const SizedBox(height: 40),
      ]),
    );
  }
}

class _QuoteResultCard extends StatelessWidget {
  final ShippingMode mode;
  final double cost;
  final VoidCallback onAccept;

  const _QuoteResultCard({required this.mode, required this.cost, required this.onAccept});

  Color get _color {
    switch (mode) {
      case ShippingMode.sea:     return AppColors.statusInTransit;
      case ShippingMode.air:     return AppColors.statusCleared;
      case ShippingMode.express: return AppColors.chinaRed;
      case ShippingMode.rail:    return AppColors.statusPending;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _color.withOpacity(0.3)),
    ),
    child: Row(children: [
      Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: _color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _color.withOpacity(0.2)),
        ),
        child: Center(child: Text(mode.emoji, style: const TextStyle(fontSize: 24))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(mode.label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
        const SizedBox(height: 2),
        Row(children: [
          Icon(Icons.schedule, size: 11, color: _color),
          const SizedBox(width: 3),
          Text('${mode.daysMin}–${mode.daysMax} siku',
            style: TextStyle(fontSize: 10, color: _color, fontWeight: FontWeight.w600)),
        ]),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('\$${cost.toStringAsFixed(0)}', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w900, color: _color, fontFamily: 'Georgia')),
        const Text('USD', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onAccept,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _color.withOpacity(0.3)),
            ),
            child: Text('Omba', style: TextStyle(fontSize: 10, color: _color, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    ]),
  );
}

class _QuoteHistoryTab extends StatelessWidget {
  const _QuoteHistoryTab();
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final quotes = prov.quotes;
    if (quotes.isEmpty) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('💰', style: TextStyle(fontSize: 52)),
        SizedBox(height: 12),
        Text('Hakuna maombi ya bei bado', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        Text('Hesabu bei kwanza kwenye kichupo cha juu', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotes.length,
      itemBuilder: (_, i) {
        final q = quotes[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E3A5F)),
          ),
          child: Row(children: [
            Text(q.cargoType.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(q.cargoType.label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
              Text('${q.mode.emoji} ${q.mode.label} · ${q.originCity} → ${q.destinationCity}',
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('${q.weightKg.toStringAsFixed(0)}kg | ${q.volumeCbm.toStringAsFixed(2)}CBM',
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('\$${q.estimatedCost?.toStringAsFixed(0) ?? "—"}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusCleared.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(q.status == 'received' ? '✅ Imepokelewa' : q.status,
                  style: const TextStyle(fontSize: 9, color: AppColors.statusCleared, fontWeight: FontWeight.w700)),
              ),
            ]),
          ]),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5));
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final void Function(String)? onChanged;

  const _InputField(this.ctrl, this.label, this.icon, {this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: TextInputType.number,
    onChanged: onChanged,
    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    ),
  );
}
