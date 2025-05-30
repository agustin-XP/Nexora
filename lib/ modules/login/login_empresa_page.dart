import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginEmpresaPage extends StatefulWidget {
  const LoginEmpresaPage({super.key});

  @override
  State<LoginEmpresaPage> createState() => _LoginEmpresaPageState();
}



class _LoginEmpresaPageState extends State<LoginEmpresaPage> {

  @override
  void initState() {
    super.initState();
    _verificarSesionEmpresa();
  }

  final TextEditingController _urlController = TextEditingController( text: "https://app.agrota.com.ec/");
  bool _isLoading = false;

  Future<void> _validarYGuardarUrl() async {
    final rawUrl = _urlController.text.trim();

    if (rawUrl.isEmpty) {
      _mostrarAlerta("Por favor ingresa una URL válida.");
      return;
    }

    setState(() => _isLoading = true);

    String baseUrl = rawUrl.endsWith('/') ? rawUrl.substring(0, rawUrl.length - 1) : rawUrl;
    final testUrl = Uri.parse(baseUrl);

    try {
      final response = await http.get(testUrl).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('empresa_url', baseUrl);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboardEg'); // o donde cargues WebView
      } else {
        _mostrarAlerta("La URL respondió con código ${response.statusCode}, pero no se pudo validar.");
      }
    } catch (e) {
      _mostrarAlerta("No se pudo conectar con la URL ingresada.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verificarSesionEmpresa() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUrl = prefs.getString('empresa_url');

    if (storedUrl != null && storedUrl.isNotEmpty) {
      // Redirige automáticamente si ya hay una empresa guardada
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboardEg');
      }
    }
  }

  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error de conexión'),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingreso de Empresa')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Ingresa la URL (con puerto si aplica):"),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'http://192.168.0.100:8080',

              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text("Validar y continuar"),
              onPressed: _validarYGuardarUrl,
            )
          ],
        ),
      ),
    );
  }
}
