const { google } = require('googleapis');
const admin = require('firebase-admin');

// Chemin vers ton fichier JSON du compte de service téléchargé depuis Firebase
const serviceAccount = require('./chemin-vers-ton-fichier.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function sendNotifications(title, body) {
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

    if (tokens.length === 0) {
      console.log('Aucun utilisateur avec notifications activées');
      return;
    }

    const result = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
    });

    console.log(`✅ Envoyé à ${result.successCount}/${tokens.length} appareils`);
    if (result.failureCount > 0) {
      console.log('❌ Échecs:', result.responses.filter(r => !r.success).length);
    }
  } catch (error) {
    console.error('Erreur:', error);
  }
}

// Exemple : notifier validation de document
sendNotifications(
  'Nouveau document validé 📄',
  'Un document vient d\'être validé sur KHINTS+ !'
);
