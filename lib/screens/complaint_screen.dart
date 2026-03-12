import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/message_model.dart';

class ComplaintScreen extends StatefulWidget {
  final String? initialType;  // Chat se auto-filled type
  final Map<String, dynamic>? prefilledData; // Chat se auto-filled data
  
  const ComplaintScreen({
    super.key,
    this.initialType,
    this.prefilledData,
  });

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Controllers
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _suspectInfoController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _suspectPhoneController = TextEditingController();
  
  // Selected options
  String? _complaintType;
  String? _priority;
  List<File> _evidenceFiles = [];
  DateTime? _incidentDate;
  TimeOfDay? _incidentTime;
  bool _isSubmitting = false;
  int _currentStep = 0;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<Map<String, dynamic>> _complaintTypes = [
    {'name': 'UPI/Payment Fraud', 'icon': Icons.payment, 'color': Colors.blue, 'fields': ['amount', 'transaction_id', 'bank']},
    {'name': 'Social Media Hacking', 'icon': Icons.facebook, 'color': Colors.indigo, 'fields': ['platform']},
    {'name': 'Phishing Attack', 'icon': Icons.link_off, 'color': Colors.orange, 'fields': ['url']},
    {'name': 'Blackmail/Extortion', 'icon': Icons.warning, 'color': Colors.red, 'fields': ['suspect_info']},
    {'name': 'Bank Fraud', 'icon': Icons.account_balance, 'color': Colors.green, 'fields': ['amount', 'transaction_id', 'bank']},
    {'name': 'OTP Fraud', 'icon': Icons.message, 'color': Colors.purple, 'fields': ['amount', 'transaction_id', 'bank']},
    {'name': 'Fake Customer Care', 'icon': Icons.phone, 'color': Colors.orange, 'fields': ['suspect_phone']},
    {'name': 'Identity Theft', 'icon': Icons.person_outline, 'color': Colors.teal, 'fields': ['suspect_info']},
    {'name': 'Cyber Stalking', 'icon': Icons.person_search, 'color': Colors.pink, 'fields': ['suspect_info']},
    {'name': 'Other', 'icon': Icons.help, 'color': Colors.grey, 'fields': []},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'name': 'High - Money already lost', 'color': Colors.red, 'value': 'high'},
    {'name': 'Medium - Suspicious activity', 'color': Colors.orange, 'value': 'medium'},
    {'name': 'Low - Just reporting', 'color': Colors.green, 'value': 'low'},
  ];

  @override
  void initState() {
    super.initState();
    _incidentDate = DateTime.now();
    _incidentTime = TimeOfDay.now();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
    
    // Pre-fill data from chat if available
    _prefillData();
  }

  void _prefillData() {
    if (widget.initialType != null) {
      // Find matching complaint type
      for (var type in _complaintTypes) {
        if (type['name'].toString().toLowerCase().contains(widget.initialType!.toLowerCase())) {
          _complaintType = type['name'];
          break;
        }
      }
    }
    
    if (widget.prefilledData != null) {
      if (widget.prefilledData!.containsKey('amount')) {
        _amountController.text = widget.prefilledData!['amount'].toString();
      }
      if (widget.prefilledData!.containsKey('transactionId')) {
        _transactionIdController.text = widget.prefilledData!['transactionId'].toString();
      }
      if (widget.prefilledData!.containsKey('description')) {
        _descriptionController.text = widget.prefilledData!['description'].toString();
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _transactionIdController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _suspectInfoController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _upiIdController.dispose();
    _suspectPhoneController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickEvidence() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'pdf', 'doc', 'docx'],
      );
      
      if (result != null) {
        setState(() {
          _evidenceFiles.addAll(result.paths.map((path) => File(path!)));
        });
        
        _showSnackBar(
          '${result.files.length} file(s) added',
          type: 'success',
        );
      }
    } catch (e) {
      _showErrorDialog('Error picking files');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _evidenceFiles.add(File(photo.path));
        });
        _showSnackBar('Photo added', type: 'success');
      }
    } catch (e) {
      _showErrorDialog('Error taking photo');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _incidentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _incidentDate) {
      setState(() {
        _incidentDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _incidentTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _incidentTime) {
      setState(() {
        _incidentTime = picked;
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _evidenceFiles.removeAt(index);
    });
    _showSnackBar('File removed', type: 'info');
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate API call with progress
      for (int i = 0; i <= 100; i += 20) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          // Update progress if needed
        }
      }

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // Update user stats
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.incrementComplaintCount();

      // Generate complaint ID
      final complaintId = 'CMP${DateTime.now().millisecondsSinceEpoch}';

      // Show success dialog
      _showSuccessDialog(complaintId);
    }
  }

  void _showSuccessDialog(String complaintId) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final isHindi = chatProvider.currentLanguage == 'hi';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withAlpha(77),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              isHindi ? 'शिकायत सबमिट हो गई!' : 'Complaint Submitted!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    isHindi ? 'आपका complaint number:' : 'Your complaint number:',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    complaintId,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isHindi
                  ? 'हम जल्द ही संपर्क करेंगे'
                  : 'We will contact you soon',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, complaintId);
            },
            child: Text(
              isHindi ? 'ठीक है' : 'OK',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {String type = 'info'}) {
    Color color;
    switch (type) {
      case 'success':
        color = Colors.green;
        break;
      case 'error':
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      _complaintType = null;
      _priority = null;
      _evidenceFiles.clear();
      _incidentDate = DateTime.now();
      _incidentTime = TimeOfDay.now();
      _descriptionController.clear();
      _amountController.clear();
      _transactionIdController.clear();
      _bankNameController.clear();
      _accountNumberController.clear();
      _suspectInfoController.clear();
      _phoneController.clear();
      _emailController.clear();
      _upiIdController.clear();
      _suspectPhoneController.clear();
    });
    _showSnackBar('Form cleared', type: 'info');
  }

  void _callHelpline() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '1930');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Map<String, dynamic>? _getSelectedType() {
    return _complaintType != null
        ? _complaintTypes.firstWhere(
            (type) => type['name'] == _complaintType,
            orElse: () => _complaintTypes.last,
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isHindi = chatProvider.currentLanguage == 'hi';
    final selectedType = _getSelectedType();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isHindi ? 'साइबर शिकायत दर्ज करें' : 'File Cyber Complaint',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearForm,
            tooltip: isHindi ? 'फॉर्म साफ करें' : 'Clear form',
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _callHelpline,
            tooltip: isHindi ? 'हेल्पलाइन कॉल करें' : 'Call helpline',
          ),
        ],
      ),
      body: _isSubmitting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: 0.5 + (value * 0.5),
                        child: const CircularProgressIndicator(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isHindi ? 'शिकायत सबमिट हो रही है...' : 'Submitting complaint...',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHindi ? 'कृपया प्रतीक्षा करें' : 'Please wait',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Progress indicator
                      _buildProgressIndicator(),
                      
                      const SizedBox(height: 16),
                      
                      // User Info Card
                      _buildUserInfoCard(context, userProvider, isHindi),
                      
                      const SizedBox(height: 16),
                      
                      // Complaint Type Card with Icons
                      _buildComplaintTypeCard(context, isHindi),
                      
                      const SizedBox(height: 16),
                      
                      // Priority Card
                      _buildPriorityCard(context, isHindi),
                      
                      const SizedBox(height: 16),
                      
                      // Date and Time Card
                      _buildDateTimeCard(context, isHindi),
                      
                      const SizedBox(height: 16),
                      
                      // Description Card
                      _buildDescriptionCard(context, isHindi),
                      
                      const SizedBox(height: 16),
                      
                      // Dynamic Fields based on complaint type
                      if (selectedType != null) ...[
                        ..._buildDynamicFields(selectedType, isHindi),
                        const SizedBox(height: 16),
                      ],
                      
                      // Suspect Info Card
                      _buildSuspectInfoCard(context, isHindi),
                      
                      const SizedBox(height: 16),
                      
                      // Evidence Card
                      _buildEvidenceCard(context, isHindi),
                      
                      const SizedBox(height: 24),
                      
                      // Submit Button
                      _buildSubmitButton(context, isHindi),
                      
                      const SizedBox(height: 16),
                      
                      // Important Note
                      _buildImportantNote(context, isHindi),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStep(1, 'Info', _currentStep >= 0),
          Expanded(child: Divider(color: _currentStep >= 1 ? Colors.blue : Colors.grey)),
          _buildStep(2, 'Details', _currentStep >= 1),
          Expanded(child: Divider(color: _currentStep >= 2 ? Colors.blue : Colors.grey)),
          _buildStep(3, 'Evidence', _currentStep >= 2),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label, bool active) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.blue : Colors.grey.shade300,
      ),
      child: Center(
        child: Text(
          step.toString(),
          style: TextStyle(
            color: active ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, UserProvider userProvider, bool isHindi) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isHindi ? 'आपकी जानकारी' : 'Your Information',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: isHindi ? 'फोन नंबर' : 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.phone,
                initialValue: userProvider.currentUser?.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isHindi ? 'फोन नंबर दर्ज करें' : 'Enter phone number';
                  }
                  if (value.length != 10) {
                    return isHindi ? '10 अंकों का नंबर दर्ज करें' : 'Enter 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
                initialValue: userProvider.currentUser?.email,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.contains('@') || !value.contains('.')) {
                      return isHindi ? 'मान्य ईमेल दर्ज करें' : 'Enter valid email';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintTypeCard(BuildContext context, bool isHindi) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.category, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  isHindi ? 'शिकायत का प्रकार' : 'Complaint Type',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _complaintTypes.length,
              itemBuilder: (context, index) {
                final type = _complaintTypes[index];
                final isSelected = _complaintType == type['name'];
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _complaintType = type['name'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (type['color'] as Color).withAlpha(26)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? type['color'] as Color
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type['icon'] as IconData,
                          color: isSelected 
                              ? type['color'] as Color
                              : Colors.grey.shade600,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            type['name'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected 
                                  ? type['color'] as Color
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityCard(BuildContext context, bool isHindi) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.priority_high, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  isHindi ? 'प्राथमिकता' : 'Priority',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._priorities.map((priority) {
              final isSelected = _priority == priority['name'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _priority = priority['name'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (priority['color'] as Color).withAlpha(26)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? priority['color'] as Color
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: priority['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            priority['name'],
                            style: GoogleFonts.poppins(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeCard(BuildContext context, bool isHindi) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  isHindi ? 'घटना की तारीख और समय' : 'Incident Date & Time',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: Text(
                      isHindi ? 'तारीख' : 'Date',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      _incidentDate != null
                          ? '${_incidentDate!.day}/${_incidentDate!.month}/${_incidentDate!.year}'
                          : isHindi ? 'चुनें' : 'Select',
                    ),
                    onTap: _selectDate,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      isHindi ? 'समय' : 'Time',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      _incidentTime != null
                          ? _incidentTime!.format(context)
                          : isHindi ? 'चुनें' : 'Select',
                    ),
                    onTap: _selectTime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, bool isHindi) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.description, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  isHindi ? 'घटना का विवरण' : 'Incident Description',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isHindi
                  ? 'पूरी जानकारी दें - क्या हुआ, कब हुआ, कैसे हुआ?'
                  : 'Provide complete details - what happened, when, how?',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: isHindi
                    ? 'जैसे: मैंने गलत नंबर पर ₹5000 भेज दिए...'
                    : 'E.g.: I sent ₹5000 to wrong number...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return isHindi ? 'विवरण दर्ज करें' : 'Enter description';
                }
                if (value.length < 20) {
                  return isHindi 
                      ? 'कम से कम 20 अक्षर दर्ज करें' 
                      : 'Enter at least 20 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicFields(Map<String, dynamic> selectedType, bool isHindi) {
    final List<Widget> fields = [];
    final fieldsList = selectedType['fields'] as List;
    
    if (fieldsList.contains('amount')) {
      fields.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'राशि' : 'Amount',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (fieldsList.contains('transaction_id')) {
      fields.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'ट्रांजेक्शन ID' : 'Transaction ID',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _transactionIdController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.receipt),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (fieldsList.contains('bank')) {
      fields.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'बैंक विवरण' : 'Bank Details',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bankNameController,
                  decoration: InputDecoration(
                    labelText: isHindi ? 'बैंक का नाम' : 'Bank Name',
                    prefixIcon: const Icon(Icons.account_balance),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _accountNumberController,
                  decoration: InputDecoration(
                    labelText: isHindi ? 'खाता नंबर' : 'Account Number',
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (fieldsList.contains('suspect_phone')) {
      fields.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'संदिग्ध का फोन नंबर' : 'Suspect Phone Number',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _suspectPhoneController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return fields;
  }

  Widget _buildSuspectInfoCard(BuildContext context, bool isHindi) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_off, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  isHindi ? 'आरोपी की जानकारी' : 'Suspect Information',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isHindi
                  ? 'अगर पता हो तो भरें (फोन नंबर, UPI ID, नाम)'
                  : 'Fill if known (phone number, UPI ID, name)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _upiIdController,
              decoration: InputDecoration(
                labelText: 'UPI ID',
                prefixIcon: const Icon(Icons.payment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _suspectPhoneController,
              decoration: InputDecoration(
                labelText: isHindi ? 'फोन नंबर' : 'Phone Number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _suspectInfoController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isHindi
                    ? 'अन्य जानकारी (नाम, पता, आदि)'
                    : 'Other information (name, address, etc.)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceCard(BuildContext context, bool isHindi) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.attach_file, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  isHindi ? 'सबूत' : 'Evidence',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isHindi
                  ? 'स्क्रीनशॉट, फोटो, दस्तावेज़ अटैच करें'
                  : 'Attach screenshots, photos, documents',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            
            // Evidence buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickEvidence,
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      isHindi ? 'फाइल चुनें' : 'Choose File',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      isHindi ? 'फोटो लें' : 'Take Photo',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Evidence list
            if (_evidenceFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _evidenceFiles.length,
                  itemBuilder: (context, index) {
                    return _buildEvidenceItem(index);
                  },
                ),
              ),
            ],
            
            // Max files info
            const SizedBox(height: 8),
            Text(
              isHindi 
                  ? 'अधिकतम 10 फाइलें, प्रत्येक 5MB तक'
                  : 'Max 10 files, each up to 5MB',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceItem(int index) {
    final file = _evidenceFiles[index];
    final isImage = _isImageFile(file);
    
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isImage
                ? Image.file(
                    file,
                    width: 100,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 100,
                    height: 120,
                    color: Colors.grey.shade100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          size: 40,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getFileExtension(file.path),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeFile(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
          if (isImage)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '📷',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isHindi) {
    return Container(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _submitComplaint,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send),
            const SizedBox(width: 12),
            Text(
              isHindi ? 'शिकायत दर्ज करें' : 'File Complaint',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportantNote(BuildContext context, bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info, color: Colors.amber.shade800, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? '⚠️ महत्वपूर्ण' : '⚠️ Important',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isHindi
                      ? 'गंभीर मामलों में तुरंत 1930 पर कॉल करें'
                      : 'In serious cases, call 1930 immediately',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.phone, color: Colors.amber.shade800),
            onPressed: _callHelpline,
          ),
        ],
      ),
    );
  }

  bool _isImageFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  String _getFileExtension(String path) {
    final parts = path.split('.');
    return parts.isNotEmpty ? parts.last.toUpperCase() : 'FILE';
  }
}