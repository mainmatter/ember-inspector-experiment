import { pageTitle } from 'ember-page-title';
import Hello from '../components/hello.gjs';
import Goodbye from '../components/goodbye.js';

<template>
  {{pageTitle "Application"}}

  {{outlet}}
</template>
