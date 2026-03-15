import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'حان وقت صلاة المغرب',
      'body': 'لا تنسَ الصلاة على وقتها',
      'time': 'منذ 5 دقائق',
      'type': 'prayer',
      'read': false,
    },
    {
      'title': 'أذكار المساء 🌙',
      'body': 'حان وقت أذكار المساء، لا تنسَ ذكر الله',
      'time': 'منذ ساعة',
      'type': 'azkar',
      'read': false,
    },
    {
      'title': '🎉 تحدي جديد!',
      'body': 'تحدي اليوم: قراءة سورة الكهف',
      'time': 'منذ 3 ساعات',
      'type': 'challenge',
      'read': true,
    },
    {
      'title': '🔥 سلسلة 7 أيام!',
      'body': 'ماشاء الله! أكملت 7 أيام متتالية من الذكر',
      'time': 'أمس',
      'type': 'achievement',
      'read': true,
    },
    {
      'title': 'حان وقت صلاة الفجر',
      'body': 'الصلاة خير من النوم',
      'time': 'أمس 5:15 ص',
      'type': 'prayer',
      'read': true,
    },
    {
      'title': '📖 تذكير القراءة',
      'body': 'لم تقرأ القرآن اليوم، ورد اليوم في انتظارك',
      'time': 'منذ يومين',
      'type': 'quran',
      'read': true,
    },
  ];

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'prayer':
        return Icons.mosque;
      case 'azkar':
        return Icons.auto_stories;
      case 'challenge':
        return Icons.emoji_events;
      case 'achievement':
        return Icons.stars;
      case 'quran':
        return Icons.menu_book;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'prayer':
        return const Color(0xFF667eea);
      case 'azkar':
        return const Color(0xFF11998e);
      case 'challenge':
        return const Color(0xFFf093fb);
      case 'achievement':
        return const Color(0xFFFFD700);
      case 'quran':
        return const Color(0xFF4facfe);
      default:
        return Colors.grey;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف جميع الإشعارات'),
        content: const Text('هل تريد حذف جميع الإشعارات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _notifications.clear());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = _notifications.where((n) => !n['read']).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('قراءة الكل'),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _notifications.isNotEmpty ? _clearAll : null,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationCard(notification, isDark);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا إشعارات الصلاة والتذكيرات',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, bool isDark) {
    final isRead = notification['read'] as bool;
    final type = notification['type'] as String;
    final color = _getNotificationColor(type);

    return Dismissible(
      key: Key(notification['title'] + notification['time']),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() => _notifications.remove(notification));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark
              ? (isRead ? const Color(0xFF1e1e1e) : const Color(0xFF252525))
              : (isRead ? Colors.white : Colors.blue.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: isRead
              ? null
              : Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getNotificationIcon(type),
              color: color,
              size: 26,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification['title'],
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (!isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                notification['body'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                notification['time'],
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ),
          onTap: () {
            setState(() => notification['read'] = true);
          },
        ),
      ),
    );
  }
}