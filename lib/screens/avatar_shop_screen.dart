import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/progress_provider.dart';

class AvatarShopScreen extends StatelessWidget {
  const AvatarShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    
    final List<Map<String, dynamic>> shopItems = [
      {'id': 'standard_suit', 'name': 'Standard Suit', 'price': 0, 'color': Colors.grey},
      {'id': 'red_warrior', 'name': 'Red Warrior', 'price': 500, 'color': AppColors.primaryRed},
      {'id': 'golden_king', 'name': 'Golden King', 'price': 2000, 'color': Colors.amber},
      {'id': 'forest_scout', 'name': 'Forest Scout', 'price': 1000, 'color': Colors.green},
      {'id': 'space_explorer', 'name': 'Space Explorer', 'price': 1500, 'color': Colors.deepPurple},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Shop'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${progress.coins}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Avatar Preview
          Container(
            height: 250,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   _buildAvatarPreview(progress.currentEquipped, shopItems),
                   const SizedBox(height: 16),
                   Text('Level ${progress.level} Explorer', style: const TextStyle(color: Colors.grey)),
                ],
              ),
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
                final isEquipped = progress.currentEquipped == item['id'];

                return GestureDetector(
                  onTap: () {
                    if (isOwned) {
                      progress.equipItem(item['id']);
                    } else if (progress.coins >= (item['price'] as int)) {
                      _showBuyDialog(context, progress, item);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isEquipped ? AppColors.primaryRed : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 60, color: item['color'] as Color),
                        const SizedBox(height: 12),
                        Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (isOwned)
                          Text(isEquipped ? 'EQUIPPED' : 'OWNED', style: TextStyle(color: isEquipped ? AppColors.primaryRed : Colors.green, fontWeight: FontWeight.bold))
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.monetization_on, size: 16, color: Colors.amber),
                              Text(' ${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
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

  Widget _buildAvatarPreview(String equippedID, List<Map<String, dynamic>> items) {
    final item = items.firstWhere((i) => i['id'] == equippedID);
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: (item['color'] as Color).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 80, color: item['color'] as Color),
    );
  }

  void _showBuyDialog(BuildContext context, ProgressProvider progress, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buy ${item['name']}?'),
        content: Text('This will cost ${item['price']} coins.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              progress.buyItem(item['id'], item['price']);
              Navigator.pop(context);
            },
            child: const Text('Buy Now'),
          ),
        ],
      ),
    );
  }
}
