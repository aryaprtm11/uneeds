import 'package:flutter/material.dart';
import 'package:uneeds/utils/color.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FD),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                'Kebijakan Pengguna',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B4865),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2B4865),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: primaryBlueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryBlueColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primaryBlueColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kebijakan ini menjelaskan ketentuan penggunaan aplikasi Uneeds dan hak serta kewajiban pengguna.',
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryBlueColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildPolicySection(
              title: '1. Ketentuan Umum',
              content: [
                'Dengan menggunakan aplikasi Uneeds, Anda menyetujui untuk mematuhi semua ketentuan dan syarat yang berlaku.',
                'Uneeds adalah aplikasi manajemen produktivitas untuk membantu mahasiswa mengelola jadwal, catatan, dan target akademik.',
                'Pengguna harus berusia minimal 17 tahun atau memiliki persetujuan dari orang tua/wali.',
              ],
            ),

            _buildPolicySection(
              title: '2. Akun Pengguna',
              content: [
                'Anda bertanggung jawab untuk menjaga keamanan akun dan kata sandi Anda.',
                'Informasi yang Anda berikan harus akurat dan terkini.',
                'Kami berhak menonaktifkan akun yang melanggar ketentuan penggunaan.',
                'Setiap aktivitas yang terjadi di akun Anda adalah tanggung jawab Anda.',
              ],
            ),

            _buildPolicySection(
              title: '3. Penggunaan Aplikasi',
              content: [
                'Aplikasi ini hanya boleh digunakan untuk tujuan pendidikan dan produktivitas yang sah.',
                'Dilarang menggunakan aplikasi untuk aktivitas yang melanggar hukum atau merugikan pihak lain.',
                'Konten yang Anda buat (catatan, jadwal, target) adalah milik Anda dan akan dijaga kerahasiaannya.',
                'Kami berhak membatasi atau menghentikan layanan jika terjadi penyalahgunaan.',
              ],
            ),

            _buildPolicySection(
              title: '4. Data dan Privasi',
              content: [
                'Kami menghormati privasi pengguna dan berkomitmen melindungi data pribadi Anda.',
                'Data yang dikumpulkan hanya untuk keperluan operasional aplikasi dan peningkatan layanan.',
                'Kami tidak akan membagikan data pribadi Anda kepada pihak ketiga tanpa persetujuan.',
                'Anda memiliki hak untuk mengakses, mengubah, atau menghapus data pribadi Anda.',
              ],
            ),

            _buildPolicySection(
              title: '5. Batasan Tanggung Jawab',
              content: [
                'Uneeds disediakan "sebagaimana adanya" tanpa jaminan tersurat atau tersirat.',
                'Kami tidak bertanggung jawab atas kerugian yang timbul dari penggunaan aplikasi.',
                'Ketersediaan layanan dapat berubah sewaktu-waktu untuk maintenance atau perbaikan.',
                'Backup data secara berkala disarankan untuk menghindari kehilangan data.',
              ],
            ),

            _buildPolicySection(
              title: '6. Konten dan Hak Kekayaan Intelektual',
              content: [
                'Semua elemen aplikasi (desain, kode, logo) adalah hak milik pengembang.',
                'Anda dilarang menyalin, memodifikasi, atau mendistribusikan aplikasi tanpa izin.',
                'Konten yang Anda buat tetap menjadi hak milik Anda.',
                'Laporkan jika menemukan pelanggaran hak cipta atau konten yang tidak pantas.',
              ],
            ),

            _buildPolicySection(
              title: '7. Pembaruan Kebijakan',
              content: [
                'Kebijakan ini dapat diperbarui sewaktu-waktu untuk menyesuaikan dengan perubahan layanan.',
                'Notifikasi akan diberikan untuk perubahan kebijakan yang signifikan.',
                'Penggunaan berkelanjutan setelah pembaruan dianggap sebagai persetujuan terhadap kebijakan baru.',
              ],
            ),

            _buildPolicySection(
              title: '8. Kontak dan Dukungan',
              content: [
                'Untuk pertanyaan atau keluhan, hubungi tim support melalui email: support@uneeds.app',
                'Tim support akan merespons dalam 1-3 hari kerja.',
                'Sertakan detail yang jelas saat melaporkan masalah atau memberikan saran.',
              ],
            ),

            const SizedBox(height: 32),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Text(
                    'Terakhir diperbarui: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dengan menggunakan aplikasi Uneeds, Anda menyatakan telah membaca, memahami, dan menyetujui seluruh ketentuan dalam kebijakan pengguna ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required List<String> content,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlueColor,
            ),
          ),
          const SizedBox(height: 12),
          ...content.map((text) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  decoration: BoxDecoration(
                    color: primaryBlueColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
} 