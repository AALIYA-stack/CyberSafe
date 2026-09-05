import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/awareness_article.dart';

class AwarenessService {
AwarenessService._();

static final AwarenessService instance =
AwarenessService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

CollectionReference<Map<String, dynamic>>
get _articlesCollection =>
_firestore.collection('awareness_articles');

// ==============================
// GET ALL ARTICLES - REAL TIME
// ==============================

Stream<List<AwarenessArticle>> watchArticles() {
return _articlesCollection.snapshots().map(
(snapshot) {
final articles = snapshot.docs
    .map(
(document) =>
AwarenessArticle.fromFirestore(document),
)
    .where(
(article) =>
article.title.trim().isNotEmpty &&
article.description.trim().isNotEmpty &&
article.content.trim().isNotEmpty,
)
    .toList();

articles.sort(
(a, b) => a.title
    .toLowerCase()
    .compareTo(b.title.toLowerCase()),
);

return articles;
},
);
}

// ==============================
// GET ALL ARTICLES - ONCE
// ==============================

Future<List<AwarenessArticle>> getArticles() async {
final snapshot = await _articlesCollection.get();

final articles = snapshot.docs
    .map(
(document) =>
AwarenessArticle.fromFirestore(document),
)
    .where(
(article) =>
article.title.trim().isNotEmpty &&
article.description.trim().isNotEmpty &&
article.content.trim().isNotEmpty,
)
    .toList();

articles.sort(
(a, b) => a.title
    .toLowerCase()
    .compareTo(b.title.toLowerCase()),
);

return articles;
}

// ==============================
// GET SINGLE ARTICLE
// ==============================

Future<AwarenessArticle?> getArticle(
String articleId,
) async {
if (articleId.trim().isEmpty) {
return null;
}

final document =
await _articlesCollection.doc(articleId).get();

if (!document.exists) {
return null;
}

return AwarenessArticle.fromFirestore(document);
}

// ==============================
// ADD ARTICLE
// ADMIN ONLY BY FIRESTORE RULES
// ==============================

Future<String> addArticle(
AwarenessArticle article,
) async {
final document =
await _articlesCollection.add(
article.toFirestore(),
);

return document.id;
}

// ==============================
// UPDATE ARTICLE
// ADMIN ONLY BY FIRESTORE RULES
// ==============================

Future<void> updateArticle(
String articleId,
AwarenessArticle article,
) async {
if (articleId.trim().isEmpty) {
throw ArgumentError(
'Article ID cannot be empty.',
);
}

await _articlesCollection
    .doc(articleId)
    .update(
article.toFirestore(),
);
}

// ==============================
// DELETE ARTICLE
// ADMIN ONLY BY FIRESTORE RULES
// ==============================

Future<void> deleteArticle(
String articleId,
) async {
if (articleId.trim().isEmpty) {
throw ArgumentError(
'Article ID cannot be empty.',
);
}

await _articlesCollection
    .doc(articleId)
    .delete();
}
}
