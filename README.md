# Moli Kit

Moli 各仓库共用的、可以公开的 GitHub Actions 步骤：密钥扫描、CI 汇总、部署。

![ci](https://github.com/MoliDuo/MoliKit/actions/workflows/ci.yml/badge.svg)
![release](https://img.shields.io/github/v/release/MoliDuo/MoliKit)
![license](https://img.shields.io/badge/license-All%20rights%20reserved-lightgrey)

## 功能

放在 `actions/` 下，每个是一个独立的步骤，用 `uses:` 引用：

| 步骤 | 做什么 |
|---|---|
| `actions/verified` | 推送到 `main` 时，查这个提交是否已被合并队列测过，输出 `skip`，避免重复检查 |
| `actions/ci-gate` | 汇总其他任务的结果，任何一个失败、取消或意外跳过就失败 |
| `actions/gitleaks` | 用官方镜像扫描全部历史里的密钥 |
| `actions/deploy` | 只在该提交仍是 main 最新时：构建镜像，临时加入内网，经 SSH 送到服务器并部署；不是最新就跳过 |
| `actions/auto-merge` | 给 PR 打开自动合并（以专用 App 的身份），绿了就自动进合并队列 |

## 安装或访问

不用安装。在应用仓库的 workflow 里引用，**固定到提交哈希**，后面注释版本号，Dependabot 会按月提醒升级：

```yaml
- uses: MoliDuo/MoliKit/actions/gitleaks@<提交哈希> # vX.Y.Z
```

CI 里的完整用法（`verified` 和 `ci-gate` 配合，任务名固定）：

```yaml
jobs:
  verified:
    runs-on: ubuntu-latest
    permissions:
      actions: read
    outputs:
      skip: ${{ steps.queue.outputs.skip }}
    steps:
      - id: queue
        uses: MoliDuo/MoliKit/actions/verified@<提交哈希> # vX.Y.Z

  check:
    needs: verified
    if: needs.verified.outputs.skip != 'true'
    # 各应用自己的检查步骤

  ci-gate:
    if: always()
    needs: [verified, check, gitleaks]   # 列出所有任务
    runs-on: ubuntu-latest
    steps:
      - uses: MoliDuo/MoliKit/actions/ci-gate@<提交哈希> # vX.Y.Z
        with:
          needs: ${{ toJSON(needs) }}
```

部署（接在 `ci` 成功之后，密钥由应用仓库传入，用法见各输入的说明）：

```yaml
- uses: MoliDuo/MoliKit/actions/deploy@<提交哈希> # vX.Y.Z
  with:
    app: cashier
    sha: ${{ github.event.workflow_run.head_sha }}
    host-key: "ssh-ed25519 …"
    server: ${{ secrets.DEPLOY_SERVER }}
    server-user: ${{ secrets.DEPLOY_SERVER_USER }}
    ssh-key: ${{ secrets.DEPLOY_SSH_KEY }}
    tailscale-client-id: ${{ secrets.DEPLOY_TAILSCALE_CLIENT_ID }}
    tailscale-client-secret: ${{ secrets.DEPLOY_TAILSCALE_CLIENT_SECRET }}
```

## 登录方式

无。这里只有 CI 步骤，没有应用。

## 部署

无。引用它的应用各自部署，见规范 005。

## 开发

```bash
./scripts/check.sh   # 需要 Docker 和带 PyYAML 的 Python
```

这些步骤没法在本机运行：改动后开 PR，看 `ci` 的结果；引用方仓库通过自己的 PR 试用新版本。**不要改步骤的名字、输入和输出**，各仓库依赖它们，只增不改。**这是公开仓库，不放服务器地址、用户名、主机名、密钥**，这些由引用方传入。

## 许可

版权所有，保留一切权利（见 [LICENSE](LICENSE)）。仓库公开只是为了让其他 Moli 仓库能引用。
