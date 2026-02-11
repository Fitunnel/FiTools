#!/bin/bash

# Folder Proyek & File
DIR="$HOME/fitools"
INDEX="$DIR/index.php"
DB="$DIR/links.db"
DOMAIN_FILE="$DIR/domain.txt"
DOWNLOAD_DIR="$DIR/downloads"

# Warna Terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

show_menu() {
    clear
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${BLUE}      F IT O O L S - BLUE EDITION      ${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo -e "1) Install & Update (Auto-Clean All)"
    echo -e "2) Atur Domain / Subdomain"
    echo -e "3) Jalankan Server (ON)"
    echo -e "4) Matikan Server (OFF)"
    echo -e "5) Manajemen Tunnel & Info DNS"
    echo -e "6) Manajemen Link (Lihat/Hapus)"
    echo -e "7) Reset Semua Proyek"
    echo -e "8) Keluar"
    echo -e "${BLUE}=======================================${NC}"
    read -p "Pilih menu [1-8]: " pilihan
}

while true; do
    show_menu
    case $pilihan in
        1)
            echo -e "${GREEN}Mengupdate sistem & Pembersihan Cache...${NC}"
            rm -f "$DB"
            pkg update && pkg upgrade -y
            pkg install php cloudflared python ffmpeg sqlite screen -y
            pip install yt-dlp
            mkdir -p $DIR && mkdir -p $DOWNLOAD_DIR
            chmod 777 $DOWNLOAD_DIR
            
            cat <<EOF > $INDEX
<?php
\$db_file = 'links.db';
\$download_dir = 'downloads/';

if (is_dir($download_dir)) {
    $files = glob($download_dir . '*');
    foreach ($files as $file) {
        if (is_file($file) && time() - filemtime($file) > 86400) {
            unlink($file);
        }
    }
}

try {
    \$db = new PDO("sqlite:\$db_file");
    \$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    \$db->exec("CREATE TABLE IF NOT EXISTS links (id INTEGER PRIMARY KEY, code TEXT, url TEXT, expires_at DATETIME)");
    \$db->exec("DELETE FROM links WHERE expires_at < DATETIME('now') AND expires_at IS NOT NULL");
} catch (Exception \$e) { die("Database Error."); }

\$msg = "";

if (isset(\$_POST['action']) && \$_POST['action'] == 'download') {
    array_map('unlink', glob("\$download_dir*"));
    \$url = escapeshellarg(\$_POST['d_url']);
    \$res_val = \$_POST['format'];
    \$opt = (\$res_val == 'mp3') ? "-x --audio-format mp3" : "-f 'bestvideo[height<=".\$res_val."]+bestaudio/best' --merge-output-format mp4";
    \$output_template = \$download_dir . "%(title)s.%(ext)s";
    \$cmd = "yt-dlp \$opt --restrict-filenames -o " . escapeshellarg(\$output_template) . " " . \$url . " 2>&1";
    exec(\$cmd, \$output, \$res);
    if (\$res === 0) {
        \$new_files = glob(\$download_dir . "*");
        if (\$new_files) {
            \$file_path = \$new_files[0];
            \$msg = "<div style='color:#3498db;border:1px solid #3498db;padding:15px;border-radius:12px;'><b>Berhasil!</b><br><small style='color:#888'>".basename(\$file_path)."</small><br><a href='\$file_path' download style='display:inline-block;background:#3498db;color:white;padding:12px 25px;margin-top:10px;text-decoration:none;border-radius:8px;font-weight:bold;'>UNDUH SEKARANG</a><br><p style='font-size:10px;color:#666;margin-top:5px;'>File otomatis dihapus dalam 5 menit.</p></div>";
        }
    } else { \$msg = "<div style='color:#e74c3c;'>Gagal memproses media.</div>"; }
}

if (isset(\$_POST['action']) && \$_POST['action'] == 'shorten') {
    \$url = \$_POST['url'];
    \$custom = trim(\$_POST['custom']);
    \$days = (int)\$_POST['expiry'];
    \$code = !empty(\$custom) ? preg_replace('/[^a-zA-Z0-9]/', '', \$custom) : substr(md5(uniqid()), 0, 5);
    \$expiry_date = (\$days > 0) ? date('Y-m-d H:i:s', strtotime("+\$days days")) : null;
    \$stmt = \$db->prepare("INSERT INTO links (code, url, expires_at) VALUES (?, ?, ?)");
    if(\$stmt->execute([\$code, \$url, \$expiry_date])) {
        \$domain = trim(@file_get_contents('domain.txt')) ?: \$_SERVER['HTTP_HOST'];
        \$short = "https://".\$domain."/".\$code;
        \$msg = "<div style='color:#3498db;'><b>Link Pendek:</b><br><input type='text' value='\$short' readonly onclick='this.select()' style='width:100%;text-align:center;padding:12px;background:#152333;color:white;border:1px solid #1e3a5a;margin-top:10px;border-radius:8px;'></div>";
    }
}

\$path = trim(\$_SERVER['REQUEST_URI'], '/');
if (\$path && !strpos(\$path, '.php') && !strpos(\$path, 'downloads/')) {
    \$stmt = \$db->prepare("SELECT url FROM links WHERE code = ?");
    \$stmt->execute([\$path]);
    \$row = \$stmt->fetch();
    if (\$row) { header("Location: " . \$row['url']); exit; }
}
?>
<!DOCTYPE html><html><head><title>FiTools Blue</title><meta name='viewport' content='width=device-width,initial-scale=1'><style>
body{font-family:sans-serif;background:#050a0f;color:#dce4f0;margin:0;padding:15px}
.card{background:#0d1621;padding:25px;border-radius:15px;max-width:450px;margin:10px auto;text-align:center;border:1px solid #1e3a5a;box-shadow:0 10px 30px rgba(0,0,0,0.5)}
h2,h3{color:#3498db;margin:10px 0;text-transform:uppercase;letter-spacing:1px}
input,select,button{width:100%;padding:14px;margin:10px 0;border-radius:10px;border:1px solid #1e3a5a;box-sizing:border-box;background:#152333;color:white;font-size:15px}
button{background:#3498db;border:none;font-weight:bold;cursor:pointer;color:white;transition:0.3s}
button:hover{background:#2980b9;transform:translateY(-2px)}
.footer{font-size:11px;color:#4a6583;margin-top:25px;text-align:center}
</style></head>
<body>
    <div class='card'><h2>FiTools Blue 🛠️</h2><?=\$msg?></div>
    <div class='card'>
        <h3>📥 Downloader</h3>
        <form method='post'><input type='hidden' name='action' value='download'><input type='url' name='d_url' placeholder='Link Video / Musik' required>
        <select name='format'><option value='1080'>1080p</option><option value='720' selected>720p</option><option value='480'>480p</option><option value='mp3'>Musik MP3</option></select><button type='submit'>Mulai Proses</button></form>
    </div>
    <div class='card'>
        <h3>🔗 Shortlink</h3>
        <form method='post'><input type='hidden' name='action' value='shorten'><input type='url' name='url' placeholder='Link Panjang' required><input type='text' name='custom' placeholder='Custom Nama'>
        <select name='expiry'><option value='0'>Permanen</option><option value='3'>3 Hari</option><option value='7'>7 Hari</option><option value='30'>30 Hari</option></select>
        <button type='submit'>Pendekkan</button></form>
    </div>
    <div class='footer'>Fitunnel Project © 2026</div>
</body></html>
EOF
            echo -e "${GREEN}Update Selesai!${NC}"
            sleep 2
            ;;
        2)
            mkdir -p "$DIR"
            read -p "Masukkan Domain (contoh: tools.alfinet.my.id): " INPUT_DOMAIN
            if [ ! -z "$INPUT_DOMAIN" ]; then
                echo "$INPUT_DOMAIN" > "$DOMAIN_FILE"
                DOMAIN="$INPUT_DOMAIN"
                echo -e "${GREEN}Domain berhasil diset ke: $DOMAIN${NC}"
            else
                echo -e "${RED}Domain tidak boleh kosong!${NC}"
            fi
            sleep 2
            ;;
        3)
            [ -z "$DOMAIN" ] && DOMAIN=$(cat "$DOMAIN_FILE" 2>/dev/null)
            if [ -z "$DOMAIN" ]; then 
                echo -e "${RED}Error: Atur domain dulu di Menu 2!${NC}"
            else
                echo -e "${BLUE}Menghidupkan Server untuk $DOMAIN...${NC}"
                pkill -9 -f "php -S"; pkill -9 cloudflared
                cd $DIR && screen -dmS phptools php -S 127.0.0.1:8080
                screen -dmS tunnel cloudflared tunnel run --url http://127.0.0.1:8080 termux-fitools
                echo -e "${GREEN}✅ ONLINE: https://$DOMAIN${NC}"
            fi
            sleep 2
            ;;
        4)
            pkill -9 -f "php -S"; pkill -9 cloudflared
            echo -e "${RED}🛑 Server telah dimatikan.${NC}"
            sleep 1
            ;;
        5)
            clear
            echo -e "${BLUE}=== MANAJEMEN TUNNEL & DNS ===${NC}"
            echo "1) Lihat ID & Info DNS Record"
            echo "2) Login Cloudflare (Ambil Cert)"
            echo "3) Reset & Buat Tunnel Baru"
            echo "4) Hubungkan Domain (Auto Route)"
            echo "5) Kembali"
            read -p "Pilih [1-5]: " t_pilih
            case $t_pilih in
                1)
                    ID_TUN=$(cloudflared tunnel list | grep "termux-fitools" | awk '{print $1}')
                    if [ -z "$ID_TUN" ]; then echo "Tunnel belum dibuat.";
                    else
                        echo -e "\n${CYAN}--- INFO CLOUDFLARE ---${NC}"
                        echo -e "Type   : ${GREEN}CNAME${NC}"
                        echo -e "Name   : ${GREEN}tools${NC}"
                        echo -e "Target : ${YELLOW}${ID_TUN}.cfargotunnel.com${NC}"
                        echo -e "Proxy  : ${YELLOW}ON (Awan Orange)${NC}"
                        echo -e "TTL    : ${YELLOW}Auto${NC}"
                        echo -e "${CYAN}-----------------------${NC}"
                    fi
                    ;;
                2)
                    echo -e "${YELLOW}Silakan klik link yang muncul untuk Login:${NC}"
                    cloudflared tunnel login
                    ;;
                3)
                    cloudflared tunnel delete -f termux-fitools > /dev/null 2>&1
                    cloudflared tunnel create termux-fitools
                    echo -e "${GREEN}Tunnel baru berhasil dibuat!${NC}"
                    ;;
                4)
                    read -p "Masukkan domain untuk Route: " D_DNS
                    cloudflared tunnel route dns termux-fitools $D_DNS
                    ;;
            esac
            read -p "Tekan Enter..."
            ;;
        6)
            clear
            echo -e "${BLUE}--- DAFTAR LINK AKTIF ---${NC}"
            if [ ! -f "$DB" ]; then echo "Kosong.";
            else
                sqlite3 "$DB" "SELECT id, code, CASE WHEN expires_at IS NULL THEN 'PERMANEN' ELSE expires_at END, url FROM links;" | sed 's/|/ | /g'
                read -p "ID Hapus: " DEL_ID
                [ ! -z "$DEL_ID" ] && sqlite3 "$DB" "DELETE FROM links WHERE id=$DEL_ID;" && echo "Dihapus!"
            fi
            read -p "Enter..."
            ;;
        7)
            read -p "Reset semua? (y/n): " confirm
            [[ "$confirm" == "y" ]] && rm -rf $DIR && echo "Dibersihkan!"
            sleep 1
            ;;
        8) exit 0 ;;
    esac
done
