import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/biometric_lock_provider.dart';
import '../../core/constants/app_colors.dart';

class BiometricLockScreen extends StatefulWidget {
  final Widget child;
  const BiometricLockScreen({super.key, required this.child});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> with WidgetsBindingObserver {
  DateTime? _backgroundedAt;
  static const _lockTimeout = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BiometricLockProvider>().unlock();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<BiometricLockProvider>();
    if (state == AppLifecycleState.paused) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundedAt != null) {
        final elapsed = DateTime.now().difference(_backgroundedAt!);
        if (elapsed >= _lockTimeout) {
          provider.lock();
          provider.unlock();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BiometricLockProvider>();
    
    if (provider.isLocked) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.black),
              const SizedBox(height: 16),
              const Text('CHROME HEARTS',
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  )),
              const SizedBox(height: 8),
              const Text('App Locked',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Text(provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error)),
                ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: provider.unlock,
                icon: const Icon(Icons.fingerprint, color: Colors.black),
                label: const Text('Unlock', style: TextStyle(color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}
