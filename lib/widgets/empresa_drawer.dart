import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmpresaDrawer extends StatelessWidget {
  const EmpresaDrawer({super.key});

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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black12),
            child: Text("Menú Empresa", style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Login"),
            onTap: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dash Board"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/dashboardEg');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Cerrar sesión"),
            onTap: () => _cerrarSesion(context),
          ),

        ],
      ),
    );
  }
}
