import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AiChatScreen extends StatefulWidget {
const AiChatScreen({super.key});

@override
State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
final TextEditingController _messageController =
TextEditingController();

final ScrollController _scrollController =
ScrollController();

final FocusNode _messageFocusNode =
FocusNode();

final List<Map<String, String>> _messages = [
{
'sender': 'ai',
'message':
'Hello! I am CyberSafe AI Assistant 🤖\n\n'
'I can help you with cyber-safety awareness, '
'online fraud, phishing, fake accounts, '
'account security, harassment and complaint guidance.\n\n'
'Please do not share passwords, OTPs, banking details '
'or other private information with me.',
},
];

bool _isTyping = false;

static const int _maxMessageLength = 500;

@override
void dispose() {
_messageController.dispose();
_scrollController.dispose();
_messageFocusNode.dispose();
super.dispose();
}

// ==========================================================
// SEND USER MESSAGE
// ==========================================================

void _sendMessage() {
final String text =
_messageController.text.trim();

if (text.isEmpty || _isTyping) {
return;
}

if (text.length > _maxMessageLength) {
_showMessage(
'Message cannot exceed '
'$_maxMessageLength characters.',
);
return;
}

if (_containsSensitiveInformation(text)) {
_showPrivacyWarning();
return;
}

_messageController.clear();

setState(() {
_messages.add({
'sender': 'user',
'message': text,
});

_isTyping = true;
});

_scrollToBottom();

// Temporary local response.
//
// In the next AI API phase this section will be replaced
// with:
//
// AIChatService -> OpenRouter API -> AI response
//
Future.delayed(
const Duration(milliseconds: 900),
() {
if (!mounted) return;

final String response =
_generateResponse(text);

setState(() {
_messages.add({
'sender': 'ai',
'message': response,
});

_isTyping = false;
});

_scrollToBottom();
},
);
}

// ==========================================================
// QUICK QUESTION
// ==========================================================

void _sendQuickQuestion(String question) {
if (_isTyping) {
return;
}

if (_containsSensitiveInformation(question)) {
return;
}

setState(() {
_messages.add({
'sender': 'user',
'message': question,
});

_isTyping = true;
});

_scrollToBottom();

Future.delayed(
const Duration(milliseconds: 700),
() {
if (!mounted) return;

final response =
_generateResponse(question);

setState(() {
_messages.add({
'sender': 'ai',
'message': response,
});

_isTyping = false;
});

_scrollToBottom();
},
);
}

// ==========================================================
// LOCAL AI RESPONSE
// ==========================================================

String _generateResponse(String question) {
final String q =
question.toLowerCase().trim();

if (q.contains('hack') ||
q.contains('hacked') ||
q.contains('account stolen')) {
return 'If you think your account has been compromised, '
'change its password using the official service, '
'enable two-factor authentication, sign out of '
'unknown devices and preserve relevant security alerts '
'as evidence.\n\n'
'Do not share your password or verification codes with anyone.';
}

if (q.contains('scam') ||
q.contains('fraud') ||
q.contains('cheat')) {
return 'For an online scam or fraud, do not send additional '
'money or private information. Preserve messages, '
'transaction records, screenshots and other relevant '
'evidence.\n\n'
'You can then use CyberSafe to submit a complaint.';
}

if (q.contains('fake account') ||
q.contains('fake profile')) {
return 'For a fake account or profile, preserve screenshots '
'of the profile, username and relevant messages. '
'Use the platform reporting tools and submit a complaint '
'through CyberSafe when appropriate.';
}

if (q.contains('harass') ||
q.contains('harassment') ||
q.contains('threat')) {
return 'For online harassment or threats, avoid escalating '
'the conversation. Preserve relevant messages and '
'screenshots, use the platform reporting tools and '
'consider submitting a CyberSafe complaint.';
}

if (q.contains('link') ||
q.contains('phishing') ||
q.contains('suspicious website')) {
return 'Do not open suspicious links or enter passwords, '
'OTP codes or financial information on unknown websites.\n\n'
'If you already interacted with a suspicious site, '
'secure the affected account through its official service '
'and monitor for unusual activity.';
}

if (q.contains('complaint') ||
q.contains('report')) {
return 'You can submit a cyber-crime complaint through '
'the My Complaints section of CyberSafe.\n\n'
'Provide accurate incident details, category, platform, '
'description and available evidence.';
}

if (q.contains('password') ||
q.contains('secure account')) {
return 'Use a strong and unique password for each important '
'account and enable two-factor authentication when available.\n\n'
'Never share passwords or OTP/verification codes with anyone.';
}

if (q.contains('otp') ||
q.contains('verification code')) {
return 'Never share an OTP or verification code with another person. '
'Legitimate services generally do not need you to tell someone '
'your one-time verification code.';
}

if (q.contains('privacy') ||
q.contains('private information')) {
return 'Protect personal information such as passwords, OTPs, '
'financial details, private addresses and account recovery '
'information. Only provide information to trusted official '
'services when necessary.';
}

return 'I can help with cyber-safety topics such as:\n\n'
'• Phishing and suspicious links\n'
'• Online scams and fraud\n'
'• Fake accounts\n'
'• Account security\n'
'• Password safety\n'
'• Online harassment\n'
'• Cyber-crime complaint guidance\n\n'
'Ask me a specific cyber-safety question.';
}

// ==========================================================
// BASIC PRIVACY CHECK
// ==========================================================

bool _containsSensitiveInformation(String text) {
final q = text.toLowerCase();

final sensitivePatterns = [
'password:',
'password is',
'my password',
'otp:',
'otp is',
'my otp',
'verification code:',
'verification code is',
'card number',
'credit card',
'debit card',
'cvv',
];

return sensitivePatterns.any(
(pattern) => q.contains(pattern),
);
}

void _showPrivacyWarning() {
showDialog(
context: context,
builder: (context) {
return AlertDialog(
title: const Row(
children: [
Icon(
Icons.security_rounded,
color: Color(0xFF0B3D91),
),
SizedBox(width: 10),
Expanded(
child: Text(
'Protect Your Information',
),
),
],
),
content: const Text(
'Please do not share passwords, OTPs, '
'verification codes, card details or other '
'private information in the AI chat.',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text('OK'),
),
],
);
},
);
}

// ==========================================================
// BLOCK COPY / PASTE
// ==========================================================

Widget _secureMessageField() {
return Focus(
onKeyEvent: (
FocusNode node,
KeyEvent event,
) {
if (event is KeyDownEvent) {
final bool isPasteShortcut =
HardwareKeyboard.instance.isControlPressed &&
event.logicalKey ==
LogicalKeyboardKey.keyV;

final bool isMacPasteShortcut =
HardwareKeyboard.instance.isMetaPressed &&
event.logicalKey ==
LogicalKeyboardKey.keyV;

if (isPasteShortcut ||
isMacPasteShortcut) {
return KeyEventResult.handled;
}
}

return KeyEventResult.ignored;
},
child: TextField(
controller: _messageController,
focusNode: _messageFocusNode,

textInputAction:
TextInputAction.send,

minLines: 1,
maxLines: 4,

maxLength: _maxMessageLength,

keyboardType:
TextInputType.multiline,

onSubmitted: (_) {
_sendMessage();
},

// Disable the normal long-press/click
// copy/paste/context menu.
contextMenuBuilder: (
context,
editableTextState,
) {
return const SizedBox.shrink();
},

decoration: InputDecoration(
hintText:
'Ask a cyber-safety question...',
counterText: '',
filled: true,
fillColor:
const Color(0xFFF5F7FB),

prefixIcon: const Icon(
Icons.security_rounded,
color: Color(0xFF0B3D91),
),

border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(25),
borderSide: BorderSide.none,
),

focusedBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(25),
borderSide: const BorderSide(
color: Color(0xFF0B3D91),
width: 1.2,
),
),

contentPadding:
const EdgeInsets.symmetric(
horizontal: 16,
vertical: 12,
),
),
),
);
}

// ==========================================================
// SCROLL
// ==========================================================

void _scrollToBottom() {
WidgetsBinding.instance
    .addPostFrameCallback((_) {
if (!_scrollController.hasClients) {
return;
}

_scrollController.animateTo(
_scrollController.position.maxScrollExtent,
duration:
const Duration(milliseconds: 300),
curve: Curves.easeOut,
);
});
}

// ==========================================================
// CLEAR CHAT
// ==========================================================

void _clearChat() {
showDialog(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text(
'Clear Chat',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
content: const Text(
'Are you sure you want to clear '
'this conversation?',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
Navigator.pop(dialogContext);

setState(() {
_messages.clear();

_messages.add({
'sender': 'ai',
'message':
'Hello! I am CyberSafe AI Assistant 🤖\n\n'
'How can I help you with cyber safety today?\n\n'
'Please do not share passwords, OTPs '
'or private information.',
});
});

_scrollToBottom();
},
child: const Text('Clear'),
),
],
);
},
);
}

// ==========================================================
// SNACKBAR
// ==========================================================

void _showMessage(String message) {
ScaffoldMessenger.of(context)
    .hideCurrentSnackBar();

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
behavior: SnackBarBehavior.floating,
),
);
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
const Color(0xFFF5F7FB),

appBar: AppBar(
backgroundColor:
const Color(0xFF0B3D91),
foregroundColor: Colors.white,
elevation: 0,
titleSpacing: 16,

title: Row(
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color: Colors.white
    .withValues(alpha: 0.15),
borderRadius:
BorderRadius.circular(13),
),
child: const Icon(
Icons.smart_toy_rounded,
color: Colors.white,
),
),

const SizedBox(width: 12),

const Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'CyberSafe AI',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
),
),
Text(
'Cyber Safety Assistant',
style: TextStyle(
fontSize: 11,
color: Colors.white70,
),
),
],
),
],
),

actions: [
IconButton(
tooltip: 'Clear chat',
onPressed: _clearChat,
icon: const Icon(
Icons.delete_outline_rounded,
),
),
],
),

body: Column(
children: [
Expanded(
child: ListView.builder(
controller:
_scrollController,
padding:
const EdgeInsets.fromLTRB(
16,
18,
16,
12,
),
itemCount:
_messages.length +
(_isTyping ? 1 : 0),

itemBuilder:
(context, index) {
if (_isTyping &&
index ==
_messages.length) {
return _typingBubble();
}

final message =
_messages[index];

final bool isUser =
message['sender'] ==
'user';

return _messageBubble(
message['message'] ?? '',
isUser,
);
},
),
),

if (_messages.length <= 2 &&
!_isTyping)
_quickQuestions(),

_messageInput(),
],
),
);
}

// ==========================================================
// MESSAGE BUBBLE
// ==========================================================

Widget _messageBubble(
String message,
bool isUser,
) {
return Align(
alignment: isUser
? Alignment.centerRight
    : Alignment.centerLeft,

child: Padding(
padding:
const EdgeInsets.only(
bottom: 12,
),

child: Row(
mainAxisAlignment: isUser
? MainAxisAlignment.end
    : MainAxisAlignment.start,

crossAxisAlignment:
CrossAxisAlignment.start,

children: [
if (!isUser)
Container(
width: 36,
height: 36,
margin:
const EdgeInsets.only(
right: 8,
),
decoration:
BoxDecoration(
color:
const Color(0xFFE8F0FE),
borderRadius:
BorderRadius.circular(12),
),
child: const Icon(
Icons.smart_toy_rounded,
size: 20,
color:
Color(0xFF0B3D91),
),
),

Flexible(
child: Container(
constraints:
const BoxConstraints(
maxWidth: 330,
),

padding:
const EdgeInsets.symmetric(
horizontal: 15,
vertical: 12,
),

decoration:
BoxDecoration(
color: isUser
? const Color(
0xFF0B3D91,
)
    : Colors.white,

borderRadius:
BorderRadius.circular(
17,
),

boxShadow: isUser
? null
    : [
BoxShadow(
color: Colors.black
    .withValues(
alpha: 0.05,
),
blurRadius: 6,
offset:
const Offset(
0,
2,
),
),
],
),

child: Text(
message,
style: TextStyle(
color: isUser
? Colors.white
    : const Color(
0xFF172B4D,
),
fontSize: 14,
height: 1.45,
),
),
),
),

if (isUser)
const SizedBox(
width: 44,
),
],
),
),
);
}

// ==========================================================
// TYPING INDICATOR
// ==========================================================

Widget _typingBubble() {
return Align(
alignment: Alignment.centerLeft,

child: Row(
children: [
Container(
width: 36,
height: 36,
decoration:
BoxDecoration(
color:
const Color(0xFFE8F0FE),
borderRadius:
BorderRadius.circular(12),
),
child: const Icon(
Icons.smart_toy_rounded,
size: 20,
color:
Color(0xFF0B3D91),
),
),

const SizedBox(width: 8),

Container(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
vertical: 13,
),
decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(17),
),
child: const Text(
'•••',
style: TextStyle(
fontSize: 18,
color:
Color(0xFF0B3D91),
),
),
),
],
),
);
}

// ==========================================================
// QUICK QUESTIONS
// ==========================================================

Widget _quickQuestions() {
const questions = [
'My account was hacked',
'I received a scam link',
'How do I report fraud?',
'Someone created a fake account',
];

return Container(
width: double.infinity,

padding:
const EdgeInsets.fromLTRB(
16,
8,
16,
8,
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [
const Text(
'Quick Questions',
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 13,
color: Color(0xFF172B4D),
),
),

const SizedBox(height: 8),

SingleChildScrollView(
scrollDirection:
Axis.horizontal,

child: Row(
children:
questions.map(
(question) {
return Padding(
padding:
const EdgeInsets.only(
right: 8,
),

child: ActionChip(
label: Text(
question,
style:
const TextStyle(
fontSize: 12,
),
),

onPressed:
_isTyping
? null
    : () {
_sendQuickQuestion(
question,
);
},
),
);
},
).toList(),
),
),
],
),
);
}

// ==========================================================
// MESSAGE INPUT
// ==========================================================

Widget _messageInput() {
return SafeArea(
top: false,

child: Container(
padding:
const EdgeInsets.fromLTRB(
12,
8,
12,
10,
),

decoration:
BoxDecoration(
color: Colors.white,
boxShadow: [
BoxShadow(
color: Colors.black
    .withValues(alpha: 0.08),
blurRadius: 8,
offset:
const Offset(0, -2),
),
],
),

child: Row(
crossAxisAlignment:
CrossAxisAlignment.end,

children: [
Expanded(
child:
_secureMessageField(),
),

const SizedBox(width: 8),

Container(
width: 48,
height: 48,

decoration:
BoxDecoration(
color:
const Color(0xFF0B3D91),
borderRadius:
BorderRadius.circular(16),
),

child: IconButton(
tooltip: 'Send',
onPressed:
_isTyping
? null
    : _sendMessage,

icon: const Icon(
Icons.send_rounded,
color: Colors.white,
),
),
),
],
),
),
);
}
}

