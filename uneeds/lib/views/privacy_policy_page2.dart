import 'package:flutter/material.dart';
import 'package:uneeds/utils/color.dart';

class PrivacyPolicy2Page extends StatelessWidget {
  const PrivacyPolicy2Page({super.key});

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
                'Kebijakan Privasi',
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
                    Icons.privacy_tip_outlined,
                    color: primaryBlueColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kebijakan ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi data pribadi Anda.',
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryBlueColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildPrivacySection(
              title: '1. Informasi yang Kami Kumpulkan',
              content: [
                'Informasi Akun: Nama, email, dan foto profil dari akun Google Anda.',
                'Data Aplikasi: Jadwal kuliah, catatan, target, dan pengaturan yang Anda buat.',
                'Data Penggunaan: Informasi tentang bagaimana Anda menggunakan aplikasi untuk peningkatan layanan.',
                'Data Perangkat: Jenis perangkat, sistem operasi, dan identifier unik untuk keperluan teknis.',
              ],
            ),

            _buildPrivacySection(
              title: '2. Bagaimana Kami Menggunakan Data',
              content: [
                'Menyediakan dan memelihara layanan aplikasi Uneeds.',
                'Menyinkronkan data Anda antar perangkat yang terhubung.',
                'Mengirim notifikasi pengingat sesuai pengaturan Anda.',
                'Menganalisis penggunaan untuk meningkatkan fitur dan pengalaman pengguna.',
                'Mendeteksi dan mencegah aktivitas yang mencurigakan atau melanggar ketentuan.',
              ],
            ),

            _buildPrivacySection(
              title: '3. Penyimpanan dan Keamanan Data',
              content: [
                'Data Anda disimpan dengan aman menggunakan enkripsi dan protokol keamanan standar industri.',
                'Kami menggunakan Firebase (Google Cloud) sebagai penyedia layanan cloud yang terpercaya.',
                'Akses ke data dibatasi hanya untuk personel yang memerlukan untuk operasional layanan.',
                'Kami melakukan backup data secara berkala untuk mencegah kehilangan data.',
              ],
            ),

            _buildPrivacySection(
              title: '4. Berbagi Data dengan Pihak Ketiga',
              content: [
                'Kami TIDAK menjual, menyewakan, atau membagikan data pribadi Anda untuk tujuan komersial.',
                'Data hanya dibagikan dengan penyedia layanan yang membantu operasional aplikasi (seperti Firebase).',
                'Kami dapat membagikan data yang telah dianonimkan untuk keperluan penelitian dan analisis.',
                'Dalam kondisi tertentu, kami dapat membagikan data jika diwajibkan oleh hukum.',
              ],
            ),

            _buildPrivacySection(
              title: '5. Hak Pengguna',
              content: [
                'Hak Akses: Anda dapat mengakses dan melihat data pribadi yang kami simpan.',
                'Hak Koreksi: Anda dapat mengubah atau memperbarui informasi pribadi Anda.',
                'Hak Penghapusan: Anda dapat meminta penghapusan akun dan semua data terkait.',
                'Hak Portabilitas: Anda dapat meminta salinan data pribadi dalam format yang dapat dibaca mesin.',
                'Hak Keberatan: Anda dapat menolak pemrosesan data untuk tujuan tertentu.',
              ],
            ),

            _buildPrivacySection(
              title: '6. Cookies dan Teknologi Pelacakan',
              content: [
                'Kami menggunakan teknologi pelacakan minimal untuk fungsi dasar aplikasi.',
                'Data analytics dikumpulkan secara anonim untuk memahami pola penggunaan.',
                'Anda dapat mengontrol beberapa pengaturan pelacakan melalui menu pengaturan aplikasi.',
                'Kami tidak menggunakan cookies untuk iklan atau pelacakan lintas platform.',
              ],
            ),

            _buildPrivacySection(
              title: '7. Perlindungan Data Anak',
              content: [
                'Aplikasi ini tidak secara khusus dirancang untuk anak-anak di bawah 13 tahun.',
                'Jika kami mengetahui bahwa kami telah mengumpulkan data dari anak di bawah 13 tahun, kami akan segera menghapusnya.',
                'Orang tua atau wali dapat menghubungi kami untuk meminta penghapusan data anak.',
              ],
            ),

            _buildPrivacySection(
              title: '8. Perubahan Kebijakan Privasi',
              content: [
                'Kami dapat memperbarui kebijakan privasi ini untuk mencerminkan perubahan dalam layanan atau hukum.',
                'Perubahan signifikan akan dikomunikasikan melalui notifikasi dalam aplikasi atau email.',
                'Tanggal "terakhir diperbarui" di bagian bawah menunjukkan versi terbaru kebijakan.',
              ],
            ),

            _buildPrivacySection(
              title: '9. Kontak untuk Masalah Privasi',
              content: [
                'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini, hubungi: privacy@uneeds.app',
                'Untuk melakukan permintaan terkait data pribadi, gunakan: datarequest@uneeds.app',
                'Tim privasi kami akan merespons dalam 7 hari kerja.',
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
                  Icon(
                    Icons.verified_user,
                    color: Colors.green[600],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Komitmen Privasi Kami',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kami berkomitmen penuh untuk melindungi privasi dan keamanan data Anda. Kepercayaan Anda adalah prioritas utama kami.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Terakhir diperbarui: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
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

  Widget _buildPrivacySection({
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