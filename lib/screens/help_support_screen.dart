import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────
// NO API KEY NEEDED — 100% offline, rule-based chatbot
// Only dependency needed: url_launcher (already in your pubspec)
// ─────────────────────────────────────────────────────────────

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const _email = 'officialboipara@gmail.com';
  static const _whatsapp = '8801410651007';
  static const _facebook =
      'https://www.facebook.com/profile.php?id=61581000306072';

  static const _brown = Color(0xFF613613);
  static const _bg = Color(0xFFF5F0E9);

  final List<_FaqItem> _faqs = [
    _FaqItem(
      q: 'How do I sell a book?',
      a: 'Go to the homepage and tap "Sell". Fill in your book details (name, author, condition, price), choose your payment method, and submit. Our team will review and approve it within 24 hours.',
    ),
    _FaqItem(
      q: 'How does delivery work?',
      a: 'After a buyer places an order, the seller packages the book. You can track every step live in "Track Delivery". Typical delivery is 2–5 business days inside Bangladesh.',
    ),
    _FaqItem(
      q: 'What payment methods are supported?',
      a: 'We support bKash, Nagad, Bank Transfer, and Cash on Delivery. Manage your payment methods from your Profile page.',
    ),
    _FaqItem(
      q: 'How do I get paid after a sale?',
      a: 'Once the order is marked "Delivered", payment is transferred to your registered bKash/Nagad/bank account within 1–2 business days.',
    ),
    _FaqItem(
      q: 'Can I return a book?',
      a: 'Returns are accepted within 3 days of delivery if the book condition significantly differs from the listing. Contact support with photos and your order ID.',
    ),
    _FaqItem(
      q: 'How do I join a Book Club?',
      a: 'Tap "Clubs" in the bottom navigation bar. Browse available clubs and tap "Join". You can also create your own club by tapping the "+" button.',
    ),
    _FaqItem(
      q: 'How do I publish my own book?',
      a: 'Tap "Publish" on the homepage. Fill in your manuscript details and submit for review. Boipara handles distribution — you earn royalties on every sale.',
    ),
    _FaqItem(
      q: 'Is my payment information secure?',
      a: 'Yes. We never store your full payment credentials. All transactions go through licensed payment gateways and are encrypted in transit.',
    ),
  ];

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {
        'subject': 'Boipara Support Request',
        'body': 'Hi Boipara team,\n\nI need help with...',
      },
    );
    if (!await launchUrl(uri)) _snack('Could not open email app.');
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse(
      'https://wa.me/$_whatsapp?text=${Uri.encodeComponent('Hi Boipara! I need some help.')}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication))
      _snack('Could not open WhatsApp.');
  }

  Future<void> _launchFacebook() async {
    final uri = Uri.parse(_facebook);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication))
      _snack('Could not open Facebook.');
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _openChat() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ChatbotSheet(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _brown,
        foregroundColor: Colors.white,
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AiCard(onTap: _openChat),
          const SizedBox(height: 24),
          Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _brown,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ContactCard(
                  icon: Icons.email_outlined,
                  iconColor: Colors.blue.shade700,
                  label: 'Email Us',
                  sub: _email,
                  onTap: _launchEmail,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ContactCard(
                  icon: Icons.chat,
                  iconColor: Colors.green.shade600,
                  label: 'WhatsApp',
                  sub: '+880 1410 651007',
                  onTap: _launchWhatsApp,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ContactCard(
                  icon: Icons.facebook,
                  iconColor: const Color(0xFF1877F2),
                  label: 'Facebook',
                  sub: 'Boipara BD',
                  onTap: _launchFacebook,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _brown,
            ),
          ),
          const SizedBox(height: 12),
          ..._faqs.map((f) => _FaqTile(item: f)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ── AI Banner Card ────────────────────────────────────────────
class _AiCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AiCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4700), Color(0xFF613613)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE07B39),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Beta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ask anything about Boipara — buying, selling, delivery, payments, clubs and more.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Chat with Assistant',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.support_agent_rounded,
              size: 80,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact Card ──────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, sub;
  final VoidCallback onTap;
  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── FAQ ───────────────────────────────────────────────────────
class _FaqItem {
  final String q, a;
  _FaqItem({required this.q, required this.a});
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  const _FaqTile({required this.item});
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          title: Text(
            widget.item.q,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          trailing: AnimatedRotation(
            turns: _open ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.keyboard_arrow_down),
          ),
          onExpansionChanged: (v) => setState(() => _open = v),
          children: [
            Text(
              widget.item.a,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CHATBOT SHEET — 100% Offline / Rule-based
// ─────────────────────────────────────────────────────────────
class _ChatbotSheet extends StatefulWidget {
  const _ChatbotSheet();
  @override
  State<_ChatbotSheet> createState() => _ChatbotSheetState();
}

class _ChatbotSheetState extends State<_ChatbotSheet> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _showTyping = false;

  final List<_Msg> _messages = [
    _Msg(
      role: 'bot',
      text:
          'আস্সালামু আলাইকুম! 👋 I\'m Boipara\'s assistant.\n\nI can help you with selling, buying, delivery tracking, payments, book clubs, and more. What do you need help with?',
    ),
  ];

  static const _chips = [
    'How do I sell a book?',
    'Track my order',
    'Payment methods',
    'How to join a club?',
    'How to publish a book?',
    'Return a book',
    'Contact support',
  ];

  // ── Rule engine ───────────────────────────────────────────
  static final List<_Rule> _rules = [
    _Rule(
      keys: ['sell', 'listing', 'list my book', 'how to sell', 'selling'],
      reply:
          '📚 To sell a book:\n\n1. Tap "Sell" on the homepage\n2. Fill in book name, author, edition, condition & price\n3. Choose your payment method (bKash/Nagad/Bank)\n4. Submit — our team reviews within 24 hours\n5. Once approved, buyers can find and order your book!\n\nTip: A detailed listing with good condition info sells faster.',
    ),

    _Rule(
      keys: ['buy', 'purchase', 'order a book', 'how to buy', 'buying'],
      reply:
          '🛒 To buy a book:\n\n1. Tap "Buy" on the homepage or browse\n2. Find the book you want and tap it\n3. Tap "Buy Now" and fill in your delivery address\n4. Select your payment method\n5. Confirm — the seller will be notified!\n\nYou can track your delivery live from "Track Delivery".',
    ),

    _Rule(
      keys: [
        'track',
        'delivery',
        'where is my order',
        'order status',
        'shipping',
        'tracking',
      ],
      reply:
          '📦 To track your delivery:\n\n1. Go to Profile → "My Orders"\n   OR tap "Track" on the homepage\n2. You\'ll see a live 5-step timeline:\n   ✅ Ordered\n   📦 Packaging\n   🚚 Picked Up\n   🛵 Out for Delivery\n   ✅ Delivered\n\nDelivery typically takes 2–5 business days inside Bangladesh.',
    ),

    _Rule(
      keys: [
        'payment',
        'bkash',
        'nagad',
        'bank',
        'cash on delivery',
        'cod',
        'pay',
      ],
      reply:
          '💳 Boipara supports these payment methods:\n\n• bKash\n• Nagad\n• Bank Transfer\n• Cash on Delivery (COD)\n\nAdd or manage payment methods from:\nProfile → Payment Methods\n\nYour payment info is fully encrypted and secure.',
    ),

    _Rule(
      keys: [
        'paid',
        'earnings',
        'revenue',
        'seller payment',
        'get my money',
        'withdrawal',
      ],
      reply:
          '💰 After your book is delivered:\n\n1. Order is marked "Delivered"\n2. Payment is transferred to your bKash/Nagad/bank\n3. Usually takes 1–2 business days\n\nSee all your earnings in:\nProfile → Transaction History → Earnings tab',
    ),

    _Rule(
      keys: ['return', 'refund', 'wrong book', 'damaged', 'condition'],
      reply:
          '🔄 Return Policy:\n\nReturns are accepted within 3 days of delivery if:\n• The condition is significantly different from the listing\n• Wrong book was sent\n\nTo return:\n1. Take photos of the book\n2. Contact us on WhatsApp: +8801410651007\n3. Share your Order ID and photos\n4. We\'ll arrange the return and refund.',
    ),

    _Rule(
      keys: ['club', 'book club', 'join club', 'create club', 'reading group'],
      reply:
          '📖 Book Clubs on Boipara:\n\n• Tap "Clubs" in the bottom nav bar\n• Browse all available clubs\n• Tap "Join" to become a member\n• Tap "+" to create your own club\n\nInside a club you can:\n✅ Discuss books\n✅ Chat with members\n✅ See upcoming events\n✅ Track what the club is reading',
    ),

    _Rule(
      keys: ['publish', 'author', 'write', 'my book', 'new book', 'manuscript'],
      reply:
          '✍️ To publish your own book on Boipara:\n\n1. Tap "Publish" on the homepage\n2. Fill in your book details\n3. Submit for review\n4. Boipara handles printing & distribution\n5. You earn royalties on every sale!\n\nFor details, contact:\nofficialboipara@gmail.com',
    ),

    _Rule(
      keys: [
        'account',
        'profile',
        'edit profile',
        'change name',
        'update info',
      ],
      reply:
          '👤 To manage your account:\n\n• Profile photo & bio → Profile → Edit Profile\n• Delivery addresses → Profile → Addresses\n• Payment methods → Profile → Payment Methods\n• Change password → use "Forgot Password" on login screen',
    ),

    _Rule(
      keys: ['notification', 'alert', 'notify', 'bell'],
      reply:
          '🔔 You get notified for:\n\n• New order on your book\n• Question asked about your book\n• Answer to your question\n• Like on your post\n• Comment on your post\n\nTap the 🔔 bell icon in the top-right of the homepage to see all notifications.',
    ),

    _Rule(
      keys: ['security', 'safe', 'secure', 'privacy', 'data'],
      reply:
          '🔒 Your data is safe with Boipara:\n\n• We never store full payment credentials\n• All data is encrypted in transit\n• Firebase Auth — industry-standard security\n• Contact us to delete your account anytime\n\nEmail: officialboipara@gmail.com',
    ),

    _Rule(
      keys: [
        'contact',
        'support',
        'help',
        'reach',
        'human',
        'agent',
        'talk to',
      ],
      reply:
          '📞 Contact Boipara Support:\n\n📧 Email: officialboipara@gmail.com\n💬 WhatsApp: +8801410651007\n📘 Facebook: fb.com/boiparabd\n\nWhatsApp is fastest — we usually reply within a few hours!',
    ),

    _Rule(
      keys: [
        'hello',
        'hi',
        'hey',
        'assalamu',
        'salam',
        'hola',
        'good morning',
        'good afternoon',
        'good evening',
      ],
      reply:
          '👋 Hello! Welcome to Boipara support!\n\nI\'m here to help you with:\n📚 Buying & selling books\n📦 Delivery tracking\n💳 Payments\n📖 Book clubs\n✍️ Publishing\n\nWhat do you need help with?',
    ),

    _Rule(
      keys: ['thank', 'thanks', 'ধন্যবাদ', 'shukriya', 'dhonnobad'],
      reply:
          '😊 You\'re welcome! Happy reading! 📚\n\nIf you need anything else, just ask. You can also reach us on WhatsApp anytime: +8801410651007',
    ),

    _Rule(
      keys: [
        'guest',
        'without account',
        'login',
        'sign up',
        'register',
        'create account',
      ],
      reply:
          '🔑 Account & Login:\n\n• Browse as a guest without logging in\n• To buy, sell, or join clubs — you need an account\n• Sign up with Email, Google, or Phone number\n• Forgot password? Use "Forgot Password" on login\n\nCreating an account is free and takes under a minute!',
    ),

    _Rule(
      keys: [
        'university',
        'student',
        'du',
        'buet',
        'nsu',
        'brac',
        'student price',
      ],
      reply:
          '🎓 Boipara is built for university students!\n\nAvailable to students across Bangladesh:\nDU, BUET, NSU, BRAC, IUT, RUET, CUET and more\n\nSell your old textbooks and buy preloved books at student-friendly prices! 📚',
    ),
  ];

  static const _fallback =
      'Sorry, I didn\'t quite understand that. 🤔\n\nYou can ask me about:\n• Selling or buying books\n• Delivery tracking\n• Payment methods\n• Book clubs\n• Publishing a book\n• Returns & refunds\n• Account settings\n\nOr reach us on WhatsApp: +8801410651007';

  String _getReply(String input) {
    final lower = input.toLowerCase().trim();
    for (final rule in _rules) {
      for (final key in rule.keys) {
        if (lower.contains(key)) return rule.reply;
      }
    }
    return _fallback;
  }

  void _sendWithTyping([String? preText]) {
    final text = (preText ?? _ctrl.text).trim();
    if (text.isEmpty || _showTyping) return;
    setState(() {
      _messages.add(_Msg(role: 'user', text: text));
      _showTyping = true;
    });
    _ctrl.clear();
    _scrollDown();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _showTyping = false;
        _messages.add(_Msg(role: 'bot', text: _getReply(text)));
      });
      _scrollDown();
    });
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F0E9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF613613),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Boipara Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Always online',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
              itemCount: _messages.length + (_showTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length) return const _TypingIndicator();
                return _ChatBubble(msg: _messages[i]);
              },
            ),
          ),
          // Suggestion chips
          if (_messages.length <= 1)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                children: _chips
                    .map(
                      (chip) => GestureDetector(
                        onTap: () => _sendWithTyping(chip),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE07B39).withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            chip,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7C4700),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottomInset),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onSubmitted: (_) => _sendWithTyping(),
                    textInputAction: TextInputAction.send,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Type your question...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F0E9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendWithTyping,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF613613),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MODELS & WIDGETS
// ─────────────────────────────────────────────────────────────
class _Rule {
  final List<String> keys;
  final String reply;
  const _Rule({required this.keys, required this.reply});
}

class _Msg {
  final String role, text;
  _Msg({required this.role, required this.text});
}

class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  const _ChatBubble({required this.msg});
  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF613613),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF613613) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.grey.shade800,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      );
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF613613),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => AnimatedBuilder(
                  animation: _ctrls[i],
                  builder: (_, __) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 7,
                    height: 7 + _ctrls[i].value * 6,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        Colors.grey.shade300,
                        const Color(0xFFE07B39),
                        _ctrls[i].value,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}