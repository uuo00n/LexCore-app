import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/document/application/document_user_input_builder.dart';

void main() {
  test('buildLaborArbitrationUserInput keeps expected labels and no null', () {
    const result = '''类型：劳动仲裁
申请人姓名：李某
被申请人名称：上海某某科技有限公司
入职时间：2023年3月1日
离职时间：
工作岗位：运营专员
月工资：12000元
核心诉求：支付拖欠工资并承担经济补偿
仲裁请求：1. 支付工资；2. 支付经济补偿
事实经过：持续拖欠工资；多次催告未果
其他说明：是否签订劳动合同：是；是否缴纳社保：否；补充说明''';

    final input = buildLaborArbitrationUserInput(
      const LaborArbitrationInputData(
        applicantName: '李某',
        respondentName: '上海某某科技有限公司',
        entryDate: '2023年3月1日',
        exitDate: '',
        position: '运营专员',
        monthlySalary: '12000元',
        coreClaim: '支付拖欠工资并承担经济补偿',
        arbitrationRequests: '1. 支付工资\n2. 支付经济补偿',
        factDetails: '持续拖欠工资\n多次催告未果',
        otherNotes: '补充说明',
        hasLaborContract: '是',
        hasSocialSecurity: '否',
      ),
    );

    expect(input, result);
    expect(input, contains('类型：劳动仲裁'));
    expect(input.contains('null'), isFalse);
  });

  test('buildLawyerLetterUserInput flattens multiline lists', () {
    final input = buildLawyerLetterUserInput(
      const LawyerLetterInputData(
        senderOrg: '上海某某律师事务所',
        senderLawyer: '张某某 律师',
        senderContact: '13800000000',
        recipientName: '某某企业管理有限公司',
        recipientAddress: '上海市浦东新区某某路88号',
        subject: '立即清偿拖欠服务费并承担违约责任',
        factBackground: '逾期未支付\n多次催告未果',
        legalBasis: '民法典577条\n民法典578条',
        demands: '3日内付款\n承担违约责任',
        toneStyle: '正式严肃型',
        deadline: '收到本函7日内履行',
        deliveryMethod: '电子邮件及快递送达',
        letterDate: '2026年4月20日',
        otherNotes: '',
      ),
    );

    expect(input, contains('类型：律师函'));
    expect(input, contains('收函方：某某企业管理有限公司'));
    expect(input, contains('发函事由：立即清偿拖欠服务费并承担违约责任'));
    expect(input, contains('事实背景：逾期未支付；多次催告未果'));
    expect(input, contains('具体要求：3日内付款；承担违约责任'));
    expect(input, contains('语气风格：正式严肃型'));
    expect(input, contains('法律依据：民法典577条；民法典578条'));
    expect(input, isNot(contains('其他说明：')));
    expect(input.contains('null'), isFalse);
  });

  test('buildLawyerLetterUserInput matches workflow prompt shape', () {
    final input = buildLawyerLetterUserInput(
      const LawyerLetterInputData(
        senderOrg: '',
        senderLawyer: '',
        senderContact: '',
        recipientName: '北京某商贸有限公司',
        recipientAddress: '',
        subject: '催收拖欠货款',
        factBackground: '双方签订供货合同后，我方已完成供货义务，但对方拖欠货款50000元未支付，催要无果。',
        legalBasis: '',
        demands: '请于收到本函后7日内支付全部欠款。',
        toneStyle: '正式严肃型',
        deadline: '',
        deliveryMethod: '',
        letterDate: '',
        otherNotes: '',
      ),
    );

    expect(input, contains('类型：律师函'));
    expect(input, contains('收函方：北京某商贸有限公司'));
    expect(input, contains('发函事由：催收拖欠货款'));
    expect(input, contains('事实背景：双方签订供货合同后，我方已完成供货义务，但对方拖欠货款50000元未支付，催要无果。'));
    expect(input, contains('具体要求：请于收到本函后7日内支付全部欠款。'));
    expect(input, contains('语气风格：正式严肃型'));
  });
}
