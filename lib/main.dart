import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bucarest_web/firebase_options.dart';

// make sure to import the auto-generated file from shared/repositores


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: FlutterBucarestWeb(),
    )
  );
}

class FlutterBucarestWeb extends StatelessWidget {
  const FlutterBucarestWeb({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
      ),
      home: const FlutterBucarestMain(),
    );
  }
}

class FlutterBucarestMain extends StatelessWidget {
  const FlutterBucarestMain({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1481BE),
                  Color(0xFF023755)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
              )
            ),
          ),
          const FlutterBucarestIntro(),
          FlutterRomaniaFlag(),
          // 
        ],
      )
    );
  }
}

class FlutterRomaniaFlag extends ConsumerWidget {
  const FlutterRomaniaFlag({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final colors = [Color(0xFF022A7F), Color(0xFFFED116), Color(0xFFCE1127)];

    return Row(
            children: List.generate(colors.length,
            (index) => Expanded(
              child: Container(
                color: colors[index],
              ),
            )).animate(
              interval: 250.ms,
              onComplete:(controller) {
                ref.read(notifyIntroProvider.notifier).state = true;
              },
            ).slideY(
              begin: 0, end: 1,
              duration: 2.seconds,
              curve: Curves.easeInOut
            )
        
          );
  }
}

class FlutterBucarestIntro extends ConsumerWidget {
  const FlutterBucarestIntro({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final showIntro = ref.watch(notifyIntroProvider);
    final pageData = ref.watch(pageProvider);

    return pageData.when(
      data: (data) {
        return showIntro ? Center(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FlutterDashWidget(),
                Text(data.greeting, style: const TextStyle(color: Colors.white, fontSize: 20)),
                Text(data.title, style: const TextStyle(color: Colors.white, fontSize: 80)),
                Text(data.subtitle, style: const TextStyle(color: Colors.white, fontSize: 80)),
                Text(data.content, style: const TextStyle(color: Colors.white, fontSize: 20)),
              ].animate(
                interval: 100.ms
              )
              .slideY(
                begin: 1.5, end: 0,
                duration: 0.5.seconds
              ).fadeIn()
            ),
        ) : const SizedBox();
      },
      loading: () => const CircularProgressIndicator(),
      error:(error, stackTrace) {
        return const Center(child: Text('error'));
      });
  }
}

final notifyIntroProvider = StateProvider<bool>((ref) {
  return false;
});

class FlutterDashWidget extends StatefulWidget {

  const FlutterDashWidget({
    super.key
  });

  @override
  State<FlutterDashWidget> createState() => _FlutterDashWidgetState();
}

class _FlutterDashWidgetState extends State<FlutterDashWidget> {


  late rive.StateMachineController smController;
  late rive.RiveAnimation animation;

  @override
  void initState() {
    super.initState();

    animation = rive.RiveAnimation.asset(
      './assets/anims/flutter_dash.riv',
      artboard: 'flutter_dash',
      fit: BoxFit.contain,
      onInit: onRiveInit,
    );
  }

  void onRiveInit(rive.Artboard artboard) {
    
    smController = rive.StateMachineController.fromArtboard(
      artboard,
      'flutter_dash'
    )!;
    artboard.addController(smController);
  }

  @override
  void dispose() {
    super.dispose();
    smController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 300,
      height: 300,
      child: animation
    );
  }
}

final dbProvider = Provider((ref) {
  return FirebaseFirestore.instance;
});

final pageRepositoryProvider = Provider((ref) {
  return DatabaseRepository(ref);
});

final pageProvider = FutureProvider<FlutterBucarestContent>((ref) {
  return ref.read(pageRepositoryProvider).getPageData();
});


class DatabaseRepository {

  final Ref ref;

  DatabaseRepository(this.ref);

  Future<FlutterBucarestContent> getPageData() async {

    final db = ref.read(dbProvider);
    DocumentSnapshot doc = await db.collection('pagecontent').doc('flutterbucarest').get();

    FlutterBucarestContent pageContent = FlutterBucarestContent.fromFirebase(doc.data() as Map<String, dynamic>);

    return pageContent;
  }
}



class FlutterBucarestContent {

  final String greeting;
  final String title;
  final String subtitle;
  final String content;

  FlutterBucarestContent({
    required this.content,
    required this.greeting,
    required this.subtitle,
    required this.title
  });

  factory FlutterBucarestContent.fromFirebase(Map<String, dynamic> json) {
    return FlutterBucarestContent(
      content: json['meetup'],
      title: json['tech'],
      subtitle: json['country'],
      greeting: json['greeting'],
    );
  }
}