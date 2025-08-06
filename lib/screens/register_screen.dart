import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'main_screen.dart';

class RegisterScreen
    extends
        StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<
    RegisterScreen
  >
  createState() => _RegisterScreenState();
}

class _RegisterScreenState
    extends
        State<
          RegisterScreen
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(
      () => _isLoading = true,
    );

    final success = await AuthService().signUpWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(
      () => _isLoading = false,
    );

    if (success &&
        mounted) {
      Navigator.of(
        context,
      ).pushReplacement(
        MaterialPageRoute(
          builder:
              (
                context,
              ) => const MainScreen(),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Kayıt başarısız. Lütfen tekrar deneyin.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<
    void
  >
  _signUpWithGoogle() async {
    setState(
      () => _isLoading = true,
    );

    final success = await AuthService().signInWithGoogle();

    setState(
      () => _isLoading = false,
    );

    if (success &&
        mounted) {
      Navigator.of(
        context,
      ).pushReplacement(
        MaterialPageRoute(
          builder:
              (
                context,
              ) => const MainScreen(),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Google ile kayıt başarısız.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(
                0xFF667eea,
              ),
              Color(
                0xFF764ba2,
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                24,
              ),
              child: Card(
                elevation: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppConstants.projectName,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(
                              0xFF667eea,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text(
                          'Hesap oluşturun',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: const Icon(
                              Icons.email,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          validator:
                              (
                                value,
                              ) {
                                if (value ==
                                        null ||
                                    value.isEmpty) {
                                  return 'E-posta gerekli';
                                }
                                if (!value.contains(
                                  '@',
                                )) {
                                  return 'Geçerli bir e-posta girin';
                                }
                                return null;
                              },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: const Icon(
                              Icons.lock,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(
                                  () {
                                    _obscurePassword = !_obscurePassword;
                                  },
                                );
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          validator:
                              (
                                value,
                              ) {
                                if (value ==
                                        null ||
                                    value.isEmpty) {
                                  return 'Şifre gerekli';
                                }
                                if (value.length <
                                    6) {
                                  return 'Şifre en az 6 karakter olmalı';
                                }
                                return null;
                              },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Şifre Tekrar',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(
                                  () {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  },
                                );
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          validator:
                              (
                                value,
                              ) {
                                if (value ==
                                        null ||
                                    value.isEmpty) {
                                  return 'Şifre tekrarı gerekli';
                                }
                                if (value !=
                                    _passwordController.text) {
                                  return 'Şifreler eşleşmiyor';
                                }
                                return null;
                              },
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF667eea,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Kayıt Ol',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : _signUpWithGoogle,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                            ),
                            icon: const Text(
                              'G',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            label: const Text(
                              'Google ile Kayıt Ol',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Zaten hesabınız var mı? ',
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(
                                  context,
                                ).pop();
                              },
                              child: const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  color: Color(
                                    0xFF667eea,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
