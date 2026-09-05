import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/awareness_article.dart';
import '../../../services/awareness_service.dart';

class GuestAwarenessScreen extends StatefulWidget {
const GuestAwarenessScreen({
super.key,
});

@override
State<GuestAwarenessScreen> createState() =>
_GuestAwarenessScreenState();
}

class _GuestAwarenessScreenState
extends State<GuestAwarenessScreen> {
final AwarenessService _awarenessService =
AwarenessService.instance;

final TextEditingController _searchController =
TextEditingController();

String _selectedCategory = 'All';
String _searchQuery = '';

@override
void initState() {
super.initState();

_searchController.addListener(() {
setState(() {
_searchQuery =
_searchController.text.trim().toLowerCase();
});
});
}

@override
void dispose() {
_searchController.dispose();
super.dispose();
}

// ==========================================
// FILTER ARTICLES
// ==========================================

List<AwarenessArticle> _filterArticles(
List<AwarenessArticle> articles,
) {
return articles.where((article) {
final title =
article.title.toLowerCase();

final description =
article.description.toLowerCase();

final category =
article.category.toLowerCase();

final matchesSearch =
_searchQuery.isEmpty ||
title.contains(_searchQuery) ||
description.contains(_searchQuery) ||
category.contains(_searchQuery);

final matchesCategory =
_selectedCategory == 'All' ||
article.category == _selectedCategory;

return matchesSearch && matchesCategory;
}).toList();
}

// ==========================================
// GET CATEGORIES FROM FIREBASE
// ==========================================

List<String> _getCategories(
List<AwarenessArticle> articles,
) {
final categories = <String>{};

for (final article in articles) {
final category = article.category.trim();

if (category.isNotEmpty) {
categories.add(category);
}
}

final result = categories.toList();

result.sort(
(a, b) => a.toLowerCase().compareTo(
b.toLowerCase(),
),
);

return [
'All',
...result,
];
}

// ==========================================
// ICON CONVERTER
// ==========================================

IconData _getIcon(String iconName) {
switch (iconName.trim().toLowerCase()) {
case 'phishing_outlined':
return Icons.phishing_outlined;

case 'security_outlined':
return Icons.security_outlined;

case 'lock_outline':
return Icons.lock_outline;

case 'password_outlined':
return Icons.password_outlined;

case 'privacy_tip_outlined':
return Icons.privacy_tip_outlined;

case 'report_problem_outlined':
return Icons.report_problem_outlined;

case 'warning_amber_outlined':
return Icons.warning_amber_outlined;

case 'shield_outlined':
return Icons.shield_outlined;

case 'verified_user_outlined':
return Icons.verified_user_outlined;

case 'smartphone_outlined':
return Icons.smartphone_outlined;

case 'public_outlined':
return Icons.public_outlined;

default:
return Icons.security_outlined;
}
}

// ==========================================
// CATEGORY ICON
// ==========================================

IconData _getCategoryIcon(String category) {
switch (category.toLowerCase()) {
case 'phishing':
return Icons.phishing_outlined;

case 'scams':
case 'online scams':
return Icons.warning_amber_outlined;

case 'social media':
return Icons.people_outline;

case 'passwords':
case 'password security':
return Icons.password_outlined;

case 'privacy':
case 'personal information':
return Icons.privacy_tip_outlined;

case 'cyber harassment':
case 'harassment':
return Icons.report_problem_outlined;

default:
return Icons.security_outlined;
}
}

// ==========================================
// BUILD
// ==========================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
AppColors.background,
appBar: AppBar(
elevation: 0,
backgroundColor:
AppColors.background,
foregroundColor:
AppColors.primary,
title: const Text(
'Cyber Safety Awareness',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
),
body: StreamBuilder<List<AwarenessArticle>>(
stream:
_awarenessService.watchArticles(),
builder: (
context,
snapshot,
) {
// ==================================
// LOADING
// ==================================

if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

// ==================================
// ERROR
// ==================================

if (snapshot.hasError) {
return _buildErrorState(
snapshot.error.toString(),
);
}

final articles =
snapshot.data ?? [];

// ==================================
// EMPTY
// ==================================

if (articles.isEmpty) {
return _buildEmptyState();
}

final categories =
_getCategories(articles);

// If selected category no longer
// exists in Firebase, reset it.
if (!categories.contains(
_selectedCategory,
)) {
WidgetsBinding.instance
    .addPostFrameCallback((_) {
if (!mounted) return;

setState(() {
_selectedCategory = 'All';
});
});
}

final filteredArticles =
_filterArticles(articles);

return RefreshIndicator(
onRefresh: () async {
try {
await _awarenessService
    .getArticles();
} catch (_) {}
},
child: ListView(
physics:
const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.fromLTRB(
16,
8,
16,
32,
),
children: [
_buildHeader(),
const SizedBox(height: 20),

_buildSearchBar(),
const SizedBox(height: 16),

_buildCategorySection(
categories,
),

const SizedBox(height: 20),

if (filteredArticles.isEmpty)
_buildNoResultsState()
else
...List.generate(
filteredArticles.length,
(index) {
final article =
filteredArticles[index];

return Padding(
padding:
const EdgeInsets.only(
bottom: 14,
),
child: _buildArticleCard(
article,
index,
),
);
},
),
],
),
);
},
),
);
}

// ==========================================
// HEADER
// ==========================================

Widget _buildHeader() {
return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(22),
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
AppColors.primary,
AppColors.secondary,
],
),
),
child: const Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
Icons.shield_outlined,
color: Colors.white,
size: 38,
),
SizedBox(height: 14),
Text(
'Stay Safe in the Digital World',
style: TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight: FontWeight.w800,
),
),
SizedBox(height: 8),
Text(
'Learn about common cyber threats and discover practical ways to protect yourself online.',
style: TextStyle(
color: Colors.white70,
fontSize: 14,
height: 1.5,
),
),
],
),
);
}

// ==========================================
// SEARCH BAR
// ==========================================

Widget _buildSearchBar() {
return TextField(
controller: _searchController,
textInputAction:
TextInputAction.search,
decoration: InputDecoration(
hintText:
'Search awareness articles...',
prefixIcon: const Icon(
Icons.search,
),
suffixIcon:
_searchController.text.isNotEmpty
? IconButton(
onPressed: () {
_searchController.clear();
},
icon: const Icon(
Icons.clear,
),
)
    : null,
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(16),
borderSide: BorderSide.none,
),
enabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(16),
borderSide: BorderSide.none,
),
focusedBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(16),
borderSide: BorderSide(
color: AppColors.primary,
width: 1.5,
),
),
),
);
}

// ==========================================
// CATEGORY SECTION
// ==========================================

Widget _buildCategorySection(
List<String> categories,
) {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Categories',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 12),
SizedBox(
height: 42,
child: ListView.separated(
scrollDirection:
Axis.horizontal,
itemCount: categories.length,
separatorBuilder: (
context,
index,
) =>
const SizedBox(width: 8),
itemBuilder: (
context,
index,
) {
final category =
categories[index];

final selected =
category ==
_selectedCategory;

return ChoiceChip(
selected: selected,
label: Text(category),
avatar: Icon(
_getCategoryIcon(
category,
),
size: 18,
),
selectedColor:
AppColors.primary,
labelStyle: TextStyle(
color: selected
? Colors.white
    : AppColors.primary,
fontWeight:
FontWeight.w600,
),
onSelected: (_) {
setState(() {
_selectedCategory =
category;
});
},
);
},
),
),
],
);
}

// ==========================================
// ARTICLE CARD
// ==========================================

Widget _buildArticleCard(
AwarenessArticle article,
int index,
) {
return TweenAnimationBuilder<double>(
duration: Duration(
milliseconds:
350 + (index * 80),
),
tween: Tween(
begin: 0,
end: 1,
),
builder: (
context,
value,
child,
) {
return Opacity(
opacity: value,
child: Transform.translate(
offset: Offset(
0,
20 * (1 - value),
),
child: child,
),
);
},
child: Material(
color: Colors.white,
borderRadius:
BorderRadius.circular(20),
child: InkWell(
borderRadius:
BorderRadius.circular(20),
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
GuestArticleDetailsScreen(
article: article,
),
),
);
},
child: Padding(
padding:
const EdgeInsets.all(16),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 54,
height: 54,
decoration: BoxDecoration(
color: AppColors.primary
    .withOpacity(0.10),
borderRadius:
BorderRadius.circular(
16,
),
),
child: Icon(
_getIcon(
article.icon,
),
color:
AppColors.primary,
size: 28,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Expanded(
child: Text(
article.title,
maxLines: 2,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w700,
),
),
),
const SizedBox(
width: 8,
),
const Icon(
Icons
    .arrow_forward_ios,
size: 14,
),
],
),
const SizedBox(
height: 7,
),
Text(
article.description,
maxLines: 3,
overflow:
TextOverflow.ellipsis,
style:
TextStyle(
color:
Colors.grey[700],
fontSize: 13,
height: 1.45,
),
),
const SizedBox(
height: 12,
),
Wrap(
spacing: 8,
runSpacing: 6,
children: [
_buildSmallTag(
article.category,
),
_buildSmallTag(
article.readingTime,
),
],
),
],
),
),
],
),
),
),
),
);
}

// ==========================================
// SMALL TAG
// ==========================================

Widget _buildSmallTag(
String text,
) {
return Container(
padding:
const EdgeInsets.symmetric(
horizontal: 9,
vertical: 5,
),
decoration: BoxDecoration(
color: AppColors.background,
borderRadius:
BorderRadius.circular(8),
),
child: Text(
text,
style: TextStyle(
color: AppColors.primary,
fontSize: 11,
fontWeight:
FontWeight.w600,
),
),
);
}

// ==========================================
// EMPTY STATE
// ==========================================

Widget _buildEmptyState() {
return Center(
child: Padding(
padding:
const EdgeInsets.all(32),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.menu_book_outlined,
size: 70,
color: Colors.grey[400],
),
const SizedBox(height: 18),
const Text(
'No awareness articles available',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 8),
Text(
'Articles added by the administrator will appear here.',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.grey[600],
height: 1.5,
),
),
],
),
),
);
}

// ==========================================
// NO SEARCH RESULTS
// ==========================================

Widget _buildNoResultsState() {
return Padding(
padding:
const EdgeInsets.symmetric(
vertical: 70,
),
child: Column(
children: [
Icon(
Icons.search_off_outlined,
size: 64,
color: Colors.grey[400],
),
const SizedBox(height: 16),
const Text(
'No articles found',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 7),
Text(
'Try another keyword or category.',
style: TextStyle(
color: Colors.grey[600],
),
),
],
),
);
}

// ==========================================
// ERROR STATE
// ==========================================

Widget _buildErrorState(
String error,
) {
return Center(
child: Padding(
padding:
const EdgeInsets.all(28),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.cloud_off_outlined,
size: 68,
color: Colors.grey[400],
),
const SizedBox(height: 18),
const Text(
'Unable to load awareness content',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 8),
Text(
'Please check your internet connection and Firebase configuration.',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.grey[600],
height: 1.5,
),
),
],
),
),
);
}
}

// ======================================================
// ARTICLE DETAILS SCREEN
// ======================================================

class GuestArticleDetailsScreen
extends StatelessWidget {
final AwarenessArticle article;

const GuestArticleDetailsScreen({
super.key,
required this.article,
});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
AppColors.background,
appBar: AppBar(
elevation: 0,
backgroundColor:
AppColors.background,
foregroundColor:
AppColors.primary,
title: const Text(
'Awareness Article',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
),
body: SingleChildScrollView(
padding:
const EdgeInsets.fromLTRB(
18,
10,
18,
35,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: double.infinity,
padding:
const EdgeInsets.all(22),
decoration: BoxDecoration(
color: AppColors.primary,
borderRadius:
BorderRadius.circular(22),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
_getIcon(
article.icon,
),
color: Colors.white,
size: 42,
),
const SizedBox(height: 18),
Text(
article.category,
style: const TextStyle(
color: Colors.white70,
fontSize: 13,
fontWeight:
FontWeight.w600,
),
),
const SizedBox(height: 7),
Text(
article.title,
style: const TextStyle(
color: Colors.white,
fontSize: 25,
fontWeight:
FontWeight.w800,
height: 1.2,
),
),
const SizedBox(height: 12),
Row(
children: [
const Icon(
Icons
    .access_time_outlined,
color: Colors.white70,
size: 17,
),
const SizedBox(width: 6),
Text(
article.readingTime,
style:
const TextStyle(
color:
Colors.white70,
fontSize: 13,
),
),
],
),
],
),
),
const SizedBox(height: 22),
Text(
article.description,
style: TextStyle(
color: Colors.grey[800],
fontSize: 16,
height: 1.6,
fontWeight:
FontWeight.w500,
),
),
const SizedBox(height: 24),
const Text(
'Learn More',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 12),
Text(
article.content,
style: TextStyle(
color: Colors.grey[800],
fontSize: 15,
height: 1.7,
),
),
],
),
),
);
}

IconData _getIcon(String iconName) {
switch (iconName.trim().toLowerCase()) {
case 'phishing_outlined':
return Icons.phishing_outlined;

case 'security_outlined':
return Icons.security_outlined;

case 'lock_outline':
return Icons.lock_outline;

case 'password_outlined':
return Icons.password_outlined;

case 'privacy_tip_outlined':
return Icons.privacy_tip_outlined;

case 'report_problem_outlined':
return Icons.report_problem_outlined;

case 'warning_amber_outlined':
return Icons.warning_amber_outlined;

case 'shield_outlined':
return Icons.shield_outlined;

case 'verified_user_outlined':
return Icons.verified_user_outlined;

case 'smartphone_outlined':
return Icons.smartphone_outlined;

case 'public_outlined':
return Icons.public_outlined;

default:
return Icons.security_outlined;
}
}
}

