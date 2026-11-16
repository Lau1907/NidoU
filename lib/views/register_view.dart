import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = AppUser.roleEstudiante;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu nombre';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _submitRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );

    if (success && mounted) {
      // Si el registro fue exitoso, cerramos la vista para volver a la raíz
      // donde main.dart mostrará la pantalla principal gracias al cambio de estado.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.arena,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.texto),
          onPressed: () {
            authVM.clearError();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo circular terracota
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.terracota,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.home_outlined,
                        color: AppColors.blanco,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Título
                  const Text(
                    'Crear cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.texto,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtítulo
                  const Text(
                    'Regístrate para encontrar o publicar alojamientos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.texto,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Banner de error visible si existe
                  if (authVM.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.errorFondo,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.terracota.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.terracota,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              authVM.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.errorTexto,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.texto,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => authVM.clearError(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Campo Nombre completo
                  const Text(
                    'Nombre completo',
                    style: TextStyle(
                      color: AppColors.texto,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      color: AppColors.texto,
                      fontSize: 15,
                    ),
                    validator: _validateName,
                    onChanged: (_) => authVM.clearError(),
                    decoration: _inputDecoration(hintText: 'Tu nombre y apellido'),
                  ),
                  const SizedBox(height: 18),

                  // Campo Correo electrónico
                  const Text(
                    'Correo electrónico',
                    style: TextStyle(
                      color: AppColors.texto,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      color: AppColors.texto,
                      fontSize: 15,
                    ),
                    validator: _validateEmail,
                    onChanged: (_) => authVM.clearError(),
                    decoration: _inputDecoration(hintText: 'nombre@correo.com'),
                  ),
                  const SizedBox(height: 18),

                  // Selector de Rol: Estudiante / Arrendador
                  const Text(
                    '¿Qué rol tendrás en NidoU?',
                    style: TextStyle(
                      color: AppColors.texto,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _RoleCard(
                          title: 'Estudiante',
                          subtitle: 'Busco alojamiento',
                          icon: Icons.school_outlined,
                          isSelected: _selectedRole == AppUser.roleEstudiante,
                          onTap: () {
                            setState(() {
                              _selectedRole = AppUser.roleEstudiante;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RoleCard(
                          title: 'Arrendador',
                          subtitle: 'Ofrezco alojamiento',
                          icon: Icons.home_work_outlined,
                          isSelected: _selectedRole == AppUser.roleArrendador,
                          onTap: () {
                            setState(() {
                              _selectedRole = AppUser.roleArrendador;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Campo Contraseña
                  const Text(
                    'Contraseña',
                    style: TextStyle(
                      color: AppColors.texto,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      color: AppColors.texto,
                      fontSize: 15,
                    ),
                    validator: _validatePassword,
                    onChanged: (_) => authVM.clearError(),
                    decoration: _inputDecoration(
                      hintText: 'Mínimo 6 caracteres',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.salvia,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Campo Confirmar contraseña
                  const Text(
                    'Confirmar contraseña',
                    style: TextStyle(
                      color: AppColors.texto,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitRegister(),
                    style: const TextStyle(
                      color: AppColors.texto,
                      fontSize: 15,
                    ),
                    validator: _validateConfirmPassword,
                    onChanged: (_) => authVM.clearError(),
                    decoration: _inputDecoration(
                      hintText: 'Repite tu contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.salvia,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botón Registrarse
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: authVM.isLoading ? null : _submitRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.terracota,
                        foregroundColor: AppColors.blanco,
                        disabledBackgroundColor:
                            AppColors.terracota.withValues(alpha: 0.65),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: authVM.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.blanco,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Crear cuenta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blanco,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Enlace "Ya tengo cuenta"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Ya tienes cuenta? ',
                        style: TextStyle(
                          color: AppColors.texto,
                          fontSize: 14.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          authVM.clearError();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: AppColors.terracota,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.hintTexto,
        fontSize: 15,
      ),
      fillColor: AppColors.blanco,
      filled: true,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.bordeInput,
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.bordeInput,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.salvia,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.terracota,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.terracota,
          width: 2.0,
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.terracota : AppColors.blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.terracota : AppColors.bordeInput,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.terracota.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? AppColors.blanco : AppColors.salvia,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? AppColors.blanco : AppColors.texto,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? AppColors.blanco.withValues(alpha: 0.9)
                    : AppColors.hintTexto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
