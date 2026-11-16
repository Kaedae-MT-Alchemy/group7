import 'package:flutter/material.dart';
import 'auth_service.dart';

/// Confirms sign-out, clears the protected navigation stack, and returns
/// the user to the public home page.
Future<void> confirmAndSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Sign out?'),
      content: const Text('Are you sure you want to log out of MT Alchemy?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Sign out'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    await AuthService().signOut();
    if (!context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
          (route) => false,
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to sign out. Please try again.')),
    );
  }
}
