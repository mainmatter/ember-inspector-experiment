import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { get } from '@ember/object';

class TreeNode extends Component {
  get node() {
    return this.args.node.type === 'outlet' ? this.args.node.children[0] : this.args.node;
  }

  <template>
    <li class="p-0 list-none">
      <div class="flex">
        <header class="font-mono text-sm px-1 py-0.5 font-semibold">
          <span class="text-blue-600">&lt;{{this.node.name}}</span><span class="text-blue-600">&gt;</span>
        </header>

        {{#if this.node.instance}}
          <div>
          <button class="bg-slate-200 text-slate-600 hover:bg-slate-300 hover:text-slate-700 text-sm px-2 py-0 rounded-lg cursor-pointer" type="button" {{on "click" (fn this.args.onInspect this.node.instance.id)}}>Inspect</button>
          </div>
        {{/if}}
      </div>

      <ul class="px-10">
        {{#each this.node.children as |child|}}
          <TreeNode @node={{child}} @onInspect={{@onInspect}} />
        {{/each}}
      </ul>
    </li>
  </template>
}

class PropertyNode extends Component {
  @tracked value;

  get type() {
    const { desc } = this.args;

    if (desc.instanceOf) {
      return desc.instanceOf;
    }

    if (desc.valueType === 'undefined') {
      return '';
    }

    return desc.valueType;
  }

  get first() {
    return this.type.slice(0, 1).toUpperCase();
  }

  constructor() {
    super(...arguments);

    const { obj, property } = this.args;

    globalThis.requestParentData('inspect:value', { id: obj.id, property, }).then((value) => {
      this.value = value;
    });
  }

  <template>
    <li>
      {{#if this.first}}
        <span>{{this.first}}</span>
      {{/if}}
      <strong>{{@property}}</strong>
      <span class="text-slate-500">{{this.value}}</span>
    </li>
  </template>
}

class ObjectNode extends Component {
  <template>
    <li>
      <header class="bg-slate-200 border-b border-slate-300 px-2 py-1">{{@obj.name}}</header>

      <ul class="px-2 p-1 font-mono text-sm">
        {{#each-in @obj.properties as |name desc|}}
          <PropertyNode @obj={{@obj}} @property={{name}} @desc={{desc}} />
        {{/each-in}}
      </ul>
    </li>
  </template>
}

export default class InspectorTemplate extends Component {
  @tracked inspected = null;

  onInspect = async (id) => {
    this.inspected = await globalThis.requestParentData('inspect:deep', { id });
  };

  close = () => {
    this.inspected = null;
  };

  get first() {
    return this.args.model[0];
  }

  <template>
    {{pageTitle "Inspector"}}

    <div class="h-screen w-full flex text-slate-800">
      <div class="flex-1">
        <header class="border-b border-gray-300 h-7 bg-slate-100">
        </header>
        <ul class="h-[calc(100%-1.75rem)] overflow-y-auto p-1">
          <TreeNode @node={{get @model '0.children.0.children.0'}} @onInspect={{this.onInspect}} />
        </ul>
      </div>


      {{#if this.inspected}}
        <div class="border-l border-slate-300 w-1/3">
          <header class="border-b border-slate-300 h-7 bg-slate-100 flex justify-end  text-slate-500">
            <button type="button" {{on "click" this.close}} class="cursor-pointer px-2">Close</button>
          </header>
          <ul class="list-none h-[calc(100%-1.75rem)] overflow-y-auto">
            {{#each this.inspected as |obj|}}
              <ObjectNode @obj={{obj}} />
            {{/each}}
          </ul>
        </div>
      {{/if}}
    </div>

    {{outlet}}
  </template>
}
