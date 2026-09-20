import 'package:flutter/material.dart';
import 'dart:async';
import '../models/emergency_contact.dart';

class FakeCallScreen extends StatefulWidget {
  final EmergencyContact? contact;
  const FakeCallScreen({super.key, this.contact});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool _isCalling = true;
  int _seconds = 0;
  Timer? _timer;

  void _answerCall() {
    setState(() {
      _isCalling = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  void _endCall() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactName = widget.contact?.name ?? "Unknown";
    final contactNumber = widget.contact?.phoneNumber ?? "Private Number";

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Top Section: Caller Info
              Text(
                contactName,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 12),
              Text(
                _isCalling ? "Mobile $contactNumber" : _formatDuration(_seconds),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              
            const Spacer(),

            // Bottom Section: Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: _isCalling 
                ? _buildIncomingCallUI() 
                : _buildActiveCallUI(),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingCallUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CallActionButton(
            icon: Icons.call_end,
            color: Colors.red,
            label: "Decline",
            onTap: _endCall,
          ),
          _CallActionButton(
            icon: Icons.call,
            color: Colors.green,
            label: "Accept",
            onTap: _answerCall,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCallUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Responsive Grid for active call controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActiveCallControl(icon: Icons.mic_off, label: "mute"),
                  _ActiveCallControl(icon: Icons.dialpad, label: "keypad"),
                  _ActiveCallControl(icon: Icons.volume_up, label: "speaker"),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActiveCallControl(icon: Icons.add, label: "add call"),
                  _ActiveCallControl(icon: Icons.videocam_off, label: "FaceTime"),
                  _ActiveCallControl(icon: Icons.account_circle, label: "contacts"),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
        // End Call Button
        _CallActionButton(
          icon: Icons.call_end,
          color: Colors.red,
          label: "End",
          onTap: _endCall,
          size: 75,
        ),
      ],
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final double size;

  const _CallActionButton({required this.icon, required this.color, required this.label, required this.onTap, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: size * 0.45),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}

class _ActiveCallControl extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActiveCallControl({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }
}
