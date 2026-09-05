import 'package:cloud_firestore/cloud_firestore.dart';

class AwarenessArticle {
final String id;
final String title;
final String category;
final String description;
final String content;
final String readingTime;
final String icon;

const AwarenessArticle({
required this.id,
required this.title,
required this.category,
required this.description,
required this.content,
required this.readingTime,
required this.icon,
});

factory AwarenessArticle.fromFirestore(
DocumentSnapshot<Map<String, dynamic>> document,
) {
final data = document.data() ?? {};

return AwarenessArticle(
id: document.id,
title: (data['title'] ?? '').toString(),
category: (data['category'] ?? '').toString(),
description: (data['description'] ?? '').toString(),
content: (data['content'] ?? '').toString(),
readingTime:
(data['readingTime'] ?? '5 min read').toString(),
icon:
(data['icon'] ?? 'security_outlined').toString(),
);
}

Map<String, dynamic> toFirestore() {
return {
'title': title,
'category': category,
'description': description,
'content': content,
'readingTime': readingTime,
'icon': icon,
};
}

AwarenessArticle copyWith({
String? id,
String? title,
String? category,
String? description,
String? content,
String? readingTime,
String? icon,
}) {
return AwarenessArticle(
id: id ?? this.id,
title: title ?? this.title,
category: category ?? this.category,
description: description ?? this.description,
content: content ?? this.content,
readingTime: readingTime ?? this.readingTime,
icon: icon ?? this.icon,
);
}
}

