import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Notification } from "firebase-admin/lib/messaging/messaging-api";

const notification: Notification = {
  "title": "Překvápko!",
  "body": "Máte novou zprávu, zkontrolujte ji",
};

export const notify = functions
  .region("europe-central2")
  .firestore
  .document("messages_v2/{docId}")
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const users = await admin.firestore()
      .collection("users")
      .where("id", "!=", data.author)
      .where("dev", "==", false)
      .get();
    const userTokens = users.docs.map((d) => d.data().token);

    await Promise.all(userTokens.map((token) => (
      admin.messaging().send({
        notification,
        token,
      })
    )));
  });
