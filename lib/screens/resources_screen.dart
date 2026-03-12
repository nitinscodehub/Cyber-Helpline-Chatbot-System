import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/chat_provider.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredResources = [];
  String _selectedCategory = 'all';
  
  final List<Map<String, dynamic>> _allResources = [
    // Learn Section
    {
      'id': '1',
      'category': 'learn',
      'title': 'What is Cyber Crime?',
      'description': 'Basic understanding of cyber crimes',
      'icon': Icons.school,
      'color': Colors.blue,
      'content': '''
Cyber crime is any criminal activity that involves a computer, network, or networked device. 

Most cyber crimes are committed by cybercriminals or hackers who want to make money. However, occasionally cyber crime aims to damage computers or networks for reasons other than profit.

**Common Types:**
• Financial fraud
• Identity theft
• Cyber stalking
• Phishing attacks
• Ransomware

**Key Takeaway:** Stay informed and stay safe!''',
      'readTime': '3 min',
      'url': 'https://cybercrime.gov.in',
    },
    {
      'id': '2',
      'category': 'learn',
      'title': 'Types of Online Fraud',
      'description': 'UPI, Phishing, OTP scams explained',
      'icon': Icons.warning,
      'color': Colors.orange,
      'content': '''
**1. UPI Fraud**
Fraudsters trick you into sending money to wrong UPI IDs or fake QR codes.

**2. Phishing Attacks**
Fake emails/messages that look legitimate to steal your credentials.

**3. OTP Scams**
Scammers pose as bank officials to get your OTP.

**4. Fake Customer Care**
Fake numbers online that steal your money.

**5. Lottery Scams**
"You won a lottery" messages asking for advance payment.

**Protection Tips:**
• Never share OTP
• Verify before paying
• Use official apps only''',
      'readTime': '5 min',
    },
    {
      'id': '3',
      'category': 'learn',
      'title': 'Digital Safety Basics',
      'description': 'Essential tips for beginners',
      'icon': Icons.security,
      'color': Colors.green,
      'content': '''
**Password Safety**
• Use 12+ characters
• Mix letters, numbers, symbols
• Don't reuse passwords
• Use password manager

**Two-Factor Authentication**
Enable 2FA on all accounts:
• Gmail
• Facebook
• Instagram
• WhatsApp
• Banking apps

**Safe Browsing**
• Check for HTTPS
• Avoid public Wi-Fi
• Don't click suspicious links
• Keep browser updated''',
      'readTime': '4 min',
    },

    // Guide Section
    {
      'id': '4',
      'category': 'guide',
      'title': 'How to File Complaint',
      'description': 'Step by step guide',
      'icon': Icons.description,
      'color': Colors.purple,
      'content': '''
**Step 1: Call 1930**
Immediately call National Cyber Helpline

**Step 2: Collect Evidence**
• Screenshots
• Transaction IDs
• Phone numbers
• Email IDs

**Step 3: Visit Website**
Go to cybercrime.gov.in

**Step 4: Fill Details**
• Your information
• Incident details
• Suspect information

**Step 5: Submit**
Get complaint number for tracking

**Step 6: Follow Up**
Check status using complaint number''',
      'readTime': '6 min',
    },
    {
      'id': '5',
      'category': 'guide',
      'title': 'Secure Your Account',
      'description': 'Enable 2FA, strong passwords',
      'icon': Icons.lock,
      'color': Colors.teal,
      'content': '''
**Password Best Practices**
• Minimum 12 characters
• Include uppercase & lowercase
• Add numbers and symbols
• Avoid personal info
• Change every 3 months

**Two-Factor Authentication**
What is 2FA?
Extra layer of security beyond password

How to enable:
1. Go to account settings
2. Find security options
3. Enable 2FA
4. Choose method (SMS/App)
5. Scan QR code

**Authentication Apps**
• Google Authenticator
• Microsoft Authenticator
• Authy''',
      'readTime': '5 min',
    },
    {
      'id': '6',
      'category': 'guide',
      'title': 'What to do if Hacked',
      'description': 'Immediate recovery steps',
      'icon': Icons.refresh,
      'color': Colors.red,
      'content': '''
**Immediate Actions**

1. **Change Passwords**
   Use a different device if possible

2. **Enable 2FA**
   Add extra security layer

3. **Check Account Activity**
   Look for unauthorized access

4. **Remove Unknown Devices**
   Log out from all sessions

5. **Alert Friends**
   Tell them not to respond to messages

6. **Report to Platform**
   Use "hacked account" option

7. **Contact Cyber Cell**
   Call 1930 if financial loss

**Prevention for Future**
• Use unique passwords
• Enable login alerts
• Regular security checks''',
      'readTime': '7 min',
    },

    // Video Section
    {
      'id': '7',
      'category': 'video',
      'title': 'UPI Fraud Prevention',
      'description': 'Watch: 2 min guide',
      'icon': Icons.play_circle,
      'color': Colors.red,
      'duration': '2:30',
      'thumbnail': '🎥',
      'url': 'https://youtube.com/watch?v=example1',
    },
    {
      'id': '8',
      'category': 'video',
      'title': 'Phishing Awareness',
      'description': 'Watch: 3 min guide',
      'icon': Icons.play_circle,
      'color': Colors.red,
      'duration': '3:15',
      'thumbnail': '🎥',
      'url': 'https://youtube.com/watch?v=example2',
    },
    {
      'id': '9',
      'category': 'video',
      'title': 'Secure Your Accounts',
      'description': 'Complete guide',
      'icon': Icons.play_circle,
      'color': Colors.red,
      'duration': '5:20',
      'thumbnail': '🎥',
      'url': 'https://youtube.com/watch?v=example3',
    },
    {
      'id': '10',
      'category': 'video',
      'title': 'Cyber Crime Awareness',
      'description': 'Educational video',
      'icon': Icons.play_circle,
      'color': Colors.red,
      'duration': '4:45',
      'thumbnail': '🎥',
      'url': 'https://youtube.com/watch?v=example4',
    },

    // FAQ Section
    {
      'id': '11',
      'category': 'faq',
      'title': 'What to do if OTP shared?',
      'description': 'Immediate steps',
      'icon': Icons.help,
      'color': Colors.cyan,
      'answer': '''
If you've shared OTP:

1. **Call Bank Immediately**
   Use helpline number

2. **Block Card/Account**
   Request immediate block

3. **Call 1930**
   Report to cyber cell

4. **Check Transactions**
   Note any unauthorized ones

5. **File Complaint**
   At cybercrime.gov.in

**Remember:** Banks never ask for OTP!
''',
    },
    {
      'id': '12',
      'category': 'faq',
      'title': 'How to report fake call?',
      'description': 'Step by step',
      'icon': Icons.help,
      'color': Colors.cyan,
      'answer': '''
**Reporting Fake Calls:**

1. **Save the Number**
   Take screenshot

2. **Note Details**
   • What they said
   • When they called
   • What they asked

3. **Report Online**
   cybercrime.gov.in

4. **Forward to 1930**
   Send number via SMS

5. **Block Number**
   Add to block list

6. **Warn Others**
   Share on social media

**Pro Tip:** Install Truecaller to identify spam numbers
''',
    },
    {
      'id': '13',
      'category': 'faq',
      'title': 'Is cyber insurance helpful?',
      'description': 'Understanding cyber insurance',
      'icon': Icons.help,
      'color': Colors.cyan,
      'answer': '''
**Cyber Insurance Benefits:**

✅ Covers financial loss from online fraud
✅ Legal support for cyber crimes
✅ Identity theft protection
✅ Data recovery assistance

**What to Check:**
• Coverage limits
• Exclusions
• Claim process
• Premium costs

**Verdict:** Useful for frequent online transactions
''',
    },
    {
      'id': '14',
      'category': 'faq',
      'title': 'How to create strong password?',
      'description': 'Password tips',
      'icon': Icons.help,
      'color': Colors.cyan,
      'answer': '''
**Strong Password Formula:**

Use this pattern:
`Word + Number + Symbol + Word`

Example:
`Blue\$45Tiger`

**DON'T Use:**
❌ Birthdays
❌ 123456
❌ Password123
❌ Your name

**DO Use:**
✅ 12+ characters
✅ Mix uppercase/lowercase
✅ Add numbers
✅ Add symbols (!@#\$%)

**Remember:** Use password manager like LastPass or Bitwarden
''',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _filteredResources = _allResources;
    _searchController.addListener(_filterResources);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedCategory = 'all';
          break;
        case 1:
          _selectedCategory = 'learn';
          break;
        case 2:
          _selectedCategory = 'guide';
          break;
        case 3:
          _selectedCategory = 'video';
          break;
        case 4:
          _selectedCategory = 'faq';
          break;
      }
    });
    _filterResources();
  }

  void _filterResources() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty && _selectedCategory == 'all') {
        _filteredResources = _allResources;
      } else {
        _filteredResources = _allResources.where((r) {
          final matchesCategory = _selectedCategory == 'all' || r['category'] == _selectedCategory;
          final matchesSearch = query.isEmpty ||
              r['title'].toLowerCase().contains(query) ||
              r['description'].toLowerCase().contains(query);
          return matchesCategory && matchesSearch;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final isHindi = chatProvider.currentLanguage == 'hi';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isHindi ? 'सुरक्षा संसाधन' : 'Safety Resources',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: const Icon(Icons.apps),
              text: isHindi ? 'सभी' : 'All',
            ),
            Tab(
              icon: const Icon(Icons.school),
              text: isHindi ? 'सीखें' : 'Learn',
            ),
            Tab(
              icon: const Icon(Icons.menu_book),
              text: isHindi ? 'गाइड' : 'Guide',
            ),
            Tab(
              icon: const Icon(Icons.play_circle),
              text: isHindi ? 'वीडियो' : 'Videos',
            ),
            Tab(
              icon: const Icon(Icons.help),
              text: isHindi ? 'FAQ' : 'FAQ',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: isHindi ? 'खोजें...' : 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ),
          
          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCategoryChip('all', 'All', 'सभी', Icons.apps),
                const SizedBox(width: 8),
                _buildCategoryChip('learn', 'Learn', 'सीखें', Icons.school),
                const SizedBox(width: 8),
                _buildCategoryChip('guide', 'Guide', 'गाइड', Icons.menu_book),
                const SizedBox(width: 8),
                _buildCategoryChip('video', 'Videos', 'वीडियो', Icons.play_circle),
                const SizedBox(width: 8),
                _buildCategoryChip('faq', 'FAQ', 'FAQ', Icons.help),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Resources list
          Expanded(
            child: _filteredResources.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          isHindi ? 'कोई परिणाम नहीं मिला' : 'No results found',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredResources.length,
                    itemBuilder: (context, index) {
                      final resource = _filteredResources[index];
                      return _buildResourceCard(context, resource, isHindi);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String enLabel, String hiLabel, IconData icon) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final isSelected = _selectedCategory == value;
    
    return FilterChip(
      selected: isSelected,
      label: Text(
        chatProvider.currentLanguage == 'hi' ? hiLabel : enLabel,
      ),
      avatar: Icon(icon, size: 16),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = value;
          if (value == 'all') {
            _tabController.animateTo(0);
          } else if (value == 'learn') {
            _tabController.animateTo(1);
          } else if (value == 'guide') {
            _tabController.animateTo(2);
          } else if (value == 'video') {
            _tabController.animateTo(3);
          } else if (value == 'faq') {
            _tabController.animateTo(4);
          }
          _filterResources();
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    );
  }

  Widget _buildResourceCard(BuildContext context, Map<String, dynamic> resource, bool isHindi) {
    final category = resource['category'];
    
    if (category == 'video') {
      return _buildVideoCard(context, resource, isHindi);
    } else if (category == 'faq') {
      return _buildFaqCard(context, resource, isHindi);
    } else {
      return _buildArticleCard(context, resource, isHindi);
    }
  }

  Widget _buildArticleCard(BuildContext context, Map<String, dynamic> resource, bool isHindi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showResourceDetail(context, resource, isHindi),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (resource['color'] as Color).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  resource['icon'] as IconData,
                  color: resource['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          resource['readTime'] ?? '3 min read',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, Map<String, dynamic> resource, bool isHindi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _playVideo(context, resource, isHindi),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: const DecorationImage(
                  image: NetworkImage('https://picsum.photos/400/200'),
                  fit: BoxFit.cover,
                  opacity: 0.7,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(128),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(179),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        resource['duration'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Video info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (resource['color'] as Color).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      resource['icon'] as IconData,
                      color: resource['color'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          resource['description'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCard(BuildContext context, Map<String, dynamic> resource, bool isHindi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (resource['color'] as Color).withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              resource['icon'] as IconData,
              color: resource['color'],
              size: 20,
            ),
          ),
          title: Text(
            resource['title'],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            resource['description'],
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                resource['answer'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResourceDetail(BuildContext context, Map<String, dynamic> resource, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (resource['color'] as Color).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      resource['icon'] as IconData,
                      color: resource['color'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      resource['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    resource['content'] ?? resource['answer'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(isHindi ? 'बंद करें' : 'Close'),
                  ),
                  const SizedBox(width: 8),
                  if (resource.containsKey('url'))
                    ElevatedButton(
                      onPressed: () async {
                        final url = Uri.parse(resource['url']);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      child: Text(isHindi ? 'और पढ़ें' : 'Read More'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playVideo(BuildContext context, Map<String, dynamic> resource, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 200,
                color: Colors.grey.shade900,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resource['duration'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                resource['title'],
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                resource['description'],
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(isHindi ? 'बंद करें' : 'Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (resource.containsKey('url')) {
                        final url = Uri.parse(resource['url']);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(isHindi ? 'देखें' : 'Watch'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}