// 让预览页里的 http(s) 外链在新标签页打开，避免导航走预览页后回退命中 404。
// 本地相对路径（如 ../foo.md）无法在浏览器中打开，拦截跳转并提示，同时复制路径方便在 nvim 中 :e 打开。
// 用捕获阶段的事件委托，兼容 socket 刷新后动态重渲染的内容。
(function () {
  function copy(text) {
    var fallback = function () {
      var area = document.createElement('textarea')
      area.value = text
      document.body.appendChild(area)
      area.select()
      document.execCommand('copy')
      area.remove()
    }
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).catch(fallback)
      return
    }
    fallback()
  }

  function notify(message) {
    var old = document.getElementById('md-link-notice')
    if (old) old.remove()
    var box = document.createElement('div')
    box.id = 'md-link-notice'
    box.textContent = message
    box.style.cssText =
      'position:fixed;left:50%;bottom:24px;transform:translateX(-50%);z-index:1000;' +
      'max-width:80vw;padding:8px 14px;border-radius:6px;background:#1f1f1f;color:#fff;' +
      'font:13px/1.5 -apple-system,BlinkMacSystemFont,"PingFang SC",sans-serif;' +
      'box-shadow:0 2px 8px rgba(0,0,0,.25);transition:opacity .3s'
    document.body.appendChild(box)
    setTimeout(function () {
      box.style.opacity = '0'
      setTimeout(function () {
        box.remove()
      }, 300)
    }, 3000)
  }

  document.addEventListener('click', function (e) {
    var a = e.target.closest && e.target.closest('a[href]')
    if (!a) return
    var href = a.getAttribute('href') || ''
    if (/^https?:\/\//i.test(href)) {
      e.preventDefault()
      window.open(href, '_blank', 'noopener')
      return
    }
    if (href === '' || href.charAt(0) === '#' || /^[a-z][a-z0-9+.-]*:/i.test(href)) return
    e.preventDefault()
    copy(href)
    notify('本地文件无法在浏览器中打开：' + href + '（路径已复制，可在 nvim 中 :e 打开）')
  }, true)
})()
