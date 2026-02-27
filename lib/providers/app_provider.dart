import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  AppUser? _user;
  List<Shipment> _shipments = [];
  List<QuoteRequest> _quotes = [];
  bool _loaded = false;
  String _search = '';

  final _uuid = const Uuid();

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loaded => _loaded;
  String get search => _search;

  List<Shipment> get shipments => _search.isEmpty
      ? _shipments
      : _shipments.where((s) =>
          s.trackingNumber.toLowerCase().contains(_search.toLowerCase()) ||
          s.description.toLowerCase().contains(_search.toLowerCase()) ||
          s.destinationCity.toLowerCase().contains(_search.toLowerCase()) ||
          s.supplierName?.toLowerCase().contains(_search.toLowerCase()) == true)
        .toList();

  List<Shipment> get activeShipments => _shipments
      .where((s) => s.status != ShipmentStatus.delivered && s.status != ShipmentStatus.cancelled)
      .toList();

  List<Shipment> get completedShipments => _shipments
      .where((s) => s.status == ShipmentStatus.delivered)
      .toList();

  List<QuoteRequest> get quotes => _quotes;

  // Stats
  int get totalShipments => _shipments.length;
  int get inTransitCount => _shipments.where((s) => s.status == ShipmentStatus.inTransit).length;
  int get customsCount   => _shipments.where((s) => s.status == ShipmentStatus.customsClearing).length;
  double get totalSpentUSD => _shipments.fold(0, (sum, s) => sum + s.costUSD);

  void setSearch(String q) { _search = q; notifyListeners(); }

  AppProvider() { _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final u = p.getString('cs_user');
    if (u != null) { try { _user = AppUser.fromJson(jsonDecode(u)); } catch (_) {} }
    final sh = p.getString('cs_shipments');
    if (sh != null) {
      try { _shipments = (jsonDecode(sh) as List).map((e) => Shipment.fromJson(e)).toList(); }
      catch (_) {}
    }
    final qr = p.getString('cs_quotes');
    if (qr != null) {
      try { _quotes = (jsonDecode(qr) as List).map((e) => QuoteRequest.fromJson(e)).toList(); }
      catch (_) {}
    }
    if (_user != null && _shipments.isEmpty) _addDemoData();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _saveShipments() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('cs_shipments', jsonEncode(_shipments.map((s) => s.toJson()).toList()));
  }

  Future<void> _saveQuotes() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('cs_quotes', jsonEncode(_quotes.map((q) => q.toJson()).toList()));
  }

  // ── AUTH ──
  Future<String?> login({required String email, required String password}) async {
    final p = await SharedPreferences.getInstance();
    final all = p.getStringList('cs_users') ?? [];
    for (final u in all) {
      final parsed = AppUser.fromJson(jsonDecode(u.split('|||')[0]));
      final pass = u.split('|||')[1];
      if (parsed.email.toLowerCase() == email.toLowerCase() && pass == password) {
        _user = parsed;
        await p.setString('cs_user', jsonEncode(parsed.toJson()));
        final sh = p.getString('cs_shipments_${parsed.id}');
        if (sh != null) {
          try { _shipments = (jsonDecode(sh) as List).map((e) => Shipment.fromJson(e)).toList(); }
          catch (_) {}
        }
        if (_shipments.isEmpty) _addDemoData();
        notifyListeners();
        return null;
      }
    }
    return 'Barua pepe au neno siri si sahihi';
  }

  Future<String?> register({
    required String name, required String email, required String password,
    required String phone, required String company,
    required String country, required String city,
  }) async {
    final p = await SharedPreferences.getInstance();
    final all = p.getStringList('cs_users') ?? [];
    for (final u in all) {
      final parsed = AppUser.fromJson(jsonDecode(u.split('|||')[0]));
      if (parsed.email.toLowerCase() == email.toLowerCase()) return 'Barua pepe hii imetumika tayari';
    }
    final user = AppUser(
      id: _uuid.v4(), name: name, email: email, phone: phone,
      company: company, country: country, city: city, joinedAt: DateTime.now(),
    );
    all.add('${jsonEncode(user.toJson())}|||$password');
    await p.setStringList('cs_users', all);
    await p.setString('cs_user', jsonEncode(user.toJson()));
    _user = user;
    _shipments = [];
    _addDemoData();
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    if (_user != null) {
      await p.setString('cs_shipments_${_user!.id}', jsonEncode(_shipments.map((s) => s.toJson()).toList()));
    }
    await p.remove('cs_user');
    _user = null; _shipments = []; _quotes = [];
    notifyListeners();
  }

  Future<void> updateProfile(AppUser updated) async {
    _user = updated;
    final p = await SharedPreferences.getInstance();
    await p.setString('cs_user', jsonEncode(updated.toJson()));
    notifyListeners();
  }

  // ── SHIPMENTS ──
  Future<Shipment> addShipment({
    required String description,
    required CargoType cargoType,
    required ShippingMode mode,
    required double weightKg,
    required double volumeCbm,
    required int quantity,
    required String originCity,
    required String destinationCity,
    required String destinationCountry,
    String? supplierName,
    String? receiverName,
    String? notes,
  }) async {
    final now = DateTime.now();
    final cost = _calculateCost(mode, weightKg, volumeCbm);
    final s = Shipment(
      id: _uuid.v4(),
      trackingNumber: 'CS${now.year}${(now.month).toString().padLeft(2,'0')}${_shipments.length + 1001}',
      description: description,
      cargoType: cargoType,
      mode: mode,
      status: ShipmentStatus.pending,
      weightKg: weightKg,
      volumeCbm: volumeCbm,
      quantity: quantity,
      originCity: originCity,
      destinationCity: destinationCity,
      destinationCountry: destinationCountry,
      createdAt: now,
      estimatedArrival: now.add(Duration(days: mode.daysMin + 5)),
      costUSD: cost,
      supplierName: supplierName,
      receiverName: receiverName,
      notes: notes,
      events: [
        TrackingEvent(
          time: now,
          location: originCity,
          description: 'Agizo limepokelewa na kusajiliwa',
        ),
      ],
    );
    _shipments.insert(0, s);
    await _saveShipments();
    notifyListeners();
    return s;
  }

  double _calculateCost(ShippingMode mode, double kg, double cbm) {
    const rates = {
      ShippingMode.sea: 3.5,
      ShippingMode.air: 8.0,
      ShippingMode.express: 15.0,
      ShippingMode.rail: 5.0,
    };
    final chargeableWeight = cbm * 167 > kg ? cbm * 167 : kg;
    return chargeableWeight * (rates[mode] ?? 3.5) + 120;
  }

  Future<void> updateShipmentStatus(String id, ShipmentStatus status) async {
    final idx = _shipments.indexWhere((s) => s.id == id);
    if (idx < 0) return;
    _shipments[idx].status = status;
    _shipments[idx].events.add(TrackingEvent(
      time: DateTime.now(),
      location: _locationForStatus(status),
      description: _descriptionForStatus(status),
    ));
    if (status == ShipmentStatus.delivered) {
      _shipments[idx].actualArrival = DateTime.now();
    }
    await _saveShipments();
    notifyListeners();
  }

  Future<void> deleteShipment(String id) async {
    _shipments.removeWhere((s) => s.id == id);
    await _saveShipments();
    notifyListeners();
  }

  String _locationForStatus(ShipmentStatus s) {
    switch (s) {
      case ShipmentStatus.pickedUp:         return 'Guangzhou, China';
      case ShipmentStatus.inTransit:        return 'Bahari ya Hindi';
      case ShipmentStatus.customsClearing:  return 'Bandari ya Mombasa';
      case ShipmentStatus.cleared:          return 'Mombasa, Kenya';
      case ShipmentStatus.outForDelivery:   return 'Nairobi, Kenya';
      case ShipmentStatus.delivered:        return 'Anwani ya Mpokeaji';
      default:                              return 'Guangzhou, China';
    }
  }

  String _descriptionForStatus(ShipmentStatus s) {
    switch (s) {
      case ShipmentStatus.confirmed:        return 'Agizo limethibitishwa na kampuni';
      case ShipmentStatus.pickedUp:         return 'Mizigo imechukuliwa kutoka kwa muuzaji';
      case ShipmentStatus.inTransit:        return 'Meli imesafiri — njiani';
      case ShipmentStatus.customsClearing:  return 'Mizigo ipo forodhani — inachunguzwa';
      case ShipmentStatus.cleared:          return 'Mizigo imepita forodha kikamilifu';
      case ShipmentStatus.outForDelivery:   return 'Gari la usafirishaji limetoka';
      case ShipmentStatus.delivered:        return 'Mizigo imefikia salama!';
      case ShipmentStatus.held:             return 'Mizigo imesimamishwa — tafadhali wasiliana nasi';
      default:                              return s.label;
    }
  }

  // ── QUOTES ──
  Future<QuoteRequest> addQuote({
    required CargoType cargoType,
    required ShippingMode mode,
    required double weightKg,
    required double volumeCbm,
    required int quantity,
    required String originCity,
    required String destinationCity,
    required String destinationCountry,
  }) async {
    final q = QuoteRequest(
      id: _uuid.v4(),
      cargoType: cargoType, mode: mode, weightKg: weightKg,
      volumeCbm: volumeCbm, quantity: quantity, originCity: originCity,
      destinationCity: destinationCity, destinationCountry: destinationCountry,
      createdAt: DateTime.now(),
      estimatedCost: _calculateCost(mode, weightKg, volumeCbm),
      status: 'received',
    );
    _quotes.insert(0, q);
    await _saveQuotes();
    notifyListeners();
    return q;
  }

  // ── DEMO DATA ──
  void _addDemoData() {
    final now = DateTime.now();
    _shipments = [
      Shipment(
        id: _uuid.v4(), trackingNumber: 'CS202401001',
        description: 'Samsung Phones x200 - Galaxy A54',
        cargoType: CargoType.electronics, mode: ShippingMode.sea,
        status: ShipmentStatus.inTransit,
        weightKg: 450, volumeCbm: 2.4, quantity: 200,
        originCity: 'Shenzhen', destinationCity: 'Nairobi', destinationCountry: 'Kenya',
        createdAt: now.subtract(const Duration(days: 18)),
        estimatedArrival: now.add(const Duration(days: 14)),
        costUSD: 1850, supplierName: 'Huatong Electronics',
        receiverName: _user?.name ?? 'Client',
        events: [
          TrackingEvent(time: now.subtract(const Duration(days:18)), location: 'Shenzhen, China', description: 'Agizo limepokelewa'),
          TrackingEvent(time: now.subtract(const Duration(days:15)), location: 'Shenzhen, China', description: 'Mizigo imechukuliwa'),
          TrackingEvent(time: now.subtract(const Duration(days:12)), location: 'Bahari ya China Kusini', description: 'Meli imesafiri'),
          TrackingEvent(time: now.subtract(const Duration(days:3)), location: 'Bahari ya Hindi', description: 'Njiani — inasonga vizuri 🚢'),
        ],
      ),
      Shipment(
        id: _uuid.v4(), trackingNumber: 'CS202401002',
        description: 'Nguo za Kiume - Batch 500pcs',
        cargoType: CargoType.clothing, mode: ShippingMode.sea,
        status: ShipmentStatus.customsClearing,
        weightKg: 320, volumeCbm: 4.5, quantity: 500,
        originCity: 'Guangzhou', destinationCity: 'Dar es Salaam', destinationCountry: 'Tanzania',
        createdAt: now.subtract(const Duration(days: 35)),
        estimatedArrival: now.add(const Duration(days: 5)),
        costUSD: 2200, supplierName: 'Guangzhou Textile Co.',
        events: [
          TrackingEvent(time: now.subtract(const Duration(days:35)), location: 'Guangzhou, China', description: 'Agizo limepokelewa'),
          TrackingEvent(time: now.subtract(const Duration(days:30)), location: 'Guangzhou, China', description: 'Imechukuliwa'),
          TrackingEvent(time: now.subtract(const Duration(days:28)), location: 'Bandari ya Guangzhou', description: 'Meli imesafiri'),
          TrackingEvent(time: now.subtract(const Duration(days:5)), location: 'Bandari ya Mombasa', description: 'Imefika bandari — forodha inaendelea'),
        ],
      ),
      Shipment(
        id: _uuid.v4(), trackingNumber: 'CS202312003',
        description: 'Spare Parts - Motorcycle',
        cargoType: CargoType.automotive, mode: ShippingMode.air,
        status: ShipmentStatus.delivered,
        weightKg: 85, volumeCbm: 0.6, quantity: 50,
        originCity: 'Yiwu', destinationCity: 'Kampala', destinationCountry: 'Uganda',
        createdAt: now.subtract(const Duration(days: 45)),
        estimatedArrival: now.subtract(const Duration(days: 38)),
        actualArrival: now.subtract(const Duration(days: 40)),
        costUSD: 780,
        events: [
          TrackingEvent(time: now.subtract(const Duration(days:45)), location: 'Yiwu, China', description: 'Agizo limepokelewa'),
          TrackingEvent(time: now.subtract(const Duration(days:44)), location: 'Yiwu, China', description: 'Imechukuliwa'),
          TrackingEvent(time: now.subtract(const Duration(days:43)), location: 'Shanghai Airport', description: 'Imepanda ndege'),
          TrackingEvent(time: now.subtract(const Duration(days:41)), location: 'Entebbe Airport', description: 'Imefika Uganda'),
          TrackingEvent(time: now.subtract(const Duration(days:40)), location: 'Kampala, Uganda', description: 'Imefikia salama! ✅'),
        ],
      ),
    ];
    _saveShipments();
  }
}
