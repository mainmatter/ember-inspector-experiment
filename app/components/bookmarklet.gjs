import Component from '@glimmer/component';
import { htmlSafe } from '@ember/template';
import { uniqueId } from '@ember/helper';


const scriptUrl = `${window.location.origin}/bookmarklet.js`;

export default class Bookmarklet extends Component {
  get href() {
    return htmlSafe(`javascript:(() => {
      var s = document.createElement('script');
      s.src='${scriptUrl}';
      document.body.appendChild(s);
    })();`.replaceAll(/\s+/g,' ').trim());
  }

  <template>
    <div class="bg-amber-50 text-amber-700 px-3 py-2 rounded-md max-w-1/2 border border-amber-200">
      {{#let (uniqueId) as |id|}}
      <label for={{id}} class="font-medium ">Bookmarklet</label>
      <p class="mb-3">
        <input id={{id}} readonly class="font-mono text-xs bg-amber-100 border border-amber-200 text-amber-600 p-1 rounded w-full" value="{{this.href}}" />
      </p>
      {{/let}}
      <p class="text-sm">
        <span class="text-amber-600">Drag this link to your bookmarks bar:</span> <a href={{this.href}} class="underline ">Launch Inspector</a>
      </p>
    </div>
    {{yield}}
  </template>
}
