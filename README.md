# 👕 Chrome Hearts Streetwear App

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?logo=flutter)
![Golang](https://img.shields.io/badge/Backend-Golang-00ADD8?logo=go)
![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

> **Chrome Hearts Streetwear** adalah platform *e-commerce* premium dan eksklusif yang dirancang khusus untuk memudahkan pengguna berbelanja produk-produk original Chrome Hearts secara aman, cepat, dan terpercaya.

## 📖 Deskripsi Proyek & Latar Belakang

Pencinta *streetwear* seringkali kesulitan menemukan platform yang menjual produk original dengan jaminan autentisitas dan *user experience* (UX) yang berkelas layaknya *luxury brand*.

**Chrome Hearts Streetwear App** dibangun untuk menjawab kebutuhan tersebut. Aplikasi ini menghadirkan pengalaman berbelanja *streetwear* premium dari genggaman. Dengan backend **Golang** yang cepat dan andal untuk menangani pesanan (*orders*) dan keranjang belanja (*cart*), serta frontend **Flutter** yang menampilkan UI elegan dan *smooth*, proyek ini menghadirkan standar baru dalam aplikasi *fashion e-commerce*.

## ✨ Fitur Utama

1. **Katalog Produk Premium**: Tampilan etalase produk eksklusif dengan gambar beresolusi tinggi dan detail produk yang komprehensif.
2. **Sistem Keranjang (Cart) & Checkout**: Integrasi *cart* yang mulus dan proses *checkout* pemesanan (Order) yang terstruktur rapi.
3. **Manajemen Pengguna & Autentikasi**: Sistem login/register yang aman untuk melacak pesanan dan menyimpan wishlist.

## 📱 Screenshot / UI Demo

| Home / Catalog | Product Details | Cart & Checkout |
| :---: | :---: | :---: |
<img width="610" height="1356" alt="WhatsApp Image 2026-07-03 at 19 27 19" src="https://github.com/user-attachments/assets/d3ca6883-896d-46c2-9833-0567b38fc077" />
<img width="610" height="1356" alt="WhatsApp Image 2026-07-03 at 19 27 19 (3)" src="https://github.com/user-attachments/assets/238ae7ee-e8d8-427b-b632-1c6f66830139" />
<img width="610" height="1356" alt="WhatsApp Image 2026-07-03 at 19 27 19 (2)" src="https://github.com/user-attachments/assets/2b5ab31a-0084-4df9-91f2-db77a660f9e7" />
<img width="610" height="1356" alt="WhatsApp Image 2026-07-03 at 19 27 19 (1)" src="https://github.com/user-attachments/assets/d733c394-13ab-431c-94bb-fbcb8520b0b3" />
<img width="610" height="1356" alt="WhatsApp Image 2026-07-03 at 19 27 18" src="https://github.com/user-attachments/assets/da0fa1a7-109e-4162-94ed-2f38e15fe8f9" />
<img width="610" height="1356" alt="WhatsApp Image 2026-07-03 at 19 27 18 (3)" src="https://github.com/user-attachments/assets/776b12ea-6037-4eed-af9e-190b71635a62" />
<img width="610" height="1356" alt="WhatsApp Image 2026-07-03 at 19 27 18 (2)" src="https://github.com/user-attachments/assets/c5f1b198-b50e-46f8-b1d1-4b0d9a984228" />
<img width="610" height="1356" alt="WhatsApp Image 2026-07-03 at 19 27 18 (1)" src="https://github.com/user-attachments/assets/79eb75b5-6584-43c7-8dcd-9af8aa91710f" />


## 🛠️ Tech Stack

Proyek ini dibangun menggunakan teknologi mutakhir untuk memastikan skalabilitas, keamanan transaksi, dan *user experience* terbaik:

- **Frontend (Mobile App)**: Flutter (Dart)
- **State Management**: Provider / Riverpod 
- **Backend (API)**: Golang (Go)
- **Database**: PostgreSQL / MySQL
- **Architecture**: Clean Architecture & RESTful API

## 📐 Arsitektur Sistem & Database

Sistem ini memisahkan layer *Client* (Aplikasi Mobile) dan *Server* (REST API Golang). Berikut adalah gambaran relasi Entity-Relationship Diagram (ERD) utamanya:

```mermaid
erDiagram
    USERS ||--o{ ORDERS : "melakukan"
    USERS ||--o{ CARTS : "memiliki"
    CARTS ||--o{ CART_ITEMS : "berisi"
    PRODUCTS ||--o{ CART_ITEMS : "dimasukkan ke"
    PRODUCTS ||--o{ ORDER_ITEMS : "dibeli dalam"
    ORDERS ||--o{ ORDER_ITEMS : "terdiri dari"

    USERS {
        uuid id PK
        string nama
        string email
        string password
    }
    PRODUCTS {
        uuid id PK
        string nama_produk
        decimal harga
        string deskripsi
        int stok
    }
    CARTS {
        uuid id PK
        uuid user_id FK
    }
    ORDERS {
        uuid id PK
        uuid user_id FK
        decimal total_harga
        string status_pesanan
        datetime created_at
    }
```

## ⚙️ Prasyarat Instalasi

Pastikan sistem operasi kamu sudah terinstal *tools* berikut:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0+)
- [Golang](https://go.dev/doc/install) (v1.20+)
- Database Server (PostgreSQL/MySQL) yang berjalan di *local* atau *remote*.

## 🚀 Cara Menjalankan Proyek (Installation Guide)

### 1. Setup Backend (Golang)
```bash
# Buka terminal dan masuk ke direktori backend
cd ch-streetwear-backend

# Salin file environment dan atur koneksi database (jika ada)
cp .env.example .env

# Unduh semua dependencies Go
go mod tidy

# Jalankan server
go run main.go
```

### 2. Setup Frontend (Flutter)
```bash
# Buka tab terminal baru, masuk ke direktori frontend
cd chrome_hearts

# Unduh dependencies Flutter
flutter pub get

# Jalankan aplikasi di emulator atau physical device
flutter run
```

## 📂 Struktur Direktori Utama

```text
📦 uts(chrome hearts)
 ┣ 📂 ch-streetwear-backend/      # Backend Service (Golang)
 ┃ ┣ 📂 models/                   # Berisi entity Cart, Order, User, dll
 ┃ ┣ 📂 controllers/              # Handler logika HTTP
 ┃ ┣ 📂 routes/                   # Routing endpoint API
 ┃ ┗ 📜 main.go                   # Entry point backend
 ┃
 ┗ 📂 chrome_hearts/              # Frontend App (Flutter)
   ┣ 📂 lib/
   ┃ ┣ 📂 core/                   # Konstanta, Tema, Utils
   ┃ ┣ 📂 models/                 # Data class mobile
   ┃ ┣ 📂 screens/                # UI Presentation Layer
   ┃ ┣ 📂 services/               # Integrasi HTTP / API
   ┃ ┗ 📜 main.dart               # Entry point mobile app
```

## 🤝 Panduan Berkontribusi

1. *Fork* repository ini.
2. Buat branch fitur baru (`git checkout -b feature/FiturBaru`).
3. *Commit* perubahanmu (`git commit -m 'Menambahkan FiturBaru'`).
4. *Push* ke branch tersebut (`git push origin feature/FiturBaru`).
5. Buat *Pull Request*.

## 📜 Lisensi & Kontak

Proyek ini menggunakan lisensi [MIT License](LICENSE).

**Dikembangkan oleh:**  
[Masukkan Nama Kamu] – [Masukkan Email atau LinkedIn]  
Jika ada pertanyaan atau menemukan *bug*, silakan buat [Issue] baru di repository ini.
