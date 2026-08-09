import * as admin from "firebase-admin";
import * as messages from "./data/messages";

// Hydrate our context of Firebase Admin SDK
admin.initializeApp();

const firestore = admin.firestore();
const messaging = admin.messaging();

export {messages, firestore, messaging};
