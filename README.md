# 🛠️ FiTools - Blue Edition

**FiTools** adalah script manajemen server portabel berbasis Termux yang menggabungkan fitur **Video/Music Downloader** dan **URL Shortener** dalam satu dashboard web yang estetik dan ringan.



## 🌟 Fitur Utama
* **📥 Universal Downloader**: Mengunduh video atau musik (MP3) dari berbagai platform menggunakan `yt-dlp`.
* **🔗 URL Shortener**: Membuat link pendek dengan dukungan *Custom Name* dan *Expiration Date* (3-30 hari).
* **🧹 Auto-Clean Cache**: Otomatis menghapus file hasil unduhan (Video/Musik) setelah 1 hari untuk menjaga ruang penyimpanan HP.
* **☁️ Cloudflare Tunnel Integration**: Membuka server lokal ke publik menggunakan Cloudflare Tunnel tanpa perlu Port Forwarding.
* **📊 Database Management**: Manajemen link aktif langsung dari terminal menggunakan SQLite3.

## 🚀 Cara Instalasi

Pastikan Anda menggunakan **Termux** versi terbaru (F-Droid disarankan).

1. **Clone Repository**
   ```
   git clone https://github.com/Fitunnel/FiTools
   cd FiTools
   ```
2. **Jalankan**
   ```
   chmod +x FiTools.sh
   ./FiTools.sh
   ```
