import 'package:flutter/material.dart';
import '../widgets/mobile_dashboard.dart';
import '../widgets/web_dashboard.dart';
import '../widgets/sidebar.dart';

class DashboardGuru extends StatelessWidget {
  const DashboardGuru({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(
        title: const Text(
          'EduConnect',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF465940),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const Sidebar(),
      body: const SafeArea(
        child: ResponsiveDashboard(),
      ),
    );
  }
}

class ResponsiveDashboard extends StatelessWidget {
  const ResponsiveDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return const MobileDashboard();
        } else {
          return const WebDashboard();
        }
      },
    );
  }
}