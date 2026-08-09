/* eslint-disable max-len */
import * as firebase from "../firebase/firebase";
import {Message} from "../models/message";

/**
 * Contact Message - [Callable Function]
 * This function sends a message to a firebase collection
 *
 * @param {any} data
 */
export async function handleContactMessage(data: any) {
  // console.log("contact email function");
  // console.log(data.data["email"]);
  const userEmail = data.data["email"];
  // console.log(data.data["message"]);
  const userMessage = data.data["message"];
  // console.log(data.data["name"]);
  const userName = data.data["name"];
  const date = new Date();
  // console.log(date);

  await firebase.firestore.runTransaction(async (transaction) => {
    const message: Message = {
      email: userEmail,
      message: userMessage,
      name: userName,
      sent: new Date().toISOString(),
    };
    firebase.messages.createMessage(transaction, message);
    console.log(`Message created @ ${date}`);
  });
}
