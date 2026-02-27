import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import 'auth/auth_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logo, _text;
  late Animation<double> _logoScale, _textFade, _logoFade;

  @override
  void initState() {
    super.initState();
    _logo = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _text = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _logoScale = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _logo, curve: Curves.elasticOut));
    _logoFade  = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logo, curve: const Interval(0, 0.4)));
    _textFade  = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _text, curve: Curves.easeIn));

    _logo.forward().then((_) => _text.forward());
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final prov = context.read<AppProvider>();
    while (!prov.loaded) { await Future.delayed(const Duration(milliseconds: 50)); }
    if (!mounted) return;
    Navigator.pushReplacement(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => prov.isLoggedIn ? const HomeScreen() : const AuthScreen(),
      transitionDuration: const Duration(milliseconds: 800),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  @override void dispose() { _logo.dispose(); _text.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.navyMid, AppColors.navy, Color(0xFF050E1A)],
          ),
        ),
        child: Stack(
          children: [
            // Decorative red line
            Positioned(top: 0, left: 0, right: 0,
              child: Container(height: 4, decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.chinaRed, AppColors.gold, AppColors.chinaRed])))),
            // Background pattern - subtle cargo container lines
            Positioned.fill(
              child: Opacity(opacity: 0.03, child: CustomPaint(painter: _GridPainter())),
            ),
            Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Logo
                FadeTransition(opacity: _logoFade,
                  child: ScaleTransition(scale: _logoScale,
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.chinaRed,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(color: AppColors.chinaRed.withOpacity(0.5), blurRadius: 30, spreadRadius: 4),
                            ],
                          ),
                          child: const Center(child: Text('🚢', style: TextStyle(fontSize: 40))),
                        ),
                        const SizedBox(width: 16),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('CHINA', style: TextStyle(
                            fontFamily: 'Georgia', fontSize: 36, fontWeight: FontWeight.w900,
                            color: AppColors.chinaRed, letterSpacing: 6)),
                          Row(children: [
                            const Text('FREIGHT', style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.gold, letterSpacing: 8)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('PRO', style: TextStyle(fontSize: 9, color: AppColors.gold, letterSpacing: 2)),
                            ),
                          ]),
                        ]),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(opacity: _textFade, child: Column(children: [
                  const Text('Usafirishaji wa Bidhaa', style: TextStyle(
                    fontSize: 16, color: AppColors.textSecondary, letterSpacing: 1)),
                  const Text('China → Afrika', style: TextStyle(
                    fontSize: 13, color: AppColors.textMuted, letterSpacing: 3)),
                  const SizedBox(height: 40),
                  // Loading indicator
                  SizedBox(
                    width: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.navyLight,
                        valueColor: const AlwaysStoppedAnimation(AppColors.chinaRed),
                        minHeight: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Inapakia...', style: TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 1)),
                ])),
              ]),
            ),
            // Bottom flags
            Positioned(bottom: 40, left: 0, right: 0,
              child: FadeTransition(opacity: _textFade,
                child: Column(children: [
                  const Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🇨🇳', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('🇰🇪', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('🇹🇿', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('🇺🇬', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('🇿🇦', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('🇳🇬', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Nchi 15+ za Afrika zinazotumikiwa',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.6), letterSpacing: 0.5)),
                ])),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}
