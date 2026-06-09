// markdown-preview.nvim 的前端会在 startSocket 里执行
//   history.replaceState(null, '', '/' + bufnr)
// 把地址栏从 /page/<bufnr> 改成 /<bufnr>。但服务端只路由 /page/\d+，
// 且 componentDidMount 用 location.pathname.split('/')[2] 解析 bufnr，
// 所以刷新或回退到 /<bufnr> 时会 404、且无法解析 bufnr。
// 这里拦截 replaceState：把裸 /<数字> 的目标地址改回 /page/<数字>，
// 保持地址栏始终是可被服务端路由、也能被前端正确解析的形式。
// 本脚本以同步方式注入在 <head> 顶部，保证在前端 hydration 之前装好拦截。
(function () {
  var original = history.replaceState.bind(history)
  history.replaceState = function (state, title, url) {
    if (typeof url === 'string') {
      var m = url.match(/^\/(\d+)$/)
      if (m) {
        url = '/page/' + m[1]
      }
    }
    return original(state, title, url)
  }
})()
