import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';

class AvatarShopScreen extends StatelessWidget {
  const AvatarShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    final List<Map<String, dynamic>> shopItems = [
      {'id': 'standard', 'name': 'Classic', 'price': 0, 'emoji': '👦', 'description': 'The Original Buddy'},
      {'id': 'india_explorer', 'name': 'Learner', 'price': 300, 'emoji': '🇮🇳', 'description': 'Proud Student'},
      {'id': 'warrior', 'name': 'Warrior', 'price': 500, 'emoji': '💂', 'description': 'Tamil Guard'},
      {'id': 'londoner', 'name': 'Explorer', 'price': 800, 'emoji': '🎡', 'description': 'World Traveler'},
      {'id': 'usa_scholar', 'name': 'Scholar', 'price': 1000, 'emoji': '🎓', 'description': 'Master Degree'},
      {'id': 'eelam_scholar', 'name': 'Farmer', 'price': 700, 'emoji': '🌾', 'description': 'Nature Lover'},
      {'id': 'singapore_tech', 'name': 'Techie', 'price': 1200, 'emoji': '💻', 'description': 'Future Designer'},
      {'id': 'dubai_explorer', 'name': 'Tourist', 'price': 1100, 'emoji': '🏙️', 'description': 'City Adventurer'},
      {'id': 'swiss_scholar', 'name': 'Alpinist', 'price': 1500, 'emoji': '🏔️', 'description': 'Peak Achiever'},
      {'id': 'king', 'name': 'Monarch', 'price': 5000, 'emoji': '👑', 'description': 'True Legend'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        title: Text(
          'AVATAR SHOP',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 2, fontSize: 13),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('🪙 ', style: TextStyle(fontSize: 14)),
                Text(
                  '${progress.totalCoins}', 
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 14)
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Avatar Banner
          Container(
            padding: const EdgeInsets.all(28),
            margin: const EdgeInsets.all(24),
            decoration: AppTheme.premiumCard(radius: 36),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppTheme.primaryDark.withOpacity(0.3), blurRadius: 20)],
                  ),
                  child: Center(
                    child: Text(progress.avatar, style: const TextStyle(fontSize: 44)),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT STYLE',
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.white.withOpacity(0.8), letterSpacing: 1),
                      ),
                      Text(
                        progress.userName,
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${progress.level} Explorer',
                        style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 12),
                Text(
                  'COLLECTION',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: isEquipped 
                      ? BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: AppTheme.primary, width: 2.5),
                          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
                        )
                      : AppTheme.whiteCard(radius: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: isEquipped ? AppTheme.primary.withOpacity(0.06) : AppTheme.offWhite,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(item['emoji'] as String, style: const TextStyle(fontSize: 40)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['name'] as String, 
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textDark, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['description'] as String, 
                          style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textGray, fontWeight: FontWeight.w600), 
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (isOwned)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isEquipped ? AppTheme.primary : AppTheme.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isEquipped ? 'ACTIVE' : 'READY',
                              style: GoogleFonts.outfit(
                                color: isEquipped ? AppTheme.white : AppTheme.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🪙 ', style: TextStyle(fontSize: 10)),
                                Text(
                                  '${item['price']}',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 13),
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
    );
  }

  void _showBuyDialog(BuildContext context, EnhancedProgressProvider progress, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(color: AppTheme.offWhite, shape: BoxShape.circle),
              child: Center(child: Text(item['emoji'], style: const TextStyle(fontSize: 56))),
            ),
            const SizedBox(height: 24),
            Text(
              'UNLOCK ${item['name']}',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.textDark, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Would you like to spend ${item['price']} coins to unlock this avatar style?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppTheme.textSlate, fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('NOT YET', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textGray)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      progress.buyItem(item['id'], item['price'] as int, item['emoji'] as String);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text('BUY NOW', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
