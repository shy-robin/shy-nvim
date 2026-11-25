// 点击预览页中的图片时全屏显示大图，点击任意位置或按 Esc 关闭。
// 被链接包裹的图片保持原有的链接行为；使用事件委托，兼容 socket 刷新后重新渲染的内容。
(function () {
  var OVERLAY_ID = 'md-image-viewer'

  function close() {
    var overlay = document.getElementById(OVERLAY_ID)
    if (overlay) overlay.remove()
    document.removeEventListener('keydown', onKey)
  }

  function onKey(event) {
    if (event.key === 'Escape') close()
  }

  function open(src, alt) {
    close()
    var overlay = document.createElement('div')
    overlay.id = OVERLAY_ID
    overlay.style.cssText =
      'position:fixed;inset:0;z-index:2000;display:flex;align-items:center;justify-content:center;' +
      'background:rgba(0,0,0,.85);cursor:zoom-out;padding:24px;box-sizing:border-box'

    var image = document.createElement('img')
    image.src = src
    image.alt = alt || ''
    image.style.cssText = 'max-width:100%;max-height:100%;object-fit:contain;border-radius:6px;box-shadow:0 8px 32px rgba(0,0,0,.4)'

    overlay.appendChild(image)
    overlay.addEventListener('click', close)
    document.body.appendChild(overlay)
    document.addEventListener('keydown', onKey)
  }

  document.addEventListener('click', function (event) {
    var image = event.target.closest && event.target.closest('.markdown-body img')
    if (!image || image.closest('a')) return
    if (!image.getAttribute('src')) return
    open(image.currentSrc || image.src, image.alt)
  }, true)
})()
