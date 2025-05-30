import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nexora/widgets/base_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EdgeWebViewPage extends StatefulWidget {
  const EdgeWebViewPage({super.key});

  @override
  State<EdgeWebViewPage> createState() => _EdgeWebViewPageState();
}

class _EdgeWebViewPageState extends State<EdgeWebViewPage> {
  InAppWebViewController? webViewController;
  bool _isLoading = true;
  String? storedUrl; // ← variable global para usar luego

  @override
  void initState() {
    super.initState();
    _prepararWebView();
  }

  Future<void> _prepararWebView() async {
    await CookieManager.instance().deleteAllCookies();
    await _loadEmpresaUrl();
  }

  Future<void> _loadEmpresaUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('empresa_url');

    if (url == null || url.isEmpty) {
      _mostrarError("No se encontró la URL de la empresa.");
      return;
    }

    storedUrl = url;

    final fullUrl = WebUri('$storedUrl/FrmBitacoraClientes.aspx');

    webViewController?.loadUrl(
      urlRequest: URLRequest(
        url: fullUrl,
        headers: {
          "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0 Edg/124.0.2478.97",
          "X-Requested-With": "com.microsoft.emmx"
        },
      ),
    );
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (webViewController != null) {
          final canGoBack = await webViewController!.canGoBack();
          if (canGoBack) {
            webViewController!.goBack();
            return false; // No salir de la app
          }
        }
        return true; // Salir si no hay historial
      },
      child: BaseScaffold(
        title: 'Portal Empresa',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () {
              webViewController?.reload(); // Recargar la página
            },
          ),
        ],
        body: Stack(
          children: [
            InAppWebView(
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useHybridComposition: false,
                supportZoom: true,
                transparentBackground: false,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
                if (storedUrl != null) {
                  final fullUrl = WebUri('$storedUrl/FrmBitacoraClientes.aspx');
                  controller.loadUrl(
                    urlRequest: URLRequest(
                      url: fullUrl,
                      headers: {
                        "User-Agent":
                        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0 Edg/124.0.2478.97",
                        "X-Requested-With": "com.microsoft.emmx"
                      },
                    ),
                  );
                }
              },
              onLoadStop: (controller, url) async {
                await controller.evaluateJavascript(source: """ 
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0';
                document.getElementsByTagName('head')[0].appendChild(meta);
              """);
                setState(() => _isLoading = false);
              },
              onLoadError: (controller, url, code, message) {
                setState(() => _isLoading = false);
                debugPrint("❌ Error al cargar: $code - $message");
              },
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

}
