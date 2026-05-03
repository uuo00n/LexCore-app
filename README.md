# LexCore App

![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11.1+-0175C2?logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/State-Riverpod-0E7AFE)
![go_router](https://img.shields.io/badge/Routing-go__router-4B32C3)
![License](https://img.shields.io/badge/License-AGPL--3.0--only-A42E2B)

衡法智核 LexCore 的 Flutter 客户端，面向法律咨询、文书生成、案件分析、法规检索、历史记录和个人中心等移动端场景。

当前客户端已从 mock 页面推进到真实后端 API 接入阶段，通过统一 `{ code, message, data }` 响应包络对接 LexCore Backend。

## 目录
- [项目评估](#assessment)
- [核心特性](#features)
- [技术栈](#tech-stack)
- [架构概览](#architecture)
- [快速开始](#quickstart)
- [常用开发命令](#dev-commands)
- [接口与后端协作](#api-contract)
- [功能模块](#modules)
- [质量门禁](#quality-gates)
- [上线落地建议](#production-readiness)
- [贡献与许可证](#contribution-license)

<a id="assessment"></a>
## 项目评估（2026-05-04）

### 已具备的能力
- 统一网络层：`ApiClient` + Dio + token 拦截器 + `{ code, message, data }` 解包。
- 真实后端联调：认证、文书、PDF、法规、裁判文书检索、历史记录等链路已接入 `/api/v1`。
- 文书闭环：支持生成任务、保存列表、详情轮询、Markdown 编辑、PDF 导出与系统分享。
- 法规检索：支持本地法规目录 `/laws`、法规详情、原文 WebView 预览与裁判文书上游检索。
- 移动端能力：语音检索、头像选择、通知权限、生物识别、缓存状态和帮助支持页已落地。
- 工程约束：主题颜色使用和 mock/demo 残留均有脚本检查。

### 当前主要缺口
- 认证态启动恢复、token 刷新失败后的全局重定向还需补强。
- 咨询会话与案件分析仍需继续打通完整后端业务闭环。
- 移动端发布材料、签名、图标、渠道包和隐私合规清单尚未完善。
- 关键业务路径还可以继续增加端到端测试和真机回归记录。

<a id="features"></a>
## 核心特性
- 认证鉴权：登录、注册、token 本地存储与接口鉴权。
- 文书服务：文书生成、状态轮询、详情查看、编辑保存、PDF 导出与分享。
- 法规检索：法规目录、裁判文书检索、语音输入、法规详情和原文预览。
- 咨询与案件：咨询列表、会话页、咨询详情、案件上传、案件看板与分析页。
- 个人中心：个人资料、头像、手机号规范化、账单、订阅、安全与设置入口。
- 系统设置：通知权限、生物识别、缓存状态、帮助支持、关于页、隐私政策和服务条款。
- 可维护性：Feature-First 分层结构、Riverpod 状态编排、共享组件和主题约束。

<a id="tech-stack"></a>
## 技术栈

| 分类 | 技术 |
| --- | --- |
| Framework | Flutter |
| Language | Dart `^3.11.1` |
| State | Riverpod |
| Routing | go_router + StatefulShellRoute |
| Network | Dio |
| Storage | shared_preferences |
| Native | image_picker, file_picker, local_auth, permission_handler, speech_to_text, share_plus, webview_flutter |
| UI | Material 3, TDesign Flutter, google_fonts, flutter_markdown, shimmer |
| Codegen | freezed, json_serializable, build_runner |

<a id="architecture"></a>
## 架构概览

```text
Flutter App
   |
   |-- app/      路由、导航、DI、动效、自适应容器
   |-- core/     网络、存储、错误、导出、常量、工具
   |-- shared/   共享组件、模型、静态 UI 配置
   |
   v
Feature Modules
   |-- presentation  页面与 Widget
   |-- application   Riverpod controller/provider
   |-- data          repository 与后端 API 适配
   |-- domain        领域实体与状态对象
   |
   v
LexCore Backend /api/v1
```

<a id="quickstart"></a>
## 快速开始

### 1) 准备环境
- Flutter Stable
- Dart SDK `^3.11.1`
- 已启动的 LexCore Backend（默认 API 前缀：`/api/v1`）

### 2) 安装依赖
```bash
flutter pub get
```

### 3) 运行项目
```bash
# Web 本地联调，显式指定后端地址
flutter run -d chrome --dart-define=BASE_API_URL=http://localhost:8000/api/v1

# Android 模拟器默认回退到 http://10.0.2.2:8000/api/v1
flutter run -d <android_device_id>

# 真机/桌面建议显式指定可访问的后端地址
flutter run -d <device_id> --dart-define=BASE_API_URL=http://<server-ip>:8000/api/v1
```

API 地址解析规则见 `lib/core/constants/app_constants.dart`：

| 平台 | 未指定 `BASE_API_URL` 时的默认值 |
| --- | --- |
| Web | `/api/v1` |
| Android 模拟器 | `http://10.0.2.2:8000/api/v1` |
| iOS/桌面/其他 | `http://115.190.4.230:8000/api/v1` |

<a id="dev-commands"></a>
## 常用开发命令

```bash
# 静态检查
flutter analyze

# 测试
flutter test

# 代码格式化
dart format lib test

# 代码生成（freezed/json）
dart run build_runner build --delete-conflicting-outputs

# 主题约束检查
./tool/check_theme_usage.sh

# mock/demo 残留检查
./tool/check_no_mock_data.sh
```

<a id="api-contract"></a>
## 接口与后端协作

- Base URL 通过 `--dart-define=BASE_API_URL=...` 指定，默认指向后端 `/api/v1`。
- 所有接口按 `{ code, message, data }` 解包；非 `OK` 会映射为 `AppException`。
- Dio 请求会自动读取本地 token 并附加 `Authorization: Bearer <token>`。
- 文书生成是异步任务：App 创建任务后进入详情页轮询状态，`completed` 后允许编辑、导出和分享。
- 法规详情可能返回 HTML/PDF/DOCX/来源链接，App 会通过内置 WebView 或系统能力打开。
- 裁判文书检索走后端 `/search/cases`，不可用时会降级为法规库检索提示。

<a id="modules"></a>
## 功能模块

| 模块 | 路由/入口 | 当前能力 |
| --- | --- | --- |
| 认证 | `/auth`, `/register` | 登录、注册、token 本地存储与后续请求鉴权 |
| 首页 | `/home` | 快捷入口、最近活动、主导航承载 |
| 咨询 | `/consultation`, `/consultation/chat/:threadId` | 咨询列表、会话页、咨询详情与意见书详情展示 |
| 案件 | `/cases/upload`, `/cases/detail`, `/dashboard` | 案件上传、分析详情、案件看板 |
| 文书 | `/document/generate`, `/document/preview`, `/document/saved`, `/document/saved/:documentId` | 文书生成、草稿预览、保存列表、详情轮询、编辑、PDF 导出与分享 |
| 法规/检索 | `/search`, `/search/article`, `/webview` | 法规目录检索、裁判文书检索、语音检索、法规详情与原文预览 |
| 历史记录 | `/history` | 历史列表、筛选、关键事件记录 |
| 个人中心 | `/profile` 及订阅/账单/安全子页面 | 个人资料、头像、手机号规范化、账单、订阅管理 |
| 设置 | `/settings`, `/settings/help-support`, `/about` | 通知、生物识别、缓存状态、帮助支持、关于页 |
| 法务文档 | `/legal/privacy-policy`, `/legal/terms-of-service` | 内置 Markdown 隐私政策与用户服务协议 |

<a id="quality-gates"></a>
## 质量门禁

提交前建议至少执行：

```bash
flutter analyze
flutter test
./tool/check_theme_usage.sh
./tool/check_no_mock_data.sh
```

当前测试覆盖包括路由导航、主题约束、认证页、咨询、案件、文书、法规检索、语音搜索、历史记录、个人资料、设置页、WebView 和共享组件。

<a id="production-readiness"></a>
## 上线落地建议

上线前最低建议：
1. 完成认证态恢复、刷新失败处理和全局登录态保护。
2. 补齐咨询会话、案件分析与订阅权益的完整后端联调。
3. 完成移动端应用图标、签名、渠道包、隐私弹窗与权限说明。
4. 建立真机回归清单，覆盖 Android/iOS/Web 的关键链路。
5. 接入 CI：`flutter analyze + flutter test + README/协议检查`。

<a id="contribution-license"></a>
## 贡献与许可证

### 贡献
- 推荐流程：`feature branch -> PR -> review -> merge`。
- 提交规范：Conventional Commits（`feat`/`fix`/`refactor`/`test`/`docs`/`chore`）。
- PR 建议包含：变更摘要、影响模块/路由、UI 截图、`flutter analyze` 与 `flutter test` 结果。

### 许可证
本项目采用 GNU Affero General Public License v3.0 only（`AGPL-3.0-only`）。

任何商业化使用、网络部署、修改、再分发或衍生作品发布，均需遵守 AGPL-3.0-only 的全部条款；如需其他授权，请先取得项目版权所有者的书面许可。
