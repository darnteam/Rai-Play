import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  String _timeRange = "Weekly"; // Weekly, Monthly, All-time
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock data - in a real app, this would come from a provider
    final globalUsers = [
      _LeaderboardUser(rank: 1, name: "Maya", avatar: "M", xp: 2350),
      _LeaderboardUser(rank: 2, name: "Jackson", avatar: "J", xp: 2100),
      _LeaderboardUser(rank: 3, name: "Olivia", avatar: "O", xp: 1900),
      _LeaderboardUser(rank: 4, name: "Noah", avatar: "N", xp: 1750),
      _LeaderboardUser(rank: 5, name: "Emma", avatar: "E", xp: 1600),
      _LeaderboardUser(rank: 6, name: "Liam", avatar: "L", xp: 1450),
      _LeaderboardUser(rank: 7, name: "Ava", avatar: "A", xp: 1350),
      _LeaderboardUser(rank: 8, name: "Alex", avatar: "A", xp: 1220, isCurrentUser: true),
      _LeaderboardUser(rank: 9, name: "Sophia", avatar: "S", xp: 1100),
      _LeaderboardUser(rank: 10, name: "Ethan", avatar: "E", xp: 950),
    ];
    
    final friendUsers = [
      _LeaderboardUser(rank: 1, name: "Emma", avatar: "E", xp: 1600),
      _LeaderboardUser(rank: 2, name: "Alex", avatar: "A", xp: 1220, isCurrentUser: true),
      _LeaderboardUser(rank: 3, name: "Noah", avatar: "N", xp: 950),
      _LeaderboardUser(rank: 4, name: "Sophia", avatar: "S", xp: 800),
      _LeaderboardUser(rank: 5, name: "Ethan", avatar: "E", xp: 750),
    ];
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text("Leaderboard"),
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
      ),
      body: Column(
        children: [
          // Tab Bar and Time Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Time range dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$_timeRange Leaderboard",
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      DropdownButton<String>(
                        value: _timeRange,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: theme.colorScheme.primary,
                        ),
                        elevation: 16,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        underline: Container(
                          height: 0,
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            _timeRange = value!;
                          });
                        },
                        items: ["Weekly", "Monthly", "All-time"]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tab bar
                TabBar(
                  controller: _tabController,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 3,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                  tabs: const [
                    Tab(text: "Global"),
                    Tab(text: "Friends"),
                  ],
                ),
              ],
            ),
          ),
          
          // Leaderboard content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Global leaderboard
                _buildLeaderboardList(globalUsers),
                
                // Friends leaderboard
                _buildLeaderboardList(friendUsers),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLeaderboardList(List<_LeaderboardUser> users) {
    final theme = Theme.of(context);
    final topThree = users.take(3).toList();
    final otherUsers = users.skip(3).toList();
    
    return CustomScrollView(
      slivers: [
        // Top 3 users
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (topThree.length > 1)
                  _buildTopUserWidget(topThree[1], 2, 75, false), // 2nd place
                if (topThree.isNotEmpty)
                  _buildTopUserWidget(topThree[0], 1, 100, true), // 1st place
                if (topThree.length > 2)
                  _buildTopUserWidget(topThree[2], 3, 60, false), // 3rd place
              ],
            ),
          ),
        ),
        
        // Other users
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final user = otherUsers[index];
              return _buildUserListItem(user);
            },
            childCount: otherUsers.length,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTopUserWidget(_LeaderboardUser user, int position, double size, bool isFirst) {
    final theme = Theme.of(context);
    
    // Define colors and icons based on position
    Color avatarBgColor;
    Widget? badge;
    
    switch (position) {
      case 1:
        avatarBgColor = const Color(0xFFFFD700); // Gold
        badge = const Text("👑", style: TextStyle(fontSize: 24));
        break;
      case 2:
        avatarBgColor = const Color(0xFFC0C0C0); // Silver
        badge = const Text("🥈", style: TextStyle(fontSize: 20));
        break;
      case 3:
        avatarBgColor = const Color(0xFFCD7F32); // Bronze
        badge = const Text("🥉", style: TextStyle(fontSize: 20));
        break;
      default:
        avatarBgColor = theme.colorScheme.primary;
        badge = null;
    }
    
    return Column(
      children: [
        if (badge != null) ...[
          badge,
          const SizedBox(height: 8),
        ],
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarBgColor.withOpacity(0.8),
                border: Border.all(
                  color: avatarBgColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: avatarBgColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.avatar,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isFirst ? 36 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (user.isCurrentUser)
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.onSecondary,
                  size: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: user.isCurrentUser ? FontWeight.bold : FontWeight.normal,
            color: user.isCurrentUser ? theme.colorScheme.primary : null,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isFirst
                ? const Color(0xFFFFD700).withOpacity(0.2)
                : theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "${user.xp} XP",
            style: theme.textTheme.labelMedium?.copyWith(
              color: isFirst ? const Color(0xFFAA8500) : theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildUserListItem(_LeaderboardUser user) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: user.isCurrentUser
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: user.isCurrentUser
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: user.isCurrentUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.rank.toString(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: user.isCurrentUser
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Avatar
          CircleAvatar(
            backgroundColor: user.isCurrentUser
                ? theme.colorScheme.secondary
                : theme.colorScheme.primary.withOpacity(0.2),
            radius: 20,
            child: Text(
              user.avatar,
              style: TextStyle(
                color: user.isCurrentUser
                    ? theme.colorScheme.onSecondary
                    : theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Name
          Expanded(
            child: Text(
              user.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: user.isCurrentUser ? FontWeight.bold : null,
              ),
            ),
          ),
          
          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: user.isCurrentUser
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "${user.xp} XP",
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardUser {
  final int rank;
  final String name;
  final String avatar;
  final int xp;
  final bool isCurrentUser;
  
  _LeaderboardUser({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.xp,
    this.isCurrentUser = false,
  });
}