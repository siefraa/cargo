import 'package:flutter/material.dart';

// ── Shipment Status ──
enum ShipmentStatus {
  pending,
  confirmed,
  pickedUp,
  inTransit,
  customsClearing,
  cleared,
  outForDelivery,
  delivered,
  held,
  cancelled,
}

extension ShipmentStatusX on ShipmentStatus {
  String get label {
    switch (this) {
      case ShipmentStatus.pending:          return 'Inasubiri';
      case ShipmentStatus.confirmed:        return 'Imethibitishwa';
      case ShipmentStatus.pickedUp:         return 'Imechukuliwa';
      case ShipmentStatus.inTransit:        return 'Njiani';
      case ShipmentStatus.customsClearing:  return 'Forodha';
      case ShipmentStatus.cleared:          return 'Imepita Forodha';
      case ShipmentStatus.outForDelivery:   return 'Inafika';
      case ShipmentStatus.delivered:        return 'Imefikia';
      case ShipmentStatus.held:             return 'Imesimamishwa';
      case ShipmentStatus.cancelled:        return 'Imefutwa';
    }
  }

  Color get color {
    switch (this) {
      case ShipmentStatus.pending:          return const Color(0xFFF59E0B);
      case ShipmentStatus.confirmed:        return const Color(0xFF60A5FA);
      case ShipmentStatus.pickedUp:         return const Color(0xFF818CF8);
      case ShipmentStatus.inTransit:        return const Color(0xFF0EA5E9);
      case ShipmentStatus.customsClearing:  return const Color(0xFFF97316);
      case ShipmentStatus.cleared:          return const Color(0xFF10B981);
      case ShipmentStatus.outForDelivery:   return const Color(0xFF34D399);
      case ShipmentStatus.delivered:        return const Color(0xFF6366F1);
      case ShipmentStatus.held:             return const Color(0xFFEF4444);
      case ShipmentStatus.cancelled:        return const Color(0xFF6B7280);
    }
  }

  String get emoji {
    switch (this) {
      case ShipmentStatus.pending:          return '⏳';
      case ShipmentStatus.confirmed:        return '✅';
      case ShipmentStatus.pickedUp:         return '📦';
      case ShipmentStatus.inTransit:        return '🚢';
      case ShipmentStatus.customsClearing:  return '🛃';
      case ShipmentStatus.cleared:          return '✔️';
      case ShipmentStatus.outForDelivery:   return '🚛';
      case ShipmentStatus.delivered:        return '🏠';
      case ShipmentStatus.held:             return '⛔';
      case ShipmentStatus.cancelled:        return '❌';
    }
  }
}

// ── Shipping Mode ──
enum ShippingMode { sea, air, express, rail }

extension ShippingModeX on ShippingMode {
  String get label {
    switch (this) {
      case ShippingMode.sea:     return 'Baharini (Sea)';
      case ShippingMode.air:     return 'Angani (Air)';
      case ShippingMode.express: return 'Haraka (Express)';
      case ShippingMode.rail:    return 'Reli (Rail)';
    }
  }
  String get emoji {
    switch (this) {
      case ShippingMode.sea:     return '🚢';
      case ShippingMode.air:     return '✈️';
      case ShippingMode.express: return '⚡';
      case ShippingMode.rail:    return '🚂';
    }
  }
  int get daysMin {
    switch (this) {
      case ShippingMode.sea:     return 25;
      case ShippingMode.air:     return 5;
      case ShippingMode.express: return 3;
      case ShippingMode.rail:    return 18;
    }
  }
  int get daysMax {
    switch (this) {
      case ShippingMode.sea:     return 40;
      case ShippingMode.air:     return 10;
      case ShippingMode.express: return 5;
      case ShippingMode.rail:    return 22;
    }
  }
}

// ── Cargo Type ──
enum CargoType {
  electronics, clothing, furniture, machinery, food, chemicals,
  automotive, toys, cosmetics, other,
}

extension CargoTypeX on CargoType {
  String get label {
    switch (this) {
      case CargoType.electronics: return 'Elektroniki';
      case CargoType.clothing:    return 'Nguo';
      case CargoType.furniture:   return 'Fanicha';
      case CargoType.machinery:   return 'Mashine';
      case CargoType.food:        return 'Chakula';
      case CargoType.chemicals:   return 'Kemikali';
      case CargoType.automotive:  return 'Magari/Spea';
      case CargoType.toys:        return 'Toys';
      case CargoType.cosmetics:   return 'Vipodozi';
      case CargoType.other:       return 'Mengineyo';
    }
  }
  String get emoji {
    switch (this) {
      case CargoType.electronics: return '📱';
      case CargoType.clothing:    return '👕';
      case CargoType.furniture:   return '🪑';
      case CargoType.machinery:   return '⚙️';
      case CargoType.food:        return '🍜';
      case CargoType.chemicals:   return '🧪';
      case CargoType.automotive:  return '🚗';
      case CargoType.toys:        return '🧸';
      case CargoType.cosmetics:   return '💄';
      case CargoType.other:       return '📦';
    }
  }
}

// ── Tracking Event ──
class TrackingEvent {
  final DateTime time;
  final String location;
  final String description;
  final bool isCompleted;

  const TrackingEvent({
    required this.time,
    required this.location,
    required this.description,
    this.isCompleted = true,
  });

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'location': location,
    'description': description,
    'isCompleted': isCompleted,
  };

  factory TrackingEvent.fromJson(Map<String, dynamic> j) => TrackingEvent(
    time: DateTime.parse(j['time']),
    location: j['location'],
    description: j['description'],
    isCompleted: j['isCompleted'] ?? true,
  );
}

// ── Shipment ──
class Shipment {
  final String id;
  final String trackingNumber;
  String description;
  CargoType cargoType;
  ShippingMode mode;
  ShipmentStatus status;
  double weightKg;
  double volumeCbm;
  int quantity;
  String originCity;
  String destinationCity;
  String destinationCountry;
  DateTime createdAt;
  DateTime? estimatedArrival;
  DateTime? actualArrival;
  double costUSD;
  List<TrackingEvent> events;
  String? supplierName;
  String? receiverName;
  String? notes;

  Shipment({
    required this.id,
    required this.trackingNumber,
    required this.description,
    required this.cargoType,
    required this.mode,
    required this.status,
    required this.weightKg,
    required this.volumeCbm,
    required this.quantity,
    required this.originCity,
    required this.destinationCity,
    required this.destinationCountry,
    required this.createdAt,
    this.estimatedArrival,
    this.actualArrival,
    required this.costUSD,
    List<TrackingEvent>? events,
    this.supplierName,
    this.receiverName,
    this.notes,
  }) : events = events ?? [];

  int get daysRemaining {
    if (estimatedArrival == null) return 0;
    return estimatedArrival!.difference(DateTime.now()).inDays.clamp(0, 999);
  }

  double get progressPercent {
    final steps = ShipmentStatus.values;
    final idx = steps.indexOf(status);
    return (idx / (steps.length - 1)).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trackingNumber': trackingNumber,
    'description': description,
    'cargoType': cargoType.index,
    'mode': mode.index,
    'status': status.index,
    'weightKg': weightKg,
    'volumeCbm': volumeCbm,
    'quantity': quantity,
    'originCity': originCity,
    'destinationCity': destinationCity,
    'destinationCountry': destinationCountry,
    'createdAt': createdAt.toIso8601String(),
    'estimatedArrival': estimatedArrival?.toIso8601String(),
    'actualArrival': actualArrival?.toIso8601String(),
    'costUSD': costUSD,
    'events': events.map((e) => e.toJson()).toList(),
    'supplierName': supplierName,
    'receiverName': receiverName,
    'notes': notes,
  };

  factory Shipment.fromJson(Map<String, dynamic> j) => Shipment(
    id: j['id'],
    trackingNumber: j['trackingNumber'],
    description: j['description'],
    cargoType: CargoType.values[j['cargoType'] ?? 0],
    mode: ShippingMode.values[j['mode'] ?? 0],
    status: ShipmentStatus.values[j['status'] ?? 0],
    weightKg: (j['weightKg'] ?? 0).toDouble(),
    volumeCbm: (j['volumeCbm'] ?? 0).toDouble(),
    quantity: j['quantity'] ?? 1,
    originCity: j['originCity'] ?? 'Guangzhou',
    destinationCity: j['destinationCity'] ?? '',
    destinationCountry: j['destinationCountry'] ?? '',
    createdAt: DateTime.parse(j['createdAt']),
    estimatedArrival: j['estimatedArrival'] != null ? DateTime.parse(j['estimatedArrival']) : null,
    actualArrival: j['actualArrival'] != null ? DateTime.parse(j['actualArrival']) : null,
    costUSD: (j['costUSD'] ?? 0).toDouble(),
    events: (j['events'] as List? ?? []).map((e) => TrackingEvent.fromJson(e)).toList(),
    supplierName: j['supplierName'],
    receiverName: j['receiverName'],
    notes: j['notes'],
  );
}

// ── Quote Request ──
class QuoteRequest {
  final String id;
  CargoType cargoType;
  ShippingMode mode;
  double weightKg;
  double volumeCbm;
  int quantity;
  String originCity;
  String destinationCity;
  String destinationCountry;
  DateTime createdAt;
  double? estimatedCost;
  String status; // 'pending' | 'received' | 'accepted' | 'rejected'

  QuoteRequest({
    required this.id,
    required this.cargoType,
    required this.mode,
    required this.weightKg,
    required this.volumeCbm,
    required this.quantity,
    required this.originCity,
    required this.destinationCity,
    required this.destinationCountry,
    required this.createdAt,
    this.estimatedCost,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'cargoType': cargoType.index, 'mode': mode.index,
    'weightKg': weightKg, 'volumeCbm': volumeCbm, 'quantity': quantity,
    'originCity': originCity, 'destinationCity': destinationCity,
    'destinationCountry': destinationCountry,
    'createdAt': createdAt.toIso8601String(),
    'estimatedCost': estimatedCost, 'status': status,
  };

  factory QuoteRequest.fromJson(Map<String, dynamic> j) => QuoteRequest(
    id: j['id'], cargoType: CargoType.values[j['cargoType'] ?? 0],
    mode: ShippingMode.values[j['mode'] ?? 0],
    weightKg: (j['weightKg'] ?? 0).toDouble(),
    volumeCbm: (j['volumeCbm'] ?? 0).toDouble(),
    quantity: j['quantity'] ?? 1,
    originCity: j['originCity'] ?? 'Guangzhou',
    destinationCity: j['destinationCity'] ?? '',
    destinationCountry: j['destinationCountry'] ?? '',
    createdAt: DateTime.parse(j['createdAt']),
    estimatedCost: j['estimatedCost']?.toDouble(),
    status: j['status'] ?? 'pending',
  );
}

// ── User ──
class AppUser {
  final String id;
  String name;
  String email;
  String phone;
  String company;
  String country;
  String city;
  DateTime joinedAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.country,
    required this.city,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'phone': phone,
    'company': company, 'country': country, 'city': city,
    'joinedAt': joinedAt.toIso8601String(),
  };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'], name: j['name'], email: j['email'] ?? '',
    phone: j['phone'] ?? '', company: j['company'] ?? '',
    country: j['country'] ?? '', city: j['city'] ?? '',
    joinedAt: DateTime.parse(j['joinedAt']),
  );
}
