# 一级标题 H1 Heading

这是一段普通正文，包含 **粗体**、*斜体*、***粗斜体***、~~删除线~~、==高亮==、`行内代码` 和 [普通链接](https://github.com)。中英文混排 mixed with English text，数字 123 和标点符号（括号）“引号” 也要看清楚。

这是第二段，用来观察段落之间的间距。段落里可以有很长很长的一行文字，用来测试自动换行和行宽，直到超过一般阅读宽度为止，看看右侧边界和行高是否舒服。

## 二级标题 H2 Heading

### 三级标题 H3 Heading

#### 四级标题 H4 Heading

##### 五级标题 H5 Heading

###### 六级标题 H6 Heading

---

## 引用 Blockquote

> 这是一段单层引用。好的排版应该让读者忘记排版本身。
>
> 这是同一引用里的第二段。

> 外层引用
>
> > 内层嵌套引用
> >
> > - 引用中的列表
> > - 第二项

> **注意：** 引用中可以包含 `代码`、[链接](https://example.com) 和 *强调*。

## 列表 Lists

### 无序列表

- 第一项
- 第二项，较长的内容用来测试换行与对齐，看看多行文字缩进是否整齐，是否与上一行对齐
- 第三项
  - 子项 A
  - 子项 B
    - 孙项 B-1
    - 孙项 B-2
- 第四项

### 有序列表

1. 第一步：备份原有配置
2. 第二步：克隆仓库
   1. 子步骤 2.1
   2. 子步骤 2.2
3. 第三步：启动 `nvim`
10. 从 10 开始的编号

### 任务列表

- [x] 已完成的任务
- [ ] 未完成的任务
- [ ] 嵌套任务
  - [x] 子任务已完成
  - [ ] 子任务未完成

### 定义列表式写法

术语 A
: 定义 A 的解释文字。

术语 B
: 定义 B 的解释文字。

## 表格 Tables

### 普通表格

| 功能 | 快捷键 | 描述 |
| --- | --- | --- |
| 搜索文件 | `:FzfLua files` | 在当前工作目录启动文件选择器 |
| 搜索文本 | `:FzfLua live_grep` | 在当前工作目录启动实时文本搜索 |
| 隐藏 fzf-lua | `Esc` | 隐藏当前 picker |

### 对齐表格

| 左对齐 | 居中对齐 | 右对齐 |
| :--- | :---: | ---: |
| apple | 1 | $3.00 |
| banana | 22 | $12.50 |
| cherry | 333 | $120.75 |

### 长表格（测试横向溢出）

| 列一 | 列二 | 列三 | 列四 | 列五 | 列六 | 列七 | 列八 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| a1 | b1 | c1 | d1 | e1 | f1 | g1 | h1 |
| a2 | b2 | c2 | d2 | e2 | f2 | g2 | h2 |

## 代码块 Code Blocks

### 带语言标记

```lua
local function greet(name)
  -- 注释：打印问候语
  print("hello, " .. name)
end

greet("world")
```

```python
def fib(n: int) -> int:
    """返回第 n 个斐波那契数。"""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

print([fib(i) for i in range(10)])
```

```javascript
const sum = (...xs) => xs.reduce((a, b) => a + b, 0)
console.log(sum(1, 2, 3)) // 6
```

```typescript
interface User {
  id: number
  name: string
  tags?: string[]
}
```

```shell
mv ~/.config/nvim ~/.config/nvim.bak
git clone --depth 1 --branch nvim-0.11 https://github.com/shy-robin/shy-nvim ~/.config/nvim
nvim
```

```json
{
  "name": "shy-nvim",
  "version": "0.11.0",
  "private": true
}
```

```diff
- old line removed
+ new line added
  unchanged line
```

```css
.markdown-body pre {
  padding: 16px;
  border-radius: 8px;
}
```

### 无语言标记

```
这是一个没有语言标记的代码块。
用来测试顶部栏在没有语言时的显示效果。
```

### 长行代码（测试横向滚动）

```text
git clone --depth 1 --branch nvim-0.11 https://github.com/shy-robin/shy-nvim.git ~/.config/nvim && echo "this is a very long line to test horizontal overflow behaviour in the code block"
```

### 缩进代码块

    这是四个空格缩进的代码块。
    第二行。

## 图片 Images

![示例图片占位](https://picsum.photos/seed/markdown/640/240)

## 键盘与标记 Keyboard and Marks

按 <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> 打开命令面板，或者使用 <kbd>Esc</kbd> 退出。

<mark>这段文字用 HTML mark 标签高亮</mark>，<sub>下标</sub> 与 <sup>上标</sup> 也要检查。

## 折叠块 Details

<details>
<summary>点击展开：更多细节</summary>

这里是折叠内容，可以包含 **粗体**、`代码` 和列表：

- 折叠中的列表项 1
- 折叠中的列表项 2

</details>

## 脚注 Footnotes

这里有一个脚注引用[^1]，还有另一个[^note]。

[^1]: 这是第一条脚注的内容。
[^note]: 这是带名字的脚注内容。

## 数学公式 Math

行内公式：$E = mc^2$，以及 $\sum_{i=1}^{n} i = \frac{n(n+1)}{2}$。

块级公式：

$$
\int_0^\infty e^{-x^2}\,dx = \frac{\sqrt{\pi}}{2}
$$

## 转义与特殊字符 Escapes

\*这不是斜体\*，\`这不是代码\`，\# 这不是标题。

特殊符号：&copy; &amp; &lt;tag&gt; — 破折号、… 省略号、© ® ™、emoji 🚀 ✨ 📄

## 链接变体 Link Variants

- 自动链接：<https://neovim.io>
- 带标题的链接：[Neovim](https://neovim.io "Neovim 官网")
- 引用式链接：[参考链接][ref]
- 锚点链接：[回到一级标题](#一级标题-h1-heading)

[ref]: https://github.com/neovim/neovim

## 段落与换行

第一行结尾有两个空格，  
所以这里会强制换行。

这是一个很长的单词：Supercalifragilisticexpialidocious-Supercalifragilisticexpialidocious-Supercalifragilisticexpialidocious，用来测试长单词是否会撑破布局。

---

## 结束

这是最后一段正文，用来观察文档末尾的留白和底部间距。
