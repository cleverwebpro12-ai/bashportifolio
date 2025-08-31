import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Add this import for URL strategy.
// Make sure to add flutter_web_plugins to your pubspec.yaml under dependencies:
// dependencies:
//   flutter_web_plugins:
//     sdk: flutter
import 'package:flutter_web_plugins/url_strategy.dart';

// Import the generated firebase_options.dart file
import 'firebase_options.dart';
import 'dashboard/admin_dashboard.dart'; // Import the new admin dashboard screen

void main() async {
  // Ensure that Flutter bindings are initialized before calling Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  // Use PathUrlStrategy to remove the '#' from the URL, allowing direct navigation.
  usePathUrlStrategy();
  // Initialize Firebase with the default options for the current platform.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Design Portfolio',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1a1a2e),
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6a4de3)),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white30),
        ),
        fontFamily: 'Inter',
      ),
      // The '/admin' route now works when typed directly in the browser
      routes: {
        '/': (context) => const PortfolioPage(),
        '/admin': (context) => const AdminDashboard(),
      },
      initialRoute: '/',
    );
  }
}

// The main portfolio page, containing all sections
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _processKey = GlobalKey();
  final GlobalKey _portfolioKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _insightsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  // Controllers for the contact form
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- FORM SUBMISSION LOGIC ---
  Future<void> _sendMessage() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Please fill out all required fields.'),
        ),
      );
      return;
    }

    try {
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Add data to Firestore
      await FirebaseFirestore.instance.collection('messages').add({
        'name': _nameController.text,
        'email': _emailController.text,
        'subject': _subjectController.text,
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Hide loading indicator
      Navigator.of(context).pop();

      // Clear the form fields
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Message sent successfully!'),
        ),
      );
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Failed to send message: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to determine padding
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 800 ? 96.0 : 24.0;

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeader(),
            _buildHeroSection(),
            // Use a Padding widget to apply responsive padding to sections
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  Container(key: _aboutKey, child: _buildAboutMeSection()),
                  Container(
                    key: _processKey,
                    child: _buildDesignProcessSection(),
                  ),
                  Container(
                    key: _portfolioKey,
                    child: _buildPortfolioSection(),
                  ),
                  Container(
                    key: _testimonialsKey,
                    child: _buildTestimonialsSection(),
                  ),
                  Container(key: _insightsKey, child: _buildInsightsSection()),
                  Container(key: _contactKey, child: _buildContactSection()),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // Header Section
  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 48,
            vertical: 24,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Design Portfolio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (!isMobile)
                Row(
                  children: [
                    _navLink('About', _aboutKey),
                    _navLink('Process', _processKey),
                    _navLink('Portfolio', _portfolioKey),
                    _navLink('Testimonials', _testimonialsKey),
                    _navLink('Insights', _insightsKey),
                    _navLink('Contact', _contactKey),
                    const SizedBox(width: 24),
                    const Icon(Icons.wb_sunny_outlined, color: Colors.white),
                  ],
                )
              else
                PopupMenuButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  color: const Color(0xFF212138),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('About'),
                      onTap: () => _scrollToSection(_aboutKey),
                    ),
                    PopupMenuItem(
                      child: const Text('Process'),
                      onTap: () => _scrollToSection(_processKey),
                    ),
                    PopupMenuItem(
                      child: const Text('Portfolio'),
                      onTap: () => _scrollToSection(_portfolioKey),
                    ),
                    PopupMenuItem(
                      child: const Text('Testimonials'),
                      onTap: () => _scrollToSection(_testimonialsKey),
                    ),
                    PopupMenuItem(
                      child: const Text('Insights'),
                      onTap: () => _scrollToSection(_insightsKey),
                    ),
                    PopupMenuItem(
                      child: const Text('Contact'),
                      onTap: () => _scrollToSection(_contactKey),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _navLink(String title, GlobalKey key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () => _scrollToSection(key),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ),
    );
  }

  // Hero Section
  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 96),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1a2e), Color(0xFF2a1a4e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'UI/UX Designer & Creative Developer',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Crafting Digital\nExperiences That Inspire',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'I design and build beautiful interfaces that engage users and help\nbusinesses grow through thoughtful design solutions.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _scrollToSection(_portfolioKey),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6a4de3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'View My Work',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 24),
              TextButton(
                onPressed: () => _scrollToSection(_contactKey),
                child: const Text(
                  'Let\'s Connect',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 64),
          const Icon(Icons.arrow_downward, color: Colors.white),
        ],
      ),
    );
  }

  // About Me Section
  Widget _buildAboutMeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          const Text(
            'About Me',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF212138),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'bash.jpg', // Placeholder
                    fit: BoxFit.cover,
                    height: 400,
                    width: 400,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hi, I\'m Bashir Jimoh',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "I'm a passionate UI/UX designer with over 3 years of experience creating engaging digital experiences. My approach combines aesthetic sensibility with user-centered design principles to craft interfaces that are both beautiful and functional.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  "With a background in both design and front-end development, I bridge the gap between concept and implementation, ensuring that designs not only look great but are also technically feasible.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),
                // Use Wrap for features to handle smaller screens
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildFeature(
                      Icons.person_outline,
                      'User-Centered',
                      'Designing for people first',
                    ),
                    _buildFeature(
                      Icons.lightbulb_outline,
                      'Creative',
                      'Innovative solutions',
                    ),
                    _buildFeature(
                      Icons.trending_up,
                      'Strategic',
                      'Data-driven approach',
                    ),
                    _buildFeature(
                      Icons.favorite_border,
                      'Passionate',
                      'Committed to excellence',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String subtitle) {
    return SizedBox(
      width: 150, // Give a fixed width to each item for better wrapping
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Design Process Section
  Widget _buildDesignProcessSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          const Text(
            'My Design Process',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'My systematic approach ensures thoughtful, user-centered solutions for every project',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 64),
          _buildProcessTimeline(),
        ],
      ),
    );
  }

  Widget _buildProcessTimeline() {
    // A simplified representation of the timeline
    return Column(
      children: [
        _buildProcessStep(
          Icons.search,
          'Discovery',
          'Understanding the problem space through research, interviews, and competitor analysis.',
        ),
        _buildProcessStep(
          Icons.explore_outlined,
          'Ideation',
          'Sketching concepts, creating wireframes, and exploring visual directions.',
        ),
        _buildProcessStep(
          Icons.design_services_outlined,
          'Design',
          'Crafting high-fidelity designs, interactive prototypes, and design systems.',
        ),
        _buildProcessStep(
          Icons.code,
          'Development',
          'Collaborating with developers to bring designs to life with pixel-perfect implementation.',
        ),
        _buildProcessStep(
          Icons.sync_alt,
          'Testing & Iteration',
          'Validating designs through user testing and refining based on feedback.',
        ),
      ],
    );
  }

  Widget _buildProcessStep(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6a4de3)),
            ),
            child: Icon(icon, color: const Color(0xFF6a4de3)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF212138),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Portfolio Section
  Widget _buildPortfolioSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          const Text(
            'My Portfolio',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Explore my recent design projects showcasing my skills in UI/UX design',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 64),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return GridView.count(
                crossAxisCount: isMobile ? 1 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isMobile ? 2 : 2.5,
                crossAxisSpacing: 32,
                mainAxisSpacing: 32,
                children: [
                  _buildPortfolioCard(
                    'Mobile App',
                    'Finance App Redesign',
                    'A complete redesign of a financial management application focusing on simplifying complex data and i...',
                  ),
                  _buildPortfolioCard(
                    'Web Design',
                    'E-commerce Website',
                    'A modern e-commerce platform designed to showcase artisan products with an emphasis on storytellin...',
                  ),
                  _buildPortfolioCard(
                    'Web Application',
                    'Health & Wellness Platform',
                    'A holistic wellness platform that helps users track multiple aspects of their health and wellbeing i...',
                  ),
                  _buildPortfolioCard(
                    'UI/UX Design',
                    'Smart Home Control System',
                    'An intuitive interface for managing connected home devices across multiple rooms and scenarios. ...',
                  ),
                  _buildPortfolioCard(
                    'Mobile App',
                    'Travel Experience App',
                    'A travel companion app that combines itinerary management with local discovery and social sharing. ...',
                  ),
                  _buildPortfolioCard(
                    'Web Application',
                    'Educational Platform',
                    'A comprehensive learning platform designed to make online education more engaging and effective for ...',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard(
    String category,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF212138),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: const TextStyle(
              color: Color(0xFF6a4de3),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Testimonials Section
  Widget _buildTestimonialsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64),
      color: const Color(0xFF1a1a2e),
      child: Column(
        children: [
          const Text(
            'Client Testimonials',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'What my clients say about working together',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 64),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              final testimonialCards = [
                _buildTestimonialCard(
                  'Habiba Koko',
                  'Product designer, Shebag holding Limited',
                  4,
                  'Working with this designer was an absolute pleasure. He transformed our complex ideas into a beautiful, friend that our customers love.',
                ),
                _buildTestimonialCard(
                  'Raihana Nuhu',
                  'Product Manager, Integrated communication Engineering',
                  5,
                  'The attention to detail and understanding of user experience principles really sets him apart. Our app\'s engagement metrics improved significantly after the redesign.',
                ),
                _buildTestimonialCard(
                  'Ahmed Ibrahim',
                  'Business Developer, Prime Electromech Limited',
                  5,
                  'Not only did he deliver an exceptional design, but their communication and project management skills made the entire process smooth and enjoyable.',
                ),
              ];

              if (isMobile) {
                return Column(
                  children: testimonialCards
                      .map(
                        (card) => Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: card,
                        ),
                      )
                      .toList(),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: testimonialCards[0]),
                  const SizedBox(width: 32),
                  Expanded(child: testimonialCards[1]),
                  const SizedBox(width: 32),
                  Expanded(child: testimonialCards[2]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(
    String name,
    String role,
    int rating,
    String feedback,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF212138),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '"',
            style: TextStyle(
              fontSize: 48,
              color: Color(0xFF6a4de3),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(role, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            feedback,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Design Insights Section
  Widget _buildInsightsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          const Text(
            'Design Insights',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thoughts, ideas, and perspectives on UI/UX design',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 64),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              final insightCards = [
                _buildInsightCard(
                  'https://media.gettyimages.com/id/1738752533/photo/a-view-of-a-computer-and-a-mobile-phone-on-an-office-desk.jpg?s=612x612&w=0&k=20&c=yTvkJtnPuFepIvXH2dYDIq72SfnkruvN7Flmy1_OEgs=',
                  'Research',
                  'Oct 15, 2023',
                  '6 min read',
                  'The Importance of User Research in UI/UX Design',
                  'Discover why user research is the foundation of effective design and how it can transform your products.',
                ),
                _buildInsightCard(
                  'https://media.gettyimages.com/id/2094337676/photo/diverse-team-working-together-in-modern-co-working-space.jpg?s=612x612&w=0&k=20&c=EvWROZsfro1ghOVViXVj-tKS364-NeabwNNYkyvhxoY=',
                  'Accessibility',
                  'Sep 22, 2023',
                  '8 min read',
                  'Designing for Accessibility: A Comprehensive Guide',
                  'Learn how to make your digital products accessible to all users and why it matters for your business.',
                ),
                _buildInsightCard(
                  'https://media.gettyimages.com/id/537706522/photo/overhead-image-of-a-female-blogger-writing-on-the-laptop.jpg?s=612x612&w=0&k=20&c=DLQWu1ss06K9oEeW6R1tIpGMn58ZlgFyj_wrOWKRFn0=',
                  'Design Theory',
                  'Aug 10, 2023',
                  '6 min read',
                  'Color Theory in UI Design: Creating Effective Color Schemes',
                  'Explore the psychology of color and learn how to create harmonious color palettes that enhance user experience.',
                ),
              ];
              if (isMobile) {
                return Column(
                  children: insightCards
                      .map(
                        (card) => Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: card,
                        ),
                      )
                      .toList(),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: insightCards[0]),
                  const SizedBox(width: 32),
                  Expanded(child: insightCards[1]),
                  const SizedBox(width: 32),
                  Expanded(child: insightCards[2]),
                ],
              );
            },
          ),
          const SizedBox(height: 48),
          TextButton.icon(
            onPressed: () {},
            icon: const Text(
              'View All Articles',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            label: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String imageUrl,
    String tag,
    String date,
    String readTime,
    String title,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            height: 200,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                color: const Color(0xFF212138),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              color: const Color(0xFF212138),
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.white24,
                size: 48,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(
              tag,
              style: const TextStyle(
                color: Color(0xFF6a4de3),
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(date, style: const TextStyle(color: Colors.white70)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(readTime, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {},
          icon: const Text(
            'Read More',
            style: TextStyle(color: Color(0xFF6a4de3), fontSize: 16),
          ),
          label: const Icon(Icons.arrow_forward, color: Color(0xFF6a4de3)),
        ),
      ],
    );
  }

  // Contact Section
  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          const Text(
            'Let\'s Work Together',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Have a project in mind? Let\'s create something amazing together',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 64),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              if (isMobile) {
                return Column(
                  children: [
                    _buildContactInfo(),
                    const SizedBox(height: 64),
                    _buildContactForm(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildContactInfo()),
                  const SizedBox(width: 64),
                  Expanded(flex: 2, child: _buildContactForm()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'I\'m always open to discussing new projects, creative ideas or opportunities to be part of your vision.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 32),
        _contactDetail(Icons.email_outlined, 'Email', 'bashjimoh02@gmail.com'),
        const SizedBox(height: 24),
        _contactDetail(Icons.phone_outlined, 'Phone', '+(234)8036897081'),
        const SizedBox(height: 24),
        _contactDetail(
          Icons.location_on_outlined,
          'Location',
          'Abuja, Nigeria',
        ),
        const SizedBox(height: 32),
        const Text(
          'Connect With Me',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _socialIcon(Icons.camera_alt_outlined), // Placeholder
            _socialIcon(Icons.tv_outlined), // Placeholder
            _socialIcon(Icons.sports_basketball_outlined), // Placeholder
            _socialIcon(Icons.link_outlined), // Placeholder
          ],
        ),
      ],
    );
  }

  Widget _contactDetail(IconData icon, String title, String detail) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6a4de3), size: 24),
        const SizedBox(width: 16),
        Expanded(
          // Use expanded to allow text to wrap
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70)),
              Text(
                detail,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF212138),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Me a Message',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 500;
              if (isMobile) {
                return Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Your name',
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'your.email@example.com',
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Your name',
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'your.email@example.com',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _subjectController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Subject',
              hintText: 'Project inquiry',
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _messageController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Tell me about your project...',
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendMessage, // <-- Updated this line
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6a4de3),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Send Message',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Footer Section
  Widget _buildFooter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final horizontalPadding = isMobile ? 24.0 : 96.0;

        if (isMobile) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 48,
            ),
            color: const Color(0xFF1a1a2e),
            child: Column(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Design Portfolio',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Creating beautiful, functional digital\nexperiences that connect brands with their\naudiences.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                FloatingActionButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
                const SizedBox(height: 48),
                const Text(
                  '© 2025 Design Portfolio. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 48,
          ),
          color: const Color(0xFF1a1a2e),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Design Portfolio',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Creating beautiful, functional digital\nexperiences that connect brands with their\naudiences.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const Text(
                '© 2025 Design Portfolio. All rights reserved.',
                style: TextStyle(color: Colors.white70),
              ),
              FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: Colors.white.withOpacity(0.1),
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}
