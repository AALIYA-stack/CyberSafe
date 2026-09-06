import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // ADMIN LOGIN
  // ==========================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // ------------------------------------------------------
      // FIREBASE LOGIN
      // ------------------------------------------------------

      final success = await AuthService.instance.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!success) {
        if (!mounted) return;

        _showMessage(
          'Invalid admin email or password.',
          isError: true,
        );

        return;
      }

      // ------------------------------------------------------
      // VERIFY ADMIN ROLE FROM FIRESTORE
      // ------------------------------------------------------

      final isAdmin = await AuthService.instance.isAdmin();

      if (!mounted) return;

      // ------------------------------------------------------
      // NOT AN ADMIN
      // ------------------------------------------------------

      if (!isAdmin) {
        await AuthService.instance.logout();

        if (!mounted) return;

        _showMessage(
          'This account does not have administrator access.',
          isError: true,
        );

        return;
      }

      // ------------------------------------------------------
      // ADMIN VERIFIED
      // ------------------------------------------------------

      debugPrint('ADMIN LOGIN SUCCESS');

      debugPrint(
        'ADMIN UID: ${AuthService.instance.currentUser?.uid}',
      );

      // ------------------------------------------------------
      // IMPORTANT:
      // After successful admin verification,
      // open complete AdminShell instead of only Dashboard.
      // ------------------------------------------------------

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.adminShell,
            (route) => false,
      );
    } catch (e) {
      debugPrint('ADMIN LOGIN ERROR: $e');

      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ==========================================================
  // EMAIL VALIDATION
  // ==========================================================

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter admin email';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // ==========================================================
  // PASSWORD VALIDATION
  // ==========================================================

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter password';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
          onPressed: _isLoading
              ? null
              : () {
            Navigator.pop(context);
          },
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),

            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,

                  children: [
                    // ==================================================
                    // ADMIN ICON
                    // ==================================================

                    Container(
                      width: 88,
                      height: 88,

                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    Text(
                      'Admin Login',
                      textAlign: TextAlign.center,

                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to access the CyberSafe administration panel.',
                      textAlign: TextAlign.center,

                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ==================================================
                    // SECURITY INFO
                    // ==================================================

                    Container(
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),

                        borderRadius:
                        BorderRadius.circular(14),

                        border: Border.all(
                          color:
                          AppColors.primary.withOpacity(0.15),
                        ),
                      ),

                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              'Administrator access is verified through Firebase Authentication and Firestore role permissions.',

                              style:
                              theme.textTheme.bodySmall?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // EMAIL
                    // ==================================================

                    TextFormField(
                      controller: _emailController,

                      keyboardType:
                      TextInputType.emailAddress,

                      textInputAction:
                      TextInputAction.next,

                      enabled: !_isLoading,

                      validator: _validateEmail,

                      decoration: InputDecoration(
                        labelText: 'Admin Email',

                        hintText: 'Enter admin email',

                        prefixIcon: const Icon(
                          Icons.email_outlined,
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),

                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // PASSWORD
                    // ==================================================

                    TextFormField(
                      controller: _passwordController,

                      obscureText: _obscurePassword,

                      textInputAction:
                      TextInputAction.done,

                      enabled: !_isLoading,

                      validator: _validatePassword,

                      onFieldSubmitted: (_) => _login(),

                      decoration: InputDecoration(
                        labelText: 'Password',

                        hintText: 'Enter admin password',

                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),

                        suffixIcon: IconButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            setState(() {
                              _obscurePassword =
                              !_obscurePassword;
                            });
                          },

                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),

                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // LOGIN BUTTON
                    // ==================================================

                    SizedBox(
                      height: 54,

                      child: ElevatedButton(
                        onPressed:
                        _isLoading ? null : _login,

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.primary,

                          foregroundColor:
                          Colors.white,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),

                          elevation: 0,
                        ),

                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,

                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,

                          children: [
                            Icon(
                              Icons.login_rounded,
                            ),

                            SizedBox(width: 10),

                            Text(
                              'Login as Admin',

                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // NORMAL USER LOGIN
                    // ==================================================

                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },

                      child: const Text(
                        'Login as Normal User',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // SECURITY FOOTER
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 15,
                          color: Colors.grey.shade600,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          'Secure administrator access',

                          style:
                          theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
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
    );
  }
}