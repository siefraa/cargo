import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/models.dart';

class NewShipmentScreen extends StatefulWidget {
  const NewShipmentScreen({super.key});
  @override State<NewShipmentScreen> createState() => _NewShipmentState();
}

class _NewShipmentState extends State<NewShipmentScreen> {
  final _form = GlobalKey<FormState>();
  final _desc = TextEditingController();
  final _supplier = TextEditingController();
  final _receiver = TextEditingController();
  final _origin = TextEditingController(text: 'Guangzhou');
  final _dest = TextEditingController();
  final _destCountry = TextEditingController();
  final _weight = TextEditingController();
  final _volume = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _notes = TextEditingController();

  CargoType _cargo = CargoType.electronics;
  ShippingMode _mode = ShippingMode.sea;
  bool _busy = false;
  int _step = 0;

  static const _origins = ['Guangzhou', 'Shenzhen', 'Shanghai', 'Yiwu', 'Ningbo', 'Beijing', 'Hangzhou', 'Foshan'];

  @override void dispose() {
    for (final c in [_desc,_supplier,_receiver,_origin,_dest,_destCountry,_weight,_volume,_qty,_notes]) c.dispose();
    super.dispose();
  }

  double get _estimatedCost {
    final w = double.tryParse(_weight.text) ?? 0;
    final v = double.tryParse(_volume.text) ?? 0;
    const rates = {ShippingMode.sea:3.5, ShippingMode.air:8.0, ShippingMode.express:15.0, ShippingMode.rail:5.0};
    final chargeable = v * 167 > w ? v * 167 : w;
    return chargeable * (rates[_mode] ?? 3.5) + 120;
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    await context.read<AppProvider>().addShipment(
      description: _desc.text.trim(),
      cargoType: _cargo, mode: _mode,
      weightKg: double.tryParse(_weight.text) ?? 0,
      volumeCbm: double.tryParse(_volume.text) ?? 0,
      quantity: int.tryParse(_qty.text) ?? 1,
      originCity: _origin.text.trim(),
      destinationCity: _dest.text.trim(),
      destinationCountry: _destCountry.text.trim(),
      supplierName: _supplier.text.trim().isEmpty ? null : _supplier.text.trim(),
      receiverName: _receiver.text.trim().isEmpty ? null : _receiver.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    setState(() => _busy = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Mzigo wako umesajiliwa kikamilifu!'),
          backgroundColor: AppColors.statusCleared, behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongeza Mzigo Mpya'),
        actions: [
          if (!_busy)
            TextButton(
              onPressed: _step < 2 ? () => setState(() => _step++) : _submit,
              child: Text(_step < 2 ? 'Mbele →' : 'Hifadhi',
                style: const TextStyle(color: AppColors.chinaRed, fontWeight: FontWeight.w800)),
            ),
        ],
      ),
      body: Form(
        key: _form,
        child: Column(
          children: [
            // Step indicator
            Container(
              color: AppColors.navyMid,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: List.generate(3, (i) => Expanded(
                  child: Row(children: [
                    Expanded(child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: i <= _step ? AppColors.chinaRed : AppColors.navyLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )),
                    if (i < 2) const SizedBox(width: 4),
                  ]),
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Bidhaa', 'Usafirishaji', 'Mawasiliano'].asMap().map((i, s) => MapEntry(i,
                  Text(s, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                    color: i <= _step ? AppColors.chinaRed : AppColors.textMuted)),
                )).values.toList(),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _step == 0 ? _Step1() : _step == 1 ? _Step2() : _Step3(),
              ),
            ),

            // Cost estimate bar
            if (_weight.text.isNotEmpty || _volume.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.navyMid,
                  border: const Border(top: BorderSide(color: Color(0xFF1E3A5F))),
                ),
                child: Row(children: [
                  const Icon(Icons.attach_money, color: AppColors.gold, size: 18),
                  const SizedBox(width: 6),
                  const Text('Bei ya Tahmini:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(width: 8),
                  Text('\$${_estimatedCost.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 16)),
                  const Spacer(),
                  Text(_mode.emoji, style: const TextStyle(fontSize: 16)),
                ]),
              ),

            // Nav buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              color: AppColors.navyMid,
              child: Row(children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: Color(0xFF1E3A5F)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('← Rudi'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _busy ? null : (_step < 2 ? () => setState(() => _step++) : _submit),
                    child: _busy
                        ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth:2.5))
                        : Text(_step < 2 ? 'Endelea →' : '✅ Hifadhi Mzigo',
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Cargo details
  Widget _Step1() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Label('Maelezo ya Bidhaa *'),
    const SizedBox(height: 8),
    TextFormField(
      controller: _desc,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(labelText: 'mfano: Samsung Phones x200', prefixIcon: Icon(Icons.inventory_2_outlined, size: 18)),
      validator: (v) => (v?.isEmpty ?? true) ? 'Lazima uweke maelezo' : null,
    ),
    const SizedBox(height: 16),

    _Label('Aina ya Bidhaa'),
    const SizedBox(height: 8),
    Wrap(spacing: 8, runSpacing: 8,
      children: CargoType.values.map((c) => GestureDetector(
        onTap: () => setState(() => _cargo = c),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _cargo == c ? AppColors.chinaRed.withOpacity(0.15) : AppColors.navyMid,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _cargo == c ? AppColors.chinaRed : const Color(0xFF1E3A5F)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(c.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(c.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: _cargo == c ? AppColors.chinaRed : AppColors.textSecondary)),
          ]),
        ),
      )).toList(),
    ),
    const SizedBox(height: 16),

    Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Label('Uzito (kg) *'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _weight,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(labelText: 'mfano: 500', prefixIcon: Icon(Icons.scale_outlined, size: 18)),
          validator: (v) => (v?.isEmpty ?? true) ? 'Lazima' : null,
        ),
      ])),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Label('Ujazo (CBM) *'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _volume,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(labelText: 'mfano: 2.5', prefixIcon: Icon(Icons.view_in_ar_outlined, size: 18)),
          validator: (v) => (v?.isEmpty ?? true) ? 'Lazima' : null,
        ),
      ])),
    ]),
    const SizedBox(height: 16),

    _Label('Idadi ya Vifurushi'),
    const SizedBox(height: 8),
    TextFormField(
      controller: _qty,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(labelText: 'Idadi', prefixIcon: Icon(Icons.numbers, size: 18)),
    ),
  ]);

  // Step 2: Shipping details
  Widget _Step2() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Label('Njia ya Usafirishaji'),
    const SizedBox(height: 10),
    ...ShippingMode.values.map((m) => GestureDetector(
      onTap: () => setState(() { _mode = m; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _mode == m ? AppColors.chinaRed.withOpacity(0.1) : AppColors.navyMid,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _mode == m ? AppColors.chinaRed : const Color(0xFF1E3A5F),
            width: _mode == m ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Text(m.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.label, style: TextStyle(fontWeight: FontWeight.w700,
              color: _mode == m ? AppColors.chinaRed : AppColors.textPrimary)),
            Text('${m.daysMin}–${m.daysMax} siku · \$${(_estimatedCost).toStringAsFixed(0)} tahmini',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ])),
          if (_mode == m) const Icon(Icons.check_circle, color: AppColors.chinaRed, size: 20),
        ]),
      ),
    )),
    const SizedBox(height: 16),

    _Label('Mji wa Asili (China)'),
    const SizedBox(height: 8),
    Wrap(spacing: 8, runSpacing: 8,
      children: _origins.map((o) => GestureDetector(
        onTap: () => setState(() => _origin.text = o),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _origin.text == o ? AppColors.gold.withOpacity(0.15) : AppColors.navyMid,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _origin.text == o ? AppColors.gold : const Color(0xFF1E3A5F)),
          ),
          child: Text(o, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: _origin.text == o ? AppColors.gold : AppColors.textSecondary)),
        ),
      )).toList(),
    ),
    const SizedBox(height: 16),

    Row(children: [
      Expanded(child: TextFormField(
        controller: _dest,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(labelText: 'Mji wa Kufika *', prefixIcon: Icon(Icons.location_on_outlined, size: 18)),
        validator: (v) => (v?.isEmpty ?? true) ? 'Lazima' : null,
      )),
      const SizedBox(width: 12),
      Expanded(child: TextFormField(
        controller: _destCountry,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(labelText: 'Nchi *', prefixIcon: Icon(Icons.flag_outlined, size: 18)),
        validator: (v) => (v?.isEmpty ?? true) ? 'Lazima' : null,
      )),
    ]),
  ]);

  // Step 3: Contacts & notes
  Widget _Step3() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Label('Jina la Muuzaji (Hiari)'),
    const SizedBox(height: 8),
    TextFormField(
      controller: _supplier,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(labelText: 'mfano: Huatong Electronics Co.', prefixIcon: Icon(Icons.factory_outlined, size: 18)),
    ),
    const SizedBox(height: 14),
    _Label('Jina la Mpokeaji (Hiari)'),
    const SizedBox(height: 8),
    TextFormField(
      controller: _receiver,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(labelText: 'Jina la mtu atakayepokea', prefixIcon: Icon(Icons.person_outline, size: 18)),
    ),
    const SizedBox(height: 14),
    _Label('Maelezo Zaidi (Hiari)'),
    const SizedBox(height: 8),
    TextFormField(
      controller: _notes,
      maxLines: 3,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(labelText: 'Maagizo maalum, namba za HS code, n.k.', alignLabelWithHint: true),
    ),
    const SizedBox(height: 20),
    // Summary
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.receipt_long_outlined, color: AppColors.gold, size: 16),
          SizedBox(width: 6),
          Text('Muhtasari wa Mzigo', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        _SumRow('Bidhaa:', '${_cargo.emoji} ${_cargo.label}'),
        _SumRow('Njia:', '${_mode.emoji} ${_mode.label}'),
        _SumRow('Kutoka → Kwenda:', '${_origin.text} → ${_dest.text}, ${_destCountry.text}'),
        _SumRow('Uzito:', '${_weight.text} kg | ${_volume.text} CBM'),
        _SumRow('Muda wa kufika:', '${_mode.daysMin}–${_mode.daysMax} siku'),
        const Divider(color: Color(0xFF1E3A5F)),
        _SumRow('Bei ya Tahmini:', '\$${_estimatedCost.toStringAsFixed(0)} USD',
          valueStyle: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 14)),
      ]),
    ),
  ]);

  Widget _Label(String t) => Text(t, style: const TextStyle(
    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5));

  Widget _SumRow(String k, String v, {TextStyle? valueStyle}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      SizedBox(width: 120, child: Text(k, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
      Expanded(child: Text(v, style: valueStyle ?? const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
    ]),
  );
}
