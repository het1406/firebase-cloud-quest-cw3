import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

const useEmulators = bool.fromEnvironment('USE_EMULATORS', defaultValue: true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: String.fromEnvironment(
          'FIREBASE_API_KEY',
          defaultValue: 'demo-api-key',
        ),
        appId: String.fromEnvironment(
          'FIREBASE_APP_ID',
          defaultValue: '1:123456789:android:1234567890abcdef',
        ),
        messagingSenderId: String.fromEnvironment(
          'FIREBASE_SENDER_ID',
          defaultValue: '123456789',
        ),
        projectId: String.fromEnvironment(
          'FIREBASE_PROJECT_ID',
          defaultValue: 'demo-cloud-quest',
        ),
      ),
    );
    if (useEmulators) {
      const host = String.fromEnvironment(
        'EMULATOR_HOST',
        defaultValue: '10.0.2.2',
      );
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
      FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
    }
    runApp(const QuestApp());
  } catch (_) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not connect to Firebase.'),
                  TextButton(onPressed: main, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuestApp extends StatelessWidget {
  const QuestApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Cloud Quest',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff27685b)),
      scaffoldBackgroundColor: const Color(0xfff5f7f3),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    home: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == null
            ? const AuthScreen()
            : QuestScreen(
                key: ValueKey(snapshot.data!.uid),
                user: snapshot.data!,
              );
      },
    ),
  );
}

String? validateEmail(String? value) =>
    value == null ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
    ? 'Enter a valid email address.'
    : null;
String? validatePassword(String? value) =>
    value == null || value.length < 6 ? 'Use at least 6 characters.' : null;
String friendlyError(Object error) {
  if (error is FirebaseException) {
    return switch (error.code) {
      'email-already-in-use' =>
        'This email already has an account. Sign in instead.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Check your email and password.',
      'weak-password' => 'Choose a stronger password.',
      'network-request-failed' || 'unavailable' =>
        'Service unavailable. Check the connection and try again.',
      'too-many-requests' => 'Too many attempts. Please wait and try again.',
      'unauthenticated' => 'Please sign in again.',
      _ => error.message ?? 'Something went wrong. Please retry.',
    };
  }
  return 'Something went wrong. Please retry.';
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(), password = TextEditingController();
  bool register = false, busy = false;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy) return;
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (register) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = friendlyError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.cloud_outlined,
                    size: 64,
                    color: Color(0xff27685b),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Cloud Quest',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Small challenges. Trusted rewards.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    register ? 'Create your account' : 'Welcome back',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: email,
                    enabled: !busy,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: password,
                    enabled: !busy,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: validatePassword,
                    onFieldSubmitted: (_) {
                      if (!busy) submit();
                    },
                  ),
                  const SizedBox(height: 16),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        error!,
                        semanticsLabel: 'Error: $error',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  FilledButton(
                    onPressed: busy ? null : submit,
                    child: busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(register ? 'Create account' : 'Sign in'),
                  ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() {
                            register = !register;
                            error = null;
                          }),
                    child: Text(
                      register
                          ? 'Already registered? Sign in'
                          : 'New here? Create account',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key, required this.user});
  final User user;
  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  final question = TextEditingController();
  bool completing = false, asking = false;
  String? hint, coachError, rewardMessage;
  int retry = 0;
  @override
  void dispose() {
    question.dispose();
    super.dispose();
  }

  Future<void> complete() async {
    setState(() {
      completing = true;
      rewardMessage = null;
    });
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('completeToday')
          .call({'challengeId': 'today'});
      if (mounted) {
        setState(
          () => rewardMessage = result.data['alreadyCompleted'] == true
              ? 'Already completed — your reward stays at 10 points.'
              : 'Quest complete! You earned 10 points and First Quest.',
        );
      }
    } catch (e) {
      if (mounted) setState(() => rewardMessage = friendlyError(e));
    } finally {
      if (mounted) setState(() => completing = false);
    }
  }

  Future<void> ask() async {
    if (question.text.trim().isEmpty) {
      setState(() => coachError = 'Enter a question first.');
      return;
    }
    setState(() {
      asking = true;
      coachError = null;
      hint = null;
    });
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('askQuestCoach')
          .call({'question': question.text.trim()});
      if (mounted) setState(() => hint = result.data['hint'] as String);
    } catch (e) {
      if (mounted) setState(() => coachError = friendlyError(e));
    } finally {
      if (mounted) setState(() => asking = false);
    }
  }

  Widget panel(List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );
  Widget recovery(String message) => panel([
    Text(message),
    TextButton(
      onPressed: () => setState(() => retry++),
      child: const Text('Retry'),
    ),
  ]);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cloud Quest'),
      actions: [
        IconButton(
          tooltip: 'Sign out',
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signOut();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
              }
            }
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'YOUR DAILY EXPEDITION',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'One quest. A stronger signal.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                key: ValueKey('challenge$retry'),
                stream: FirebaseFirestore.instance
                    .doc('challenges/today')
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return recovery('Could not load the challenge.');
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snap.data!.exists) {
                    return recovery('No challenge has been published yet.');
                  }
                  final data = snap.data!.data()!;
                  return panel([
                    const Icon(Icons.explore_outlined, size: 36),
                    const SizedBox(height: 12),
                    Text(
                      data['title'] as String? ?? 'Today’s challenge',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(data['prompt'] as String? ?? ''),
                    const SizedBox(height: 20),
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      key: ValueKey('progress$retry'),
                      stream: FirebaseFirestore.instance
                          .doc('users/${widget.user.uid}/progress/today')
                          .snapshots(),
                      builder: (context, progress) {
                        if (progress.hasError) {
                          return recovery(
                            'Could not load your private progress.',
                          );
                        }
                        if (!progress.hasData) {
                          return const LinearProgressIndicator();
                        }
                        final p = progress.data!.data();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 12,
                              children: [
                                Chip(
                                  label: Text('${p?['points'] ?? 0} points'),
                                ),
                                Chip(
                                  avatar: const Icon(
                                    Icons.workspace_premium_outlined,
                                  ),
                                  label: Text(
                                    p?['badgeId'] == 'first-quest'
                                        ? 'First Quest'
                                        : 'Badge not earned',
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              p?['completed'] == true
                                  ? 'Completed'
                                  : 'Ready to begin',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: completing ? null : complete,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        completing ? 'Saving…' : 'Complete Challenge',
                      ),
                    ),
                    if (rewardMessage != null) Text(rewardMessage!),
                  ]);
                },
              ),
              const SizedBox(height: 12),
              panel([
                Text(
                  'Quest Coach',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ask for a hint grounded in your daily quest. Your coach can read your progress but cannot award rewards.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: question,
                  maxLength: 300,
                  minLines: 2,
                  maxLines: 4,
                  enabled: !asking,
                  decoration: const InputDecoration(
                    labelText: 'Your question',
                    hintText: 'Can you give me a hint for today’s challenge?',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: asking ? null : ask,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: Text(asking ? 'Reading your quest…' : 'Get Hint'),
                ),
                if (asking) const LinearProgressIndicator(),
                if (coachError != null)
                  Text(
                    coachError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (hint != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Semantics(liveRegion: true, child: Text(hint!)),
                  ),
              ]),
            ],
          ),
        ),
      ),
    ),
  );
}
