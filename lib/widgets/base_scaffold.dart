import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'empresa_drawer.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showDrawer;
  final List<Widget>? actions;

  const BaseScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showDrawer = true,
    this.actions,
  });

  Future<void> _cerrarSesion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('empresa_url');
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/loginEmpresa',
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: showDrawer ? const EmpresaDrawer() : null,
      body: body,
    );
  }
}
