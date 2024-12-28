/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.listUsers = functions.https.onCall(async (data, context) => {
  // Ensure the user is an admin
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Only admins can view the users');
  }

  try {
    const listUsersResult = await admin.auth().listUsers(1000); // fetch up to 1000 users
    return { users: listUsersResult.users };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Error fetching users', error);
  }
});

exports.deleteUser = functions.https.onCall(async (data, context) => {
  const { uid } = data;
  // Ensure the user is an admin
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Only admins can delete users');
  }

  try {
    await admin.auth().deleteUser(uid);
    return { message: 'User deleted successfully' };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Error deleting user', error);
  }
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
