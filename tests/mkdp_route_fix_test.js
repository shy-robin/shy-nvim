// 运行：node tests/mkdp_route_fix_test.js  （从仓库根目录）
// 验证 route-fix.js 的 replaceState 拦截逻辑：
//   - 裸 /<数字>  →  /page/<数字>
//   - 已是 /page/<数字>  →  原样
//   - 其它路径  →  原样
const assert = require('assert')
const fs = require('fs')
const path = require('path')

// 用一个能记录最终 url 的桩替换 history.replaceState
const calls = []
global.history = {
  replaceState: function (state, title, url) {
    calls.push(url)
  },
}

// 加载并执行 route-fix.js（IIFE，引用全局 history）
const src = fs.readFileSync(path.join(__dirname, '..', 'assets', 'mkdp', 'route-fix.js'), 'utf8')
// eslint-disable-next-line no-eval
eval(src)

function lastUrl() {
  return calls[calls.length - 1]
}

history.replaceState(null, '', '/14')
assert.strictEqual(lastUrl(), '/page/14', 'bare /14 should become /page/14')

history.replaceState(null, '', '/9')
assert.strictEqual(lastUrl(), '/page/9', 'bare /9 should become /page/9')

history.replaceState(null, '', '/page/14')
assert.strictEqual(lastUrl(), '/page/14', '/page/14 should be unchanged')

history.replaceState(null, '', '/foo')
assert.strictEqual(lastUrl(), '/foo', 'non-numeric path should be unchanged')

history.replaceState(null, '', '/14/extra')
assert.strictEqual(lastUrl(), '/14/extra', 'non-terminal numeric path should be unchanged')

console.log('OK mkdp route-fix replaceState')
