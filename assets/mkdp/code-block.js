// 为预览页里的代码块补一个顶部栏：左侧显示语言，右侧提供复制按钮。
// 页面内容通过 socket 刷新时会重新渲染，因此用 MutationObserver 持续补齐。
(function () {
  var WRAP = 'md-code-block'

  function languageOf(pre) {
    var code = pre.querySelector('code')
    var source = code || pre
    var match = (source.className || '').match(/language-([\w+#-]+)/)
    return match ? match[1] : ''
  }

  var COPY_ICON =
    '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>'
  var CHECK_ICON =
    '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>'

  function copy(text, button) {
    var done = function () {
      button.innerHTML = CHECK_ICON
      button.classList.add('copied')
      setTimeout(function () {
        button.innerHTML = COPY_ICON
        button.classList.remove('copied')
      }, 1500)
    }
    var fallback = function () {
      var area = document.createElement('textarea')
      area.value = text
      document.body.appendChild(area)
      area.select()
      document.execCommand('copy')
      area.remove()
      done()
    }
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).then(done, fallback)
      return
    }
    fallback()
  }

  function trimTrailing(pre) {
    var walker = document.createTreeWalker(pre, NodeFilter.SHOW_TEXT)
    var nodes = []
    while (walker.nextNode()) nodes.push(walker.currentNode)
    for (var i = nodes.length - 1; i >= 0; i--) {
      nodes[i].textContent = nodes[i].textContent.replace(/\s+$/, '')
      if (nodes[i].textContent !== '') break
    }
  }

  function decorate(pre) {
    if (pre.parentElement && pre.parentElement.classList.contains(WRAP)) return
    trimTrailing(pre)

    var wrap = document.createElement('div')
    wrap.className = WRAP

    var bar = document.createElement('div')
    bar.className = 'md-code-header'

    var lang = document.createElement('span')
    lang.className = 'md-code-lang'
    lang.textContent = languageOf(pre)

    var button = document.createElement('button')
    button.type = 'button'
    button.className = 'md-code-copy'
    button.title = '复制'
    button.setAttribute('aria-label', '复制')
    button.innerHTML = COPY_ICON
    button.addEventListener('click', function () {
      var code = pre.querySelector('code') || pre
      copy(code.innerText.replace(/\n$/, ''), button)
    })

    bar.appendChild(lang)
    bar.appendChild(button)
    pre.parentNode.insertBefore(wrap, pre)
    wrap.appendChild(bar)
    wrap.appendChild(pre)
  }

  function scan() {
    document.querySelectorAll('.markdown-body pre').forEach(decorate)
  }

  new MutationObserver(scan).observe(document.documentElement, { childList: true, subtree: true })
  scan()
})()
