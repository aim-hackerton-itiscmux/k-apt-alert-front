import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/config/supabase_config.dart';

/// /login — 매직링크 발송 화면.
///
/// 사용자가 이메일 입력 → "로그인 링크 보내기" → 이메일 클릭 → 자동 로그인.
/// SupabaseConfig 미설정 시 안내 화면.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sending = false;
  String? _error;
  bool _sent = false;
  String? _sentEmail;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendMagicLink(
            email: _emailController.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _sent = true;
        _sentEmail = _emailController.text.trim();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '발송 실패: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: !SupabaseConfig.isConfigured
                  ? _buildNotConfigured(context)
                  : _sent
                      ? _buildSent(context)
                      : _buildForm(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotConfigured(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
        const SizedBox(height: 16.0),
        Text(
          'Supabase 미설정',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8.0),
        const Text(
          'Auth 기능을 사용하려면 빌드 시 SUPABASE_ANON_KEY를 주입하세요.\n\n'
          'flutter run -d chrome --dart-define=SUPABASE_ANON_KEY=...\n\n'
          '미설정 상태에서도 무인증 API (announcements, notice/raw 등)는 정상 동작합니다.',
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '청약 코파일럿',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8.0),
          Text(
            '이메일 주소를 입력하면 로그인 링크를 보내드려요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24.0),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            enabled: !_sending,
            decoration: const InputDecoration(
              labelText: '이메일',
              hintText: 'you@example.com',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return '이메일을 입력하세요';
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                return '올바른 이메일 형식이 아닙니다';
              }
              return null;
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8.0),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _sending ? null : _send,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _sending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('로그인 링크 보내기'),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            '계정이 없으면 자동으로 가입됩니다 (이메일 매직링크).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.mark_email_read,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16.0),
        Text(
          '이메일 확인하세요',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8.0),
        Text('${_sentEmail ?? ''} 으로 로그인 링크를 보냈습니다.'),
        const SizedBox(height: 16.0),
        const Text(
          '메일에서 "로그인" 링크를 클릭하면 자동으로 로그인됩니다.\n'
          '이메일이 보이지 않으면 스팸함을 확인해주세요.',
        ),
        const SizedBox(height: 24.0),
        TextButton(
          onPressed: () {
            setState(() {
              _sent = false;
              _sentEmail = null;
              _error = null;
            });
          },
          child: const Text('다른 이메일로 보내기'),
        ),
      ],
    );
  }
}
