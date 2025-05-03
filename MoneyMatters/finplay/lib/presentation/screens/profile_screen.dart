import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/animated_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Info
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.onPrimary,
                          child: Text(
                            "A",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // User name
                        Text(
                          "Alex Johnson",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // User level
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "Level 7 - Saver Pro",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // User stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem("1,245", "XP"),
                            Container(
                              height: 24,
                              width: 1,
                              color: theme.colorScheme.onPrimary.withOpacity(0.2),
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            _buildStatItem("32", "Quests"),
                            Container(
                              height: 24,
                              width: 1,
                              color: theme.colorScheme.onPrimary.withOpacity(0.2),
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            _buildStatItem("157", "Coins"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Tabs
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(text: "Achievements"),
                  Tab(text: "Stats"),
                  Tab(text: "Saved"),
                ],
              ),
            ),
            pinned: true,
          ),
          
          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Achievements Tab
                _buildAchievementsTab(theme),
                
                // Stats Tab
                _buildStatsTab(theme),
                
                // Saved Tab
                _buildSavedTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievementsTab(ThemeData theme) {
    // Mock achievements data
    final achievements = [
      _Achievement(
        id: 'a1',
        title: 'First Steps',
        description: 'Complete your first quest',
        iconData: Icons.flag,
        progress: 1,
        total: 1,
        isCompleted: true,
        xpReward: 20,
      ),
      _Achievement(
        id: 'a2',
        title: 'Savings Starter',
        description: 'Save your first 100',
        iconData: Icons.savings,
        progress: 1,
        total: 1,
        isCompleted: true,
        xpReward: 30,
      ),
      _Achievement(
        id: 'a3',
        title: 'Budget Master',
        description: 'Create and follow a budget for 1 month',
        iconData: Icons.trending_up,
        progress: 1,
        total: 1,
        isCompleted: true,
        xpReward: 40,
      ),
      _Achievement(
        id: 'a4',
        title: 'Game Champion',
        description: 'Win 5 financial games',
        iconData: Icons.videogame_asset,
        progress: 3,
        total: 5,
        isCompleted: false,
        xpReward: 50,
      ),
      _Achievement(
        id: 'a5',
        title: 'Knowledge Seeker',
        description: 'Watch 10 educational videos',
        iconData: Icons.movie,
        progress: 7,
        total: 10,
        isCompleted: false,
        xpReward: 50,
      ),
      _Achievement(
        id: 'a6',
        title: 'Social Butterfly',
        description: 'Invite 3 friends to join FinPlay',
        iconData: Icons.people,
        progress: 1,
        total: 3,
        isCompleted: false,
        xpReward: 60,
      ),
      _Achievement(
        id: 'a7',
        title: 'Streak Master',
        description: 'Maintain a 7-day login streak',
        iconData: Icons.local_fire_department,
        progress: 7,
        total: 7,
        isCompleted: true,
        xpReward: 35,
      ),
      _Achievement(
        id: 'a8',
        title: 'Quiz Whiz',
        description: 'Score 100% on 3 financial quizzes',
        iconData: Icons.quiz,
        progress: 2,
        total: 3,
        isCompleted: false,
        xpReward: 45,
      ),
    ];
    
    final completedAchievements = achievements.where((a) => a.isCompleted).toList();
    final inProgressAchievements = achievements.where((a) => !a.isCompleted).toList();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Completed section
        Text(
          "Completed (${completedAchievements.length})",
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: completedAchievements.length,
          itemBuilder: (context, index) {
            final achievement = completedAchievements[index];
            return _buildAchievementCard(theme, achievement);
          },
        ),
        
        const SizedBox(height: 24),
        
        // In Progress section
        Text(
          "In Progress (${inProgressAchievements.length})",
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: inProgressAchievements.length,
          itemBuilder: (context, index) {
            final achievement = inProgressAchievements[index];
            return _buildAchievementCard(theme, achievement);
          },
        ),
      ],
    );
  }
  
  Widget _buildAchievementCard(ThemeData theme, _Achievement achievement) {
    final isCompleted = achievement.isCompleted;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? Border.all(color: theme.colorScheme.secondary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and XP reward
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? theme.colorScheme.secondary.withOpacity(0.2)
                        : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    achievement.iconData,
                    color: isCompleted
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? theme.colorScheme.secondary.withOpacity(0.1)
                        : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: isCompleted
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${achievement.xpReward}",
                        style: TextStyle(
                          color: isCompleted
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            
            // Title
            Text(
              achievement.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            
            // Description
            Text(
              achievement.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            // Progress indicator
            if (!isCompleted) ...[
              LinearProgressIndicator(
                value: achievement.progress / achievement.total,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 4),
              Text(
                "${achievement.progress}/${achievement.total}",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Completed",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsTab(ThemeData theme) {
    // Mock data for user stats
    final stats = {
      'Total XP': 1245,
      'Current Level': 7,
      'Quests Completed': 32,
      'Current Streak': 14,
      'Longest Streak': 21,
      'Games Played': 47,
      'Videos Watched': 28,
      'Coins Earned': 157,
      'Quiz Score Average': '85%',
    };
    
    // Weekly activity data for chart
    final weeklyActivity = [
      _ActivityData(day: 'Mon', minutes: 15),
      _ActivityData(day: 'Tue', minutes: 25),
      _ActivityData(day: 'Wed', minutes: 10),
      _ActivityData(day: 'Thu', minutes: 30),
      _ActivityData(day: 'Fri', minutes: 20),
      _ActivityData(day: 'Sat', minutes: 45),
      _ActivityData(day: 'Sun', minutes: 35),
    ];
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Weekly activity card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Weekly Activity",
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "You spent 3h 5m learning this week",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weeklyActivity.map((data) {
                    final maxMinutes = weeklyActivity.map((d) => d.minutes).reduce((a, b) => a > b ? a : b);
                    final barHeight = (data.minutes / maxMinutes) * 150;
                    
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: barHeight,
                            width: 16,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.day,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${data.minutes}m",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // User stats grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final entry = stats.entries.elementAt(index);
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.value.toString(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.key,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Export stats button
        AnimatedButton(
          text: "Export My Stats",
          icon: Icons.download,
          backgroundColor: theme.colorScheme.surface,
          textColor: theme.colorScheme.primary,
          onPressed: () {
            // Export functionality
          },
        ),
      ],
    );
  }
  
  Widget _buildSavedTab(ThemeData theme) {
    // Mock data for saved content
    final savedVideos = [
      _SavedContent(
        id: 'v1',
        title: 'How to Start Investing with 100',
        thumbnail: 'assets/images/investing_video.png',
        type: 'video',
        creator: 'FinanceSage',
        timestamp: '2 days ago',
      ),
      _SavedContent(
        id: 'v2',
        title: 'Crypto Explained Simply',
        thumbnail: 'assets/images/crypto_video.png',
        type: 'video',
        creator: 'CryptoClarity',
        timestamp: '1 week ago',
      ),
    ];
    
    final savedArticles = [
      _SavedContent(
        id: 'a1',
        title: '10 Tips for Budgeting on a Low Income',
        thumbnail: 'assets/images/budget_article.png',
        type: 'article',
        creator: 'MoneyMentor',
        timestamp: '3 days ago',
      ),
      _SavedContent(
        id: 'a2',
        title: 'Understanding Credit Scores',
        thumbnail: 'assets/images/credit_article.png',
        type: 'article',
        creator: 'CreditPro',
        timestamp: '5 days ago',
      ),
    ];
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Saved videos section
        Text(
          "Saved Videos",
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        ...savedVideos.map((video) => _buildSavedContentCard(theme, video)),
        
        const SizedBox(height: 24),
        
        // Saved articles section
        Text(
          "Saved Articles",
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        ...savedArticles.map((article) => _buildSavedContentCard(theme, article)),
        
        const SizedBox(height: 24),
        
        // No saved quizzes message
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.bookmark_border,
                color: theme.colorScheme.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "No Saved Quizzes",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Bookmark quizzes to practice them later",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AnimatedButton(
                text: "Explore Quizzes",
                icon: Icons.quiz,
                onPressed: () {
                  // Navigate to quizzes
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSavedContentCard(ThemeData theme, _SavedContent content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Open content
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(content.thumbnail),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      content.type == 'video' ? Icons.play_arrow : Icons.article,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Content details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content type and actions
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            content.type.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          iconSize: 20,
                          onPressed: () {
                            // Show options menu
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Title
                    Text(
                      content.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Creator and timestamp
                    Row(
                      children: [
                        Text(
                          content.creator,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          content.timestamp,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
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
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  
  _SliverAppBarDelegate(this._tabBar);
  
  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }
  
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _Achievement {
  final String id;
  final String title;
  final String description;
  final IconData iconData;
  final int progress;
  final int total;
  final bool isCompleted;
  final int xpReward;
  
  _Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    required this.progress,
    required this.total,
    required this.isCompleted,
    required this.xpReward,
  });
}

class _ActivityData {
  final String day;
  final int minutes;
  
  _ActivityData({
    required this.day,
    required this.minutes,
  });
}

class _SavedContent {
  final String id;
  final String title;
  final String thumbnail;
  final String type; // 'video', 'article', 'quiz'
  final String creator;
  final String timestamp;
  
  _SavedContent({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.type,
    required this.creator,
    required this.timestamp,
  });
}