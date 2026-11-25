// 点击标题即可复制该标题的链接（替代原来的锚点图标）。
// 使用事件委托，兼容 socket 刷新后重新渲染的内容。
(function () {
  var TIP = '链接已复制'

  function copy(text, heading) {
    var done = function () {
      heading.setAttribute('data-copied', TIP)
      heading.classList.add('md-heading-copied')
      setTimeout(function () {
        heading.classList.remove('md-heading-copied')
      }, 1200)
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

  document.addEventListener('click', function (event) {
    var heading = event.target.closest && event.target.closest('.markdown-body h1, .markdown-body h2, .markdown-body h3, .markdown-body h4, .markdown-body h5, .markdown-body h6')
    if (!heading || !heading.id) return
    if (window.getSelection && window.getSelection().toString()) return
    var rect = heading.getBoundingClientRect()
    if (event.clientX < rect.left + parseFloat(getComputedStyle(heading).paddingLeft)) return
    var base = window.location.href.split('#')[0]
    copy(base + '#' + heading.id, heading)
  })
})()
