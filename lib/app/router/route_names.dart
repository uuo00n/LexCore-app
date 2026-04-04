class RouteNames {
  const RouteNames._();

  static const auth = 'auth';
  static const register = 'register';
  static const home = 'home';
  static const consultation = 'consultation';
  static const consultationChat = 'consultation_chat';
  static const consultationStitchDetail = 'consultation_stitch_detail';
  static const consultationOpinionDetail = 'consultation_opinion_detail';
  static const caseUpload = 'case_upload';
  static const caseDetail = 'case_detail';
  static const analysisDetail = 'analysis_detail';
  static const analysisResult = 'analysis_result';
  static const dashboard = 'dashboard';
  static const documentGenerate = 'document_generate';
  static const documentPreview = 'document_preview';
  static const savedDocuments = 'saved_documents';
  static const savedDocumentDetail = 'saved_document_detail';
  static const legalSearch = 'legal_search';
  static const legalArticle = 'legal_article';
  static const inAppWebView = 'in_app_webview';
  static const history = 'history';
  static const historySearch = 'history_search';
  static const profile = 'profile';
  static const profilePersonalInfo = 'profile_personal_info';
  static const profileSecurity = 'profile_security';
  static const profileBilling = 'profile_billing';
  static const profileSubscriptionManage = 'profile_subscription_manage';
  static const settings = 'settings';
  static const privacyPolicy = 'privacy_policy';
  static const termsOfService = 'terms_of_service';

  static const authPath = '/auth';
  static const registerPath = '/register';
  static const homePath = '/home';
  static const consultationPath = '/consultation';
  static const consultationChatThreadIdParam = 'threadId';
  static const consultationChatPath =
      '/consultation/chat/:$consultationChatThreadIdParam';
  static const consultationStitchDetailPath = '/consultation/stitch-detail';
  static const consultationOpinionDetailPath = '/consultation/opinion-detail';
  static const caseUploadPath = '/cases/upload';
  static const caseDetailPath = '/cases/detail';
  static const analysisDetailPath = '/analysis/detail';
  static const analysisResultPath = '/analysis/result';
  static const dashboardPath = '/dashboard';
  static const documentGeneratePath = '/document/generate';
  static const documentPreviewPath = '/document/preview';
  static const savedDocumentsPath = '/document/saved';
  static const savedDocumentIdParam = 'documentId';
  static const savedDocumentDetailPath =
      '/document/saved/:$savedDocumentIdParam';
  static const legalSearchPath = '/search';
  static const legalArticlePath = '/search/article';
  static const inAppWebViewPath = '/webview';
  static const historyPath = '/history';
  static const historySearchPath = '/history/search';
  static const profilePath = '/profile';
  static const profilePersonalInfoPath = '/profile/personal-info';
  static const profileSecurityPath = '/profile/security';
  static const profileBillingPath = '/profile/billing';
  static const profileSubscriptionManagePath = '/profile/subscription/manage';
  static const settingsPath = '/settings';
  static const privacyPolicyPath = '/legal/privacy-policy';
  static const termsOfServicePath = '/legal/terms-of-service';
}
