import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_adaptive_frame.dart';
import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/document/application/document_providers.dart';
import 'package:lexcore/features/document/application/document_user_input_builder.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';
import 'package:lexcore/shared/widgets/app_searchable_dropdown_field.dart';

class DocumentGeneratePage extends ConsumerStatefulWidget {
  const DocumentGeneratePage({super.key});

  @override
  ConsumerState<DocumentGeneratePage> createState() =>
      _DocumentGeneratePageState();
}

class _DocumentGeneratePageState extends ConsumerState<DocumentGeneratePage> {
  String _documentType = '劳动仲裁';

  // 公共字段
  final _titleController = TextEditingController();
  final _claimController = TextEditingController();
  final _factController = TextEditingController();

  // 劳动仲裁专属字段
  final _applicantNameController = TextEditingController();
  final _respondentNameController = TextEditingController();
  final _entryDateController = TextEditingController();
  final _exitDateController = TextEditingController();
  final _positionController = TextEditingController();
  final _monthlySalaryController = TextEditingController();
  final _arbitrationRequestsController = TextEditingController();
  final _laborFactDetailsController = TextEditingController();
  String _hasLaborContract = '不详';
  String _hasSocialSecurity = '不详';

  // 律师函专属字段
  final _senderOrgController = TextEditingController(text: '上海某某律师事务所');
  final _senderLawyerController = TextEditingController(text: '张某某 律师');
  final _senderContactController = TextEditingController(text: '13800000000');
  final _recipientNameController = TextEditingController();
  final _recipientAddressController = TextEditingController();
  final _legalBasisController = TextEditingController();
  final _demandsController = TextEditingController();
  final _toneStyleController = TextEditingController(text: '正式严肃型');
  final _deadlineController = TextEditingController();
  final _deliveryMethodController = TextEditingController();
  final _letterDateController = TextEditingController(
    text: _formatDate(DateTime.now()),
  );

  @override
  void initState() {
    super.initState();
    _applyTemplate(_documentType);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _claimController.dispose();
    _factController.dispose();
    _applicantNameController.dispose();
    _respondentNameController.dispose();
    _entryDateController.dispose();
    _exitDateController.dispose();
    _positionController.dispose();
    _monthlySalaryController.dispose();
    _arbitrationRequestsController.dispose();
    _laborFactDetailsController.dispose();
    _senderOrgController.dispose();
    _senderLawyerController.dispose();
    _senderContactController.dispose();
    _recipientNameController.dispose();
    _recipientAddressController.dispose();
    _legalBasisController.dispose();
    _demandsController.dispose();
    _toneStyleController.dispose();
    _deadlineController.dispose();
    _deliveryMethodController.dispose();
    _letterDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final generating = ref.watch(
      documentControllerProvider.select((state) => state.saving),
    );

    return AppPageScaffold(
      title: 'LexCore 文书生成',
      backgroundColor: colorScheme.surface,
      maxContentWidth: 1120,
      body: AppAdaptiveFrame(
        maxContentWidth: 1120,
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
            final splitLayout =
                viewport == AppViewportSize.expanded ||
                viewport == AppViewportSize.ultra;

            if (!splitLayout) {
              return _GenerateForm(
                titleController: _titleController,
                claimController: _claimController,
                factController: _factController,
                applicantNameController: _applicantNameController,
                respondentNameController: _respondentNameController,
                entryDateController: _entryDateController,
                exitDateController: _exitDateController,
                positionController: _positionController,
                monthlySalaryController: _monthlySalaryController,
                arbitrationRequestsController: _arbitrationRequestsController,
                laborFactDetailsController: _laborFactDetailsController,
                hasLaborContract: _hasLaborContract,
                hasSocialSecurity: _hasSocialSecurity,
                senderOrgController: _senderOrgController,
                senderLawyerController: _senderLawyerController,
                senderContactController: _senderContactController,
                recipientNameController: _recipientNameController,
                recipientAddressController: _recipientAddressController,
                legalBasisController: _legalBasisController,
                demandsController: _demandsController,
                toneStyleController: _toneStyleController,
                deadlineController: _deadlineController,
                deliveryMethodController: _deliveryMethodController,
                letterDateController: _letterDateController,
                documentType: _documentType,
                contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 28),
                onTypeChanged: _handleDocTypeChanged,
                onLaborContractChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _hasLaborContract = value;
                  });
                },
                onSocialSecurityChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _hasSocialSecurity = value;
                  });
                },
                onGeneratePressed: _handleGenerate,
                generating: generating,
                onTemplateSelected: _applyTemplate,
                showTemplateSection: true,
              );
            }

            return AppAdaptiveSplitView(
              splitMinWidth: 980,
              secondaryMaxWidth: 360,
              primary: _GenerateForm(
                titleController: _titleController,
                claimController: _claimController,
                factController: _factController,
                applicantNameController: _applicantNameController,
                respondentNameController: _respondentNameController,
                entryDateController: _entryDateController,
                exitDateController: _exitDateController,
                positionController: _positionController,
                monthlySalaryController: _monthlySalaryController,
                arbitrationRequestsController: _arbitrationRequestsController,
                laborFactDetailsController: _laborFactDetailsController,
                hasLaborContract: _hasLaborContract,
                hasSocialSecurity: _hasSocialSecurity,
                senderOrgController: _senderOrgController,
                senderLawyerController: _senderLawyerController,
                senderContactController: _senderContactController,
                recipientNameController: _recipientNameController,
                recipientAddressController: _recipientAddressController,
                legalBasisController: _legalBasisController,
                demandsController: _demandsController,
                toneStyleController: _toneStyleController,
                deadlineController: _deadlineController,
                deliveryMethodController: _deliveryMethodController,
                letterDateController: _letterDateController,
                documentType: _documentType,
                contentPadding: const EdgeInsets.fromLTRB(0, 10, 12, 28),
                onTypeChanged: _handleDocTypeChanged,
                onLaborContractChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _hasLaborContract = value;
                  });
                },
                onSocialSecurityChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _hasSocialSecurity = value;
                  });
                },
                onGeneratePressed: _handleGenerate,
                generating: generating,
                onTemplateSelected: _applyTemplate,
                showTemplateSection: false,
              ),
              secondary: _GenerateSidePanel(
                contentPadding: const EdgeInsets.fromLTRB(12, 10, 0, 28),
                onTemplateSelected: _applyTemplate,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleDocTypeChanged(String? value) {
    if (value == null || value == _documentType) {
      return;
    }
    _applyTemplate(value);
  }

  Future<void> _handleGenerate() async {
    if (ref.read(documentControllerProvider).saving) {
      return;
    }
    final draft = _buildDraftOrShowError();
    if (draft == null) {
      return;
    }

    try {
      final result = await ref
          .read(documentControllerProvider.notifier)
          .saveDraft(draft);
      if (!mounted) {
        return;
      }
      final documentId = result.documentId.trim();
      if (documentId.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('生成失败，请稍后重试')));
        return;
      }
      context.pushNamed(
        RouteNames.savedDocumentDetail,
        pathParameters: {RouteNames.savedDocumentIdParam: documentId},
        queryParameters: const {'mode': 'view'},
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('生成失败，请稍后重试')));
    }
  }

  DocumentDraft? _buildDraftOrShowError() {
    final missing = _validateRequiredFields();
    if (missing.isNotEmpty) {
      _showValidationError('请完善必填项：${missing.join('、')}');
      return null;
    }

    final title = _resolveTitle();
    final userInput = buildUserInputByDocType(
      docType: _documentType,
      laborData: LaborArbitrationInputData(
        applicantName: _applicantNameController.text,
        respondentName: _respondentNameController.text,
        entryDate: _entryDateController.text,
        exitDate: _exitDateController.text,
        position: _positionController.text,
        monthlySalary: _monthlySalaryController.text,
        coreClaim: _claimController.text,
        arbitrationRequests: _arbitrationRequestsController.text,
        factDetails: _laborFactDetailsController.text,
        otherNotes: _factController.text,
        hasLaborContract: _hasLaborContract,
        hasSocialSecurity: _hasSocialSecurity,
      ),
      lawyerData: LawyerLetterInputData(
        senderOrg: _senderOrgController.text,
        senderLawyer: _senderLawyerController.text,
        senderContact: _senderContactController.text,
        recipientName: _recipientNameController.text,
        recipientAddress: _recipientAddressController.text,
        subject: _claimController.text,
        factBackground: _factController.text,
        legalBasis: _legalBasisController.text,
        demands: _demandsController.text,
        toneStyle: _toneStyleController.text,
        deadline: _deadlineController.text,
        deliveryMethod: _deliveryMethodController.text,
        letterDate: _letterDateController.text,
        otherNotes: '',
      ),
    );

    return DocumentDraft(
      title: title,
      markdown: _buildPreviewMarkdown(
        title: title,
        docType: _documentType,
        userInput: userInput,
      ),
      docType: _documentType,
      userInput: userInput,
      templateParams: const {},
    );
  }

  List<String> _validateRequiredFields() {
    if (_documentType == '律师函') {
      final missing = <String>[];
      if (_recipientNameController.text.trim().isEmpty) {
        missing.add('受函方名称');
      }
      if (_claimController.text.trim().isEmpty) {
        missing.add('发函事由');
      }
      if (_factController.text.trim().isEmpty) {
        missing.add('事实背景');
      }
      if (_demandsController.text.trim().isEmpty) {
        missing.add('正式要求');
      }
      return missing;
    }

    final missing = <String>[];
    if (_applicantNameController.text.trim().isEmpty) {
      missing.add('申请人姓名');
    }
    if (_respondentNameController.text.trim().isEmpty) {
      missing.add('被申请人名称');
    }
    if (_arbitrationRequestsController.text.trim().isEmpty) {
      missing.add('仲裁请求');
    }
    if (_laborFactDetailsController.text.trim().isEmpty) {
      missing.add('事实经过');
    }
    return missing;
  }

  String _resolveTitle() {
    final title = _titleController.text.trim();
    if (title.isNotEmpty) {
      return title;
    }
    if (_documentType == '律师函') {
      final subject = _claimController.text.trim();
      if (subject.isNotEmpty) {
        return '关于$subject之律师函';
      }
      return '律师函';
    }
    return '劳动仲裁申请书';
  }

  void _applyTemplate(String docType) {
    setState(() {
      _documentType = docType;

      if (docType == '劳动仲裁') {
        _titleController.text = '劳动仲裁申请书（拖欠工资纠纷）';
        _claimController.text = '支付拖欠工资并承担经济补偿';
        _factController.text = '双方已多次协商，但被申请人仍未支付拖欠工资。';

        _applicantNameController.text = '李某';
        _respondentNameController.text = '上海某某科技有限公司';
        _entryDateController.text = '2023年3月1日';
        _exitDateController.text = '2025年1月15日';
        _positionController.text = '运营专员';
        _monthlySalaryController.text = '12000元';
        _arbitrationRequestsController.text =
            '1. 请求裁决支付拖欠工资合计36000元；\n2. 请求裁决支付解除劳动关系经济补偿金。';
        _laborFactDetailsController.text =
            '申请人于入职后持续正常履职。\n被申请人自2024年10月起未按约支付工资，经催告仍未履行。';
        _hasLaborContract = '是';
        _hasSocialSecurity = '否';
        return;
      }

      _titleController.text = '关于拖欠服务费纠纷事项之律师函';
      _claimController.text = '立即清偿拖欠服务费并承担违约责任';
      _factController.text = '贵方与委托人签订服务合同后，已逾期支付服务费。\n委托人多次催告未果，已造成持续损失。';

      _senderOrgController.text = '上海某某律师事务所';
      _senderLawyerController.text = '张某某 律师';
      _senderContactController.text = '13800000000';
      _recipientNameController.text = '某某企业管理有限公司';
      _recipientAddressController.text = '上海市浦东新区某某路88号';
      _legalBasisController.text = '《中华人民共和国民法典》第五百七十七条\n《中华人民共和国民法典》第五百七十八条';
      _demandsController.text = '1. 于收到本函后3日内支付全部拖欠服务费；\n2. 承担逾期付款违约责任。';
      _toneStyleController.text = '正式严肃型';
      _deadlineController.text = '请于收到本函之日起7日内履行完毕';
      _deliveryMethodController.text = '本函通过电子邮件及书面快递送达';
      _letterDateController.text = _formatDate(DateTime.now());
    });
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _GenerateForm extends StatelessWidget {
  const _GenerateForm({
    required this.titleController,
    required this.claimController,
    required this.factController,
    required this.applicantNameController,
    required this.respondentNameController,
    required this.entryDateController,
    required this.exitDateController,
    required this.positionController,
    required this.monthlySalaryController,
    required this.arbitrationRequestsController,
    required this.laborFactDetailsController,
    required this.hasLaborContract,
    required this.hasSocialSecurity,
    required this.senderOrgController,
    required this.senderLawyerController,
    required this.senderContactController,
    required this.recipientNameController,
    required this.recipientAddressController,
    required this.legalBasisController,
    required this.demandsController,
    required this.toneStyleController,
    required this.deadlineController,
    required this.deliveryMethodController,
    required this.letterDateController,
    required this.documentType,
    required this.contentPadding,
    required this.onTypeChanged,
    required this.onLaborContractChanged,
    required this.onSocialSecurityChanged,
    required this.onGeneratePressed,
    required this.generating,
    required this.onTemplateSelected,
    required this.showTemplateSection,
  });

  final TextEditingController titleController;
  final TextEditingController claimController;
  final TextEditingController factController;
  final TextEditingController applicantNameController;
  final TextEditingController respondentNameController;
  final TextEditingController entryDateController;
  final TextEditingController exitDateController;
  final TextEditingController positionController;
  final TextEditingController monthlySalaryController;
  final TextEditingController arbitrationRequestsController;
  final TextEditingController laborFactDetailsController;
  final String hasLaborContract;
  final String hasSocialSecurity;
  final TextEditingController senderOrgController;
  final TextEditingController senderLawyerController;
  final TextEditingController senderContactController;
  final TextEditingController recipientNameController;
  final TextEditingController recipientAddressController;
  final TextEditingController legalBasisController;
  final TextEditingController demandsController;
  final TextEditingController toneStyleController;
  final TextEditingController deadlineController;
  final TextEditingController deliveryMethodController;
  final TextEditingController letterDateController;
  final String documentType;
  final EdgeInsets contentPadding;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onLaborContractChanged;
  final ValueChanged<String?> onSocialSecurityChanged;
  final Future<void> Function() onGeneratePressed;
  final bool generating;
  final ValueChanged<String> onTemplateSelected;
  final bool showTemplateSection;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: contentPadding,
      children: [
        Text(
          '创建新文档',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '填写以下信息，由智能引擎生成结构化法律文档。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 22),
        _CommonDocumentFieldsSection(
          titleController: titleController,
          claimController: claimController,
          factController: factController,
          documentType: documentType,
          onTypeChanged: onTypeChanged,
        ),
        const SizedBox(height: 14),
        if (documentType == '劳动仲裁')
          _LaborArbitrationFieldsSection(
            applicantNameController: applicantNameController,
            respondentNameController: respondentNameController,
            entryDateController: entryDateController,
            exitDateController: exitDateController,
            positionController: positionController,
            monthlySalaryController: monthlySalaryController,
            arbitrationRequestsController: arbitrationRequestsController,
            laborFactDetailsController: laborFactDetailsController,
            hasLaborContract: hasLaborContract,
            hasSocialSecurity: hasSocialSecurity,
            onLaborContractChanged: onLaborContractChanged,
            onSocialSecurityChanged: onSocialSecurityChanged,
          )
        else
          _LawyerLetterFieldsSection(
            senderOrgController: senderOrgController,
            senderLawyerController: senderLawyerController,
            senderContactController: senderContactController,
            recipientNameController: recipientNameController,
            recipientAddressController: recipientAddressController,
            legalBasisController: legalBasisController,
            demandsController: demandsController,
            toneStyleController: toneStyleController,
            deadlineController: deadlineController,
            deliveryMethodController: deliveryMethodController,
            letterDateController: letterDateController,
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const ValueKey('document-generate-submit'),
            onPressed: generating ? null : onGeneratePressed,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: const StadiumBorder(),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            icon: generating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              generating ? '生成中...' : '立即生成文档',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (showTemplateSection) ...[
          const SizedBox(height: 28),
          _TemplateSection(onTemplateSelected: onTemplateSelected),
          const SizedBox(height: 16),
          const _GenerateHintsCard(),
        ],
      ],
    );
  }
}

class _CommonDocumentFieldsSection extends StatelessWidget {
  const _CommonDocumentFieldsSection({
    required this.titleController,
    required this.claimController,
    required this.factController,
    required this.documentType,
    required this.onTypeChanged,
  });

  final TextEditingController titleController;
  final TextEditingController claimController;
  final TextEditingController factController;
  final String documentType;
  final ValueChanged<String?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Md3TextField(
          label: '文书标题（可选）',
          helperText: documentType == '律师函'
              ? '例如：关于拖欠服务费纠纷事项之律师函'
              : '例如：劳动仲裁申请书（拖欠工资纠纷）',
          controller: titleController,
        ),
        const SizedBox(height: 14),
        AppSearchableDropdownField(
          label: '文档类型',
          value: documentType,
          options: const ['劳动仲裁', '律师函'],
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 14),
        _Md3TextField(
          label: documentType == '律师函' ? '发函事由' : '核心诉求',
          helperText: documentType == '律师函' ? '例如：催收拖欠货款' : '例如：支付拖欠工资并承担经济补偿',
          controller: claimController,
        ),
        const SizedBox(height: 14),
        _Md3TextField(
          label: documentType == '律师函' ? '事实背景' : '事实经过 / 详细描述',
          controller: factController,
          minLines: 4,
          maxLines: 4,
        ),
      ],
    );
  }
}

class _LaborArbitrationFieldsSection extends StatelessWidget {
  const _LaborArbitrationFieldsSection({
    required this.applicantNameController,
    required this.respondentNameController,
    required this.entryDateController,
    required this.exitDateController,
    required this.positionController,
    required this.monthlySalaryController,
    required this.arbitrationRequestsController,
    required this.laborFactDetailsController,
    required this.hasLaborContract,
    required this.hasSocialSecurity,
    required this.onLaborContractChanged,
    required this.onSocialSecurityChanged,
  });

  final TextEditingController applicantNameController;
  final TextEditingController respondentNameController;
  final TextEditingController entryDateController;
  final TextEditingController exitDateController;
  final TextEditingController positionController;
  final TextEditingController monthlySalaryController;
  final TextEditingController arbitrationRequestsController;
  final TextEditingController laborFactDetailsController;
  final String hasLaborContract;
  final String hasSocialSecurity;
  final ValueChanged<String?> onLaborContractChanged;
  final ValueChanged<String?> onSocialSecurityChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '劳动仲裁专属信息',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _Md3TextField(label: '申请人姓名', controller: applicantNameController),
        const SizedBox(height: 12),
        _Md3TextField(label: '被申请人名称', controller: respondentNameController),
        const SizedBox(height: 12),
        _Md3TextField(label: '入职时间', controller: entryDateController),
        const SizedBox(height: 12),
        _Md3TextField(label: '离职时间（可选）', controller: exitDateController),
        const SizedBox(height: 12),
        _Md3TextField(label: '工作岗位', controller: positionController),
        const SizedBox(height: 12),
        _Md3TextField(label: '月工资', controller: monthlySalaryController),
        const SizedBox(height: 12),
        AppSearchableDropdownField(
          label: '是否签订劳动合同',
          value: hasLaborContract,
          options: const ['是', '否', '不详'],
          onChanged: onLaborContractChanged,
        ),
        const SizedBox(height: 12),
        AppSearchableDropdownField(
          label: '是否缴纳社保',
          value: hasSocialSecurity,
          options: const ['是', '否', '不详'],
          onChanged: onSocialSecurityChanged,
        ),
        const SizedBox(height: 12),
        _Md3TextField(
          label: '仲裁请求（多行，支持分条）',
          controller: arbitrationRequestsController,
          minLines: 4,
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        _Md3TextField(
          label: '事实经过（多行）',
          controller: laborFactDetailsController,
          minLines: 4,
          maxLines: 4,
        ),
      ],
    );
  }
}

class _LawyerLetterFieldsSection extends StatelessWidget {
  const _LawyerLetterFieldsSection({
    required this.senderOrgController,
    required this.senderLawyerController,
    required this.senderContactController,
    required this.recipientNameController,
    required this.recipientAddressController,
    required this.legalBasisController,
    required this.demandsController,
    required this.toneStyleController,
    required this.deadlineController,
    required this.deliveryMethodController,
    required this.letterDateController,
  });

  final TextEditingController senderOrgController;
  final TextEditingController senderLawyerController;
  final TextEditingController senderContactController;
  final TextEditingController recipientNameController;
  final TextEditingController recipientAddressController;
  final TextEditingController legalBasisController;
  final TextEditingController demandsController;
  final TextEditingController toneStyleController;
  final TextEditingController deadlineController;
  final TextEditingController deliveryMethodController;
  final TextEditingController letterDateController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '律师函专属信息',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _Md3TextField(label: '发函机构', controller: senderOrgController),
        const SizedBox(height: 12),
        _Md3TextField(label: '承办律师', controller: senderLawyerController),
        const SizedBox(height: 12),
        _Md3TextField(label: '联系方式', controller: senderContactController),
        const SizedBox(height: 12),
        _Md3TextField(label: '受函方名称', controller: recipientNameController),
        const SizedBox(height: 12),
        _Md3TextField(
          label: '受函方地址',
          controller: recipientAddressController,
          minLines: 2,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _Md3TextField(
          label: '法律依据（每行一条）',
          controller: legalBasisController,
          minLines: 3,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        _Md3TextField(
          label: '正式要求（每行一条）',
          controller: demandsController,
          minLines: 3,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        _Md3TextField(label: '语气风格', controller: toneStyleController),
        const SizedBox(height: 12),
        _Md3TextField(label: '履行期限', controller: deadlineController),
        const SizedBox(height: 12),
        _Md3TextField(label: '送达方式', controller: deliveryMethodController),
        const SizedBox(height: 12),
        _Md3TextField(label: '函件日期', controller: letterDateController),
      ],
    );
  }
}

class _GenerateSidePanel extends StatelessWidget {
  const _GenerateSidePanel({
    required this.contentPadding,
    required this.onTemplateSelected,
  });

  final EdgeInsets contentPadding;
  final ValueChanged<String> onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: contentPadding,
      children: [
        _TemplateSection(onTemplateSelected: onTemplateSelected),
        const SizedBox(height: 16),
        const _GenerateHintsCard(),
      ],
    );
  }
}

class _TemplateSection extends StatelessWidget {
  const _TemplateSection({required this.onTemplateSelected});

  final ValueChanged<String> onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推荐模板',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _TemplateCard(
                icon: Icons.description_outlined,
                title: '劳动仲裁申请书',
                onTap: () => onTemplateSelected('劳动仲裁'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TemplateCard(
                icon: Icons.gavel_outlined,
                title: '律师函',
                onTap: () => onTemplateSelected('律师函'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 94,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerateHintsCard extends StatelessWidget {
  const _GenerateHintsCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '填写建议',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const _Hint(text: '按时间顺序描述事实，便于模型抽取证据链'),
          const _Hint(text: '明确诉求优先级，便于生成结构化文书'),
          const _Hint(text: '引用具体条款可提升输出精度'),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 6,
              color: colorScheme.primary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Md3TextField extends StatelessWidget {
  const _Md3TextField({
    required this.label,
    required this.controller,
    this.helperText,
    this.minLines,
    this.maxLines = 1,
  });

  final String label;
  final String? helperText;
  final TextEditingController controller;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: _md3Decoration(context, label: label, helperText: helperText),
    );
  }
}

InputDecoration _md3Decoration(
  BuildContext context, {
  required String label,
  String? helperText,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final fillColor = colorScheme.surfaceContainerHigh;
  final borderColor = colorScheme.outlineVariant;

  final baseBorder = UnderlineInputBorder(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    ),
    borderSide: BorderSide(color: borderColor, width: 1.8),
  );

  return InputDecoration(
    labelText: label,
    helperText: helperText,
    helperStyle: TextStyle(color: colorScheme.onSurfaceVariant),
    filled: true,
    fillColor: fillColor,
    contentPadding: const EdgeInsets.fromLTRB(14, 22, 14, 10),
    border: baseBorder,
    enabledBorder: baseBorder,
    focusedBorder: baseBorder.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    ),
  );
}

String _buildPreviewMarkdown({
  required String title,
  required String docType,
  required String userInput,
}) {
  return [
    '# $title',
    '',
    '> 文档类型：$docType',
    '',
    '## 结构化输入',
    userInput,
  ].join('\n');
}

String _formatDate(DateTime date) {
  return '${date.year}年${date.month}月${date.day}日';
}
