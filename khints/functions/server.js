const admin = require('firebase-admin');
const express = require('express');
const app = express();

// Initialiser Firebase Admin avec la variable d'environnement
const serviceAccountBase64 = process.env.FIREBASE_SERVICE_ACCOUNT;
if (serviceAccountBase64) {
  const serviceAccount = JSON.parse(Buffer.from(serviceAccountBase64, 'base64').toString());
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log('✅ Firebase Admin initialisé');
} else {
  console.error('❌ Variable FIREBASE_SERVICE_ACCOUNT non définie');
  process.exit(1);
}

const db = admin.firestore();

// Endpoint santé
app.get('/', (req, res) => {
  res.send('KHINTS+ Notification Service OK');
});

// Endpoint pour envoyer une notification manuellement
app.post('/notify', express.json(), async (req, res) => {
  const { title, body } = req.body;
  if (!title || !body) {
    return res.status(400).json({ error: 'title et body requis' });
  }

  try {
    const users = await db.collection('users')
      .where('notificationsEnabled', '==', true)
      .get();

    const tokens = [];
    users.forEach(user => {
      const token = user.data().fcmToken;
      if (token) tokens.push(token);
    });

    if (tokens.length === 0) {
      return res.json({ success: true, sent: 0, message: 'Aucun utilisateur avec notifications' });
    }

    const result = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
    });

    res.json({
      success: true,
      sent: result.successCount,
      total: tokens.length,
      failures: result.failureCount,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Écouter Firestore en temps réel
let listenerReady = false;
db.collection('documents').onSnapshot((snapshot) => {
  snapshot.docChanges().forEach(async (change) => {
    console.log('Changement détecté:', change.type, change.doc.id);
    if (change.type !== 'modified') return;

    const data = change.after.data();
    const before = change.doc.data();

    console.log('before.isValidated:', before?.isValidated, 'after.isValidated:', data?.isValidated);

    if (data.isValidated === true && (!before || before.isValidated !== true)) {
      const title = data.title || 'Document';
      const departmentCode = data.departmentCode || '';

      console.log(`📄 Document validé: "${title}" (${departmentCode})`);

      try {
        const users = await db.collection('users')
          .where('notificationsEnabled', '==', true)
          .get();

        const tokens = [];
        users.forEach(user => {
          const token = user.data().fcmToken;
          if (token) tokens.push(token);
        });

        if (tokens.length === 0) return;

        const result = await admin.messaging().sendEachForMulticast({
          tokens,
          notification: {
            title: 'Nouveau document validé 📄',
            body: `"${title}" est maintenant disponible en ${departmentCode}`,
          },
        });

        console.log(`  ✅ ${result.successCount}/${tokens.length} envoyés`);
      } catch (error) {
        console.error('  ❌ Erreur:', error.message);
      }
    }
  });
}, (error) => {
  console.error('Erreur Firestore listener:', error);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Serveur KHINTS+ démarré sur le port ${PORT}`);
  console.log('👂 Écoute des validations Firestore...');
});
