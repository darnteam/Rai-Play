import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/game_category_card.dart';
import '../widgets/game_card.dart';
import 'games/impulse_invaders_screen.dart';
import 'games/savings_builder_screen.dart';
import 'games/budget_rush_screen.dart';
import 'games/investor_island_screen.dart';
import 'games/credit_quest_screen.dart';
import 'games/crypto_craze_screen.dart';
import 'games/bank_rush_screen.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  String _selectedCategory = "All";

  final List<String> _categories = [
    "All",
    "Savings",
    "Budgeting",
    "Investing",
    "Credit",
    "Crypto",
    "Taxes",
    "Banking",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock data - in a real app, this would come from a provider
    final games = [
      _GameInfo(
        id: "game1",
        title: "Budget Rush",
        description: "Make quick spending decisions under pressure with a limited budget",
        category: "Budgeting",
        difficulty: 2,
        xpReward: 25,
        coinReward: 20,
        durationMinutes: 3,
        imageUrl: "assets/images/budget_game.png",
      ),
      _GameInfo(
        id: "game2",
        title: "Impulse Invaders",
        description: "Swipe away temptations and save for what really matters!",
        category: "Savings",
        difficulty: 2,
        xpReward: 25,
        coinReward: 20,
        durationMinutes: 5,
        imageUrl: "assets/images/savings_game.png",
      ),
      _GameInfo(
        id: "game3",
        title: "Savings Builder",
        description: "Learn delayed gratification and watch your savings grow!",
        category: "Savings",
        difficulty: 2,
        xpReward: 30,
        coinReward: 25,
        durationMinutes: 8,
        imageUrl: "assets/images/savings_game.png",
      ),
      _GameInfo(
        id: "game4",
        title: "Investor Island",
        description: "Build your investment portfolio and learn about risk and reward!",
        category: "Investing",
        difficulty: 3,
        xpReward: 35,
        coinReward: 30,
        durationMinutes: 5,
        imageUrl: "assets/images/investing_game.png",
      ),
      _GameInfo(
        id: "game5",
        title: "Credit Crush",
        description: "Match items to improve your credit score",
        category: "Credit",
        difficulty: 2,
        xpReward: 25,
        coinReward: 20,
        durationMinutes: 6,
        imageUrl: "assets/images/credit_game.png",
      ),
      _GameInfo(
        id: "game9",
        title: "Credit Quest",
        description: "Go from rookie to tycoon! Build your credit score through life events.",
        category: "Credit",
        difficulty: 3,
        xpReward: 35,
        coinReward: 30,
        durationMinutes: 5,
        imageUrl: "assets/images/credit_game.png",
      ),
      _GameInfo(
        id: "game10",
        title: "CryptoCraze: Hype or HODL?",
        description: "Navigate the wild world of crypto, avoid scams, and learn to HODL!",
        category: "Crypto",
        difficulty: 3,
        xpReward: 35,
        coinReward: 30,
        durationMinutes: 5,
        imageUrl: "assets/images/crypto_game.png",
      ),
      _GameInfo(
        id: "game7",
        title: "Tax Tactics",
        description: "Learn about taxes by helping characters file correctly",
        category: "Taxes",
        difficulty: 4,
        xpReward: 40,
        coinReward: 35,
        durationMinutes: 12,
        imageUrl: "assets/images/tax_game.png",
      ),
      _GameInfo(
        id: "game8",
        title: "Bank Buddies",
        description: "Banking basics made fun with puzzles and challenges",
        category: "Banking",
        difficulty: 1,
        xpReward: 15,
        coinReward: 10,
        durationMinutes: 4,
        imageUrl: "assets/images/banking_game.png",
      ),
      _GameInfo(
        id: "game11",
        title: "BankRush: Master Your Money Moves",
        description: "Master checking, savings, and smart money moves in a fun banking adventure!",
        category: "Banking",
        difficulty: 2,
        xpReward: 30,
        coinReward: 25,
        durationMinutes: 6,
        imageUrl: "assets/images/banking_game.png",
      ),
    ];

    // Filter games by selected category
    final filteredGames = _selectedCategory == "All" ? games : games.where((game) => game.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 90,
            pinned: true,
            backgroundColor: const Color(0xFFFFED00),
            automaticallyImplyLeading: false,
            stretch: true,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Games",
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),
              titlePadding: const EdgeInsets.only(bottom: 20),
              background: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFED00),
                ),
              ),
            ),
          ),

          // Category filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          category,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Popular games carousel
          if (_selectedCategory == "All") ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Popular Games",
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFED00),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "HOT",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Check out what others are playing",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Popular games list
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    GameCard(
                      title: games[1].title, // Impulse Invaders
                      description: games[1].description,
                      imageUrl: games[1].imageUrl,
                      category: games[1].category,
                      difficulty: games[1].difficulty,
                      xpReward: games[1].xpReward,
                      coinReward: games[1].coinReward,
                      durationMinutes: games[1].durationMinutes,
                      isPopular: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImpulseInvadersScreen(
                              difficulty: games[1].difficulty,
                              onGameComplete: (score, coins) {
                                // Here you would update the user's profile with XP and coins
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('You earned $score points and $coins coins!'),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    GameCard(
                      title: games[0].title,
                      description: games[0].description,
                      imageUrl: games[0].imageUrl,
                      category: games[0].category,
                      difficulty: games[0].difficulty,
                      xpReward: games[0].xpReward,
                      coinReward: games[0].coinReward,
                      durationMinutes: games[0].durationMinutes,
                      isPopular: true,
                      onTap: () {
                        // Navigate to game
                      },
                    ),
                    GameCard(
                      title: games[3].title,
                      description: games[3].description,
                      imageUrl: games[3].imageUrl,
                      category: games[3].category,
                      difficulty: games[3].difficulty,
                      xpReward: games[3].xpReward,
                      coinReward: games[3].coinReward,
                      durationMinutes: games[3].durationMinutes,
                      isPopular: true,
                      onTap: () {
                        // Navigate to game
                      },
                    ),
                    GameCard(
                      title: games[4].title,
                      description: games[4].description,
                      imageUrl: games[4].imageUrl,
                      category: games[4].category,
                      difficulty: games[4].difficulty,
                      xpReward: games[4].xpReward,
                      coinReward: games[4].coinReward,
                      durationMinutes: games[4].durationMinutes,
                      isPopular: true,
                      onTap: () {
                        // Navigate to game
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Game categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Categories",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Find games by topic",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1.4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        GameCategoryCard(
                          title: "Savings",
                          icon: "💰",
                          gameCount: games.where((g) => g.category == "Savings").length,
                          color: const Color(0xFF4CD964),
                          onTap: () {
                            setState(() {
                              _selectedCategory = "Savings";
                            });
                          },
                        ),
                        GameCategoryCard(
                          title: "Budgeting",
                          icon: "📊",
                          gameCount: games.where((g) => g.category == "Budgeting").length,
                          color: const Color(0xFF5AC8FA),
                          onTap: () {
                            setState(() {
                              _selectedCategory = "Budgeting";
                            });
                          },
                        ),
                        GameCategoryCard(
                          title: "Investing",
                          icon: "📈",
                          gameCount: games.where((g) => g.category == "Investing").length,
                          color: const Color(0xFF007AFF),
                          onTap: () {
                            setState(() {
                              _selectedCategory = "Investing";
                            });
                          },
                        ),
                        GameCategoryCard(
                          title: "Credit",
                          icon: "💳",
                          gameCount: games.where((g) => g.category == "Credit").length,
                          color: const Color(0xFFFF2D55),
                          onTap: () {
                            setState(() {
                              _selectedCategory = "Credit";
                            });
                          },
                        ),
                        GameCategoryCard(
                          title: "Crypto",
                          icon: "🪙",
                          gameCount: games.where((g) => g.category == "Crypto").length,
                          color: const Color(0xFFFF9500),
                          onTap: () {
                            setState(() {
                              _selectedCategory = "Crypto";
                            });
                          },
                        ),
                        GameCategoryCard(
                          title: "Bank",
                          icon: "🧾",
                          gameCount: games.where((g) => g.category == "Bank").length,
                          color: const Color(0xFF5856D6),
                          onTap: () {
                            setState(() {
                              _selectedCategory = "Taxes";
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Category title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "$_selectedCategory Games",
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFED00),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${filteredGames.length}",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Play games to earn XP and coins",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filtered games list
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = filteredGames[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GameCard(
                        title: game.title,
                        description: game.description,
                        imageUrl: game.imageUrl,
                        category: game.category,
                        difficulty: game.difficulty,
                        xpReward: game.xpReward,
                        coinReward: game.coinReward,
                        durationMinutes: game.durationMinutes,
                        isPopular: false,
                        onTap: () {
                          _onGameTap(game);
                        },
                      ),
                    );
                  },
                  childCount: filteredGames.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onGameTap(_GameInfo game) {
    switch (game.id) {
      case "game1":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BudgetRushScreen()),
        );
        break;
      case "game2":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImpulseInvadersScreen(
              difficulty: game.difficulty,
              onGameComplete: (score, coins) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Score: $score | Coins earned: $coins'),
                  ),
                );
              },
            ),
          ),
        );
        break;
      case "game3":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SavingsBuilderScreen(
              onGameComplete: (score, coins) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Score: $score | Coins earned: $coins'),
                  ),
                );
              },
            ),
          ),
        );
        break;
      case "game4":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InvestorIslandScreen()),
        );
        break;
      case "game9":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreditQuestScreen()),
        );
        break;
      case "game10":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CryptoCrazeScreen()),
        );
        break;
      case "game11":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BankRushScreen()),
        );
        break;
      default:
        // Show coming soon for other games
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coming soon!'),
          ),
        );
    }
  }
}

class _GameInfo {
  final String id;
  final String title;
  final String description;
  final String category;
  final int difficulty;
  final int xpReward;
  final int coinReward;
  final int durationMinutes;
  final String imageUrl;

  _GameInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.xpReward,
    required this.coinReward,
    required this.durationMinutes,
    required this.imageUrl,
  });
}
