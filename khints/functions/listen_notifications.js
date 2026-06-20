const admin = require('firebase-admin');
const path = require('path');

// Remplace par le chemin vers ton fichier JSON du compte de service
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

try {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} catch (e) {
  console.error('❌ Fichier serviceAccountKey.json introuvable.');
  console.error('Télécharge-le depuis Console Firebase > Paramètres > Comptes de service > Générer une clé privée');
  console.error('Place-le dans le dossier functions/ avec le nom serviceAccountKey.json');
  process.exit(1);
}

const db = admin.firestore();

console.log('👂 Écoute des validations de documents...');
console.log('Appuie sur Ctrl+C pour arrêter.\n');

// Écoute les mises à jour de documents
db.collection('documents').onSnapshot((snapshot) => {
  snapshot.docChanges().forEach(async (change) => {
    // Ne traiter que les modifications
    if (change.type !== 'modified') return;

    const data = change.after.data();
    const before = change.doc.data();

    // Vérifier si le document vient d'être validé
    if (data.isValidated === true && before.isValidated !== true) {
      const title = data.title || 'Document';
      const departmentCode = data.departmentCode || '';

      console.log(`📄 Document validé : "${title}" (${departmentCode})`);

      try {
        // Récupérer tous les tokens des utilisateurs qui ont activé les notifs
        const users = await db.collection('users')
          .where('notificationsEnabled', '==', true)
          .get();

        const tokens = [];
        users.forEach(user => {
          const token = user.data().fcmToken;
          if (token) tokens.push(token);
        });

        if (tokens.length === 0) {
          console.log('  ⚠️ Aucun utilisateur avec notifications activées');
          return;
        }

        // Envoyer la notification
        const result = await admin.messaging().sendEachForMulticast({
          tokens,
          notification: {
            title: 'Nouveau document validé 📄',
            body: `"${title}" est maintenant disponible en ${departmentCode}`,
          },
        });

        console.log(`  ✅ Envoyé à ${result.successCount}/${tokens.length} appareils`);
        if (result.failureCount > 0) {
          console.log(`  ❌ Échecs: ${result.failureCount}`);
        }
      } catch (error) {
        console.error('  ❌ Erreur:', error.message);
      }
    }
  });
}, (error) => {
  console.error('Erreur Firestore:', error);
});
