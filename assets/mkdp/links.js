// 让预览页里的 http(s) 外链在新标签页打开，避免导航走预览页后回退命中 404。
// 用捕获阶段的事件委托，兼容 socket 刷新后动态重渲染的内容。
document.addEventListener('click', function (e) {
  var a = e.target.closest && e.target.closest('a[href]')
  if (!a) return
  var href = a.getAttribute('href') || ''
  if (/^https?:\/\//i.test(href)) {
    e.preventDefault()
    window.open(href, '_blank', 'noopener')
  }
}, true)
