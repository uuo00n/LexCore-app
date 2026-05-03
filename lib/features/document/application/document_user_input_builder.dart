class LaborArbitrationInputData {
  const LaborArbitrationInputData({
    required this.applicantName,
    required this.respondentName,
    required this.entryDate,
    required this.exitDate,
    required this.position,
    required this.monthlySalary,
    required this.coreClaim,
    required this.arbitrationRequests,
    required this.factDetails,
    required this.otherNotes,
    required this.hasLaborContract,
    required this.hasSocialSecurity,
  });

  final String applicantName;
  final String respondentName;
  final String entryDate;
  final String exitDate;
  final String position;
  final String monthlySalary;
  final String coreClaim;
  final String arbitrationRequests;
  final String factDetails;
  final String otherNotes;
  final String hasLaborContract;
  final String hasSocialSecurity;
}

class LawyerLetterInputData {
  const LawyerLetterInputData({
    required this.senderOrg,
    required this.senderLawyer,
    required this.senderContact,
    required this.recipientName,
    required this.recipientAddress,
    required this.subject,
    required this.factBackground,
    required this.legalBasis,
    required this.demands,
    required this.toneStyle,
    required this.deadline,
    required this.deliveryMethod,
    required this.letterDate,
    required this.otherNotes,
  });

  final String senderOrg;
  final String senderLawyer;
  final String senderContact;
  final String recipientName;
  final String recipientAddress;
  final String subject;
  final String factBackground;
  final String legalBasis;
  final String demands;
  final String toneStyle;
  final String deadline;
  final String deliveryMethod;
  final String letterDate;
  final String otherNotes;
}

String buildUserInputByDocType({
  required String docType,
  required LaborArbitrationInputData laborData,
  required LawyerLetterInputData lawyerData,
}) {
  if (docType == '律师函') {
    return buildLawyerLetterUserInput(lawyerData);
  }
  return buildLaborArbitrationUserInput(laborData);
}

String buildLaborArbitrationUserInput(LaborArbitrationInputData data) {
  final mergedOtherNotes = _mergeOtherNotes(
    otherNotes: data.otherNotes,
    hasLaborContract: data.hasLaborContract,
    hasSocialSecurity: data.hasSocialSecurity,
  );
  return [
    _line('类型', '劳动仲裁'),
    _line('申请人姓名', data.applicantName),
    _line('被申请人名称', data.respondentName),
    _line('入职时间', data.entryDate),
    _line('离职时间', data.exitDate),
    _line('工作岗位', data.position),
    _line('月工资', data.monthlySalary),
    _line('核心诉求', data.coreClaim),
    _line('仲裁请求', _normalizeMultiline(data.arbitrationRequests)),
    _line('事实经过', _normalizeMultiline(data.factDetails)),
    _line('其他说明', _normalizeMultiline(mergedOtherNotes)),
  ].join('\n');
}

String buildLawyerLetterUserInput(LawyerLetterInputData data) {
  final lines = <String>[
    _line('类型', '律师函'),
    _line('收函方', data.recipientName),
    _line('发函事由', data.subject),
    _line('事实背景', _normalizeMultiline(data.factBackground)),
    _line('具体要求', _normalizeMultiline(data.demands)),
    _line('语气风格', data.toneStyle),
  ];

  _appendOptionalLine(lines, '发函机构', data.senderOrg);
  _appendOptionalLine(lines, '承办律师', data.senderLawyer);
  _appendOptionalLine(lines, '联系方式', data.senderContact);
  _appendOptionalLine(lines, '收函方地址', data.recipientAddress);
  _appendOptionalLine(lines, '法律依据', _normalizeMultiline(data.legalBasis));
  _appendOptionalLine(lines, '履行期限', data.deadline);
  _appendOptionalLine(lines, '送达方式', data.deliveryMethod);
  _appendOptionalLine(lines, '函件日期', data.letterDate);
  _appendOptionalLine(lines, '其他说明', _normalizeMultiline(data.otherNotes));

  return lines.join('\n');
}

String _line(String label, String value) {
  return '$label：${_normalize(value)}';
}

String _normalize(String value) {
  return value.trim();
}

void _appendOptionalLine(List<String> lines, String label, String value) {
  final normalized = _normalize(value);
  if (normalized.isEmpty) {
    return;
  }
  lines.add(_line(label, normalized));
}

String _normalizeMultiline(String value) {
  return value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join('；');
}

String _mergeOtherNotes({
  required String otherNotes,
  required String hasLaborContract,
  required String hasSocialSecurity,
}) {
  final parts = <String>[
    '是否签订劳动合同：${_normalize(hasLaborContract)}',
    '是否缴纳社保：${_normalize(hasSocialSecurity)}',
  ];
  final normalizedNotes = _normalizeMultiline(otherNotes);
  if (normalizedNotes.isNotEmpty) {
    parts.add(normalizedNotes);
  }
  return parts.join('；');
}
