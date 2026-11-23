// 让预览页顶部的 Dark Mode 开关常驻显示。
// 原生开关只在鼠标悬浮到标题栏时才渲染，这里在标题栏里补一个常驻开关，
// 直接切换 main[data-theme]，并与原生开关的状态保持同步。
(function () {
  var ID = 'md-theme-toggle'

  function sync(main, input) {
    input.checked = main.getAttribute('data-theme') === 'dark'
  }

  function init() {
    var header = document.getElementById('page-header')
    var main = document.querySelector('main')
    if (!header || !main || document.getElementById(ID)) return

    var label = document.createElement('label')
    label.id = ID
    label.setAttribute('for', ID + '-input')

    var input = document.createElement('input')
    input.type = 'checkbox'
    input.id = ID + '-input'

    var text = document.createElement('span')
    text.textContent = 'Dark Mode'

    label.appendChild(input)
    label.appendChild(text)
    header.appendChild(label)

    sync(main, input)
    input.addEventListener('change', function () {
      main.setAttribute('data-theme', input.checked ? 'dark' : 'light')
    })
    new MutationObserver(function () {
      sync(main, input)
    }).observe(main, { attributes: true, attributeFilter: ['data-theme'] })
  }

  new MutationObserver(init).observe(document.documentElement, { childList: true, subtree: true })
  init()
})()
