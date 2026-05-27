# dotfiles

由 [chezmoi](https://chezmoi.io) 管理，一键部署开发环境。

## 新机器初始化

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
chezmoi init --apply LING-LITONG
```

首次运行会提示输入 git name/email，然后自动安装 zsh、neovim、lazygit 等工具。

## 已有机器同步

```bash
chezmoi update
```

## 日常使用

```bash
# 本地修改后推送到 GitHub
chezmoi cd              # 进入源目录
git add -A && git commit -m "..."
git push
chezmoi exit            # 返回原目录

# 或一步到位
chezmoi edit ~/.zshrc   # 编辑并自动应用
chezmoi diff            # 查看变更
chezmoi apply           # 手动应用
```

## 包含的配置

- zsh (oh-my-zsh + powelevel10k + 插件)
- tmux
- neovim (LazyVim)
- lazygit
- git
