import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:couple_tasks/services/invite_service.dart';
import 'package:couple_tasks/services/auth_service.dart';
import 'package:couple_tasks/models/invite_model.dart';

/// Onboarding screen for inviting partner (with skip option)
/// 
/// Shown after onboarding, allows user to:
/// - Invite partner immediately
/// - Skip and explore app first
class InvitePartnerScreen extends StatefulWidget {
  final bool canSkip; // true for onboarding, false for mandatory gate
  
  const InvitePartnerScreen({
    Key? key,
    this.canSkip = true,
  }) : super(key: key);

  @override
  State<InvitePartnerScreen> createState() => _InvitePartnerScreenState();
}

class _InvitePartnerScreenState extends State<InvitePartnerScreen> {
  final InviteService _inviteService = InviteService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
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
          ),
        );
      }
    } catch (e) {
      print('Error sharing invite: $e');
    }
  }

  Future<void> _copyInviteLink() async {
    if (_activeInvite == null) return;

    await Clipboard.setData(
      ClipboardData(text: _activeInvite!.getInviteLink()),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invite link copied! 📋'),
          backgroundColor: Color(0xFFFF6B9D),
        ),
      );
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Back button (only if can skip)
              if (widget.canSkip)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Two cards with heart
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Left card
                          Transform.translate(
                            offset: const Offset(-20, 0),
                            child: Transform.rotate(
                              angle: -0.1,
                              child: Container(
                                width: 60,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Right card
                          Transform.translate(
                            offset: const Offset(20, 0),
                            child: Transform.rotate(
                              angle: 0.1,
                              child: Container(
                                width: 60,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Heart
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B9D),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6B9D).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                  children: const [
                    TextSpan(text: 'Better '),
                    TextSpan(
                      text: 'Together',
                      style: TextStyle(color: Color(0xFFFF6B9D)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Share lists, sync schedules, and celebrate small wins with your favorite person.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              
              const Spacer(),
              
              // Invite button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAndShareInvite,
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
                            const Icon(Icons.person_add, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Invite Your Partner',
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
              
              // Skip button (only if allowed)
              if (widget.canSkip)
                TextButton(
                  onPressed: _skip,
                  child: Text(
                    "I'll do this later",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Helper text
              Text(
                'Your partner will receive a unique link to join your shared space instantly.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
