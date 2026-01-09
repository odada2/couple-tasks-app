import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:couple_tasks/services/invite_service.dart';
import 'package:couple_tasks/services/auth_service.dart';
import 'package:couple_tasks/models/invite_model.dart';

/// Mandatory partner gate screen (no skip option)
/// 
/// Shown after user creates their second task.
/// Warmly explains that the journey is better together.
/// User must send invite to continue using the app.
class PartnerGateScreen extends StatefulWidget {
  const PartnerGateScreen({Key? key}) : super(key: key);

  @override
  State<PartnerGateScreen> createState() => _PartnerGateScreenState();
}

class _PartnerGateScreenState extends State<PartnerGateScreen> {
  final InviteService _inviteService = InviteService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _inviteSent = false;
  PartnerInvite? _activeInvite;

  @override
  void initState() {
    super.initState();
    _checkForActiveInvite();
  }

  Future<void> _checkForActiveInvite() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final invite = await _inviteService.getActiveInviteForUser(user.uid);
    if (invite != null && mounted) {
      setState(() {
        _activeInvite = invite;
        _inviteSent = true;
      });
    }
  }

  Future<void> _createAndShareInvite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Create invite
      final invite = await _inviteService.createInvite(
        userId: user.uid,
        userName: user.displayName ?? 'Your Partner',
        userEmail: user.email ?? '',
      );

      setState(() {
        _activeInvite = invite;
      });

      // Share invite
      await _shareInvite(invite);

      setState(() {
        _inviteSent = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating invite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _shareInvite(PartnerInvite invite) async {
    try {
      await Share.share(
        invite.getShareMessage(),
        subject: 'Join me on Couple Tasks! 💕',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invite sent! 💕'),
            backgroundColor: Color(0xFFFF6B9D),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error sharing invite: $e');
    }
  }

  Future<void> _copyInviteCode() async {
    if (_activeInvite == null) return;

    await Clipboard.setData(
      ClipboardData(text: _activeInvite!.inviteCode),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invite code copied! 📋'),
          backgroundColor: Color(0xFFFF6B9D),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _continue() {
    // Navigate to home and wait for partner to join
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Heart icon at top
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B9D),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Illustration - User connected to partner (dashed line)
                SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Dashed line
                      Positioned(
                        left: 80,
                        right: 80,
                        child: CustomPaint(
                          painter: DashedLinePainter(),
                          child: const SizedBox(height: 2),
                        ),
                      ),
                      // User icon (left)
                      Positioned(
                        left: 40,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B9D),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      // Partner icon (right, dashed circle)
                      Positioned(
                        right: 40,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person_add,
                            color: Colors.grey[400],
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Title
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.3,
                    ),
                    children: const [
                      TextSpan(text: "You're on a roll!\n"),
                      TextSpan(
                        text: "Now, let's bring your\npartner in.",
                        style: TextStyle(color: Color(0xFFFF6B9D)),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Description
                Text(
                  'To continue building your shared life and organizing your future together, you need to connect your accounts.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Quick Invite section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.link,
                          color: Color(0xFFFF6B9D),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Invite',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your partner will get a link to join you instantly.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Show invite code if already sent
                if (_inviteSent && _activeInvite != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF6B9D).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Invite Code',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _activeInvite!.inviteCode,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF6B9D),
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              color: const Color(0xFFFF6B9D),
                              onPressed: _copyInviteCode,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Send Invite button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_inviteSent ? _continue : _createAndShareInvite),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B9D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _inviteSent ? Icons.check : Icons.send,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _inviteSent
                                    ? 'Continue to App'
                                    : 'Send Invite Link',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Why do I need to do this?
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Why connect accounts?',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'Couple Tasks is designed for two people working together. By connecting your accounts, you can:\n\n'
                          '• Share tasks and sync schedules\n'
                          '• Send loving nudges and reminders\n'
                          '• Celebrate wins together\n'
                          '• Build your shared life as a team\n\n'
                          'The app works best when both partners are involved!',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Got it!',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFF6B9D),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Why do I need to do this?',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFFFF6B9D),
                      decoration: TextDecoration.underline,
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

/// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
