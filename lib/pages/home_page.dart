import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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
      // appBar: AppBar(
      //   title: Text('Tracking App'),
      //   centerTitle: true,
      // ),
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
            selectedIcon: Icon(Iconsax.home1),
            icon: Icon(Iconsax.home),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Iconsax.people5),
            icon: Icon(Iconsax.people),
            label: 'My Group',
          ),
          NavigationDestination(
            icon: Icon(Icons.sos),
            label: 'SOS',
          ),
          NavigationDestination(
            selectedIcon: Icon(Iconsax.call5),
            icon: Icon(Iconsax.call),
            label: 'Fake Call',
          ),
          NavigationDestination(
            selectedIcon: Icon(Iconsax.profile_2user5),
            icon: Icon(Iconsax.profile_2user4),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
