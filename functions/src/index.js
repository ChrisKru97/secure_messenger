'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
admin.initializeApp();

const notification = {
  "title": "Překvápko!",
  "body": "Máte novou zprávu, zkontrolujte ji",
};

exports.notify = functions
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

    await admin.messaging().sendEach(userTokens.map(token => ({
      notification,
      token,
    })));
  });