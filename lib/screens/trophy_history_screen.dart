import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trophy_provider.dart';
import '../models/trophy.dart';

/// トロフィー履歴画面
/// 獲得済みのトロフィーを一覧表示する
class TrophyHistoryScreen extends StatelessWidget {
  const TrophyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TrophyProviderから状態を取得
    final trophyProvider = context.watch<TrophyProvider>();
    final trophies = trophyProvider.trophies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('トロフィー履歴'),
        centerTitle: true,
      ),
      body: trophies.isEmpty
          ? _buildEmptyState(context)
          : _buildTrophyList(context, trophies),
    );
  }

  /// トロフィーがない場合の表示
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'まだトロフィーを獲得していません',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '生まれてからの節目の日にトロフィーが獲得できます',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// トロフィー一覧の表示
  Widget _buildTrophyList(BuildContext context, List<Trophy> trophies) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trophies.length,
      itemBuilder: (context, index) {
        final trophy = trophies[index];
        return _buildTrophyCard(context, trophy);
      },
    );
  }

  /// 個別のトロフィーカード
  Widget _buildTrophyCard(BuildContext context, Trophy trophy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              trophy.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          trophy.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(trophy.description),
            const SizedBox(height: 4),
            Text(
              _formatDate(trophy.acquiredAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  /// 日付をフォーマット
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}