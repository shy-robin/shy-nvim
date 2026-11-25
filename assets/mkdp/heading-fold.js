// 点击标题左侧的级别徽章，折叠或展开该标题下的内容（直到下一个同级或更高级标题）。
// 使用事件委托，兼容 socket 刷新后重新渲染的内容。
(function () {
  var SELECTOR = '.markdown-body h1, .markdown-body h2, .markdown-body h3, .markdown-body h4, .markdown-body h5, .markdown-body h6'
  var HEADING = /^H[1-6]$/

  function level(el) {
    return Number(el.tagName.substr(1))
  }

  function toggle(heading) {
    var folded = !heading.classList.contains('md-folded')
    heading.classList.toggle('md-folded', folded)
    var current = level(heading)
    var el = heading.nextElementSibling
    while (el && !(HEADING.test(el.tagName) && level(el) <= current)) {
      el.classList.toggle('md-fold-hidden', folded)
      el = el.nextElementSibling
    }
  }

  document.addEventListener('click', function (event) {
    var heading = event.target.closest && event.target.closest(SELECTOR)
    if (!heading) return
    var rect = heading.getBoundingClientRect()
    if (event.clientX >= rect.left + parseFloat(getComputedStyle(heading).paddingLeft)) return
    toggle(heading)
  }, true)
})()
