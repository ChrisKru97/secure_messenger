import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

export const notify = functions
    .region("europe-central2")
    .firestore
    .document("messages/{docId}")
    .onCreate(async (snapshot) => {
      const data = snapshot.data();
      const users = await admin.firestore()
          .collection("users")
          .where("id", "!=", data.author)
          .get();
      const userTokens = users.docs.map((d)=>d.data().token);

      admin.messaging().sendToDevice(userTokens, {notification: {
        "title": "Překvápko!",
        "body": "Máte novou zprávu, zkontrolujte ji",
      }});
    });

