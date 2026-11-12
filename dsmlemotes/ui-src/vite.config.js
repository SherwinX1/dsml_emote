import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Builds the emote menu into ../html (index.html + html/bundle/*). base: './' is required -
// RedM's NUI loads index.html from a local file root, so asset URLs must be relative.
export default defineConfig({
  plugins: [react()],
  base: './',
  build: {
    outDir: '../html',
    emptyOutDir: false,
    assetsDir: 'bundle',
  },
});
