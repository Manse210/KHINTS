const admin = require('firebase-admin');
const express = require('express');

// Utiliser directement la base64 de la clé de service
const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
if (!raw) {
  console.error('FIREBASE_SERVICE_ACCOUNT manquante');
  process.exit(1);
}

try {
  const sa = JSON.parse(Buffer.from(raw, 'base64').toString());
  admin.initializeApp({ credential: admin.credential.cert(sa) });
  console.log('Firebase OK');
} catch (e) {
  console.error('Erreur init Firebase:', e.message);
  process.exit(1);
}

const db = admin.firestore();
const app = express();

app.get('/', (req, res) => res.send('KHINTS+ OK'));

app.post('/notify', express.json(), async (req, res) => {
  const { title, body } = req.body;
  if (!title || !body) return res.status(400).json({ error: 'title et body requis' });

  try {
    const users = await db.collection('users').where('notificationsEnabled', '==', true).get();
    const tokens = [];
    users.forEach(u => { const t = u.data().fcmToken; if (t) tokens.push(t); });
    if (tokens.length === 0) return res.json({ sent: 0 });

    const r = await admin.messaging().sendEachForMulticast({ tokens, notification: { title, body } });
    res.json({ sent: r.successCount, total: tokens.length });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Polling: vérifier les docs validés non notifiés
setInterval(async () => {
  try {
    const docs = await db.collection('documents').where('isValidated', '==', true).where('_notified', '==', false).get();
    for (const doc of docs.docs) {
      const d = doc.data();
      console.log('Nouveau doc validé:', d.title);
      const users = await db.collection('users').where('notificationsEnabled', '==', true).get();
      const tokens = [];
      users.forEach(u => { const t = u.data().fcmToken; if (t) tokens.push(t); });
      if (tokens.length > 0) {
        const r = await admin.messaging().sendEachForMulticast({
          tokens,
          notification: { title: 'Nouveau document validé 📄', body: `"${d.title}" disponible` },
        });
        console.log(`Envoyé à ${r.successCount}/${tokens.length}`);
      }
      await doc.ref.update({ _notified: true });
    }
  } catch (e) {
    if (e.code !== 16) console.error('Polling:', e.message);
  }
}, 5000);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`✅ Serveur sur port ${PORT}`));
