import 'package:doctor_appointment_app/views/admin/admin_home_screen.dart';
import 'package:doctor_appointment_app/viewmodels/login/auth_viewmodel.dart';
import 'package:doctor_appointment_app/views/home/home_screen.dart';
import 'package:doctor_appointment_app/views/user/forgot_password_flow_screens.dart';
import 'package:doctor_appointment_app/views/user/signup_screen.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  static const String _logoAsset = 'assets/images/logo.png';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Sử dụng Singleton instance
  final _authViewModel = AuthViewModel();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _authViewModel.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _navigateAfterLogin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authViewModel.errorMessage ?? 'Đăng nhập thất bại'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _onGoogleSignIn() async {
    setState(() => _isLoading = true);
    final success = await _authViewModel.signInWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _navigateAfterLogin();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_authViewModel.errorMessage ?? 'Đăng nhập Google thất bại'),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateAfterLogin() {
    final isAdmin = _authViewModel.currentUser?.role == 'admin';
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => isAdmin ? const AdminHomeScreen() : const HomeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _buildLogoHeader(),
                const SizedBox(height: 32),
                _buildWelcomeHeader(),
                const SizedBox(height: 32),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 24),
                _buildSignInButton(),
                const SizedBox(height: 23),
                const _OrSeparator(),
                const SizedBox(height: 24),
                _SocialButton(
                  label: 'Đăng nhập bằng Google',
                  icon: Icons.g_mobiledata_rounded,
                  iconColor: const Color(0xFFEA4335),
                  onPressed: _isLoading ? () {} : _onGoogleSignIn,
                ),
                const SizedBox(height: 16),
                _SocialButton(
                  label: 'Đăng nhập bằng Facebook',
                  icon: Icons.facebook_rounded,
                  iconColor: const Color(0xFF1877F2),
                  onPressed: () {},
                ),
                const SizedBox(height: 24),
                _buildForgotPasswordLink(),
                const SizedBox(height: 16),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        Image.asset(
          _logoAsset,
          width: 66,
          height: 66,
          color: const Color(0xFF1C2A3A),
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.local_hospital_outlined, size: 66, color: Color(0xFF1C2A3A)),
        ),
        const SizedBox(height: 16),
        const Text(
          'AnKhang',
          style: TextStyle(fontSize: 20, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return const Column(
      children: [
        Text(
          'Chào mừng bạn trở lại!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1C2A3A)),
        ),
        SizedBox(height: 8),
        Text(
          'Hy vọng bạn đang có một ngày tốt lành.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: _authViewModel.validateEmail,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: _inputDecoration(hint: 'Email', icon: Icons.mail_outline),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: _authViewModel.validatePassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: _inputDecoration(
        hint: 'Mật khẩu',
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C2A3A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(54)),
        ),
        child: _isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Đăng nhập', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
        child: const Text('Quên mật khẩu?', style: TextStyle(color: Color(0xFF1C64F2), fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SignUpScreen())),
        child: RichText(
          text: const TextSpan(
            text: 'Bạn chưa có tài khoản? ',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            children: [
              TextSpan(text: 'Đăng ký', style: TextStyle(color: Color(0xFF1C64F2), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1C2A3A))),
    );
  }
}

class _OrSeparator extends StatelessWidget {
  const _OrSeparator();
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('hoặc', style: TextStyle(color: Color(0xFF6B7280)))),
        Expanded(child: Divider()),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon, required this.iconColor, required this.onPressed});
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor),
        label: Text(label, style: const TextStyle(color: Color(0xFF1C2A3A))),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
