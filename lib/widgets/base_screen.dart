import 'package:aplikasi_pencatatan/screens/add_transaction_screen.dart';
import 'package:aplikasi_pencatatan/screens/home_screen.dart';
import 'package:aplikasi_pencatatan/screens/transaction_screen.dart';
import 'package:flutter/material.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;

  // Daftar rute berdasarkan indeks bottom bar
  final List<String> _routes = [
    '/home',
    '/transactions',
    // '/settings',
  ];

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), // Widget untuk tab Beranda
    AddTransactionScreen(), // Widget untuk tab Tambah
    // ... widget untuk tab lainnya
  ];

    void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk berpindah tab sekaligus berpindah rute
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushNamed(context, _routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Pencatatan'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Transaksi'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.pushNamed(context, '/transactions');
              },
            ),
          ],
        ),
      ),
      body: Navigator(
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/home':
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            case '/transaction':
              return MaterialPageRoute(
                  builder: (_) => const TransactionScreen());
            // case '/settings':
            //   return MaterialPageRoute(builder: (_) => const SettingsScreen());
            default:
              return MaterialPageRoute(
                builder: (_) => const Center(child: Text('404 Not Found')),
              );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Tambah',
          ),
          // Item bottom bar lainnya
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.amber[800],
      ),
    );
  }
}
