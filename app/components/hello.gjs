import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { readOnly } from '@ember/object/computed';
import { schedule } from '@ember/runloop';
import { service } from '@ember/service';

export default class Hello extends Component {
  @service('router') blah;

  @tracked entity = 'World';
  @tracked foo = 'foo';

  x = 'x';

  get bar() {
    return this.entity + this.foo;
  }

  @readOnly('bar')
  get fu() {
    return '1';
  }

  @readOnly('bar') baz;

  constructor() {
    super(...arguments);

    setInterval(() => {
      this.entity = this.entity === 'World' ? 'Ember' : 'World';
    }, 1000);
  }

  <template>
    <div>
      <span class="bg-indigo-300 border border-indigo-400 text-indigo-800 text-sm px-1 py-0.5 rounded">Glimmer Component</span>
      <h1 class="text-3xl mt-1">Hello {{this.bar}}</h1>
    </div>
  </template>
}
