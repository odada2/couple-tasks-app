import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:couple_tasks/services/invite_service.dart';
import 'package:couple_tasks/services/auth_service.dart';
import 'package:couple_tasks/models/invite_model.dart';

/// Screen for accepting partner invite
/// 
/// Shown when partner clicks invite link or enters invite code
class AcceptInviteScreen extends StatefulWidget {
  final String? inviteCode; // Pre-filled from deep link
  
  const AcceptInviteScreen({
    Key? key,
    this.inviteCode,
  }) : super(key: key);

  @override
  State<AcceptInviteScreen> createState() => _AcceptInviteScreenState();
}

class _AcceptInviteScreenState extends State<AcceptInviteScreen> {
  final InviteService _inviteService = InviteService();
  final AuthService _authService = AuthService();
  final TextEditingController _codeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isValidating = false;
  PartnerInvite? _validatedInvite;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.inviteCode != null) {
      _codeController.text = widget.inviteCode!;
      _validateInviteCode();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _validateInviteCode() async {
    final code = _codeController.text.trim().toUpperCase();
    
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an invite code';
        _validatedInvite = null;
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    try {
      final validation = await _inviteService.validateInvite(code);
      
      if (mounted) {
        setState(() {
          _isValidating = false;
          if (validation.isValid) {
            _validatedInvite = validation.invite;
            _errorMessage = null;
          } else {
            _validatedInvite = null;
            _errorMessage = validation.errorMessage;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _errorMessage = 'Error validating code. Please try again.';
        });
      }
    }
  }

  Future<void> _acceptInvite() async {
    if (_validatedInvite == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('Please log in first');
      }

      // Accept invite and create couple
      final coupleId = await _inviteService.acceptInvite(
        inviteCode: _validatedInvite!.inviteCode,
        acceptingUserId: user.uid,
        acceptingUserName: user.displayName ?? 'Partner',
        acceptingUserEmail: user.email ?? '',
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 You\'re now connected with ${_validatedInvite!.createdByName}!',
            ),
            backgroundColor: const Color(0xFFFF6B9D),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to home
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Error accepting invite'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Join Your Partner',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                'Enter the invite code your partner shared with you to connect your accounts.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Invite code input
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 8,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  labelText: 'Invite Code',
                  hintText: 'ABC12345',
                  errorText: _errorMessage,
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFFFF5F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF6B9D),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  suffixIcon: _isValidating
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF6B9D),
                            ),
                          ),
                        )
                      : _validatedInvite != null
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : null,
                ),
                onChanged: (value) {
                  if (value.length == 8) {
                    _validateInviteCode();
                  } else {
                    setState(() {
                      _validatedInvite = null;
                      _errorMessage = null;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              // Partner info (if validated)
              if (_validatedInvite != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF6B9D).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B9D),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _validatedInvite!.createdByName,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'wants to connect with you',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFFFF6B9D),
                        size: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              const Spacer(),
              
              // Accept button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_validatedInvite != null && !_isLoading)
                      ? _acceptInvite
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
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
                      : Text(
                          'Accept Invite',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Help text
              Center(
                child: Text(
                  'By accepting, you\'ll be connected to your partner\'s shared space.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
