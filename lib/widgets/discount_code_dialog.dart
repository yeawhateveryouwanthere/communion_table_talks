import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/subscription_provider.dart';
import '../screens/auth_screen.dart';
import '../theme/app_theme.dart';

/// A dialog that lets signed-in users enter a discount code
/// (e.g., "OrangeView") to unlock premium content.
class DiscountCodeDialog extends StatefulWidget {
  const DiscountCodeDialog({super.key});

  /// Show the dialog. Returns true if a code was successfully applied.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const DiscountCodeDialog(),
    );
  }

  @override
  State<DiscountCodeDialog> createState() => _DiscountCodeDialogState();
}

class _DiscountCodeDialogState extends State<DiscountCodeDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _applyCode() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a code.');
      return;
    }

    final authProvider = context.read<app_auth.AuthProvider>();
    if (!authProvider.isSignedIn) {
      // Need to sign in first
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      if (result != true || !mounted) return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final subProvider = context.read<SubscriptionProvider>();
    final success = await subProvider.applyDiscountCode(code);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code "$code" applied! All presentations unlocked.'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid or expired code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.confirmation_number_outlined,
              size: 22, color: AppTheme.accentColor),
          const SizedBox(width: 10),
          const Text('Enter Discount Code'),
        ],
      ),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryColor,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Have a discount code? Enter it below to unlock all presentations.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _applyCode(),
            decoration: InputDecoration(
              hintText: 'e.g. ORANGEVIEW',
              hintStyle: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.4),
              ),
              prefixIcon: Icon(Icons.vpn_key_outlined,
                  color: AppTheme.primaryColor.withOpacity(0.5)),
              filled: true,
              fillColor: AppTheme.primaryColor.withOpacity(0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _applyCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}
