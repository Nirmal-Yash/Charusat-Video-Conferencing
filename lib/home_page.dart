import 'package:flutter/material.dart';
import 'package:ptunes/ProfilePage.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:ptunes/meeting_screen.dart'; // r Clipboard
class HomePage extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  const HomePage({Key? key, this.userInfo}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String generateMeetingCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    String code = '';
    for (int i = 0; i < 10; i++) {
      code += chars[rand.nextInt(chars.length)];
      if (i == 3 || i == 7) code += '-'; // format: xxxx-xxx-xx
    }
    return code;
  }

  String studentName = 'Pratham';
  String collegeId = 'D24DCS150';

  final List<Map<String, dynamic>> recentMeetings = [
    {
      'title': 'Computer Networks Lab',
      'time': '10:00 AM - 11:30 AM',
      'date': 'Today',
      'participants': 45,
      'status': 'ongoing',
      'meetingId': 'CN2024001',
    },
    {
      'title': 'Software Engineering',
      'time': '2:00 PM - 3:30 PM',
      'date': 'Yesterday',
      'participants': 38,
      'status': 'completed',
      'meetingId': 'SE2024002',
    },
    {
      'title': 'Database Management',
      'time': '11:00 AM - 12:30 PM',
      'date': 'Dec 15',
      'participants': 42,
      'status': 'scheduled',
      'meetingId': 'DB2024003',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.userInfo != null) {
      studentName = widget.userInfo!['studentName'] ?? 'Student';
      collegeId = widget.userInfo!['collegeId'] ?? 'XXXX';
    }

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickActions(),
                    const SizedBox(height: 30),
                    _buildRecentMeetings(),
                    const SizedBox(height: 30),
                    _buildStatistics(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1565C0),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1565C0),
                const Color(0xFF1976D2),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          studentName.isNotEmpty
                              ? studentName[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back,',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16)),
                            Text(studentName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            Text(collegeId,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showProfileMenu(context),
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.video_call,
                title: 'Start Meeting',
                subtitle: 'Begin new video call',
                color: const Color(0xFF4CAF50),
                onTap: () => _startNewMeeting(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.login,
                title: 'Join Meeting',
                subtitle: 'Enter meeting ID',
                color: const Color(0xFF2196F3),
                onTap: () => _joinMeeting(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.schedule,
                title: 'Schedule',
                subtitle: 'Plan future meeting',
                color: const Color(0xFFFF9800),
                onTap: () => _scheduleMeeting(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.history,
                title: 'History',
                subtitle: 'View past meetings',
                color: const Color(0xFF9C27B0),
                onTap: () => _viewHistory(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(title,
                style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMeetings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Meetings',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            TextButton(
                onPressed: () => _viewAllMeetings(),
                child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentMeetings.length,
          itemBuilder: (context, index) =>
              _buildMeetingCard(recentMeetings[index]),
        ),
      ],
    );
  }

  Widget _buildMeetingCard(Map<String, dynamic> meeting) {
    Color statusColor;
    IconData statusIcon;

    switch (meeting['status']) {
      case 'ongoing':
        statusColor = Colors.green;
        statusIcon = Icons.fiber_manual_record;
        break;
      case 'scheduled':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.video_call,
                color: Color(0xFF1565C0), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${meeting['time']} • ${meeting['date']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 12),
                        const SizedBox(width: 4),
                        Text(meeting['status'].toUpperCase(),
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people, color: Colors.grey[600], size: 12),
                        const SizedBox(width: 4),
                        Text('${meeting['participants']} participants',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _joinMeetingById(meeting['meetingId']),
            icon: Icon(
                meeting['status'] == 'ongoing' ? Icons.play_arrow : Icons.info,
                color: const Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }


  Widget _buildStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('This Week',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                  title: 'Meetings Attended',
                  value: '8',
                  icon: Icons.video_call,
                  color: const Color(0xFF4CAF50)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                  title: 'Hours Spent',
                  value: '12.5',
                  icon: Icons.access_time,
                  color: const Color(0xFF2196F3)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title,
    required String value,
    required IconData icon,
    required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ]),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _startNewMeeting(),
      backgroundColor: const Color(0xFF4CAF50),
      icon: const Icon(Icons.video_call, color: Colors.white),
      label: const Text('Start Meeting',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  // Actions
  void _startNewMeeting() {
    String meetingCode = generateMeetingCode();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingPreviewPage(
          meetingCode: meetingCode,
          isHost: true,
        ),
      ),
    );
  }


  void _joinMeeting() {
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Join Meeting"),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            hintText: "Enter Meeting Code",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              String code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeetingPreviewPage(
                      meetingCode: code,
                      isHost: false,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid Meeting Code")),
                );
              }
            },
            child: const Text("Join"),
          ),
        ],
      ),
    );
  }


  void _scheduleMeeting() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule Meeting feature coming soon!')));
  }

  void _viewHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meeting History feature coming soon!')));
  }

  void _viewAllMeetings() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All Meetings view coming soon!')));
  }

  void _joinMeetingById(String meetingId) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Joining meeting: $meetingId')));
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(userInfo: {
                              'studentName': studentName,
                              'collegeId': collegeId,
                              'email': widget.userInfo?['email'] ??
                                  'student@email.com',
                              'phone': widget.userInfo?['phone'] ??
                                  '+91 00000 00000',
                              'course': widget.userInfo?['course'] ??
                                  'BTech CSE',
                              'year': widget.userInfo?['year'] ?? '2nd Year',
                            }),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                      'Logout', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully')),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }
}
