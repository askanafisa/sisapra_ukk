import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/theme.dart';
import '../app/data.dart';

// Modern Gradient Button
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: DynamicAppColors.primaryGradient(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(text,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}

// Modern Text Field
class ModernTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const ModernTextField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    required this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                icon != null ? Icon(icon, color: AppColors.primary) : null,
            suffixIcon: suffixIcon,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

// Status Badge Modern
class StatusBadge extends StatelessWidget {
  final String status;
  final bool showEditIcon; // ✅ TAMBAH: Parameter untuk edit icon
  final VoidCallback? onEditPressed; // ✅ TAMBAH: Callback edit

  const StatusBadge({
    super.key,
    required this.status,
    this.showEditIcon = false, // ✅ TAMBAH: Default false
    this.onEditPressed, // ✅ TAMBAH: Callback edit
  });

  @override
  Widget build(BuildContext context) {
    final color = Helpers.getStatusColor(status, context);
    final icon = Helpers.getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),

          // ✅ TAMBAH: Edit icon untuk siswa jika status pending
          if (showEditIcon &&
              (status.toLowerCase() == 'pending' ||
                  status.toLowerCase() == 'menunggu')) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onEditPressed,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit_rounded, size: 12, color: Colors.blue),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Aspirasi Card Modern dengan Glassmorphism
class AspirasiCard extends StatelessWidget {
  final Aspirasi aspirasi;
  final VoidCallback? onTap;
  final bool showUser;
  final bool showMenu; // ✅ TAMBAH: Parameter untuk menu
  final VoidCallback? onEdit; // ✅ TAMBAH: Callback edit
  final VoidCallback? onDelete; // ✅ TAMBAH: Callback delete

  const AspirasiCard({
    super.key,
    required this.aspirasi,
    this.onTap,
    this.showUser = false,
    this.showMenu = false, // ✅ TAMBAH: Default false
    this.onEdit, // ✅ TAMBAH: Callback edit
    this.onDelete, // ✅ TAMBAH: Callback delete
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.5)]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        aspirasi.judul,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    StatusBadge(
                      status: aspirasi.status,
                      showEditIcon: showUser &&
                          (aspirasi.status.toLowerCase() ==
                              'pending'), // ✅ EDIT: Hanya siswa bisa edit status pending
                      onEditPressed: onEdit, // ✅ EDIT: Pass callback
                    ),

                    // ✅ TAMBAH: Popup menu untuk admin
                    if (showMenu) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert_rounded,
                            color: AppColors.textSecondary.withOpacity(0.7)),
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded,
                                    size: 20, color: AppColors.primary),
                                const SizedBox(width: 8),
                                const Text('Edit Umpan Balik'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_rounded,
                                    size: 20, color: Colors.red),
                                const SizedBox(width: 8),
                                const Text('Hapus',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit' && onEdit != null) {
                            onEdit!();
                          } else if (value == 'delete' && onDelete != null) {
                            onDelete!();
                          }
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (showUser) ...[
                      Icon(Icons.person_rounded,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${aspirasi.nama} (${aspirasi.kelas})',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      Helpers.formatDate(aspirasi.tanggal),
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        aspirasi.kategori,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  aspirasi.deskripsi,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (aspirasi.umpanBalik != null &&
                    aspirasi.umpanBalik!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.info.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.comment_rounded,
                            size: 16, color: AppColors.info),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            aspirasi.umpanBalik!,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.info),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Modern App Bar
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLogout;

  const ModernAppBar({super.key, required this.title, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: DynamicAppColors.primaryGradient(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AppBar(
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        actions: onLogout != null
            ? [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  onPressed: onLogout,
                ),
              ]
            : null,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
