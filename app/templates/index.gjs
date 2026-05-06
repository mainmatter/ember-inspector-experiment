import { pageTitle } from 'ember-page-title';
import Hello from '../components/hello.gjs';
import Goodbye from '../components/goodbye.js';
import Bookmarklet from '../components/bookmarklet.gjs';


<template>
  {{pageTitle "Index"}}

  {{outlet}}

  <div class="p-5 grid grid-rows-[1fr_min-content] min-h-screen">
    <div class="grid gap-12 grid-rows-[min-content]">
      <Hello />

      <Goodbye />
    </div>

    <div>
      <a href="https://github.com/mainmatter/ember-inspector-experiment" class="mb-4 p-3 border border-blue-300 bg-blue-100 rounded-md inline-block text-blue-500">
        <code class="text-sm text-blue-700">mainmatter/ember-inspector-experiment</code> <span class="underline">on GitHub</span>
      </a>

      <Bookmarklet />
    </div>
  </div>
</template>
