/* eslint-disable max-len */
// npm run lint -- --fix
import {onCall} from "firebase-functions/v2/https";
import {handleContactMessage} from "./funcs/contact_message";

/**
 * Contact Message
 *
 * Send an "email" to Firebase document.
 * TODO: incorporate a true email service or send as a push notification topic.
 */
export const contactMessage = onCall(async (data) =>
  handleContactMessage(data),
);

/**
 * Test onCall function
 */
export const testCallFunction = onCall(async (data) => {
  console.log("test function is callable");
  console.log("data:");
  console.log(data.data);
  console.log(data.data["payload"]);
  console.log(data.data["data"]);
});
