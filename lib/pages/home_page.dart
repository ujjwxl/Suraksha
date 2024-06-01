import 'package:flutter/material.dart';
import 'package:trackingapp/pages/fake_call_page.dart';
import 'package:trackingapp/pages/group_page.dart';
import 'package:trackingapp/pages/main_home_page.dart';
import 'package:trackingapp/pages/profile_page.dart';
import 'package:trackingapp/pages/sos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  final List<Widget> pages = [
    const MainHomePage(),
    const GroupPage(),
    const SOSPage(),
    const FakeCallPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking App'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: pages,
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        // indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'My Group',
          ),
          NavigationDestination(
            icon: Icon(Icons.sos),
            label: 'SOS',
          ),
          NavigationDestination(
            icon: Icon(Icons.call),
            label: 'Fake Call',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
