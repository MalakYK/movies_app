import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final email = TextEditingController();

  @override
  void dispose() { email.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.actionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
          Navigator.pop(context);
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message ?? 'Failed')));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                Row(children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: AppColors.primary)),
                  const Expanded(child: Center(child: Text(AppStrings.forgetPassword, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 48),
                ]),
                SizedBox(height: 350, child: Image.asset(AppAssets.forgotPasswordImage, fit: BoxFit.contain)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 56,
                  child: TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: AppStrings.email,
                      prefixIcon: Padding(padding: const EdgeInsets.all(16), child: SvgPicture.asset('assets/icons/email.svg', width: 20)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (_, state) => SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: state.status == AuthStatus.loading ? null : () {
                        if (email.text.trim().isNotEmpty) context.read<AuthCubit>().resetPassword(email.text);
                      },
                      child: state.status == AuthStatus.loading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(AppStrings.verifyEmail, style: TextStyle(fontWeight: FontWeight.bold)),
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
}
