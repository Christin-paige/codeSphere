// Import toast
import { toast } from "react-toastify";

// UI Notification Service class to manage user notifications in the application with prestyled messages.
export default class UINotification {
  // Method to display success notification with a custom message.
  static success(message: string): void {
    toast.success(message, {
      position: "top-center",
      autoClose: 3000,
      hideProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
      theme: "dark",
    });
  }

  // Method to display error notification with a custom message.
  static error(message: string): void {
    toast.error(message, {
      position: "top-center",
      autoClose: 3000,
      hideProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
      theme: "dark",
    });
  }

  // Method to display info notification with a custom message.
  static info(message: string): void {
    toast.info(message, {
      position: "top-center",
      autoClose: 3000,
      hideProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
      theme: "dark",
    });
  }
}
