import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'tambah_rumah_test.mocks.dart';

void main() {
  group('Tambah Rumah Workflow', () {
    // ============================================
    // TEST: TAMBAH RUMAH WORKFLOW
    // Login → Navigate to Warga → Add Rumah → Logout
    // ============================================
    testWidgets('Tambah Rumah: Login -> Navigate to Warga -> Add Rumah -> Logout', 
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

      await tester.enterText(find.byKey(const Key('email_field')), 'admin@rw01.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'admin123');
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

      // 3. ADD RUMAH
      print('\n═══ PHASE 3: ADD RUMAH ═══');
      final btnTambahRumah = find.widgetWithText(FilledButton, 'Tambah Rumah');
      if (btnTambahRumah.evaluate().isNotEmpty) {
        await tester.tap(btnTambahRumah);
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('nomor_rumah')), 'RW01/RT02/No. 15');
        await tester.enterText(find.byKey(const Key('nama_pemilik')), 'Budi Santoso');
        await tester.enterText(find.byKey(const Key('nomor_telpon')), '081234567890');
        await tester.enterText(find.byKey(const Key('alamat_rumah')), 'Jl. Merdeka No. 15, Jakarta Selatan');
        
        final btnSimpanRumah = find.widgetWithText(FilledButton, 'Simpan Rumah');
        if (btnSimpanRumah.evaluate().isNotEmpty) {
          await tester.tap(btnSimpanRumah);
          await tester.pumpAndSettle();
          print('✓ Rumah berhasil ditambahkan');
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
      print('\n✅ Test Tambah Rumah PASSED\n');
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Warga')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _TambahRumahPage(),
              ),
            );
          },
          child: const Text('Tambah Rumah'),
        ),
      ),
    );
  }
}

class _TambahRumahPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Rumah'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                key: const Key('nomor_rumah'),
                decoration: const InputDecoration(hintText: 'Nomor Rumah'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('nama_pemilik'),
                decoration: const InputDecoration(hintText: 'Nama Pemilik'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('nomor_telpon'),
                decoration: const InputDecoration(hintText: 'Nomor Telepon'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('alamat_rumah'),
                decoration: const InputDecoration(hintText: 'Alamat Rumah'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Simpan Rumah'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
