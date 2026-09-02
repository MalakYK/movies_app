import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool isEnglish = true;

  final List<String> avatars = [
    'assets/images/gamer_3.png',
    'assets/images/gamer_2.png',
    'assets/images/gamer_1.png',
  ];

  int selectedAvatarIndex = 1;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Widget buildField({
    required String iconPath,
    required String hint,
    required TextEditingController controller,
    bool password = false,
    bool confirmPassword = false,
    bool isEmailOrPhone = false,
    double? iconSizeOverride,
  }) {
    bool visible =
    confirmPassword ? confirmPasswordVisible : passwordVisible;

    double iconSize =
        iconSizeOverride ?? (isEmailOrPhone ? 20.0 : 26.0);

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: (password || confirmPassword) && !visible,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            child: SvgPicture.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
          suffixIcon: (password || confirmPassword)
              ? IconButton(
            onPressed: () {
              setState(() {
                if (confirmPassword) {
                  confirmPasswordVisible =
                  !confirmPasswordVisible;
                } else {
                  passwordVisible = !passwordVisible;
                }
              });
            },
            icon: Icon(
              visible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.white54,
              size: 22,
            ),
          )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        AppStrings.register,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 12),

              // Avatar Selection Section
              SizedBox(
                height: 140,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(
                    avatars.length,
                        (index) {
                      bool isSelected =
                          index == selectedAvatarIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAvatarIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          width: isSelected ? 120 : 75,
                          height: isSelected ? 120 : 75,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                              color: AppColors.primary,
                              width: 2,
                            )
                                : null,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              avatars[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                AppStrings.avatar,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // Name Field
              buildField(
                iconPath:
                'assets/icons/icon _Identification_.svg',
                hint: AppStrings.name,
                controller: nameController,
                iconSizeOverride: 30.0,
              ),

              const SizedBox(height: 12),

              // Email Field
              buildField(
                iconPath: 'assets/icons/email.svg',
                hint: AppStrings.email,
                controller: emailController,
                isEmailOrPhone: true,
              ),

              const SizedBox(height: 12),

              // Password Field
              buildField(
                iconPath: 'assets/icons/password.svg',
                hint: AppStrings.password,
                controller: passwordController,
                password: true,
              ),

              const SizedBox(height: 12),

              // Confirm Password Field
              buildField(
                iconPath: 'assets/icons/password.svg',
                hint: AppStrings.confirmPassword,
                controller: confirmPasswordController,
                confirmPassword: true,
              ),

              const SizedBox(height: 12),

              // Phone Field
              buildField(
                iconPath: 'assets/icons/phone.svg',
                hint: AppStrings.phoneNumber,
                controller: phoneController,
                isEmailOrPhone: true,
              ),

              const SizedBox(height: 20),

              // Create Account
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.updateProfile,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    AppStrings.createAccount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    AppStrings.alreadyHaveAccount,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.login,
                      );
                    },
                    child: const Text(
                      ' Login',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              buildLanguageButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLanguageButton() {
    return Container(
      width: 72,
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: AppColors.primary,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isEnglish = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEnglish
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/LR.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isEnglish = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !isEnglish
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/EG.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}