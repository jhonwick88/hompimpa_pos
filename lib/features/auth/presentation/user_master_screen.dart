import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/auth/data/user_repository.dart';
import 'package:hompimpa_pos/features/auth/domain/user_model.dart';
import 'package:hompimpa_pos/core/enums/user_role.dart';
import 'package:hompimpa_pos/features/settings/data/store_repository.dart';
import 'package:uuid/uuid.dart';

class UserMasterScreen extends ConsumerWidget {
  const UserMasterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Data User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showUserDialog(context, ref),
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) => ListView.separated(
          itemCount: users.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user.displayName ?? 'No Name'),
              subtitle: Text('${user.email} | Role: ${user.role.name}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showUserDialog(context, ref, user: user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirm(context, ref, user),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showUserDialog(BuildContext context, WidgetRef ref, {AppUser? user}) {
    final emailController = TextEditingController(text: user?.email ?? '');
    final nameController = TextEditingController(text: user?.displayName ?? '');
    UserRole role = user?.role ?? UserRole.user;
    String? selectedStoreId = user?.storeId;
    final storesAsync = ref.read(activeStoresProvider);

    showDialog(
      context: context,
      builder: (contextDialog) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(user == null ? 'Tambah User' : 'Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  readOnly: user != null, // Email is identifier
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  items: UserRole.values.map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.name.toUpperCase()),
                  )).toList(),
                  onChanged: (v) => setState(() => role = v!),
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                const SizedBox(height: 16),
                storesAsync.when(
                  data: (stores) => DropdownButtonFormField<String?>(
                    value: selectedStoreId,
                    decoration: const InputDecoration(labelText: 'Store'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('No Store')),
                      ...stores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                    ],
                    onChanged: (v) => setState(() => selectedStoreId = v),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading stores'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(contextDialog), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final newUser = AppUser(
                  uid: user?.uid ?? const Uuid().v4(), // Temporary UID for new users
                   email: emailController.text.trim(),
                  displayName: nameController.text.trim(),
                  role: role,
                  storeId: selectedStoreId,
                );

                if (user == null) {
                  await ref.read(userRepositoryProvider).addUser(newUser);
                } else {
                  await ref.read(userRepositoryProvider).updateUser(newUser);
                }
                Navigator.pop(contextDialog);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, AppUser user) {
    showDialog(
      context: context,
      builder: (contextDialog) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Apakah Anda yakin ingin menghapus user ${user.email}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(contextDialog), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(userRepositoryProvider).deleteUser(user.uid);
              Navigator.pop(contextDialog);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
