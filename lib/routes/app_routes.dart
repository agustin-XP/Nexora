import 'package:flutter/cupertino.dart';
import 'package:nexora/%20modules/dashboard/edge_web_view.dart.dart';
import 'package:nexora/%20modules/login/login_empresa_page.dart';
import 'package:nexora/%20modules/login/login_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/loginEmpresa': (_) => const LoginEmpresaPage(),
  '/login': (context) => const LoginPage(),
  '/dashboardEg': (context) => const EdgeWebViewPage(),
};
