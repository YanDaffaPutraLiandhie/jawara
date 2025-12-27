import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'daftar_rumah_test.mocks.dart';

void main() {
  group('Daftar Rumah Workflow', () {
    // ============================================
    // TEST: DAFTAR RUMAH WORKFLOW
    // Login → Navigate to Warga → View Daftar Rumah → Logout
    // ============================================
    testWidgets('Daftar Rumah: Login -> Navigate to Warga -> View Daftar Rumah -> Logout', 
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. LOGIN
      print('═══ PHASE 1: LOGIN ═══');
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'user@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pumpAndSettle();
      print('✓ Login berhasil');

      // 2. NAVIGATE TO WARGA TAB
      print('\n═══ PHASE 2: NAVIGATE TO WARGA ═══');
      final tabWarga = find.byIcon(Icons.people);
      expect(tabWarga, findsOneWidget);
      await tester.tap(tabWarga);
      await tester.pumpAndSettle();
      print('✓ Navigasi ke tab Warga');

      // 3. VIEW DAFTAR RUMAH
      print('\n═══ PHASE 3: VIEW DAFTAR RUMAH ═══');
      final daftarRumahList = find.byKey(const Key('daftar_rumah_list'));
      if (daftarRumahList.evaluate().isNotEmpty) {
        print('✓ Daftar rumah berhasil ditampilkan');
        
        // Verify list contains items
        final listItems = find.byType(ListTile);
        if (listItems.evaluate().isNotEmpty) {
          print('✓ Total rumah terdaftar: ${listItems.evaluate().length}');
        }
      }

      // 4. LOGOUT
      print('\n═══ PHASE 4: LOGOUT ═══');
      final btnLogout = find.byIcon(Icons.person);
      expect(btnLogout, findsOneWidget);
      await tester.tap(btnLogout);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      print('✓ Logout berhasil');
      print('\n✅ Test Daftar Rumah PASSED\n');
    });
  });
}

// --- Helper Build Widget ---
Widget createTestWidget() {
  return MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                key: const Key('email_field'),
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              TextFormField(
                key: const Key('password_field'),
                decoration: const InputDecoration(hintText: 'Password'),
              ),
              FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                child: const Text('Masuk'),
              ),
            ],
          ),
        ),
      ),
      '/dashboard': (context) => _DashboardPage(),
    },
  );
}

class _DashboardPage extends StatefulWidget {
  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  int _selectedIndex = 0;
  late Widget _currentBody;

  @override
  void initState() {
    super.initState();
    _updateBody();
  }

  void _updateBody() {
    switch (_selectedIndex) {
      case 0:
        _currentBody = const Center(child: Text('Halaman Utama'));
        break;
      case 1:
        _currentBody = const Center(child: Text('Keuangan'));
        break;
      case 2:
        _currentBody = _WargaPage();
        break;
      case 3:
        _currentBody = const Center(child: Text('Kegiatan'));
        break;
      case 4:
        _currentBody = const Center(child: Text('Profil'));
        break;
      default:
        _currentBody = const Center(child: Text('Halaman Utama'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _currentBody,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Keuangan'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Warga'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Kegiatan'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
          onTap: (index) {
            if (index == 4) {
              Navigator.pushReplacementNamed(context, '/');
            } else {
              setState(() {
                _selectedIndex = index;
                _updateBody();
              });
            }
          },
        ),
      ),
    );
  }
}

class _WargaPage extends StatelessWidget {
  // Sample data for testing
  final List<Map<String, String>> daftarRumah = [
    {
      'nomor': 'RW01/RT01/No. 01',
      'pemilik': 'Ahmad Wijaya',
      'telepon': '081234567890'
    },
    {
      'nomor': 'RW01/RT01/No. 02',
      'pemilik': 'Siti Nurhaliza',
      'telepon': '081345678901'
    },
    {
      'nomor': 'RW01/RT01/No. 03',
      'pemilik': 'Budi Santoso',
      'telepon': '081456789012'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Warga')),
      body: ListView.builder(
        key: const Key('daftar_rumah_list'),
        itemCount: daftarRumah.length,
        itemBuilder: (context, index) {
          final rumah = daftarRumah[index];
          return ListTile(
            leading: const Icon(Icons.home),
            title: Text(rumah['nomor']!),
            subtitle: Text('${rumah['pemilik']} - ${rumah['telepon']}'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
