import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_navigation.dart';

class AdminPortalScreen extends StatelessWidget {
  const AdminPortalScreen({super.key});

  static const Color navy = Color(0xFF292F4B);
  static const Color background = Color(0xFFF5F1E9);
  static const Color purple = Color(0xFF7774A8);

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _dashboardCard({
    required double width,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        color: Colors.white,
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 34, color: purple),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
                const SizedBox(height: 8),
                Text(description),
                const SizedBox(height: 16),
                const Text('Open section →', style: TextStyle(color: purple, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('MT Alchemy | Admin Portal'),
        actions: [
          TextButton.icon(
            onPressed: () => confirmAndSignOut(context),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Sign out', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Administrator Dashboard', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: navy)),
                const SizedBox(height: 8),
                const Text('Manage users, learning content, physical orders, corporate enquiries and platform activity.', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 28),
                LayoutBuilder(builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 750 ? 3 : 1;
                  final cardWidth = (constraints.maxWidth - (columns - 1) * 16) / columns;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _dashboardCard(width: cardWidth, icon: Icons.people_outline, title: 'User Management', description: 'Search accounts and review user profile details.', onTap: () => _open(context, const AdminUserManagementScreen())),
                      _dashboardCard(width: cardWidth, icon: Icons.local_shipping_outlined, title: 'Manage Physical Orders', description: 'Review customer orders and update Processing, Shipped or Delivered status.', onTap: () => _open(context, const AdminPhysicalOrdersScreen())),
                      _dashboardCard(width: cardWidth, icon: Icons.business_center_outlined, title: 'Corporate Enquiries', description: 'Review submitted enquiries, update status and prepare proposed programmes.', onTap: () => _open(context, const AdminCorporateEnquiriesScreen())),
                      _dashboardCard(width: cardWidth, icon: Icons.menu_book_outlined, title: 'Learning Content', description: 'Manage courses and learning pathways.', onTap: () => _showPlaceholder(context, 'Learning content management is not connected yet.')),
                      _dashboardCard(width: cardWidth, icon: Icons.analytics_outlined, title: 'Platform Overview', description: 'View platform activity and statistics.', onTap: () => _showPlaceholder(context, 'Platform analytics are not connected yet.')),
                    ],
                  );
                }),
                const SizedBox(height: 28),
                Card(
                  color: Colors.white,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(children: [
                      Icon(Icons.admin_panel_settings_outlined, size: 36, color: purple),
                      SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Administrator access', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
                        SizedBox(height: 6),
                        Text('User profiles, physical orders and corporate enquiries are connected to Firestore. Learning Content and Platform Overview remain placeholders.'),
                      ])),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

// -----------------------------------------------------------------------------
// USER MANAGEMENT
// -----------------------------------------------------------------------------
class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  static const navy = AdminPortalScreen.navy;
  static const background = AdminPortalScreen.background;
  static const purple = AdminPortalScreen.purple;
  final TextEditingController _searchController = TextEditingController();
  String _roleFilter = 'All';
  final List<String> _roles = const ['All', 'Individual', 'Learner', 'Employer', 'Admin', 'Super Admin'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _dateLabel(dynamic value) {
    if (value is Timestamp) {
      final d = value.toDate().toLocal();
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }
    return 'Not available';
  }

  Future<void> _editDisplayName(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _EditDisplayNameDialog(
        initialName: (doc.data()?['displayName'] ?? '').toString(),
      ),
    );
    if (newName == null || newName.isEmpty) return;
    try {
      await doc.reference.update({'displayName': newName});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Display name updated.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update display name: $error')));
    }
  }

  void _showUserDetails(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text((data['displayName'] ?? 'User').toString()),
        content: SizedBox(
          width: 440,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            _detailLine('Email', data['email']?.toString() ?? 'Not provided'),
            _detailLine('Role', data['role']?.toString() ?? 'Not assigned'),
            _detailLine('User ID', doc.id),
            _detailLine('Created', _dateLabel(data['createdAt'])),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Wait for the details dialog to finish disposing before opening
              // the edit dialog. This avoids overlapping dialog transitions.
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) _editDisplayName(doc);
              });
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit name'),
          ),
        ],
      ),
    );
  }

  Widget _detailLine(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 90, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600))),
      Expanded(child: SelectableText(value)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(backgroundColor: background, foregroundColor: navy, elevation: 0, title: const Text('USER MANAGEMENT')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _errorState('Unable to load users. Check that your Firestore rules allow administrators to read user profiles.\n\n${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: purple));
          final docs = [...?snapshot.data?.docs];
          docs.sort((a, b) {
            final av = a.data()['createdAt'];
            final bv = b.data()['createdAt'];
            final at = av is Timestamp ? av.millisecondsSinceEpoch : 0;
            final bt = bv is Timestamp ? bv.millisecondsSinceEpoch : 0;
            return bt.compareTo(at);
          });
          final query = _searchController.text.trim().toLowerCase();
          final filtered = docs.where((doc) {
            final data = doc.data();
            final role = (data['role'] ?? '').toString();
            final name = (data['displayName'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            final roleMatches = _roleFilter == 'All' || role.toLowerCase() == _roleFilter.toLowerCase();
            return roleMatches && (query.isEmpty || name.contains(query) || email.contains(query) || doc.id.toLowerCase().contains(query));
          }).toList();
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(hintText: 'Search by name, email or user ID', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchController.clear())), border: const OutlineInputBorder(), filled: true, fillColor: Colors.white),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Text('Filter by role:'),
                    const SizedBox(width: 12),
                    DropdownButton<String>(value: _roleFilter, items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(), onChanged: (value) { if (value != null) setState(() => _roleFilter = value); }),
                    const Spacer(),
                    Text('${filtered.length} of ${docs.length} users', style: const TextStyle(color: Colors.black54)),
                  ]),
                ]),
              ),
            ),
            Expanded(child: filtered.isEmpty
                ? const Center(child: Text('No matching user accounts found.'))
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final doc = filtered[index];
                final data = doc.data();
                final name = (data['displayName'] ?? 'Unnamed user').toString();
                final email = (data['email'] ?? 'No email').toString();
                final role = (data['role'] ?? 'Unassigned').toString();
                return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1000), child: Card(color: Colors.white, child: ListTile(
                  leading: CircleAvatar(backgroundColor: purple.withOpacity(.13), child: const Icon(Icons.person_outline, color: purple)),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: navy)),
                  subtitle: Text('$email\n$role • Created ${_dateLabel(data['createdAt'])}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showUserDetails(doc),
                ))));
              },
            )),
          ]);
        },
      ),
    );
  }

  Widget _errorState(String message) => Center(child: Padding(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: navy, height: 1.5)))));
}

// -----------------------------------------------------------------------------
// PHYSICAL ORDERS (existing Firestore collection-group workflow retained)
// -----------------------------------------------------------------------------
class AdminPhysicalOrdersScreen extends StatelessWidget {
  const AdminPhysicalOrdersScreen({super.key});
  static const Color navy = AdminPortalScreen.navy;
  static const Color background = AdminPortalScreen.background;
  static const Color purple = AdminPortalScreen.purple;

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate().toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return 'Date unavailable';
  }

  Future<void> _updateStatus(BuildContext context, DocumentSnapshot<Map<String, dynamic>> orderDoc, String newStatus) async {
    try {
      await orderDoc.reference.update({'orderStatus': newStatus, 'deliveryStatus': newStatus, 'statusUpdatedAt': FieldValue.serverTimestamp(), 'statusUpdatedBy': FirebaseAuth.instance.currentUser?.uid});
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order status updated to ${_statusLabel(newStatus)}.')));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to update order status: $error')));
    }
  }

  String _statusLabel(String status) => status.toLowerCase() == 'shipped' ? 'Shipped' : status.toLowerCase() == 'delivered' ? 'Delivered' : 'Processing';
  Color _statusColor(String status) => status.toLowerCase() == 'shipped' ? Colors.blue.shade700 : status.toLowerCase() == 'delivered' ? Colors.green.shade700 : Colors.orange.shade800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(backgroundColor: background, foregroundColor: navy, elevation: 0, title: const Text('PHYSICAL ORDER MANAGEMENT')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collectionGroup('physicalOrders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: Text('Unable to load physical orders.\n\n${snapshot.error}\n\nCheck that your Firestore rules allow Admin users collection-group read and update access.', textAlign: TextAlign.center, style: const TextStyle(color: navy, height: 1.5)))));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: purple));
          final orders = [...?snapshot.data?.docs];
          orders.sort((a, b) {
            final av = a.data()['createdAt']; final bv = b.data()['createdAt'];
            return (bv is Timestamp ? bv.millisecondsSinceEpoch : 0).compareTo(av is Timestamp ? av.millisecondsSinceEpoch : 0);
          });
          if (orders.isEmpty) return const Center(child: Text('No physical orders have been placed yet.', style: TextStyle(color: navy, fontSize: 16)));
          return ListView.separated(
            padding: const EdgeInsets.all(20), itemCount: orders.length, separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final doc = orders[index]; final order = doc.data();
              final status = (order['deliveryStatus'] ?? order['orderStatus'] ?? 'processing').toString().toLowerCase();
              final items = order['items'] is List ? order['items'] as List : const [];
              final address = order['shippingAddress'] is Map ? Map<String, dynamic>.from(order['shippingAddress'] as Map) : <String, dynamic>{};
              final addressText = [address['address'], address['city'], address['state'], address['postcode'], address['country']].where((v) => v != null && v.toString().trim().isNotEmpty).join(', ');
              final total = (order['total'] as num?)?.toDouble() ?? 0.0;
              final userId = (order['userId'] ?? doc.reference.parent.parent?.id ?? 'Unknown').toString();
              return Card(color: Colors.white, elevation: 1, child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, runSpacing: 8, children: [
                  Text('Order ${order['orderId'] ?? doc.id}', style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 16)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: _statusColor(status).withOpacity(.12), borderRadius: BorderRadius.circular(20)), child: Text(_statusLabel(status).toUpperCase(), style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 12),
                Text('Customer: ${order['customerName'] ?? 'Not provided'}'), Text('Email: ${order['customerEmail'] ?? 'Not provided'}'), Text('Phone: ${order['customerPhone'] ?? 'Not provided'}'), Text('Order date: ${_formatDate(order['createdAt'])}'),
                const SizedBox(height: 10), const Text('ITEMS', style: TextStyle(color: purple, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)), const SizedBox(height: 6),
                ...items.map((raw) { if (raw is! Map) return const SizedBox.shrink(); final item = Map<String, dynamic>.from(raw); return Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${item['productName'] ?? 'Product'} × ${item['quantity'] ?? 1}')); }),
                const SizedBox(height: 10), const Text('DELIVERY ADDRESS', style: TextStyle(color: purple, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)), const SizedBox(height: 5), Text(addressText.isEmpty ? 'No delivery address saved.' : addressText),
                const SizedBox(height: 12),
                Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 8, children: [Text('Total: RM ${total.toStringAsFixed(2)}', style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 17)), Text('Customer ID: ${userId.length > 12 ? '${userId.substring(0, 12)}…' : userId}', style: const TextStyle(color: Colors.black54, fontSize: 11))]),
                const Divider(height: 24),
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, runSpacing: 8, children: [
                  const Text('Update delivery status:', style: TextStyle(fontWeight: FontWeight.w600)),
                  DropdownButton<String>(value: ['processing', 'shipped', 'delivered'].contains(status) ? status : 'processing', items: const [DropdownMenuItem(value: 'processing', child: Text('Processing')), DropdownMenuItem(value: 'shipped', child: Text('Shipped')), DropdownMenuItem(value: 'delivered', child: Text('Delivered'))], onChanged: (value) { if (value != null && value != status) _updateStatus(context, doc, value); }),
                ]),
              ])));
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CORPORATE ENQUIRIES
// -----------------------------------------------------------------------------
class _EditDisplayNameDialog extends StatefulWidget {
  const _EditDisplayNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditDisplayNameDialog> createState() => _EditDisplayNameDialogState();
}

class _EditDisplayNameDialogState extends State<_EditDisplayNameDialog> {
  late final TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit display name'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Display name',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter a display name.'
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EditCorporateEnquiryDialog extends StatefulWidget {
  const _EditCorporateEnquiryDialog({
    required this.initialStatus,
    required this.initialProgramme,
    required this.statuses,
  });

  final String initialStatus;
  final String initialProgramme;
  final List<String> statuses;

  @override
  State<_EditCorporateEnquiryDialog> createState() => _EditCorporateEnquiryDialogState();
}

class _EditCorporateEnquiryDialogState extends State<_EditCorporateEnquiryDialog> {
  late String _selectedStatus;
  late final TextEditingController _programmeController;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _programmeController = TextEditingController(text: widget.initialProgramme);
  }

  @override
  void dispose() {
    _programmeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update corporate enquiry'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Enquiry status',
                  border: OutlineInputBorder(),
                ),
                items: widget.statuses
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedStatus = value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _programmeController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Proposed programme',
                  hintText: 'Outline a suggested training programme...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, {
            'status': _selectedStatus,
            'proposedProgramme': _programmeController.text.trim(),
          }),
          child: const Text('Save changes'),
        ),
      ],
    );
  }
}

class AdminCorporateEnquiriesScreen extends StatelessWidget {
  const AdminCorporateEnquiriesScreen({super.key});
  static const navy = AdminPortalScreen.navy;
  static const background = AdminPortalScreen.background;
  static const purple = AdminPortalScreen.purple;
  static const statuses = ['Pending', 'In Review', 'Contacted', 'Completed'];

  String _dateLabel(dynamic value) {
    if (value is Timestamp) {
      final d = value.toDate().toLocal();
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }
    return 'Date unavailable';
  }

  Future<void> _editEnquiry(BuildContext context, DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data() ?? {};
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _EditCorporateEnquiryDialog(
        initialStatus: statuses.contains(data['status']) ? data['status'] as String : 'Pending',
        initialProgramme: (data['proposedProgramme'] ?? '').toString(),
        statuses: statuses,
      ),
    );
    if (result == null) return;
    try {
      await doc.reference.update({
        'status': result['status'],
        'proposedProgramme': result['proposedProgramme'],
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enquiry updated.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update enquiry: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(backgroundColor: background, foregroundColor: navy, elevation: 0, title: const Text('CORPORATE ENQUIRIES')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('corporateEnquiries').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Unable to load corporate enquiries. Check that your Firestore rules allow administrators to read this collection.\n\n${snapshot.error}', textAlign: TextAlign.center)));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: purple));
          final enquiries = [...?snapshot.data?.docs];
          enquiries.sort((a, b) {
            final av = a.data()['createdAt']; final bv = b.data()['createdAt'];
            return (bv is Timestamp ? bv.millisecondsSinceEpoch : 0).compareTo(av is Timestamp ? av.millisecondsSinceEpoch : 0);
          });
          if (enquiries.isEmpty) return const Center(child: Text('No corporate enquiries have been submitted yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(20), itemCount: enquiries.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = enquiries[index]; final data = doc.data();
              final status = (data['status'] ?? 'Pending').toString();
              return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1000), child: Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, runSpacing: 8, children: [
                  SizedBox(width: 520, child: Text((data['organizationName'] ?? 'Organisation').toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy))),
                  Chip(label: Text(status), backgroundColor: purple.withOpacity(.12)),
                ]),
                const SizedBox(height: 8),
                Text('Contact: ${data['contactName'] ?? 'Not provided'}'), Text('Email: ${data['email'] ?? 'Not provided'}'), Text('Phone: ${data['phone'] ?? 'Not provided'}'),
                Text('Employees: ${data['employeeCount'] ?? 'Not provided'}'), Text('Preferred programme: ${data['preferredProgramme'] ?? 'Not specified'}'), Text('Submitted: ${_dateLabel(data['createdAt'])}'),
                const SizedBox(height: 12),
                const Text('TRAINING REQUIREMENTS', style: TextStyle(color: purple, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 4), Text((data['trainingRequirements'] ?? 'Not provided').toString()),
                if ((data['additionalComments'] ?? '').toString().trim().isNotEmpty) ...[
                  const SizedBox(height: 10), const Text('ADDITIONAL COMMENTS', style: TextStyle(color: purple, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)), const SizedBox(height: 4), Text(data['additionalComments'].toString()),
                ],
                if ((data['proposedProgramme'] ?? '').toString().trim().isNotEmpty) ...[
                  const SizedBox(height: 10), const Text('PROPOSED PROGRAMME', style: TextStyle(color: purple, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)), const SizedBox(height: 4), Text(data['proposedProgramme'].toString()),
                ],
                const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: () => _editEnquiry(context, doc), icon: const Icon(Icons.edit_outlined), label: const Text('Update enquiry'))),
              ])))));
            },
          );
        },
      ),
    );
  }
}
