---
title: "Hugo日常使用指南"
date: 2024-12-06T17:30:00+08:00
draft: false
categories: ["技术"]
tags: ["Hugo", "部署", "教程"]
cover: "/images/default1.jpg"
---
# Hugo 日常使用指南
## 一、基本操作
1. **创建新文章**
```bash
# 创建新文章
hugo new posts/my-new-post.md
# 或者指定类型
hugo new --kind post posts/my-new-post.md
```
2. **本地预览**
```bash
# 启动本地服务器
hugo server -D  # -D 参数会显示草稿

# 指定端口启动
hugo server -D --port 1313

# 允许局域网访问
hugo server -D --bind 0.0.0.0
```
## 二、文章前置参数（Front Matter）

```yaml
---
title: "文章标题"
date: 2024-12-06T15:30:00+08:00
draft: false
categories: ["分类"]
tags: ["标签1", "标签2"]
description: "文章描述"
featured_image: "/images/featured.jpg"
---
```
## 三、常用目录结构

```
my-blog/
├── archetypes/     # 模板目录
├── content/        # 内容目录
│   ├── posts/     # 文章
│   └── about/     # 关于页面
├── static/        # 静态文件
│   ├── images/    # 图片
│   └── css/       # 自定义样式
├── themes/        # 主题
└── config.toml    # 配置文件
```

## 四、常用命令

```bash
# 创建新站点
hugo new site my-blog

# 添加主题
git submodule add https://github.com/theme-author/theme-name.git themes/theme-name

# 生成静态文件
hugo

# 清理生成的文件
hugo --cleanDestinationDir

# 显示站点信息
hugo version
```

## 五、内容管理脚本

```bash
#!/bin/bash
# ~/manage_hugo.sh

# 配置
BLOG_DIR="$HOME/blog"
CONTENT_DIR="$BLOG_DIR/content/posts"
DRAFT_DIR="$BLOG_DIR/content/drafts"

# 创建新文章
create_post() {
    local title="$1"
    local date=$(date +%Y-%m-%d)
    local filename="${date}-${title}.md"
    
    cd "$BLOG_DIR"
    hugo new "posts/${filename}"
    echo "创建新文章: $filename"
}

# 发布草稿
publish_draft() {
    local draft="$1"
    if [ -f "$DRAFT_DIR/$draft" ]; then
        mv "$DRAFT_DIR/$draft" "$CONTENT_DIR/"
        sed -i 's/draft: true/draft: false/' "$CONTENT_DIR/$draft"
        echo "发布文章: $draft"
    fi
}

# 本地预览
preview() {
    cd "$BLOG_DIR"
    hugo server -D --bind 0.0.0.0
}

# 生成静态文件
build() {
    cd "$BLOG_DIR"
    hugo --cleanDestinationDir
    echo "生成完成"
}
```

## 六、文章模板

```markdown
# archetypes/post.md

---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: true
categories: []
tags: []
description: ""
featured_image: ""
---

## 简介

## 正文

## 总结

## 参考链接
```
## 七、部署脚本

```bash
#!/bin/bash
# ~/deploy_hugo.sh

# 配置
BLOG_DIR="$HOME/blog"
PUBLIC_DIR="$BLOG_DIR/public"
DEPLOY_DIR="/var/www/html"

# 生成静态文件
echo "生成静态文件..."
cd "$BLOG_DIR"
hugo --cleanDestinationDir

# 部署到服务器
echo "部署到服务器..."
rsync -avz --delete "$PUBLIC_DIR/" "$DEPLOY_DIR/"

# 设置权限
sudo chown -R www-data:www-data "$DEPLOY_DIR"
```

## 八、日常使用流程
1. **写新文章**
```bash
# 创建文章
hugo new posts/new-article.md

# 编辑文章
nano content/posts/new-article.md
```

2. **本地预览**
```bash
# 启动服务器
hugo server -D
```

3. **发布文章**
```bash
# 修改文章状态为非草稿
# 将 draft: true 改为 draft: false

# 生成静态文件
hugo

# 部署
./deploy_hugo.sh
```

## 九、使用建议
1. **文章组织**
- 使用清晰的目录结构
- 合理使用分类和标签
- 保持文件名规范
2. **图片管理**
- 使用相对路径
- 压缩图片大小
- 统一图片命名
3. **版本控制**
```bash
# 初始化 Git
git init

# 添加文件
git add .

# 提交更改
git commit -m "更新文章"

# 推送到远程
git push
```

