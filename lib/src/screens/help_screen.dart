import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: Color(0xFF6366F1),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Quick Tips Section
          _buildSection(
            title: 'Quick Tips',
            icon: Icons.lightbulb_outline,
            color: Colors.amber,
            children: [
              _buildTip('Double-tap any text to edit it'),
              _buildTip('Use two fingers to zoom and pan the canvas'),
              _buildTip('Tap and hold elements to move them around'),
              _buildTip('Pro members can export in JPG format without watermarks'),
            ],
          ),
          
          SizedBox(height: 24),
          
          // FAQ Section
          _buildSection(
            title: 'Frequently Asked Questions',
            icon: Icons.help_outline,
            color: Color(0xFF6366F1),
            children: [
              _buildFAQ(
                question: 'How do I change colors?',
                answer: 'Select any shape or text element, then use the color picker in the toolbar to change its color.',
              ),
              _buildFAQ(
                question: 'Can I upload my own images?',
                answer: 'Yes! Tap the image tool in the toolbar and select "Upload Image" to add your own photos.',
              ),
              _buildFAQ(
                question: 'What\'s the difference between Free and Pro?',
                answer: 'Pro members get JPG export, no watermarks, priority support, and access to premium templates.',
              ),
              _buildFAQ(
                question: 'How do I save my designs?',
                answer: 'Your designs are automatically saved to your account. Access them from the "My Designs" section.',
              ),
              _buildFAQ(
                question: 'Can I cancel my Pro subscription?',
                answer: 'Yes, you can cancel anytime from the Subscription page. You\'ll keep Pro access until the end of your billing period.',
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Contact Support
          _buildSection(
            title: 'Need More Help?',
            icon: Icons.support_agent,
            color: Color(0xFF10B981),
            children: [
              ListTile(
                leading: Icon(Icons.email, color: Color(0xFF10B981)),
                title: Text('Email Support'),
                subtitle: Text('support@artiq.com'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _launchEmail('support@artiq.com'),
              ),
              ListTile(
                leading: Icon(Icons.language, color: Color(0xFF10B981)),
                title: Text('Visit Website'),
                subtitle: Text('www.artiq.com'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _launchURL('https://www.artiq.com'),
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Keyboard Shortcuts
          _buildSection(
            title: 'Keyboard Shortcuts',
            icon: Icons.keyboard,
            color: Color(0xFF8B5CF6),
            children: [
              _buildShortcut('Ctrl/Cmd + Z', 'Undo'),
              _buildShortcut('Ctrl/Cmd + Y', 'Redo'),
              _buildShortcut('Ctrl/Cmd + C', 'Copy'),
              _buildShortcut('Ctrl/Cmd + V', 'Paste'),
              _buildShortcut('Delete/Backspace', 'Delete selected element'),
              _buildShortcut('Ctrl/Cmd + S', 'Save design'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcut(String keys, String action) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              keys,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              action,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=ARTIQ Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
