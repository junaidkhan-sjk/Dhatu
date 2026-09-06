import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/theme_service.dart';
import 'onboarding_screen.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController(text: '9876543210');
  final _otpController = TextEditingController(text: '123456');
  final _nameController = TextEditingController(text: 'रमेश कुमार (कबाड़ी)');

  bool _otpSent = false;
  bool _loading = false;
  String? _errorMessage;
  String _selectedLanguage = 'hi';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
    _checkExistingSession();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('dhatu_auth_token');
    if (token != null && token.isNotEmpty && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  Future<void> _completeLogin(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dhatu_auth_token', token);
    await prefs.setString('dhatu_user', json.encode(user));

    if (mounted) {
      final isFirstTime = prefs.getBool('dhatu_onboarded') ?? false;
      if (!isFirstTime) {
        await prefs.setBool('dhatu_onboarded', true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    }
  }

  Future<void> _quickDemoLogin() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final res = await http.post(
        Uri.parse('${ApiService().baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': '9876543210',
          'otp': '123456',
          'role': 'collector',
          'name': 'रमेश कुमार (कबाड़ी)',
          'language': _selectedLanguage,
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        await _completeLogin(data['token'], data['user']);
        return;
      }
    } catch (_) {}

    final mockUser = {
      'id': 'demo-collector-001',
      'phone': '9876543210',
      'name': 'रमेश कुमार (कबाड़ी)',
      'role': 'collector',
      'language': _selectedLanguage,
      'dataMaturity': 'demo'
    };
    await _completeLogin('demo_jwt_token_offline_collector', mockUser);
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() => _errorMessage = 'कृपया 10 अंकों का मोबाइल नंबर डालें');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final res = await http.post(
        Uri.parse('${ApiService().baseUrl}/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone}),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        setState(() {
          _otpSent = true;
          _loading = false;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _otpSent = true;
      _loading = false;
    });
  }

  Future<void> _verifyOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length < 4) {
      setState(() => _errorMessage = 'कृपया OTP दर्ज करें');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final res = await http.post(
        Uri.parse('${ApiService().baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'otp': otp,
          'role': 'collector',
          'name': _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : 'रमेश कुमार (कबाड़ी)',
          'language': _selectedLanguage,
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        await _completeLogin(data['token'], data['user']);
        return;
      }
    } catch (_) {}

    if (otp == '123456' || otp == '000000') {
      final mockUser = {
        'id': 'demo-collector-001',
        'phone': phone,
        'name': _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'रमेश कुमार (कबाड़ी)',
        'role': 'collector',
        'language': _selectedLanguage,
        'dataMaturity': 'demo'
      };
      await _completeLogin('demo_jwt_token_offline_collector', mockUser);
    } else {
      setState(() {
        _errorMessage = 'गलत OTP! डेमो के लिए 123456 का उपयोग करें।';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    final primaryText = isDark ? ThemeService.darkTextPrimary : ThemeService.lightTextPrimary;
    final secondaryText = isDark ? ThemeService.darkTextSecondary : ThemeService.lightTextSecondary;
    final accentColor = isDark ? ThemeService.darkAccent : ThemeService.lightAccent;

    return Scaffold(
      backgroundColor: isDark ? ThemeService.darkCanvas : ThemeService.lightCanvas,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Action Bar with Neumorphic Theme Switcher
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => themeService.toggleTheme(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: ThemeService.neuRaised(
                        isDark: isDark,
                        radius: 14,
                        depth: 4,
                        blur: 8,
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: accentColor,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Neumorphic Logo Icon
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: ThemeService.neuRaised(
                      isDark: isDark,
                      radius: 26,
                      depth: 8,
                      blur: 16,
                    ),
                    child: Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2B4A) : const Color(0xFFDFE6F0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.recycling_rounded,
                          size: 34,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'धातु · DHATU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: primaryText,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'कबाड़ी लॉगिन · Ragpicker Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'हर तार में मूल्य · Value in Every Wire',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
                const SizedBox(height: 24),

                // ⚡ Neumorphic Quick Demo Login Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: ThemeService.neuRaised(
                    isDark: isDark,
                    radius: 24,
                    depth: 7,
                    blur: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: ThemeService.neuInset(isDark: isDark, radius: 10),
                            child: const Icon(Icons.bolt_rounded, color: Colors.amber, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'एक-क्लिक डेमो लॉगिन',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryText),
                                ),
                                Text(
                                  '1-Click Quick Demo Login (Ramesh)',
                                  style: TextStyle(fontSize: 11, color: secondaryText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _loading ? null : _quickDemoLogin,
                        child: Container(
                          height: 48,
                          decoration: ThemeService.neuButton(
                            isDark: isDark,
                            radius: 14,
                            accentColor: accentColor,
                          ),
                          child: Center(
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login_rounded, size: 18, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'सीधा प्रवेश करें (Instant Demo Enter)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white,
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
                const SizedBox(height: 20),

                // Neumorphic Manual Form Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: ThemeService.neuRaised(
                    isDark: isDark,
                    radius: 24,
                    depth: 6,
                    blur: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'मोबाइल नंबर (Phone Number)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Neumorphic Inset Phone Input
                      Container(
                        decoration: ThemeService.neuInset(isDark: isDark, radius: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              '+91',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              color: secondaryText.withOpacity(0.2),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                enabled: !_otpSent,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryText,
                                  fontFamily: 'monospace',
                                  letterSpacing: 2,
                                ),
                                decoration: InputDecoration(
                                  hintText: '9876543210',
                                  hintStyle: TextStyle(
                                    color: secondaryText.withOpacity(0.5),
                                    fontWeight: FontWeight.normal,
                                  ),
                                  border: InputBorder.none,
                                  counterText: '',
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_otpSent) ...[
                        const SizedBox(height: 16),
                        Text(
                          'आपका नाम (Your Name)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: secondaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: ThemeService.neuInset(isDark: isDark, radius: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: TextField(
                            controller: _nameController,
                            style: TextStyle(fontSize: 14, color: primaryText),
                            decoration: InputDecoration(
                              hintText: 'रमेश कुमार (कबाड़ी)',
                              hintStyle: TextStyle(color: secondaryText.withOpacity(0.5)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              prefixIcon: Icon(Icons.person_outline_rounded, color: accentColor, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'OTP दर्ज करें (Enter OTP)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Neumorphic Inset OTP Field
                        Container(
                          decoration: ThemeService.neuInset(isDark: isDark, radius: 14),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: primaryText,
                              fontFamily: 'monospace',
                              letterSpacing: 6,
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '123456',
                              hintStyle: TextStyle(
                                color: secondaryText.withOpacity(0.3),
                                letterSpacing: 4,
                              ),
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'डेमो OTP: 123456',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: accentColor,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(isDark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      // Neumorphic Submit Button
                      GestureDetector(
                        onTap: _loading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                        child: Container(
                          height: 50,
                          decoration: ThemeService.neuRaised(
                            isDark: isDark,
                            radius: 14,
                            customSurface: isDark ? const Color(0xFF1E2B4A) : const Color(0xFFDFE6F0),
                            depth: 5,
                            blur: 10,
                          ),
                          child: Center(
                            child: _loading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: accentColor, strokeWidth: 2.5),
                                  )
                                : Text(
                                    _otpSent ? 'सत्यापित करें (Verify OTP)' : 'OTP भेजें (Send OTP)',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: primaryText,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      if (_otpSent) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _otpSent = false;
                                _errorMessage = null;
                              });
                            },
                            child: Text(
                              'नंबर बदलें (Change Number)',
                              style: TextStyle(
                                fontSize: 12,
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Neumorphic Language Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNeuLangChip('हिन्दी', 'hi', isDark, accentColor, primaryText, secondaryText),
                    const SizedBox(width: 10),
                    _buildNeuLangChip('मराठी', 'mr', isDark, accentColor, primaryText, secondaryText),
                    const SizedBox(width: 10),
                    _buildNeuLangChip('EN', 'en', isDark, accentColor, primaryText, secondaryText),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  'Dhatu · E-Waste Regularization Platform · SIH 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: secondaryText.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeuLangChip(
    String label,
    String code,
    bool isDark,
    Color accentColor,
    Color primaryText,
    Color secondaryText,
  ) {
    final isActive = _selectedLanguage == code;
    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? ThemeService.neuInset(isDark: isDark, radius: 12)
            : ThemeService.neuRaised(isDark: isDark, radius: 12, depth: 3, blur: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? accentColor : secondaryText,
          ),
        ),
      ),
    );
  }
}
