
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
