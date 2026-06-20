const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.onDocumentValidated = functions.firestore
  .document('documents/{docId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (!before || !after) return null;
    if (before.isValidated === true || after.isValidated !== true) return null;

    const title = after.title || 'Document';
    const departmentCode = after.departmentCode || '';

    const payload = {
      notification: {
        title: 'Nouveau document validé 📄',
        body: `"${title}" est maintenant disponible en ${departmentCode}`,
      },
    };

    try {
      const users = await admin.firestore()
        .collection('users')
        .where('notificationsEnabled', '==', true)
        .get();

      const tokens = [];
      users.forEach(doc => {
        const token = doc.data().fcmToken;
        if (token) tokens.push(token);
      });

      if (tokens.length === 0) return null;

      const results = await admin.messaging().sendEachForMulticast({
        tokens,
        ...payload,
      });

      functions.logger.info(`Notifications envoyées à ${results.successCount} / ${tokens.length} appareils`);
      return null;
    } catch (error) {
      functions.logger.error('Erreur envoi notifications:', error);
      return null;
    }
  });

exports.onNewDocument = functions.firestore
  .document('documents/{docId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const title = data.title || 'Document';
    const departmentCode = data.departmentCode || '';

    const payload = {
      notification: {
        title: 'Nouveau document soumis 📤',
        body: `"${title}" a été soumis en ${departmentCode} — en attente de validation`,
      },
    };

    try {
      const users = await admin.firestore()
        .collection('users')
        .where('notificationsEnabled', '==', true)
        .get();

      const tokens = [];
      users.forEach(doc => {
        const token = doc.data().fcmToken;
        if (token) tokens.push(token);
      });

      if (tokens.length === 0) return null;

      const results = await admin.messaging().sendEachForMulticast({
        tokens,
        ...payload,
      });

      functions.logger.info(`Notifications nouvelle soumission: ${results.successCount} / ${tokens.length}`);
      return null;
    } catch (error) {
      functions.logger.error('Erreur:', error);
      return null;
    }
  });
