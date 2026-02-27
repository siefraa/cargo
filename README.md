# 🚢 China Freight — Flutter App

Transport ya Bidhaa kutoka China hadi Afrika

## 🎨 Design
Dark industrial theme: Navy (#0A1628) + China Red (#DE2910) + Gold (#FCBF49)

## 📱 Screens (13 files)
| Screen | Maelezo |
|--------|---------|
| **Splash** | Animated logo + Africa flags |
| **Auth** | Login / Register tabs |
| **Dashboard** | Stats, active shipments, quick actions |
| **Shipment List** | Search + filter by status |
| **New Shipment** | 3-step wizard (Cargo → Shipping → Contact) |
| **Shipment Detail** | Full timeline + status update |
| **Tracking** | Search by tracking number + live progress |
| **Quotes** | Price calculator + history |
| **Profile** | Account info + stats + logout |

## 🚚 Vipengele
- ✅ Authentication (Login / Register)
- ✅ Add shipments with 3-step form
- ✅ Track by tracking number (e.g. CS202401001)
- ✅ Update shipment status
- ✅ Price calculator (Sea/Air/Express/Rail)
- ✅ Demo data (3 shipments pre-loaded)
- ✅ Search & filter
- ✅ Profile editing
- ✅ Local storage (SharedPreferences)

## 🏗️ Modes za Usafirishaji
| Njia | Muda | Takriban |
|------|------|---------|
| 🚢 Sea | 25-40 siku | Nafuu |
| ✈️ Air | 5-10 siku | Wastani |
| ⚡ Express | 3-5 siku | Ghali |
| 🚂 Rail | 18-22 siku | Kati |

## 🔨 Kujenga APK
```bash
cd chinaship
flutter pub get
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

## Dependencies
- provider: ^6.1.1
- shared_preferences: ^2.2.2
- uuid: ^4.3.3
- intl: ^0.19.0
# cargo
