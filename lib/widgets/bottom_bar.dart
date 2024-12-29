import 'package:aplikasi_pencatatan/screens/add_transaction_screen.dart';
import 'package:aplikasi_pencatatan/screens/home_screen.dart';
import 'package:aplikasi_pencatatan/screens/transaction_screen.dart';
import 'package:flutter/material.dart';

class PersistentBottomBar extends StatefulWidget {
  const PersistentBottomBar({Key? key}) : super(key: key);

  @override
  State<PersistentBottomBar> createState() => _PersistentBottomBarState();
}

class _PersistentBottomBarState extends State<PersistentBottomBar> {
  int _selectedIndex = 0;
  String _appBarTitle = 'Aplikasi Pencatatan'; // Judul awal AppBar

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    AddTransactionScreen(),
    TransactionScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Perbarui judul AppBar berdasarkan index yang dipilih
      switch (index) {
        case 0:
          _appBarTitle = 'Aplikasi Pencatatan';
          break;
        case 1:
          _appBarTitle = 'Tambah Transaksi';
          break;
        case 2:
          _appBarTitle = 'Riwayat Transaksi';
          break;
        default:
          _appBarTitle = 'Aplikasi Pencatatan'; // Judul default
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle), // Gunakan variabel _appBarTitle
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
                'Menu Utama',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Beranda'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0); // Panggil _onItemTapped dengan index yang sesuai
              },
            ),
            // ... (Opsi Drawer Lainnya)
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat Transaksi',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.amber[800],
      ),
    );
  }
}