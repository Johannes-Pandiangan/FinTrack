import 'package:flutter/material.dart';

class FinAIScreen extends StatefulWidget {
  const FinAIScreen({Key? key}) : super(key: key);

  @override
  State<FinAIScreen> createState() => _FinAIScreenState();
}

class _FinAIScreenState extends State<FinAIScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;

  // Struktur data simulasi untuk menyimpan riwayat chat
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Halo! Saya FinAI, asisten keuangan pribadi Anda. Berdasarkan riwayat pengeluaran Anda bulan ini, ada yang bisa saya bantu analisis atau sarankan?',
    }
  ];

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    String text = _chatController.text.trim();
    if (text.isEmpty) return;

    // 1. Tambahkan pesan pengguna ke layar
    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _chatController.clear();
      _isTyping = true; // Munculkan indikator "AI sedang mengetik..."
    });

    _scrollToBottom();

    // 2. Simulasi jeda waktu berpikir AI (1.5 detik)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. Tambahkan balasan statis dari AI (Simulasi)
    setState(() {
      _isTyping = false;
      _messages.add({
        'isUser': false,
        'text': 'Berdasarkan data Anda, porsi pengeluaran "Makanan & Minuman" cukup tinggi. Saya sarankan untuk mencoba memasak sendiri di kos 2-3 kali seminggu untuk menghemat saldo hingga akhir bulan. Tetap semangat mengatur keuangan ya!',
      });
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    // Animasi otomatis menggulir layar ke chat paling bawah
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE5F5EF),
              child: Icon(Icons.smart_toy_outlined, color: Color(0xFF0C5A3E)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('FinAI Assistant', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Area Riwayat Chat
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg['text'], msg['isUser']);
              },
            ),
          ),

          // 2. Indikator "Mengetik"
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('FinAI sedang mengetik...', style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            ),

          // 3. Area Input Teks
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Tanyakan saran keuangan...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF4F7F6),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF0C5A3E),
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF0C5A3E) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            if (!isUser) BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14, height: 1.4),
        ),
      ),
    );
  }
}