import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/extensions/context_extensions.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';
import 'package:lexcore/shared/widgets/app_searchable_dropdown_field.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

typedef CaseUploadFilePicker = Future<List<CaseUploadAttachment>> Function();

@immutable
class CaseUploadAttachment {
  const CaseUploadAttachment({
    required this.name,
    required this.extension,
    required this.sizeBytes,
  });

  final String name;
  final String extension;
  final int sizeBytes;

  String get duplicateKey => '${name.toLowerCase()}::$sizeBytes';
}

class CaseUploadPage extends StatefulWidget {
  const CaseUploadPage({super.key, this.filePicker});

  final CaseUploadFilePicker? filePicker;

  @override
  State<CaseUploadPage> createState() => _CaseUploadPageState();
}

class _CaseUploadPageState extends State<CaseUploadPage> {
  static const List<String> _causeOptions = ['民事纠纷', '刑事案件', '行政诉讼', '商事仲裁'];
  static const List<String> _allowedExtensions = [
    'pdf',
    'doc',
    'docx',
    'jpg',
    'jpeg',
    'png',
  ];
  static const int _maxFileSizeBytes = 20 * 1024 * 1024;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCause;
  bool _submitted = false;
  bool _isPickingFiles = false;
  List<CaseUploadAttachment> _attachments = const [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: AppMobileCanvas(
        maxContentWidth: 520,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppFadeSlideIn(
                delay: const Duration(milliseconds: 20),
                beginOffset: const Offset(0, -0.02),
                child: AppShellTopBar(
                  title: '上传案件',
                  leading: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: '返回',
                  ),
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      AppFadeSlideIn(
                        delay: const Duration(milliseconds: 60),
                        beginOffset: const Offset(0, 0.02),
                        child: _SectionLabel(
                          icon: Icons.info_outline_rounded,
                          title: '基本信息',
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppFadeSlideIn(
                        delay: const Duration(milliseconds: 90),
                        beginOffset: const Offset(0, 0.02),
                        child: TextFormField(
                          key: const ValueKey<String>(
                            'case_upload_title_field',
                          ),
                          controller: _titleController,
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration(
                            context,
                            label: '案件名称',
                            helperText: '请输入案件名称',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '请输入案件名称';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppFadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        beginOffset: const Offset(0, 0.02),
                        child: AppSearchableDropdownField(
                          key: const ValueKey<String>(
                            'case_upload_cause_field',
                          ),
                          label: '案由',
                          value: _selectedCause,
                          options: _causeOptions,
                          helperText: '请选择案由',
                          errorText: _submitted && _selectedCause == null
                              ? '请选择案由'
                              : null,
                          onChanged: (selection) {
                            if (selection == null) {
                              return;
                            }
                            setState(() {
                              _selectedCause = selection;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppFadeSlideIn(
                        delay: const Duration(milliseconds: 150),
                        beginOffset: const Offset(0, 0.02),
                        child: TextFormField(
                          key: const ValueKey<String>(
                            'case_upload_description_field',
                          ),
                          controller: _descriptionController,
                          textInputAction: TextInputAction.newline,
                          minLines: 5,
                          maxLines: 5,
                          decoration: _fieldDecoration(
                            context,
                            label: '案件描述',
                            helperText: '请简要描述案件经过、争议焦点等关键内容',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '请输入案件描述';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                      AppFadeSlideIn(
                        delay: const Duration(milliseconds: 190),
                        beginOffset: const Offset(0, 0.02),
                        child: _SectionLabel(
                          icon: Icons.description_outlined,
                          title: '案件文档',
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppFadeSlideIn(
                        delay: const Duration(milliseconds: 220),
                        beginOffset: const Offset(0, 0.02),
                        child: _UploadDropzone(
                          isLoading: _isPickingFiles,
                          selectedCount: _attachments.length,
                          onTap: _pickFiles,
                        ),
                      ),
                      if (_attachments.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        AppFadeSlideIn(
                          delay: const Duration(milliseconds: 250),
                          beginOffset: const Offset(0, 0.02),
                          child: Column(
                            children: [
                              for (
                                var index = 0;
                                index < _attachments.length;
                                index++
                              ) ...[
                                _AttachmentRow(
                                  key: ValueKey<String>(
                                    'case_upload_file_row_$index',
                                  ),
                                  file: _attachments[index],
                                  onRemove: () =>
                                      _removeAttachment(_attachments[index]),
                                ),
                                if (index != _attachments.length - 1)
                                  const SizedBox(height: 10),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 104),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppMobileCanvas(
        maxContentWidth: 520,
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: FilledButton.icon(
              key: const ValueKey<String>('case_upload_submit_button'),
              onPressed: _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.analytics_outlined),
              label: const Text(
                '提交分析',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    if (_isPickingFiles) {
      return;
    }

    setState(() => _isPickingFiles = true);

    try {
      final picker = widget.filePicker ?? _pickFilesFromDevice;
      final pickedFiles = await picker();
      if (!mounted || pickedFiles.isEmpty) {
        return;
      }

      final existingKeys = _attachments
          .map((file) => file.duplicateKey)
          .toSet();
      final acceptedFiles = <CaseUploadAttachment>[];
      var unsupportedCount = 0;
      var oversizedCount = 0;
      var duplicateCount = 0;

      for (final file in pickedFiles) {
        if (!_allowedExtensions.contains(file.extension)) {
          unsupportedCount += 1;
          continue;
        }
        if (file.sizeBytes > _maxFileSizeBytes) {
          oversizedCount += 1;
          continue;
        }
        if (existingKeys.contains(file.duplicateKey) ||
            acceptedFiles.any(
              (existing) => existing.duplicateKey == file.duplicateKey,
            )) {
          duplicateCount += 1;
          continue;
        }
        acceptedFiles.add(file);
      }

      if (!mounted) {
        return;
      }

      if (acceptedFiles.isNotEmpty) {
        setState(() {
          _attachments = [..._attachments, ...acceptedFiles];
        });
      }

      final notices = <String>[];
      if (unsupportedCount > 0) {
        notices.add('$unsupportedCount 个文件格式不支持');
      }
      if (oversizedCount > 0) {
        notices.add('$oversizedCount 个文件超过 20MB');
      }
      if (duplicateCount > 0) {
        notices.add('$duplicateCount 个文件已存在');
      }

      if (notices.isNotEmpty) {
        _showSnackBar(notices.join('，'));
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('文件读取失败，请稍后重试');
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingFiles = false);
      }
    }
  }

  Future<List<CaseUploadAttachment>> _pickFilesFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );
    if (result == null) {
      return const [];
    }

    return result.files
        .map(
          (file) => CaseUploadAttachment(
            name: file.name,
            extension: _resolveExtension(file),
            sizeBytes: file.size,
          ),
        )
        .toList();
  }

  String _resolveExtension(PlatformFile file) {
    final extension = file.extension?.trim().toLowerCase();
    if (extension != null && extension.isNotEmpty) {
      return extension;
    }

    final separatorIndex = file.name.lastIndexOf('.');
    if (separatorIndex == -1 || separatorIndex == file.name.length - 1) {
      return '';
    }
    return file.name.substring(separatorIndex + 1).toLowerCase();
  }

  void _removeAttachment(CaseUploadAttachment file) {
    setState(() {
      _attachments = _attachments
          .where((current) => current.duplicateKey != file.duplicateKey)
          .toList();
    });
  }

  void _submit() {
    setState(() => _submitted = true);
    FocusScope.of(context).unfocus();

    final formValid = _formKey.currentState?.validate() ?? false;
    final causeValid = _selectedCause != null;
    if (!formValid || !causeValid) {
      _showSnackBar('请先补全案件基本信息');
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('案件信息已提交，正在生成分析结果'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.colorScheme.inverseSurface,
        ),
      );

    context.push(RouteNames.analysisDetailPath);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _UploadDropzone extends StatelessWidget {
  const _UploadDropzone({
    required this.isLoading,
    required this.selectedCount,
    required this.onTap,
  });

  final bool isLoading;
  final int selectedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final title = selectedCount == 0 ? '点击上传案件相关文档' : '继续添加案件文档';
    final subtitle = selectedCount == 0
        ? '支持 PDF、Word、JPG/PNG，单文件不超过 20MB'
        : '已选择 $selectedCount 个文件，可继续补充上传';

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colorScheme.outlineVariant, width: 1.2),
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLoading
                      ? Icons.hourglass_top_rounded
                      : Icons.upload_file_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.tonalIcon(
                key: const ValueKey<String>('case_upload_pick_files_button'),
                onPressed: isLoading ? null : onTap,
                icon: Icon(
                  isLoading ? Icons.sync_rounded : Icons.attach_file_rounded,
                ),
                label: Text(isLoading ? '读取中…' : '选择文件'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({super.key, required this.file, required this.onRemove});

  final CaseUploadAttachment file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final extensionLabel = file.extension.isEmpty
        ? '文件'
        : file.extension.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _iconForExtension(file.extension),
              color: colorScheme.onSecondaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '$extensionLabel · ${_formatFileSize(file.sizeBytes)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: '移除文件',
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  IconData _iconForExtension(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}

InputDecoration _fieldDecoration(
  BuildContext context, {
  required String label,
  String? helperText,
  String? errorText,
}) {
  final colorScheme = context.colorScheme;
  final baseBorder = UnderlineInputBorder(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    ),
    borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.8),
  );

  return InputDecoration(
    labelText: label,
    helperText: helperText,
    errorText: errorText,
    helperStyle: TextStyle(color: colorScheme.onSurfaceVariant),
    filled: true,
    fillColor: colorScheme.surfaceContainerHigh,
    contentPadding: const EdgeInsets.fromLTRB(14, 22, 14, 10),
    border: baseBorder,
    enabledBorder: baseBorder,
    focusedBorder: baseBorder.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    ),
  );
}

String _formatFileSize(int sizeBytes) {
  if (sizeBytes >= 1024 * 1024) {
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (sizeBytes >= 1024) {
    return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
  }
  return '$sizeBytes B';
}
