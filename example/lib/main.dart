import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_notch_topbar/animated_notch_topbar.dart';

void main() => runApp(const ExampleApp());

// ─────────────────────────────────────────────────────────────────────────────
// Root App
// ─────────────────────────────────────────────────────────────────────────────
class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  int _index = 0;

  static const _tabs = [
    TopBarTab(label: 'COFFEE LABS', theme: TopBarTheme.green),
    TopBarTab(
      label: 'Super Mall',
      theme: TopBarTheme.purple,
      useBrandColor: true,
    ),
    TopBarTab(label: '50%', sub: 'OFF ZONE', theme: TopBarTheme.mint),
    TopBarTab(label: 'Make a Print', theme: TopBarTheme.amber),
  ];

  static const _hints = ['coffees', 'products', 'deals', 'prints'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _tabs[_index].theme.useDarkForeground
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: const Color(0xFFFDFAF6),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top App Bar ──────────────────────────────────────────────
              AnimatedNotchTopBar(
                greetingName: 'Dilshad',
                locationLabel: 'New York, USA',
                searchHint: _hints[_index],
                tabs: _tabs,
                statusTime: null,
                onTabChanged: (i) => setState(() => _index = i),
                borderRadius: 0,
              ),
              // ── Body ─────────────────────────────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_index),
                    child: [
                      const _CoffeeBody(),
                      const _MallBody(),
                      const _OffersBody(),
                      const _PrintBody(),
                    ][_index],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionTitle({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1C),
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9A9488)),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 0 — Coffee Labs
// ─────────────────────────────────────────────────────────────────────────────
class _CoffeeBody extends StatelessWidget {
  const _CoffeeBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        const _SectionTitle(title: 'Categories'),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _CoffeeChip(emoji: '☕', label: 'Espresso'),
              _CoffeeChip(emoji: '🍵', label: 'Matcha'),
              _CoffeeChip(emoji: '🥛', label: 'Latte'),
              _CoffeeChip(emoji: '🧋', label: 'Bubble Tea'),
              _CoffeeChip(emoji: '🍫', label: 'Mocha'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle(title: "Today's Picks", action: 'See all'),
        const SizedBox(height: 12),
        _DrinkCard(
          emoji: '☕',
          name: 'Café Americano',
          desc: 'Bold double-shot with hot water',
          price: r'$4.50',
          bg: const Color(0xFFEAF4D8),
        ),
        const SizedBox(height: 12),
        _DrinkCard(
          emoji: '🥛',
          name: 'Caramel Cloud Latte',
          desc: 'Espresso, steamed milk & caramel drizzle',
          price: r'$5.80',
          bg: const Color(0xFFFFF3E0),
        ),
        const SizedBox(height: 12),
        _DrinkCard(
          emoji: '🧋',
          name: 'Taro Bubble Tea',
          desc: 'Creamy taro with golden tapioca pearls',
          price: r'$6.20',
          bg: const Color(0xFFEDE8F8),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8FBF9A), Color(0xFFA9D0AF)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '☕  Loyalty Card',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3 more cups to a FREE coffee!',
                      style: TextStyle(fontSize: 12, color: Color(0xDDFFFFFF)),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(6, (i) {
                  final filled = i < 3;
                  return Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      color: filled ? Colors.white : Colors.white30,
                      shape: BoxShape.circle,
                    ),
                    child: filled
                        ? const Icon(Icons.coffee,
                            size: 10, color: Color(0xFF8FBF9A))
                        : null,
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoffeeChip extends StatelessWidget {
  final String emoji;
  final String label;
  const _CoffeeChip({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1C)),
          ),
        ],
      ),
    );
  }
}

class _DrinkCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String desc;
  final String price;
  final Color bg;
  const _DrinkCard(
      {required this.emoji,
      required this.name,
      required this.desc,
      required this.price,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1C))),
                const SizedBox(height: 3),
                Text(desc,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B665C))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1C))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Add',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — Super Mall
// ─────────────────────────────────────────────────────────────────────────────
class _MallBody extends StatelessWidget {
  const _MallBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE0), Color(0xFF9B8DF0)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🎉 Weekend Sale!',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    SizedBox(height: 4),
                    Text('Up to 40% off selected items',
                        style: TextStyle(fontSize: 12, color: Color(0xDDFFFFFF))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: const Text('Shop Now',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6C5CE0))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Categories', action: 'See all'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
          children: const [
            _MallCat(emoji: '👗', label: 'Fashion', bg: Color(0xFFEDE8F8)),
            _MallCat(emoji: '📱', label: 'Electronics', bg: Color(0xFFE8F0FE)),
            _MallCat(emoji: '🏠', label: 'Home', bg: Color(0xFFEAF4D8)),
            _MallCat(emoji: '💄', label: 'Beauty', bg: Color(0xFFFFE8F0)),
            _MallCat(emoji: '🎮', label: 'Gaming', bg: Color(0xFFE8F4FD)),
            _MallCat(emoji: '🛒', label: 'Groceries', bg: Color(0xFFFFF3E0)),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Trending Now', action: 'See all'),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _TrendCard(emoji: '📱', name: 'iPhone 16 Pro', price: r'$999', tag: '🔥 Hot'),
              _TrendCard(emoji: '👟', name: 'Air Max 2025', price: r'$189', tag: '⚡ New'),
              _TrendCard(
                  emoji: '🎧', name: 'AirPods Ultra', price: r'$299', tag: '💜 Top Pick'),
              _TrendCard(
                  emoji: '⌚', name: 'Galaxy Watch 7', price: r'$349', tag: '🌟 Popular'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MallCat extends StatelessWidget {
  final String emoji;
  final String label;
  final Color bg;
  const _MallCat({required this.emoji, required this.label, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1C))),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String price;
  final String tag;
  const _TrendCard(
      {required this.emoji,
      required this.name,
      required this.price,
      required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x0E000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const Spacer(),
          Text(tag,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9A9488))),
          const SizedBox(height: 2),
          Text(name,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1C))),
          const SizedBox(height: 4),
          Text(price,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF6C5CE0))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — 50% Off Zone
// ─────────────────────────────────────────────────────────────────────────────
class _OffersBody extends StatelessWidget {
  const _OffersBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF4D8),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚡ Flash Sale',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E6B3E))),
                    SizedBox(height: 3),
                    Text('Limited time only!',
                        style: TextStyle(fontSize: 12, color: Color(0xFF5A8A6A))),
                  ],
                ),
              ),
              _TimerBox('02'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(':',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E6B3E))),
              ),
              _TimerBox('45'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(':',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E6B3E))),
              ),
              _TimerBox('31'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Best Deals', action: 'See all'),
        const SizedBox(height: 12),
        _DealCard(
          emoji: '👟',
          name: 'Nike Air Force 1',
          original: r'$150',
          sale: r'$75',
          discount: '-50%',
          bg: const Color(0xFFEAF4D8),
        ),
        const SizedBox(height: 12),
        _DealCard(
          emoji: '🎧',
          name: 'Sony WH-1000XM5',
          original: r'$400',
          sale: r'$200',
          discount: '-50%',
          bg: const Color(0xFFE4F0E4),
        ),
        const SizedBox(height: 12),
        _DealCard(
          emoji: '💻',
          name: 'MacBook Air M3',
          original: r'$1299',
          sale: r'$649',
          discount: '-50%',
          bg: const Color(0xFFDEEEDE),
        ),
        const SizedBox(height: 12),
        _DealCard(
          emoji: '⌚',
          name: 'Apple Watch S10',
          original: r'$399',
          sale: r'$199',
          discount: '-50%',
          bg: const Color(0xFFEAF4D8),
        ),
      ],
    );
  }
}

class _TimerBox extends StatelessWidget {
  final String value;
  const _TimerBox(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF2E6B3E),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(value,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
    );
  }
}

class _DealCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String original;
  final String sale;
  final String discount;
  final Color bg;
  const _DealCard(
      {required this.emoji,
      required this.name,
      required this.original,
      required this.sale,
      required this.discount,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 38)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1C))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(original,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9A9488),
                            decoration: TextDecoration.lineThrough)),
                    const SizedBox(width: 8),
                    Text(sale,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E6B3E))),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
                color: const Color(0xFF2E6B3E),
                borderRadius: BorderRadius.circular(10)),
            child: Text(discount,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — Make a Print
// ─────────────────────────────────────────────────────────────────────────────
class _PrintBody extends StatelessWidget {
  const _PrintBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFF3DDB0), Color(0xFFECD196)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const Text('🖼️', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 8),
              const Text('Upload Your Photo',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5C4A1E))),
              const SizedBox(height: 4),
              const Text('Turn your memories into beautiful prints',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF8A6C2E))),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                    color: const Color(0xFF5C4A1E),
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('+ Upload Now',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Print Types', action: 'See all'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: const [
            _PrintType(emoji: '🖼️', label: 'Photo Print', sub: r'From $1.99'),
            _PrintType(emoji: '🎨', label: 'Canvas', sub: r'From $24.99'),
            _PrintType(emoji: '📋', label: 'Poster', sub: r'From $9.99'),
            _PrintType(emoji: '📔', label: 'Photo Book', sub: r'From $19.99'),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Recent Orders'),
        const SizedBox(height: 12),
        _OrderItem(
          emoji: '🖼️',
          name: 'Family Photo 4×6',
          date: 'Delivered Sep 3',
          status: '✅ Done',
        ),
        const SizedBox(height: 10),
        _OrderItem(
          emoji: '🎨',
          name: 'Canvas 12×16',
          date: 'In transit · Sep 8',
          status: '🚚 Shipping',
        ),
        const SizedBox(height: 10),
        _OrderItem(
          emoji: '📋',
          name: 'Birthday Poster A3',
          date: 'Processing · Sep 8',
          status: '🔄 Processing',
        ),
      ],
    );
  }
}

class _PrintType extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  const _PrintType({required this.emoji, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECD196)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5C4A1E))),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8A6C2E))),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final String emoji;
  final String name;
  final String date;
  final String status;
  const _OrderItem(
      {required this.emoji,
      required this.name,
      required this.date,
      required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1C))),
                const SizedBox(height: 2),
                Text(date,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8A8A8A))),
              ],
            ),
          ),
          Text(status,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
