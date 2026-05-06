/* eslint-disable ember/no-classic-classes */

import { set } from '@ember/object';
import Component from '@ember/component';
import { tracked } from '@glimmer/tracking';
import { readOnly } from '@ember/object/computed';
import { computed } from '@ember/object';

// eslint-disable-next-line ember/require-tagless-components
export default Component.extend({
  entity: tracked(),
  foo: tracked(),

  bar: computed('entity', 'foo', function () {
    return this.entity + this.foo;
  }),

  baz: readOnly('bar'),

  init() {
    this._super(...arguments);
    set(this, 'entity', 'World');
    set(this, 'foo', 'foo');

    setInterval(() => {
      set(this, 'entity', this.entity === 'World' ? 'Ember' : 'World');
    }, 1000);
  }
});
