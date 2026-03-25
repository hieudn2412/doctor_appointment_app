import 'package:doctor_appointment_app/viewmodels/login/auth_viewmodel.dart';
import 'package:doctor_appointment_app/views/user/signin_screen.dart';
import 'package:doctor_appointment_app/views/profile/fill_profile_screen.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const String _logoAsset = 'assets/images/logo.png';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Sử dụng AuthViewModel (Singleton đã được cập nhật)
  final _authViewModel = AuthViewModel();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    // 1. Kiểm tra validation form (bao gồm confirm password)
    if (!_formKey.currentState!.validate()) return;

    // 2. Kiểm tra điều khoản
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng đồng ý với điều khoản sử dụng'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 3. Gọi API/DB thông qua ViewModel
    final success = await _authViewModel.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Đăng ký thành công, thông tin user đã có trong AuthViewModel.currentUser
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đăng ký thành công!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // Chuyển sang màn hình hoàn thiện hồ sơ
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const FillProfileScreen(),
        ),
      );
    } else {
      // Hiển thị lỗi từ ViewModel (VD: Email đã tồn tại)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authViewModel.errorMessage ?? 'Đăng ký thất bại'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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
                // ── Logo ──
                Column(
                  children: [
                    Image.asset(
                      _logoAsset,
                      width: 66,
                      height: 66,
                      color: const Color(0xFF1C2A3A),
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.local_hospital_outlined,
                          size: 66,
                          color: Color(0xFF1C2A3A),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AnKhang',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // ── Header ──
                const _HeaderText(),
                const SizedBox(height: 32),
                // ── Name ──
                _buildNameField(),
                const SizedBox(height: 20),
                // ── Email ──
                _buildEmailField(),
                const SizedBox(height: 20),
                // ── Password ──
                _buildPasswordField(),
                const SizedBox(height: 20),
                // ── Confirm Password ──
                _buildConfirmPasswordField(),
                const SizedBox(height: 16),
                // ── Terms checkbox ──
                _buildTermsCheckbox(),
                const SizedBox(height: 24),
                // ── Sign Up Button ──
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSignUp,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF1C2A3A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(66),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Đăng ký',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                const _OrSeparator(),
                const SizedBox(height: 24),
                _SocialButton(
                  label: 'Tiếp tục với Google',
                  icon: Icons.g_mobiledata_rounded,
                  iconColor: const Color(0xFFEA4335),
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                _SocialButton(
                  label: 'Tiếp tục với Facebook',
                  icon: Icons.facebook_rounded,
                  iconColor: const Color(0xFF1877F2),
                  onPressed: () {},
                ),
                const SizedBox(height: 24),
                // ── Sign In link ──
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'Bạn đã có tài khoản? ',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Đăng nhập',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      validator: _authViewModel.validateName,
      decoration: _inputDecoration(hint: 'Họ và tên', icon: Icons.person_outline),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: _authViewModel.validateEmail,
      decoration: _inputDecoration(hint: 'Email', icon: Icons.mail_outline),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      validator: _authViewModel.validatePassword,
      decoration: _inputDecoration(
        hint: 'Mật khẩu',
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: const Color(0xFF9CA3AF),
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      validator: (value) => _authViewModel.validateConfirmPassword(
        value,
        _passwordController.text,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: _inputDecoration(
        hint: 'Nhập lại mật khẩu',
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: const Color(0xFF9CA3AF),
          ),
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
            activeColor: const Color(0xFF1C2A3A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Tôi đồng ý với Điều khoản và Chính sách bảo mật',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ),
      ],
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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1C2A3A)),
      ),
      errorStyle: const TextStyle(fontSize: 12),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText();
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Đăng ký tài khoản',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1C2A3A)),
        ),
        SizedBox(height: 8),
        Text(
          'Chúng tôi luôn sẵn sàng hỗ trợ bạn!',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _OrSeparator extends StatelessWidget {
  const _OrSeparator();
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFE5E7EB))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('hoặc', style: TextStyle(color: Color(0xFF6B7280))),
        ),
        Expanded(child: Divider(color: Color(0xFFE5E7EB))),
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
