// @ts-check
import { defineConfig } from 'astro/config';

import tailwindcss from '@tailwindcss/vite';
import { remarkRemoveReadmore } from './src/plugins/remark-remove-readmore.mjs';

// https://astro.build/config
export default defineConfig({
  markdown: {
    remarkPlugins: [remarkRemoveReadmore],
    shikiConfig: {
      theme: 'solarized-light',
    },
  },
  vite: {
    plugins: [tailwindcss()]
  }
});