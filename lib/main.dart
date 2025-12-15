import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'CHIRIBITO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailCtrl = TextEditingController(
    text: 'testaa@yopmail.com',
  );
  final TextEditingController _passwordCtlr = TextEditingController(
    text: 'password123',
  );
  String _status = 'Listo para conectar';

  final String backendUrl = 'https://api.chiribito.com';

  Future<void> _signIn() async {
    setState(() => _status = 'Logeando/Registrando...');
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailCtrl.text,
            password: _passwordCtlr.text,
          );
      setState(() {
        _status = 'Registrado ${userCredential.user?.email}';
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          UserCredential userCredential = await _auth
              .signInWithEmailAndPassword(
                email: _emailCtrl.text,
                password: _passwordCtlr.text,
              );
          setState(() {
            _status = 'Logeado como:  ${userCredential.user?.email}';
          });
        } on FirebaseAuthException catch (e) {
          setState(() {
            _status = 'Login failed: ${e.message}';
          });
        }
      } else {
        setState(() {
          _status = 'Error de Firebase: ${e.code}';
        });
      }
    }
    await _testBackendConnection();
  }

  Future<void> _testBackendConnection() async {
    User? user = _auth.currentUser;
    if (user == null) {
      setState(() => _status = 'Usuario no autenticado');
      return;
    }

    setState(() => _status = 'Obteniendo token de ID y conectando Render...');

    String? token = await user.getIdToken();
    if (token == null) {
      setState(() => _status = 'No se pudo obtener el token de ID');
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
    } catch (e) {
      // 4. CAPTURAR ERRORES DE RED (ej: DNS, Timeout)
      setState(() {
        _status = '❌ ERROR DE CONEXIÓN: No se pudo conectar al host. (Verificar URL/Red)';
      });
      print('HTTP EXCEPTION: $e'); // Imprime el error completo en la consola
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
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
                child: const Text('Conectar a Render'),
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
