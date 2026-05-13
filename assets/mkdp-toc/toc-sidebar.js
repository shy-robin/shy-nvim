(function () {
  'use strict';

  var MIN_LEVEL = 1;
  var MAX_LEVEL = 4;
  var REBUILD_DEBOUNCE_MS = 120;

  var sidebar = null;
  var listEl = null;
  var emptyEl = null;
  var contentObserver = null;
  var spyObserver = null;
  var rebuildTimer = null;
  var idCounter = 0;
  var headingMap = new Map();
  var clickLockUntil = 0;

  function ensureSidebar() {
    if (sidebar) return sidebar;
    var main = document.querySelector('main');
    if (!main) return null;

    sidebar = document.createElement('aside');
    sidebar.id = 'mkdp-toc-sidebar';
    sidebar.setAttribute('aria-label', 'Table of contents');
    sidebar.innerHTML =
      '<div class="mkdp-toc-header">' +
      '<button class="mkdp-toc-toggle" type="button" aria-label="Toggle TOC">' +
      '<svg viewBox="0 0 16 16" width="14" height="14" aria-hidden="true">' +
      '<path fill="currentColor" d="M6.22 3.22a.75.75 0 011.06 0l4.25 4.25a.75.75 0 010 1.06l-4.25 4.25a.75.75 0 11-1.06-1.06L9.94 8 6.22 4.28a.75.75 0 010-1.06z"/>' +
      '</svg>' +
      '</button>' +
      '<span class="mkdp-toc-title">目录</span>' +
      '</div>' +
      '<nav class="mkdp-toc-list" role="navigation"></nav>' +
      '<div class="mkdp-toc-empty" hidden>暂无标题</div>';

    main.appendChild(sidebar);
    listEl = sidebar.querySelector('.mkdp-toc-list');
    emptyEl = sidebar.querySelector('.mkdp-toc-empty');

    sidebar.querySelector('.mkdp-toc-toggle').addEventListener('click', function () {
      document.body.classList.toggle('mkdp-toc-collapsed');
    });

    return sidebar;
  }

  function getHeadingText(h) {
    var clone = h.cloneNode(true);
    clone.querySelectorAll('.anchor, .octicon-link').forEach(function (n) {
      n.remove();
    });
    return clone.textContent.replace(/\s+/g, ' ').trim();
  }

  function ensureId(h) {
    if (h.id) return h.id;
    var slug = getHeadingText(h)
      .toLowerCase()
      .replace(/[^\w一-龥\- ]+/g, '')
      .replace(/\s+/g, '-')
      .slice(0, 64);
    var id = slug ? 'mkdp-toc-' + slug : 'mkdp-toc-h-' + ++idCounter;
    var base = id;
    var i = 1;
    while (document.getElementById(id)) {
      id = base + '-' + i++;
    }
    h.id = id;
    return id;
  }

  function buildToc() {
    if (!ensureSidebar()) return;
    var body = document.querySelector('.markdown-body');
    if (!body) return;

    var selector = [];
    for (var i = MIN_LEVEL; i <= MAX_LEVEL; i++) selector.push('h' + i);
    var headings = Array.prototype.slice.call(body.querySelectorAll(selector.join(',')));

    headingMap.clear();

    if (headings.length === 0) {
      listEl.innerHTML = '';
      emptyEl.hidden = false;
      teardownSpy();
      return;
    }
    emptyEl.hidden = true;

    var frag = document.createDocumentFragment();
    headings.forEach(function (h) {
      var level = parseInt(h.tagName.charAt(1), 10);
      var id = ensureId(h);
      var text = getHeadingText(h);
      if (!text) return;

      var item = document.createElement('a');
      item.className = 'mkdp-toc-item mkdp-toc-level-' + level;
      item.href = '#' + id;
      item.dataset.target = id;
      item.title = text;
      item.textContent = text;

      item.addEventListener('click', onItemClick);
      headingMap.set(id, item);
      frag.appendChild(item);
    });

    listEl.innerHTML = '';
    listEl.appendChild(frag);
    setupSpy(headings);
  }

  function onItemClick(e) {
    e.preventDefault();
    var id = this.dataset.target;
    var target = document.getElementById(id);
    if (!target) return;
    setActive(id);
    clickLockUntil = Date.now() + 600;
    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    history.replaceState(null, '', '#' + id);
  }

  function setActive(id) {
    headingMap.forEach(function (el, key) {
      el.classList.toggle('active', key === id);
    });
    var active = headingMap.get(id);
    if (active && sidebar) {
      var sb = sidebar.getBoundingClientRect();
      var ab = active.getBoundingClientRect();
      if (ab.top < sb.top + 40 || ab.bottom > sb.bottom - 40) {
        active.scrollIntoView({ block: 'nearest' });
      }
    }
  }

  function teardownSpy() {
    if (spyObserver) {
      spyObserver.disconnect();
      spyObserver = null;
    }
  }

  function setupSpy(headings) {
    teardownSpy();
    var visible = new Map();
    spyObserver = new IntersectionObserver(
      function (entries) {
        if (Date.now() < clickLockUntil) return;
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            visible.set(entry.target.id, entry.target);
          } else {
            visible.delete(entry.target.id);
          }
        });
        if (visible.size > 0) {
          var first = null;
          var firstTop = Infinity;
          visible.forEach(function (el) {
            var top = el.getBoundingClientRect().top;
            if (top < firstTop) {
              firstTop = top;
              first = el;
            }
          });
          if (first) setActive(first.id);
        } else {
          var nearest = null;
          var nearestDelta = Infinity;
          headings.forEach(function (h) {
            var top = h.getBoundingClientRect().top;
            if (top < 80 && Math.abs(top) < nearestDelta) {
              nearestDelta = Math.abs(top);
              nearest = h;
            }
          });
          if (nearest) setActive(nearest.id);
        }
      },
      { rootMargin: '-60px 0px -70% 0px', threshold: 0 }
    );
    headings.forEach(function (h) {
      spyObserver.observe(h);
    });
  }

  function scheduleRebuild() {
    if (rebuildTimer) clearTimeout(rebuildTimer);
    rebuildTimer = setTimeout(buildToc, REBUILD_DEBOUNCE_MS);
  }

  function watchContent() {
    var body = document.querySelector('.markdown-body');
    if (!body) {
      setTimeout(watchContent, 100);
      return;
    }
    buildToc();

    if (contentObserver) contentObserver.disconnect();
    contentObserver = new MutationObserver(scheduleRebuild);
    contentObserver.observe(body, { childList: true, subtree: true, characterData: true });
  }

  function init() {
    ensureSidebar();
    watchContent();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
