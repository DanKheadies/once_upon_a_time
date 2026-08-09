/* eslint-disable max-len */
import {COLLECTION_MESSAGES} from "../constants";
import {firestore} from "../firebase";
import * as admin from "firebase-admin";
import {Message} from "../../models/message";

/**
 * Create a document for the user message
 * @param {admin.firestore.Transaction} transaction the FB:FS transaction
 * @param {Message} message the message to create
 */
export function createMessage(
  transaction: admin.firestore.Transaction,
  message: Message,
) {
  const doc = firestore.collection(COLLECTION_MESSAGES).doc();
  transaction.set(doc, message, {merge: true});
}
