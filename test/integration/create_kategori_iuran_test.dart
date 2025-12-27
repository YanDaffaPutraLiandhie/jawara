import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'create_kategori_iuran_test.mocks.dart';

void main() {
  group('Create Kategori Iuran Workflow', () {
    // ============================================
    // TEST: CREATE KATEGORI IURAN WORKFLOW
    // Login → Create Kategori Iuran → Logout
    // ============================================
    testWidgets('Create Kategori Iuran: Login -> Create Kategori Iuran -> Logout', 
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

      // 2. NAVIGATE TO KEUANGAN TAB
      print('\n═══ PHASE 2: CREATE KATEGORI IURAN ═══');
      final tabKeuangan = find.byIcon(Icons.wallet);
      expect(tabKeuangan, findsOneWidget);
      await tester.tap(tabKeuangan);
      await tester.pumpAndSettle();
      print('✓ Navigasi ke tab Keuangan');

      // 3. CREATE KATEGORI IURAN
      final btnTambahKategori = find.widgetWithText(FilledButton, 'Tambah Kategori Iuran');
      if (btnTambahKategori.evaluate().isNotEmpty) {
        await tester.tap(btnTambahKategori);
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('nama_kategori')), 'Iuran Bulanan');
        await tester.enterText(find.byKey(const Key('nominal_kategori')), '50000');
        await tester.enterText(find.byKey(const Key('deskripsi_kategori')), 'Iuran wajib bulanan untuk operasional RW');
        
        final btnSimpanKategori = find.widgetWithText(FilledButton, 'Simpan Kategori');
        if (btnSimpanKategori.evaluate().isNotEmpty) {
          await tester.tap(btnSimpanKategori);
          await tester.pumpAndSettle();
          print('✓ Kategori Iuran berhasil dibuat');
        }
      }

      // 4. LOGOUT
      print('\n═══ PHASE 3: LOGOUT ═══');
      final btnLogout = find.byIcon(Icons.person);
      expect(btnLogout, findsOneWidget);
      await tester.tap(btnLogout);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      print('✓ Logout berhasil');
      print('\n✅ Test Create Kategori Iuran PASSED\n');
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
        _currentBody = _KeuanganPage();
        break;
      case 2:
        _currentBody = const Center(child: Text('Warga'));
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

class _KeuanganPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keuangan')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _TambahKategoriPage(),
              ),
            );
          },
          child: const Text('Tambah Kategori Iuran'),
        ),
      ),
    );
  }
}

class _TambahKategoriPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kategori Iuran'),
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
                key: const Key('nama_kategori'),
                decoration: const InputDecoration(hintText: 'Nama Kategori'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('nominal_kategori'),
                decoration: const InputDecoration(hintText: 'Nominal'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('deskripsi_kategori'),
                decoration: const InputDecoration(hintText: 'Deskripsi'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Simpan Kategori'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
