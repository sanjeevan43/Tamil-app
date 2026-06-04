import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firestore persistence
import 'firebase_options.dart';
import 'constants/app_theme.dart';
import 'providers/enhanced_progress_provider.dart';
import 'services/audio_service.dart';
import 'services/auth_service.dart';
import 'providers/lesson_provider.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/moral_stories_data.dart';
import 'data/tamil_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set the system navigation bar color to match the premium dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: AppTheme.secondary,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
  ));
  
  await dotenv.load(fileName: '.env');
  
  try {
    debugPrint('Initializing Firebase...');
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
    
    // Enable Firestore offline persistence with a reasonable cache limit to prevent RAM bloat and UI freezes
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 50 * 1024 * 1024, // 50 MB cache limit
    );
    debugPrint('Firestore settings applied with 50MB cache limit');

    // Run database auto-seeding in the background only when explicitly needed.
    // Disabled on client launch to prevent massive RAM usage, CPU locks, and unnecessary network requests.
    // _autoSeedDatabase();

    // Initialize non-blocking services after basic setup
    AudioService.initialize().then((_) {
      debugPrint('Audio Service initialized successfully in background');
    }).catchError((e) {
      debugPrint('Non-critical service error (AudioService): $e');
    });
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService(), lazy: false),
          ChangeNotifierProvider(create: (_) => EnhancedProgressProvider(), lazy: false),
          ChangeNotifierProvider(create: (_) => LessonProvider(), lazy: false),
        ],
        child: const TamilMasterApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('CRITICAL INITIALIZATION ERROR: $e');
    debugPrint('Stack Trace: $stackTrace');
    // Still run the app but maybe show an error screen? 
    // For now, just rethrow to let it crash but with info
    rethrow;
  }
}

class TamilMasterApp extends StatelessWidget {
  const TamilMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'அகரவளம்',
      debugShowCheckedModeBanner: false,
      // Use the centralized theme data from AppTheme for consistent styling
      theme: AppTheme.themeData,
      home: const SplashScreen(),
    );
  }
}

void _autoSeedDatabase() async {
  try {
    final db = FirebaseFirestore.instance;

    // Check & Seed Stories
    final storiesSnap = await db.collection('stories').limit(1).get();
    if (storiesSnap.docs.isEmpty) {
      debugPrint('Auto-seeding stories...');
      final batch = db.batch();
      for (final story in MoralStoriesData.moralStories) {
        final docRef = db.collection('stories').doc(story['id']);
        batch.set(docRef, {
          ...story,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      debugPrint('Stories auto-seeded successfully!');
    }

    // Check & Seed Rhymes
    final rhymesSnap = await db.collection('rhymes').limit(1).get();
    if (rhymesSnap.docs.isEmpty) {
      debugPrint('Auto-seeding rhymes...');
      final batch = db.batch();
      for (final rhyme in TamilData.tamilRhymes) {
        final docId = rhyme['title'].hashCode.toString();
        final docRef = db.collection('rhymes').doc(docId);
        batch.set(docRef, {
          ...rhyme,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      debugPrint('Rhymes auto-seeded successfully!');
    }

    // Check & Seed Topics (Lessons)
    final topicsSnap = await db.collection('topics').limit(1).get();
    if (topicsSnap.docs.isEmpty) {
      debugPrint('Auto-seeding topics...');
      final batch = db.batch();
      for (final topic in TamilData.lessons) {
        final docId = topic['id'].toString();
        final docRef = db.collection('topics').doc(docId);
        batch.set(docRef, {
          ...topic,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      debugPrint('Topics auto-seeded successfully!');
    }

    // Check & Seed Kurals (Thirukkural)
    final kuralsSnap = await db.collection('kurals').limit(1).get();
    if (kuralsSnap.docs.isEmpty) {
      debugPrint('Auto-seeding kurals collection (1330 items)...');
      final String jsonString = await rootBundle.loadString('assets/data/v_thirukkural_list.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> kuralList = data['kural'];
      
      // Upload in batches to avoid Firestore limits
      int batchSize = 400;
      for (int i = 0; i < kuralList.length; i += batchSize) {
        final batch = db.batch();
        final chunk = kuralList.sublist(i, i + batchSize > kuralList.length ? kuralList.length : i + batchSize);
        
        for (final item in chunk) {
          final docId = item['Number'].toString();
          final docRef = db.collection('kurals').doc(docId);
          batch.set(docRef, {
            'number': item['Number'],
            'line1': item['Line1'],
            'line2': item['Line2'],
            'mv': item['mv'] ?? '',
            'explanation': item['explanation'] ?? '',
          });
        }
        await batch.commit();
        debugPrint('Seeded batch: $i to ${i + chunk.length}');
      }
      debugPrint('Kurals auto-seeded successfully!');
    }

    // Check & Seed Proverbs
    final proverbsSnap = await db.collection('proverbs').limit(1).get();
    if (proverbsSnap.docs.isEmpty) {
      debugPrint('Auto-seeding proverbs collection...');
      final String jsonString = await rootBundle.loadString('assets/data/tamil_proverbs.json');
      final List<dynamic> proverbList = json.decode(jsonString);
      
      final batch = db.batch();
      for (final item in proverbList) {
        final docId = item['id'].toString();
        final docRef = db.collection('proverbs').doc(docId);
        batch.set(docRef, {
          'id': item['id'],
          'proverb': item['proverb'],
          'meaning': item['meaning'],
        });
      }
      await batch.commit();
      debugPrint('Proverbs auto-seeded successfully!');
    }
  } catch (e) {
    debugPrint('Error during auto-seeding: $e');
  }
}
