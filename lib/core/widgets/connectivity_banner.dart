import 'package:flutter/material.dart';
import 'package:topup/app/theme/app_theme.dart';

class ConnectivityBanner extends StatefulWidget {
  final Stream<bool> connectivityStream;
  final bool initiallyConnected;
  final Widget child;

  const ConnectivityBanner({
    super.key,
    required this.connectivityStream,
    required this.initiallyConnected,
    required this.child,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late bool _isConnected;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _isConnected = widget.initiallyConnected;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (!_isConnected) _controller.forward();

    widget.connectivityStream.listen((connected) {
      if (!mounted) return;
      setState(() => _isConnected = connected);
      if (!connected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: double.infinity,
            color: AppColors.offline,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    color: Colors.black87, size: 16),
                const SizedBox(width: 8),
                Text(
                  'You\'re offline,changes will sync when reconnected',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
