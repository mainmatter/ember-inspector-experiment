(function loadInspector() {
  const OBJECT_CACHE = new Map();

  class BookmarkletClient extends EventTarget {
    #id;
    #url;
    #remoteWindow;

    constructor(id, src) {
      super();

      this.#id = id;

      const url = new URL(src);
      url.pathname = 'inspector';
      url.hash = new URLSearchParams({ origin: window.location.origin, src, id, });

      this.#url = url;
      this.attach();
    }

    attach() {
      this.#remoteWindow = window.open(this.#url, id, `popup,scrollbars=0,height=${parseInt(window.screen.availHeight / 2)},width=${parseInt(window.screen.availWidth / 2)},top=${parseInt(window.screen.availHeight / 4)},left=${parseInt(window.screen.availWidth / 4)}`);

      window.addEventListener('message', this.onMessage);
      window.addEventListener('beforeunload', this.detach);
    }

    postMessage = (scope, data, id) => {
      this.#remoteWindow.postMessage({
        scope,
        client: this.#id,
        id,
        data,
      }, window.location.origin);
    }

    onMessage = async ({ origin, data: raw }) => {
      if (origin !== window.location.origin) {
        return;
      }

      const { scope, client, id, data } = raw;

      // Ignore messages for other instances
      if (client !== this.#id) {
        return;
      }

      if (scope === 'detach') {
        this.detach();
        return;
      }

      if (scope === 'attach') {
        this.load();
        return;
      }

      const entry = globalThis.__EMBER_DEBUG_ENTRIES__[0];
      const { getTree, getReference, inspectDeep } = await entry.modules();

      if (scope === 'view:tree') {
        this.postMessage('view:tree', getTree(entry.reference), id);
        return;
      }

      if (scope === 'inspect:deep') {
        const obj = getReference(data.id);

        OBJECT_CACHE.set(data.id, obj);

        this.postMessage('inspect:deep', obj ? JSON.parse(JSON.stringify(inspectDeep(obj))) : null, id);
        return;
      }

      if (scope === 'inspect:value') {
        let value = undefined;

        if (OBJECT_CACHE.has(data.id) && data.property) {
          value = OBJECT_CACHE.get(data.id)[data.property];

          if (value) {
            try {
              value = JSON.parse(JSON.stringify(value));
            } catch {
              value = '<PARSE ERROR>'
            }
          } else {
            value = 'undefined';
          }
        } else {
          value = '<TBD>';
        }

        this.postMessage('inspect:value', value, id);
        return
      }

      console.log('fromChild', scope, data, id);
    }

    async load() {
      await Promise.all(globalThis.__EMBER_DEBUG_ENTRIES__.map(entry => entry.modules()));
    }

    detach = () => {
      this.#remoteWindow?.close();

      window.removeEventListener('message', this.onMessage);
      window.removeEventListener('unload', this._onUnload);
      document.querySelector('script[data-id="' + this.#id + '"]').remove();
    }
  }

  const scripts = document.getElementsByTagName('script');
  const index = Array.from(scripts).indexOf(document.currentScript);
  const id = scripts[index].dataset.id = `bookmarklet:${index}`;

  globalThis.__EMBER_DEBUG_CLIENTS__ ??= {};
  globalThis.__EMBER_DEBUG_CLIENTS__[id] = new BookmarkletClient(id, document.currentScript.src);

})();
