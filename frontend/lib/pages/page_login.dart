import 'package:flutter/material.dart';

enum UserType { client, admin }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  UserType selectedType = UserType.client;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Completa todos los campos');
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(microseconds: 700));

    if (!mounted) return;

    setState(() => isLoading = false);
    selectedType == UserType.client
        ? Navigator.pushReplacementNamed(context, '/client')
        : Navigator.pushReplacementNamed(context, '/admin');
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isClient = selectedType == UserType.client;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5), Color(0xFFFFFBEB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _builLogo(),
                  const SizedBox(height: 18),
                  const Text(
                    'Bolitos App',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF97316),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Los mejores bolos de la ciudad',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black45, fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  _builLoginCard(isClient),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _builLogo() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF97316), Color(0xFFEAB308)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.icecream_sharp, size: 52, color: Colors.white),
    );
  }

  _builLoginCard(bool isClient) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _roleButton(
                  text: 'Cliente',
                  selected: selectedType == UserType.client,
                  colors: const [Color(0xFFF97316), Color(0xFFEAB308)],
                  onTap: () {
                    setState(() => selectedType = UserType.client);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _roleButton(
                  text: 'Admin',
                  selected: selectedType == UserType.admin,
                  colors: const [Color(0xFF9333EA), Color(0xFF4F46E5)],
                  onTap: () {
                    setState(() => selectedType = UserType.admin);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          _inputField(
            label: 'Correo',
            hint: 'Ingresa tu correo',
            icon: Icons.person_outline,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 18),

          _inputField(
            label: 'Contraseña',
            hint: 'Ingresa tu contraseña',
            icon: Icons.lock_outline,
            controller: passwordController,
            obscureText: hidePassword,
            suffixIcon: IconButton(
              icon: Icon(
                hidePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() => hidePassword = !hidePassword);
              },
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : login,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                elevation: 8,
                shadowColor: isClient
                    ? Colors.orange.withOpacity(0.35)
                    : Colors.indigo.withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isClient
                        ? const [Color(0xFFF97316), Color(0xFFEAB308)]
                        : const [Color(0xFF9333EA), Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          TextButton(
            onPressed: () {
              showMessage('Luego conectamos la pantalla de registro');
            },
            child: const Text.rich(
              TextSpan(
                text: '¿No tienes cuenta? ',
                style: TextStyle(color: Colors.black54),
                children: [
                  TextSpan(
                    text: 'Regístrate aquí',
                    style: TextStyle(
                      color: Color(0xFFF97316),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _roleButton({
    required String text,
    required bool selected,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? LinearGradient(colors: colors) : null,
          color: selected ? null : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colors.first.withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
