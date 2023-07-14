#!/bin/bash
mkdir src

# Create .gitignore
echo "node_modules
dist" > .gitignore

# Create package.json
cat << EOF > package.json
{
  "name": "@wadecreative/webloaf-petite",
  "version": "1.0.0",
  "description": "A lightweight toast notification module using petite-vue",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
  },
  "keywords": ["toast", "notification", "petite-vue"],
  "author": "Travis Wade",
  "license": "MIT",
  "dependencies": {
    "petite-vue": "^0.6.2"
  },
  "devDependencies": {
    "typescript": "^4.1.5",
  }
}
EOF

# Create README.md

# Create tsconfig.json
cat << EOF > tsconfig.json
{
  "compilerOptions": {
    "target": "es6",
    "module": "commonjs",
    "declaration": true,
    "outDir": "./dist",
    "strict": true
  }
}
EOF

cat << EOF > index.ts
import { initToast } from './toast';

initToast(); // Auto-initialize the toast system when the module is imported.

export { toastStore } from './store'; // Export the toastStore for external use
EOF

cat << EOF > src/store.ts

import { reactive } from 'petite-vue';

// Options for styling and behavior of toasts.
export interface ToastOptions {
  borderColor?: string;
  textColor?: string;
  duration?: number;
}

// Information about a single toast.
export interface ToastMessage {
  id: number;
  message: string;
  type: 'success' | 'error' | 'info';
  options: ToastOptions;
}

// The global store for all toasts.
export interface ToastStore {
  toasts: ToastMessage[];
  nextToastId: number;
  addMessage: (message: string, type: 'success' | 'error' | 'info', options?: ToastOptions) => void;
  removeMessage: (id: number) => void;
}

// Initialize the global store with an empty list of toasts and methods to add and remove toasts.
export const toastStore = reactive<ToastStore>({
  toasts: [],
  nextToastId: 0,
  addMessage(message: string, type: 'success' | 'error' | 'info', options: ToastOptions = {}) {
    // Create a new toast with the provided message, type, and options, and an auto-incremented ID.
    const toast: ToastMessage = { id: this.nextToastId++, message, type, options };
    this.toasts.push(toast);
    // If a duration is specified, automatically remove the toast after that delay.
    if (options.duration) {
      setTimeout(() => this.removeMessage(toast.id), options.duration);
    }
  },
  removeMessage(id: number) {
    // Remove the toast with the specified ID from the list.
    this.toasts = this.toasts.filter(toast => toast.id !== id);
  },
});
EOF

cat << EOF > src/toast.ts
import { toastStore } from './store';
import { createApp } from 'petite-vue';

export function initToast() {
  // Automatically create and append the toast container when this function is called.
  const toastContainer = document.createElement('div');
  toastContainer.id = 'toast-container';
  document.body.appendChild(toastContainer);

  // Create and mount the Petite-Vue application.
  const toastApp = createApp({
    toasts: toastStore.toasts,
    removeMessage: toastStore.removeMessage
  });

  // Listen to toast-added event
  document.addEventListener('toast-added', (e) => {
    const toast = (e as CustomEvent).detail;
    // Create a new toast element for each added toast.
    const toastElement = document.createElement('div');
    toastElement.className = \`toast toast-\${toast.type}\`;
    toastElement.style.borderColor = toast.options.borderColor;
    toastElement.style.color = toast.options.textColor;
    toastElement.textContent = toast.message;

    // Add a close button to each toast.
    const closeButton = document.createElement('button');
    closeButton.textContent = 'Close';
    closeButton.onclick = () => toastStore.removeMessage(toast.id);
    toastElement.appendChild(closeButton);

    // Add the toast to the DOM.
    toastContainer.appendChild(toastElement);
    // Mount the Petite-Vue app on each toast element so it can react to changes in toastStore.
    toastApp.mount(toastElement);
  });

  // Listen to toast-removed event
  document.addEventListener('toast-removed', () => {
    // Clear all existing toasts from the DOM.
    while (toastContainer.firstChild) {
      toastContainer.firstChild.remove();
    }
    // Re-render all remaining toasts.
    toastStore.toasts.forEach((toast) => {
      const toastElement = document.createElement('div');
      toastElement.className = \`toast toast-\${toast.type}\`;
      toastElement.style.borderColor = toast.options.borderColor;
      toastElement.style.color = toast.options.textColor;
      toastElement.textContent = toast.message;

      const closeButton = document.createElement('button');
      closeButton.textContent = 'Close';
      closeButton.onclick = () => toastStore.removeMessage(toast.id);

      toastElement.appendChild(closeButton);
      toastContainer.appendChild(toastElement);

      // Mount the Petite-Vue app on each toast element so it can react to changes in toastStore.
      toastApp.mount(toastElement);
    });
  });
}
EOF
