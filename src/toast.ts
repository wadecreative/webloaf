import { ToastMessage, toastStore } from './store';
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
    toastElement.className = `toast toast-${toast.type}`;
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
    toastStore.toasts.forEach((toast: ToastMessage) => {
      const toastElement = document.createElement('div');
      toastElement.className = `toast toast-${toast.type}`;
      toastElement.style.borderColor = toast.options.borderColor as string;
      toastElement.style.color = toast.options.textColor as string;
      toastElement.textContent = toast.message;

      const closeButton = document.createElement('button');
      closeButton.textContent = 'Close';
      closeButton.onclick = () => toastStore.removeMessage(toast.id);

      toastElement.appendChild(closeButton);
      toastContainer.appendChild(toastElement);

      // Mount the Petite-Vue app on each toast element so it can react to changes in toastStore.
      toastApp.mount(toastElement);
      return toastStore;
    });
  });
}
