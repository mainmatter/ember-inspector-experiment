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

    <Bookmarklet />
  </div>
</template>
