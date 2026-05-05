import '../models/document_model.dart';
import '../mock/mock_data.dart';

class FirestoreService {
  // Squelette pour la future connexion avec Firebase
  
  /// Récupère la liste des documents (simulation avec MockData pour l'instant)
  Future<List<DocumentModel>> getDocuments() async {
    // Simulation d'un délai réseau
    await Future.delayed(const Duration(seconds: 1));
    return MockData.documents;
  }
  
  /// Incrémente le nombre de téléchargements d'un document
  Future<void> incrementDownloads(String documentId) async {
    // TODO: Implémenter la logique Firestore (FieldValue.increment)
    print("Incrémentation des téléchargements pour $documentId simulée.");
  }
}
