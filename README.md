<div align="center">
  <h1>衡法智核 LexCore</h1>
  <p>基于 Flutter 的智能法律服务平台客户端</p>
  <p>
    <img alt="Flutter" src="https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white" />
    <img alt="Dart" src="https://img.shields.io/badge/Dart-3.11.1+-0175C2?logo=dart&logoColor=white" />
    <img alt="State" src="https://img.shields.io/badge/State-Riverpod-0E7AFE" />
    <img alt="Routing" src="https://img.shields.io/badge/Routing-go__router-4B32C3" />
    <img alt="Architecture" src="https://img.shields.io/badge/Architecture-Feature--First-2E8B57" />
  </p>
  <p>
    <a href="#快速开始">快速开始</a> ·
    <a href="#功能一览">功能一览</a> ·
    <a href="#开发命令">开发命令</a> ·
    <a href="#贡献">贡献</a>
  </p>
</div>

LexCore 是一个面向法律场景的移动端应用，聚焦法律咨询、文档生成、案件分析、法条检索、历史记录与个人中心等能力。当前仓库以 Flutter 客户端为主，默认接入 mock 数据层，便于快速迭代页面和交互流程。

## Why LexCore
- 业务聚焦：围绕法律服务核心链路组织功能模块。
- 架构清晰：采用 Feature-First + 分层（presentation/application/data/domain）。
- 迭代友好：路由、主题、共享组件与 mock 数据解耦，便于并行开发。

## 功能一览
| 模块 | 路由/入口 | 说明 |
| --- | --- | --- |
| 认证 | `/auth` `/register` | 登录与注册 |
| 首页 | `/home` | 快捷入口、最近活动 |
| 咨询 | `/consultation` | 法律咨询会话 |
| 案件分析 | `/analysis/detail` `/analysis/result` | 分析详情与结果 |
| 文档中心 | `/document/generate` `/document/preview` `/document/saved` | 文档生成、预览、已保存 |
| 法条检索 | `/search` `/search/article` | 检索与条文详情 |
| 历史记录 | `/history` | 咨询/分析/文档历史 |
| 个人中心 | `/profile` 及子页面 | 个人信息、安全、账单、设置 |
| 法务文档 | `/legal/privacy-policy` `/legal/terms-of-service` | 隐私政策与服务条款 |

## 快速开始
### 环境要求
- Flutter Stable（建议与项目 Dart 约束匹配）
- Dart SDK `^3.11.1`

### 安装依赖
```bash
flutter pub get
```

### 运行项目
```bash
flutter run -d chrome
# 或 flutter run -d <device_id>
```

## 开发命令
```bash
# 静态检查
flutter analyze

# 测试
flutter test

# 代码格式化
dart format lib test

# 代码生成（freezed/json）
flutter pub run build_runner build --delete-conflicting-outputs
```

## 项目结构
```text
lib/
  app/                 # 应用入口、路由、导航、主题与动效
  core/                # 常量、网络、存储、错误、工具与扩展
  shared/              # 共享组件、模型、mock 服务
  features/
    <feature>/
      presentation/    # 页面与 UI
      application/     # provider / use case 编排
      data/            # repository 实现
      domain/          # 领域实体

test/                  # widget/unit tests
assets/                # 图片与图标
tool/                  # 工程脚本（如主题约束检查）
```

## 工程约束
- 颜色单一真源：`lib/theme.dart`
- `lib/` 下仅允许颜色来源：`Theme.of(context).colorScheme` 与 `context.tokens`
- 禁止在 `lib/`（`lib/theme.dart` 除外）中使用：`AppColors`、`AppTheme`、`Colors.*`、`Color(...)`
- 自动检查脚本：`./tool/check_theme_usage.sh`

## 质量门禁
提交 PR 前建议至少执行：

```bash
flutter analyze
flutter test
./tool/check_theme_usage.sh
```

## 技术栈
- Framework: Flutter
- Language: Dart
- State Management: Riverpod
- Routing: go_router
- Networking: Dio
- Persistence: shared_preferences
- Serialization: freezed + json_serializable
- UI: Material 3 + google_fonts

## 贡献
- 提交规范：Conventional Commits（`feat`/`fix`/`refactor`/`test`/`docs`/`chore`）
- PR 建议包含：变更摘要、影响模块/路由、UI 截图、`flutter analyze` 与 `flutter test` 结果
- 问题反馈：请优先通过 Issue 描述复现步骤与期望行为

## Roadmap
- 接入真实后端 API 与鉴权流程
- 完善文档模块（编辑/导出/分享）
- 增加更多业务层单测与关键页面回归测试
- 补齐发布与版本管理文档

## License
当前仓库未提供 `LICENSE` 文件。如需开源发布，请补充许可证后再对外分发。
