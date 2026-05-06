import Route from '@ember/routing/route';

const params = new URLSearchParams(window.location.hash.slice(1));
const windowOrigin = params.get('origin');
const clientId = params.get('id');

const deferred = () => {
  const ref = {};
  ref.promise = new Promise((resolve, reject) => {
    ref.resolve = resolve;
    ref.reject = reject;
  });
  return ref;
}

const postMessage = (scope, data, id) => {
  window.opener.postMessage({
    scope,
    client: clientId,
    data,
    id,
  }, windowOrigin);
}

const messageBuffer = new Map();

globalThis.requestParentData = async (scope, data) => {
  const id = crypto.randomUUID();
  const def = deferred();
  messageBuffer.set(id, def);
  postMessage(scope, data, id);

  return def.promise;
}

if (window.opener) {
  window.addEventListener('message', ({ origin, data: raw }) => {
    if (origin !== windowOrigin) {
        return;
    }

    const { client, scope, data, id } = raw;

    if (client !== clientId) {
      return;
    }

    if (id && messageBuffer.has(id)) {
      messageBuffer.get(id).resolve(data);
      messageBuffer.delete(id);
      return;
    }

    console.log('[Unhandled]', scope, data, id);
  });

  postMessage('attach');
  window.addEventListener('unload', () => postMessage('detach'));
}

export default class InspectorRoute extends Route {
  async model() {
    if (windowOrigin) {
      return globalThis.requestParentData('view:tree');
    }

    return JSON.parse('[{"id":"render-node:0","instance":null,"name":"main","type":"outlet","children":[{"id":"render-node:1","instance":null,"name":"-top-level","type":"route-template","children":[{"id":"render-node:2","instance":null,"name":"main","type":"outlet","children":[{"id":"render-node:3","instance":null,"name":"@Component","type":"component","children":[{"id":"render-node:4","instance":null,"name":"main","type":"outlet","children":[{"id":"render-node:5","instance":null,"name":"@Component","type":"component","children":[{"id":"render-node:6","instance":{"id":"ember7"},"name":"Hello","type":"component","children":[{"id":"render-node:7","instance":null,"name":"on","type":"modifier","children":[]}]},{"id":"render-node:8","instance":{"id":"ember6"},"name":"Goodbye","type":"component","children":[]},{"id":"render-node:9","instance":{"id":"ember8"},"name":"Bookmarklet","type":"component","children":[]}]}]}]}]}]}]}]');
  }
}
