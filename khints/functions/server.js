const express = require('express');
const { google } = require('googleapis');
const https = require('https');

const app = express();
app.use(express.json());

const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
if (!raw) { console.error('FIREBASE_SERVICE_ACCOUNT manquante'); process.exit(1); }

const serviceAccount = JSON.parse(Buffer.from(raw, 'base64').toString());

let _cachedToken = null;
let _tokenExpiry = 0;

async function getAccessToken() {
  if (Date.now() < _tokenExpiry && _cachedToken) return _cachedToken;
  const auth = new google.auth.GoogleAuth({
    credentials: serviceAccount,
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  });
  const client = await auth.getClient();
  const token = await client.getAccessToken();
  _cachedToken = token.token;
  _tokenExpiry = Date.now() + 3500 * 1000;
  return _cachedToken;
}

function fcmPost(token, title, body, accessToken) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({
      message: { token, notification: { title, body } },
    });
    const req = https.request({
      hostname: 'fcm.googleapis.com',
      path: '/v1/projects/khint-1fb73/messages:send',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`,
        'Content-Length': data.length,
      },
    }, (res) => {
      let body = '';
      res.on('data', c => body += c);
      res.on('end', () => resolve(res.statusCode === 200));
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

function firestoreGetAllUsers() {
  return new Promise((resolve, reject) => {
    getAccessToken().then(token => {
      const req = https.get({
        hostname: 'firestore.googleapis.com',
        path: '/v1/projects/khint-1fb73/databases/(default)/documents/users',
        headers: { Authorization: `Bearer ${token}` },
      }, (res) => {
        let body = '';
        res.on('data', c => body += c);
        res.on('end', () => {
          try { resolve(JSON.parse(body)); }
          catch (e) { reject(e); }
        });
      });
      req.on('error', reject);
    }).catch(reject);
  });
}

app.get('/', (req, res) => res.send('KHINTS+ OK'));

app.post('/notify', async (req, res) => {
  const { title, body } = req.body || {};
  if (!title || !body) return res.status(400).json({ error: 'title et body requis' });

  try {
    const token = await getAccessToken();
    const fsData = await firestoreGetAllUsers();

    const tokens = [];
    if (fsData.documents) {
      for (const doc of fsData.documents) {
        const f = doc.fields || {};
        if (f.fcmToken?.stringValue && f.notificationsEnabled?.booleanValue === true) {
          tokens.push(f.fcmToken.stringValue);
        }
      }
    }

    console.log(`${tokens.length} tokens trouvés`);
    if (tokens.length === 0) return res.json({ sent: 0 });

    let success = 0;
    for (const t of tokens) {
      const ok = await fcmPost(t, title, body, token);
      if (ok) success++;
    }

    console.log(`Envoyé: ${success}/${tokens.length}`);
    res.json({ sent: success, total: tokens.length });
  } catch (e) {
    console.error('Erreur:', e.message);
    res.status(500).json({ error: e.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`✅ Serveur sur port ${PORT}`));
