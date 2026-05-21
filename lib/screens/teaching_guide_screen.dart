import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';

class TeachingGuideScreen extends StatelessWidget {
  const TeachingGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('கற்பித்தல் வழிகாட்டி (Teaching Guide)', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryRed.withOpacity(0.05), AppTheme.offWhite],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainHeader(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('1. பொதுவான கற்பித்தல் கொள்கைகள் (Overall Principles)'),
              _buildPolicyCard([
                'பாடங்களை சுருக்கமாகவும் சுறுசுறுப்பாகவும் வைத்திருங்கள்.',
                'சிறிய படிகளாகக் கற்பிக்கவும் (ஒரு நேரத்தில் 2-3 எழுத்துக்கள்).',
                'தினமும் திரும்பச் சொல்லுங்கள் (பார்த்தல் + பேசுதல் + எழுதுதல்).',
                'அசைவு, இசை, வரைதல் மற்றும் விளையாட்டுகளைப் பயன்படுத்துங்கள்.',
                'சரியான முடிவை விட முயற்சியைப் பாராட்டுங்கள்.',
              ]),
              
              const SizedBox(height: 24),
              _buildSectionTitle('2. தினசரி பாடம் அமைப்பு (Daily Lesson - 30 Mins)'),
              _buildLessonTimeline(),

              const SizedBox(height: 24),
              _buildPointSection(
                '3. ஒலி பயிற்சி (Sound Practice)',
                'தமிழ் ஒரு ஒலிப்பு மொழி, எனவே ஒலியின் தெளிவு அவசியம்.',
                Icons.record_voice_over,
                'பயிற்சி: ஆசிரியர்: அ அ அ, க க க. க + அ = க. குழந்தைகள் தாளத்துடன் திரும்பச் சொல்ல வேண்டும்.',
              ),

              _buildPointSection(
                '4. சொல்லகராதி உருவாக்கம் (Vocabulary)',
                'எளிய அன்றாட வார்த்தைகளுடன் தொடங்குங்கள்.',
                Icons.menu_book,
                'முறை: படத்தைக்காட்டி "இது என்ன?" என்று கேளுங்கள். எழுத்துக்களைச் சேர்ந்து சொல்ல விடுங்கள்.',
              ),

              _buildPointSection(
                '5. வாக்கிய அமைப்பு (Sentence Formation)',
                '15-20 வார்த்தைகள் தெரிந்த பிறகு, எளிய வாக்கியங்களை அறிமுகப்படுத்துங்கள்.',
                Icons.forum,
                'உதாரணம்: ஆசிரியர்: "இது என் பென்சில்." குழந்தை: "இது என் பை."',
              ),

              _buildPointSection(
                '6. கதைகள் சொல்லுதல் (Storytelling)',
                'தெளிவான நீதி நெறிகளுடன் கூடிய சிறு கதைகளைப் பயன்படுத்தவும்.',
                Icons.auto_stories,
                'கேள்விகள்: யார் நல்லவன்? என்ன நடந்தது? கதையின் நீதி என்ன?',
              ),

              _buildPointSection(
                '7. பாடல்கள் மற்றும் கவிதைகள் (Songs & Rhymes)',
                'இசை நினைவாற்றலை மேம்படுத்துகிறது.',
                Icons.music_note,
                'முறை: அவ்வையாரின் "ஆத்திச்சூடி" போன்றவற்றை வரி வரியாகத் திரும்பச் சொல்லிக் கொடுக்கவும்.',
              ),

              _buildPointSection(
                '8. விளையாட்டு வழி கற்றல் (Games)',
                'கற்றலை விளையாட்டுத்தனமாக மாற்றவும்.',
                Icons.videogame_asset,
                'செயல்பாடு: படம்-சொல் பொருத்தம், எழுத்து வேட்டை, எழுத்துக்கூட்டும் போட்டி.',
              ),

              _buildPointSection(
                '9. எழுத்து வளர்ச்சித் திட்டம் (Writing Plan)',
                'படிப்படியாக எழுதுவதைப் பழக்கவும்.',
                Icons.edit,
                'படி 1: வரைதல் (Tracing). படி 2: சுதந்திரமாக எழுதுதல். படி 3: சொல் எழுதுதல். படி 4: வரைந்து பெயரிடுதல்.',
              ),

              _buildPointSection(
                '10. தினசரி பாடம் பேசுதல் (Daily Speaking)',
                'ஒவ்வொரு குழந்தையும் தினமும் 3-5 தமிழ் வாக்கியங்களை பேச வேண்டும்.',
                Icons.campaign,
                'வெகுமதி: நட்சத்திர ஸ்டிக்கர்கள், பாராட்டு கைதட்டல்.',
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('11. வாராந்திர முன்னேற்றத் திட்டம் (Weekly Plan)'),
              _buildWeeklyPlan(),

              const SizedBox(height: 24),
              _buildSectionTitle('12. கற்பித்தல் முன்னேற்றச் சுருக்கம் (Summary)'),
              _buildSummaryTree(),

              const SizedBox(height: 24),
              _buildSuccessCard(),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: AppTheme.white, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ஆசிரியர் வழிகாட்டி 2.0',
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    Text(
                      'அறிவியல்பூர்வமான தமிழ் கற்றல் முறை',
                      style: TextStyle(color: AppTheme.white.withOpacity(0.70), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.notoSansTamil(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryRed,
        ),
      ),
    );
  }

  Widget _buildPolicyCard(List<String> policies) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        children: policies.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: AppTheme.primaryRed, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(p, style: const TextStyle(fontSize: 15))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildLessonTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        children: [
          _buildTimelineItem('5m', 'Warm-Up', 'வணக்கம் சொல்லுதல், நேற்றைய பாடம் திருப்புதல்.'),
          _buildTimelineItem('10m', 'New Letter', '2-3 புதிய எழுத்துக்கள் அறிமுகம் (அ-அம்மா).'),
          _buildTimelineItem('15m', 'Practice', 'காற்று எழுத்து (Air Writing), ஒலி பயிற்சி, விளையாட்டு.'),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String time, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(8)),
            child: Text(time, style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc, style: const TextStyle(fontSize: 13, color: AppTheme.textGray)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointSection(String title, String desc, IconData icon, String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryRed),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 14, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primaryRed.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Text('💡 $tip', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlan() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        children: [
          _buildWeekItem('வாரம் 1', '10-15 எழுத்துக்கள், அடிப்படை ஒலிகள்.'),
          _buildWeekItem('வாரம் 2', 'அனைத்து அடிப்படை எழுத்துக்கள், 10 சொற்கள்.'),
          _buildWeekItem('வாரம் 3', '20+ சொற்கள், 3-5 வாக்கியங்கள்.'),
          _buildWeekItem('வாரம் 4', 'கதை சொல்லுதல், எளிய வாசிப்பு, எழுத்துப் பயிற்சி.'),
        ],
      ),
    );
  }

  Widget _buildWeekItem(String week, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(week, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
          const SizedBox(width: 12),
          Expanded(child: Text(detail, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildSummaryTree() {
    final stages = [
      'எழுத்து அடையாளம்', 'ஒலி தெளிவு', 'சொற்கள் அறிமுகம்', 'வாக்கிய முயற்சி', 'கதை புரிதல்', 'பேச்சு நம்பிக்கை', 'சுய எழுத்து'
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        children: stages.asMap().entries.map((e) => Row(
          children: [
            CircleAvatar(radius: 12, backgroundColor: AppTheme.primaryRed, child: Text('${e.key + 1}', style: const TextStyle(color: AppTheme.white, fontSize: 10))),
            const SizedBox(width: 12),
            Text(e.value, style: const TextStyle(fontSize: 14)),
            if (e.key < stages.length - 1) const Expanded(child: Icon(Icons.arrow_forward, size: 14, color: AppTheme.textGray)),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.success.withOpacity(0.2), width: 2),
      ),
      child: const Column(
        children: [
          Text('வெற்றிக்கான சூத்திரம்', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.success)),
          SizedBox(height: 8),
          Text(
            'திரும்பச் செய்தல் + கலந்துரையாடல் + ஊக்கம் + குறுகிய பாடங்கள் = பயனுள்ள தமிழ் கற்றல்',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.success),
          ),
        ],
      ),
    );
  }
}
