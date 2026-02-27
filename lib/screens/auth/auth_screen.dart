import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background: dark navy with subtle container pattern
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [AppColors.navyMid, AppColors.navy],
              ),
            ),
          ),
          // Red accent line at top
          Positioned(top: 0, left: 0, right: 0,
            child: Container(height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.chinaRed, AppColors.gold, AppColors.chinaRed]),
              ))),
          // Container ship silhouette (decorative)
          Positioned(bottom: 0, left: -20, right: -20,
            child: Opacity(opacity: 0.04,
              child: Container(height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.steel],
                  ),
                ),
              ),
            )),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Logo area
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.chinaRed,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: AppColors.chinaRed.withOpacity(0.4), blurRadius: 20)],
                      ),
                      child: const Center(child: Text('🚢', style: TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('CHINA',
                        style: TextStyle(fontFamily: 'Georgia', fontSize: 26,
                          fontWeight: FontWeight.w900, color: AppColors.chinaRed, letterSpacing: 4)),
                      Row(children: [
                        const Text('FREIGHT', style: TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w800, color: AppColors.gold, letterSpacing: 6)),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text('PRO', style: TextStyle(fontSize: 8, color: AppColors.gold, letterSpacing: 1)),
                        ),
                      ]),
                    ]),
                  ],
                ),
                const SizedBox(height: 8),
                Text('China → Dunia', style: TextStyle(fontSize: 12,
                  color: AppColors.textMuted, letterSpacing: 2)),
                const SizedBox(height: 32),

                // Stats bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat('50K+', 'Mzigo\nUliotolewa'),
                      Container(width: 1, height: 30, color: AppColors.navyLight),
                      _Stat('15+', 'Nchi za\nAfrika'),
                      Container(width: 1, height: 30, color: AppColors.navyLight),
                      _Stat('99%', 'Usalama\nBidhaa'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: const Border(
                        top: BorderSide(color: Color(0xFF1E3A5F), width: 1),
                        left: BorderSide(color: Color(0xFF1E3A5F), width: 1),
                        right: BorderSide(color: Color(0xFF1E3A5F), width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Tab bar
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.navyMid,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TabBar(
                              controller: _tabs,
                              indicator: BoxDecoration(
                                color: AppColors.chinaRed,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Colors.white,
                              unselectedLabelColor: AppColors.textMuted,
                              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              dividerColor: Colors.transparent,
                              tabs: const [Tab(text: 'Ingia'), Tab(text: 'Jiandikishe')],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabs,
                            children: [_LoginTab(tabs: _tabs), const _RegisterTab()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
      color: AppColors.gold, fontFamily: 'Georgia')),
    const SizedBox(height: 2),
    Text(label, textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10, color: AppColors.textMuted, height: 1.3)),
  ]);
}

// ─── Login ───
class _LoginTab extends StatefulWidget {
  final TabController tabs;
  const _LoginTab({required this.tabs});
  @override State<_LoginTab> createState() => _LoginTabState();
}
class _LoginTabState extends State<_LoginTab> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _show = false, _busy = false;
  @override void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final err = await context.read<AppProvider>().login(
      email: _email.text.trim(), password: _pass.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err), backgroundColor: AppColors.chinaRed, behavior: SnackBarBehavior.floating));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 4),
        const Text('Karibu tena!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Ingia kuona mizigo yako', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 22),
        _Field(ctrl: _email, label: 'Barua Pepe', icon: Icons.email_outlined,
          type: TextInputType.emailAddress, next: true,
          validator: (v) => (v?.isEmpty ?? true) ? 'Weka barua pepe' : null),
        const SizedBox(height: 14),
        _Field(ctrl: _pass, label: 'Neno Siri', icon: Icons.lock_outline,
          obscure: !_show, toggle: () => setState(() => _show = !_show), showing: _show,
          onSubmit: (_) => _login(),
          validator: (v) => (v?.isEmpty ?? true) ? 'Weka neno siri' : null),
        const SizedBox(height: 24),
        SizedBox(height: 50, child: ElevatedButton(
          onPressed: _busy ? null : _login,
          child: _busy
              ? const SizedBox(width:22, height:22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Text('INGIA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
        )),
        const SizedBox(height: 16),
        // Demo account hint
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.navyLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.steel.withOpacity(0.4)),
          ),
          child: Column(children: [
            const Row(children: [
              Icon(Icons.info_outline, size: 13, color: AppColors.gold),
              SizedBox(width: 6),
              Text('Demo — Jiandikishe bila malipo', style: TextStyle(fontSize: 11, color: AppColors.gold)),
            ]),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => widget.tabs.animateTo(1),
              child: const Text('Bonyeza "Jiandikishe" kuunda akaunti →',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ),
          ]),
        ),
      ])),
    );
  }
}

// ─── Register ───
class _RegisterTab extends StatefulWidget {
  const _RegisterTab();
  @override State<_RegisterTab> createState() => _RegisterTabState();
}
class _RegisterTabState extends State<_RegisterTab> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _company = TextEditingController();
  final _country = TextEditingController(text: 'Kenya');
  final _city = TextEditingController();
  final _pass = TextEditingController();
  bool _show = false, _busy = false;

  @override void dispose() {
    for (final c in [_name,_email,_phone,_company,_country,_city,_pass]) c.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final err = await context.read<AppProvider>().register(
      name: _name.text.trim(), email: _email.text.trim(), password: _pass.text,
      phone: _phone.text.trim(), company: _company.text.trim(),
      country: _country.text.trim(), city: _city.text.trim(),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err), backgroundColor: AppColors.chinaRed, behavior: SnackBarBehavior.floating));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 4),
        const Text('Unda Akaunti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Jiunge na wafanyabiashara wanaoimport China', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _Field(ctrl: _name, label: 'Jina Kamili', icon: Icons.person_outline, next: true,
            validator: (v) => (v?.isEmpty ?? true) ? 'Lazima' : null)),
          const SizedBox(width: 10),
          Expanded(child: _Field(ctrl: _phone, label: 'Simu', icon: Icons.phone_outlined,
            type: TextInputType.phone, next: true, validator: (_) => null)),
        ]),
        const SizedBox(height: 12),
        _Field(ctrl: _company, label: 'Jina la Kampuni/Biashara', icon: Icons.business_outlined,
          next: true, validator: (_) => null),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _Field(ctrl: _country, label: 'Nchi', icon: Icons.flag_outlined,
            next: true, validator: (v) => (v?.isEmpty ?? true) ? 'Lazima' : null)),
          const SizedBox(width: 10),
          Expanded(child: _Field(ctrl: _city, label: 'Mji', icon: Icons.location_city_outlined,
            next: true, validator: (v) => (v?.isEmpty ?? true) ? 'Lazima' : null)),
        ]),
        const SizedBox(height: 12),
        _Field(ctrl: _email, label: 'Barua Pepe', icon: Icons.email_outlined,
          type: TextInputType.emailAddress, next: true,
          validator: (v) => (v?.contains('@') == false) ? 'Barua pepe si sahihi' : null),
        const SizedBox(height: 12),
        _Field(ctrl: _pass, label: 'Neno Siri (angalau 6)', icon: Icons.lock_outline,
          obscure: !_show, toggle: () => setState(() => _show = !_show), showing: _show,
          onSubmit: (_) => _register(),
          validator: (v) => (v?.length ?? 0) < 6 ? 'Angalau herufi 6' : null),
        const SizedBox(height: 22),
        SizedBox(height: 50, child: ElevatedButton.icon(
          onPressed: _busy ? null : _register,
          icon: _busy
              ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Icon(Icons.rocket_launch_outlined, size: 18),
          label: Text(_busy ? 'Inaunda akaunti...' : 'JIANDIKISHE SASA',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
        )),
        const SizedBox(height: 16),
      ])),
    );
  }
}

// Shared text field
class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool obscure, next;
  final bool? showing;
  final VoidCallback? toggle;
  final TextInputType? type;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmit;

  const _Field({
    required this.ctrl, required this.label, required this.icon,
    this.obscure = false, this.next = false, this.showing,
    this.toggle, this.type, this.validator, this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl, obscureText: obscure,
      keyboardType: type,
      textInputAction: next ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: onSubmit, validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        suffixIcon: toggle != null
            ? IconButton(icon: Icon(showing! ? Icons.visibility_off : Icons.visibility,
                size: 18, color: AppColors.textSecondary), onPressed: toggle)
            : null,
      ),
    );
  }
}
