import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailCtrl = TextEditingController(
    text: 'testaa@yopmail.com',
  );
  final TextEditingController _passwordCtlr = TextEditingController(
    text: 'password123',
  );
  String _status = 'Listo para conectar';

  final String backendUrl = 'https://api.chiribito.com';

  // Lógica de Registro/Login
  Future<void> _signIn() async {
    // 1. setState inicial: Se puede hacer sin mounted ya que es síncrono
    setState(() => _status = 'Logeando/Registrando...');
    
    try {
      // 1. Intentar registrar (crear cuenta)
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailCtrl.text,
            password: _passwordCtlr.text,
          );
      
      // 🚨 CORRECCIÓN 1: Comprobar si el widget sigue montado
      if (mounted) {
        setState(() {
          _status = 'Registrado ${userCredential.user?.email}';
        });
      }
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // 2. Si ya existe, intentar logear
        try {
          UserCredential userCredential = await _auth
              .signInWithEmailAndPassword(
                email: _emailCtrl.text,
                password: _passwordCtlr.text,
              );
          
          // 🚨 CORRECCIÓN 2: Comprobar si el widget sigue montado
          // Si el login es exitoso, AuthWrapper navegará a GameScreen, 
          // destruyendo este widget.
          if (mounted) {
            setState(() {
              _status = 'Logeado como:  ${userCredential.user?.email}';
            });
          }
          
        } on FirebaseAuthException catch (e) {
          if (mounted) {
            setState(() {
              _status = 'Login failed: ${e.message}';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _status = 'Error de Firebase: ${e.code}';
          });
        }
      }
    }
    if (mounted) {
      await _testBackendConnection();
    }
  }

  // Lógica de Prueba de Conexión HTTP al Backend
  Future<void> _testBackendConnection() async {
    User? user = _auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _status = 'Usuario no autenticado');
      return;
    }

    // setState inicial
    if (mounted) setState(() => _status = 'Obteniendo token de ID y conectando Render...');
    
    String? token = await user.getIdToken();
    if (token == null) {
      if (mounted) setState(() => _status = 'No se pudo obtener el token de ID');
      return;
    }

    try{
      final response = await http.post(
        Uri.parse('$backendUrl/api/data'),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer $token",
        },
        body:
            '{"key": "last_login", "value": "${DateTime.now().toIso8601String()}"}',
      );

      if (mounted) {
        if (response.statusCode == 200) {
            setState(() {
              _status = '✅ Conexión OK: Datos guardados en Redis (200)';
            });
          } else if (response.statusCode == 401 || response.statusCode == 403) {
            setState(() {
              _status = '❌ ERROR ${response.statusCode}: Token Rechazado (Revisar middleware)';
            });
          }
          else {
            setState(() {
              _status = '❌ ERROR ${response.statusCode}: Servidor falló. Revisar logs de Render.';
            });
          }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = '❌ ERROR DE CONEXIÓN: No se pudo conectar al host. (Verificar URL/Red)';
        });
      }
      print('HTTP EXCEPTION: $e');
    }
  }

  // Interfaz de Usuario (UI)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Login CHIRIBITO'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordCtlr,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Logear y Probar Conexión HTTP'),
              ),
              const SizedBox(height: 30),
              const Text(
                "Estado de la conexión:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SelectableText(
                _status,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}