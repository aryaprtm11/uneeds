import 'package:flutter/material.dart';

// Models
import 'package:uneeds/models/notification.dart';

// Services
import 'package:uneeds/services/database_service.dart';

// Utils
import 'package:uneeds/utils/color.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService.instance;
  late TabController _tabController;
  List<NotificationModel> _allNotifications = [];
  List<NotificationModel> _unreadNotifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'unread', 'target', 'schedule'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
    
    // Generate smart notifications pada loading pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateSmartNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allNotifications = await _databaseService.getAllNotifications();
      final unreadNotifications = await _databaseService.getUnreadNotifications();

      setState(() {
        _allNotifications = allNotifications;
        _unreadNotifications = unreadNotifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateSmartNotifications() async {
    try {
      await _databaseService.generateSmartNotifications();
      _loadNotifications(); // Reload after generating
    } catch (e) {
      print('Error generating smart notifications: $e');
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead && notification.id != null) {
      final success = await _databaseService.markNotificationAsRead(notification.id!);
      if (success) {
        _loadNotifications();
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await _databaseService.markAllNotificationsAsRead();
    if (success) {
      _loadNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi telah dibaca'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    if (notification.id != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hapus Notifikasi'),
          content: const Text('Apakah Anda yakin ingin menghapus notifikasi ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final success = await _databaseService.deleteNotification(notification.id!);
        if (success) {
          _loadNotifications();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifikasi berhasil dihapus'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi'),
        content: const Text('Apakah Anda yakin ingin menghapus semua notifikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus Semua', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _databaseService.deleteAllNotifications();
      if (success) {
        _loadNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua notifikasi berhasil dihapus'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<NotificationModel> _getFilteredNotifications(List<NotificationModel> notifications) {
    switch (_selectedFilter) {
      case 'unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'target':
        return notifications.where((n) => n.type == 'target').toList();
      case 'schedule':
        return notifications.where((n) => n.type == 'schedule').toList();
      default:
        return notifications;
    }
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Semua', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Belum Dibaca', 'unread'),
          const SizedBox(width: 8),
          _buildFilterChip('Target', 'target'),
          const SizedBox(width: 8),
          _buildFilterChip('Jadwal', 'schedule'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF2B4865),
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: primaryBlueColor,
      checkmarkColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    final filteredNotifications = _getFilteredNotifications(notifications);

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'all' 
                ? 'Belum ada notifikasi'
                : 'Tidak ada notifikasi ${_getFilterLabel()}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _notificationCard(notification);
      },
    );
  }

  String _getFilterLabel() {
    switch (_selectedFilter) {
      case 'unread':
        return 'yang belum dibaca';
      case 'target':
        return 'target';
      case 'schedule':
        return 'jadwal';
      default:
        return '';
    }
  }

  Widget _notificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: InkWell(
        onTap: () => _markAsRead(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: notification.isRead 
              ? null 
              : Border.all(color: primaryBlueColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notification.isRead 
                    ? Colors.grey[100] 
                    : _getNotificationColor(notification.type),
                  shape: BoxShape.circle,
                  border: notification.isRead
                      ? Border.all(color: Colors.grey[300]!, width: 2)
                      : null,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: notification.isRead 
                    ? Colors.grey[600] 
                    : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead 
                                ? FontWeight.w500 
                                : FontWeight.bold,
                              color: const Color(0xFF2B4865),
                            ),
                          ),
                        ),
                        if (notification.priority == 'high')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Urgent',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getPriorityColor(notification.priority),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF2B4865).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.getTimeAgo(),
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF2B4865).withOpacity(0.5),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: primaryBlueColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'target':
        return const Color(0xFF2E7D32);
      case 'schedule':
        return primaryBlueColor;
      default:
        return const Color(0xFF2B4865);
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'target':
        return Icons.flag_outlined;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return const Color(0xFF2B4865);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FD),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B4865),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2B4865),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF2B4865),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'mark_all_read':
                            _markAllAsRead();
                            break;
                          case 'delete_all':
                            _deleteAllNotifications();
                            break;
                          case 'refresh':
                            _generateSmartNotifications();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'mark_all_read',
                          child: Row(
                            children: [
                              Icon(Icons.done_all, color: Color(0xFF2B4865)),
                              SizedBox(width: 8),
                              Text('Tandai Semua Dibaca'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'refresh',
                          child: Row(
                            children: [
                              Icon(Icons.refresh, color: Color(0xFF2B4865)),
                              SizedBox(width: 8),
                              Text('Perbarui Notifikasi'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete_all',
                          child: Row(
                            children: [
                              Icon(Icons.delete_sweep, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Hapus Semua'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            _buildFilterChips(),
            const SizedBox(height: 8),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Semua'),
                        if (_allNotifications.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B4865),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _allNotifications.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum Dibaca'),
                        if (_unreadNotifications.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _unreadNotifications.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                labelColor: const Color(0xFF2B4865),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF2B4865),
                indicatorWeight: 3,
              ),
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2B4865),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: primaryBlueColor,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildNotificationsList(_allNotifications),
                          _buildNotificationsList(_unreadNotifications),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
