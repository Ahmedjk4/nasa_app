import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nasa_app/generated/l10n.dart';
import 'package:nasa_app/utils/app_router.dart';
import 'package:nasa_app/utils/auth_firebase.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Space color palette
  static const Color spaceBlack = Color(0xFF0B0E1A);
  static const Color nebulaPurple = Color(0xFF6366F1);
  static const Color starWhite = Color(0xFFF8FAFC);
  static const Color cosmicBlue = Color(0xFF1E293B);
  static const Color galaxyPink = Color(0xFFEC4899);
  // static const Color nebulaBlue = Color(0xFF3B82F6);

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (value.contains(' ')) {
      return 'Email cannot contain spaces';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _registerPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);
        await AuthFirebase.signInWithEmail(
          email: _loginEmailController.text.trim(),
          password: _loginPasswordController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${S.of(context).loginSuccessfully}! 🚀'),
              backgroundColor: nebulaPurple,
            ),
          );
          context.go(AppRouter.mainPath);
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: galaxyPink,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_registerFormKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);
        await AuthFirebase.signUpWithEmail(
          name: _nameController.text.trim(),
          email: _registerEmailController.text.trim(),
          password: _registerPasswordController.text,
        );

        // Send email verification
        await AuthFirebase.sendEmailVerification();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${S.of(context).registerSuccessfully}! 🌌\nPlease check your email for verification.',
              ),
              backgroundColor: nebulaPurple,
              duration: Duration(seconds: 5),
            ),
          );
          // Automatically switch to login view after successful registration
          setState(() {
            isLogin = true;
            _autoValidateMode = AutovalidateMode.disabled;
          });
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: galaxyPink,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });
    }
  }

  Widget _buildStarField() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(painter: StarFieldPainter()),
    );
  }

  Widget _buildSpaceTextField({
    required TextInputType type,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        cursorColor: Colors.white,
        keyboardType: type,
        controller: controller,
        obscureText: obscureText,
        autovalidateMode: _autoValidateMode,
        validator: validator,
        style: TextStyle(color: starWhite, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: starWhite.withValues(alpha: 0.8)),
          prefixIcon: Icon(icon, color: nebulaPurple),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: nebulaPurple,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
          filled: true,
          fillColor: cosmicBlue.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: nebulaPurple.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: nebulaPurple.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: nebulaPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: galaxyPink, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: galaxyPink, width: 2),
          ),
          errorStyle: TextStyle(color: galaxyPink),
        ),
      ),
    );
  }

  Widget _buildSpaceButton({
    required String text,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.transparent : nebulaPurple,
          foregroundColor: starWhite,
          side: isSecondary
              ? BorderSide(color: nebulaPurple, width: 2)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: isSecondary ? 0 : 8,
          shadowColor: nebulaPurple.withValues(alpha: 0.4),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(starWhite),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;

    return Form(
      key: _loginFormKey,
      autovalidateMode: _autoValidateMode,
      child: Column(
        children: [
          _buildSpaceTextField(
            type: TextInputType.emailAddress,
            controller: _loginEmailController,
            label: S.of(context).email,
            icon: Icons.email_outlined,
            validator: validateEmail,
          ),
          _buildSpaceTextField(
            type: TextInputType.visiblePassword,
            controller: _loginPasswordController,
            label: S.of(context).password,
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscurePassword,
            toggleObscure: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            validator: validatePassword,
          ),
          SizedBox(height: isSmallScreen ? 20 : 30),
          _buildSpaceButton(
            text: '${S.of(context).login} 🚀',
            onPressed: _handleLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;

    return Form(
      key: _registerFormKey,
      autovalidateMode: _autoValidateMode,
      child: Column(
        children: [
          _buildSpaceTextField(
            type: TextInputType.visiblePassword,
            controller: _nameController,
            label: S.of(context).name,
            icon: Icons.person_outline,
            validator: validateName,
          ),
          _buildSpaceTextField(
            type: TextInputType.emailAddress,
            controller: _registerEmailController,
            label: S.of(context).email,
            icon: Icons.email_outlined,
            validator: validateEmail,
          ),
          _buildSpaceTextField(
            type: TextInputType.visiblePassword,
            controller: _registerPasswordController,
            label: S.of(context).password,
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscurePassword,
            toggleObscure: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            validator: validatePassword,
          ),
          _buildSpaceTextField(
            type: TextInputType.visiblePassword,
            controller: _confirmPasswordController,
            label: S.of(context).confirmPassword,
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscureConfirmPassword,
            toggleObscure: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            validator: validateConfirmPassword,
          ),
          SizedBox(height: isSmallScreen ? 20 : 30),
          _buildSpaceButton(
            text: S.of(context).register,
            onPressed: _handleRegister,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [spaceBlack, cosmicBlue, spaceBlack],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildStarField(),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    // Logo/Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [nebulaPurple, galaxyPink],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: nebulaPurple.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 12,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/app_logo.jpeg',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'AstroQuest',
                            style: TextStyle(
                              color: starWhite,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // نسيت اغير الخطا هعدله
                        ],
                      ),
                    ),
                    SizedBox(height: 50),

                    // Toggle Buttons
                    Container(
                      decoration: BoxDecoration(
                        color: cosmicBlue.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: nebulaPurple.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!isLogin) {
                                  setState(() {
                                    isLogin = true;
                                    _autoValidateMode =
                                        AutovalidateMode.disabled;
                                  });
                                  _animationController.reset();
                                  _animationController.forward();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: isLogin
                                      ? nebulaPurple
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  S.of(context).login,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: starWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (isLogin) {
                                  setState(() {
                                    isLogin = false;
                                    _autoValidateMode =
                                        AutovalidateMode.disabled;
                                  });
                                  _animationController.reset();
                                  _animationController.forward();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: !isLogin
                                      ? nebulaPurple
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  S.of(context).register,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: starWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    // Forms
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cosmicBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: nebulaPurple.withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: spaceBlack.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: isLogin
                            ? _buildLoginForm()
                            : _buildRegisterForm(),
                      ),
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for star field background
class StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1;

    // Generate random stars
    for (int i = 0; i < 100; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 73) % size.height;
      final opacity = ((i * 17) % 100) / 100;

      paint.color = Colors.white.withValues(alpha: opacity * 0.8);
      canvas.drawCircle(Offset(x, y), 1, paint);
    }

    // Add some larger stars
    for (int i = 0; i < 20; i++) {
      final x = (i * 97) % size.width;
      final y = (i * 137) % size.height;
      final opacity = ((i * 23) % 100) / 100;

      paint.color = Colors.white.withValues(alpha: opacity * 0.6);
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
