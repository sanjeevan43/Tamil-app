import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';

class AvatarShopScreen extends StatelessWidget {
  const AvatarShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    final List<Map<String, dynamic>> shopItems = [
      {'id': 'standard', 'name': 'Classic', 'price': 0, 'emoji': '👦', 'description': 'தொடக்க நண்பன்'},
      {'id': 'india_explorer', 'name': 'India Explorer', 'price': 300, 'emoji': '🇮🇳', 'description': 'இந்தியத் தமிழ் மாணவன்'},
      {'id': 'warrior', 'name': 'Tamil Warrior', 'price': 500, 'emoji': '💂', 'description': 'தமிழர் படைவீரன்'},
      {'id': 'londoner', 'name': 'UK Londoner', 'price': 800, 'emoji': '🎡', 'description': 'லண்டன் வாழ் நண்பன்'},
      {'id': 'usa_scholar', 'name': 'USA Scholar', 'price': 1000, 'emoji': '🎓', 'description': 'அமெரிக்க மாணவன்'},
      {'id': 'eelam_scholar', 'name': 'Eelam Scholar', 'price': 700, 'emoji': '🌾', 'description': 'ஈழத்து அறிஞர்'},
      {'id': 'singapore_tech', 'name': 'Singapore Techie', 'price': 1200, 'emoji': '💻', 'description': 'சிங்கப்பூர் கலைஞர்'},
      {'id': 'dubai_explorer', 'name': 'Dubai Explorer', 'price': 1100, 'emoji': '🏙️', 'description': 'துபாய் பயணி'},
      {'id': 'swiss_scholar', 'name': 'Swiss Scholar', 'price': 1500, 'emoji': '🏔️', 'description': 'சுவிஸ் அறிஞர்'},
      {'id': 'king', 'name': 'Chola King', 'price': 5000, 'emoji': '👑', 'description': 'சோழ பேரரசன்'},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('அவதார் கடை', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🪙 ', style: TextStyle(fontSize: 18)),
                Text('${progress.totalCoins}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.white)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryRed, AppTheme.lightRed, AppTheme.offWhite],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.4, 0.9],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Avatar Preview
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: AppTheme.glassCard(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppTheme.primaryRed.withOpacity(0.2), blurRadius: 20)],
                      ),
                      child: Center(
                        child: Text(progress.avatar, style: const TextStyle(fontSize: 50)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${progress.region} Explorer',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
                    ),
                    Text(
                      progress.userName,
                      style: const TextStyle(color: AppTheme.textGray),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: shopItems.length,
                  itemBuilder: (context, index) {
                    final item = shopItems[index];
                    final isOwned = progress.inventory.contains(item['id']);
                    final isEquipped = progress.avatar == item['emoji'];

                    return GestureDetector(
                      onTap: () {
                        if (isOwned) {
                          progress.updateAvatar(item['emoji']);
                        } else if (progress.totalCoins >= (item['price'] as int)) {
                          _showBuyDialog(context, progress, item);
                        }
                      },
                      child: Container(
                        decoration: isEquipped 
                          ? AppTheme.gameCard() 
                          : AppTheme.glassCard().copyWith(
                              border: Border.all(color: AppTheme.white.withOpacity(0.5)),
                            ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item['emoji'] as String, style: const TextStyle(fontSize: 50)),
                            const SizedBox(height: 12),
                            Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(item['description'] as String, style: const TextStyle(fontSize: 10, color: AppTheme.textGray), textAlign: TextAlign.center),
                            ),
                            const SizedBox(height: 12),
                            if (isOwned)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isEquipped ? AppTheme.white.withOpacity(0.2) : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isEquipped ? 'EQUIPPED' : 'OWNED',
                                  style: TextStyle(
                                    color: isEquipped ? AppTheme.white : Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.gold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🪙 ', style: TextStyle(fontSize: 12)),
                                    Text(
                                      '${item['price']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkRed),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBuyDialog(BuildContext context, EnhancedProgressProvider progress, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('${item['name']} வாங்கவா?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item['emoji'], style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text('Buy this avatar for ${item['price']} coins?'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              progress.buyItem(item['id'], item['price'] as int, item['emoji'] as String);
              Navigator.pop(context);
            },
            child: const Text('Buy Now'),
          ),
        ],
      ),
    );
  }
}
