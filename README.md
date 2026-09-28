# 🚀 AutoScriptSamBa_CentOS7

<p align="center">
  <img src="https://img.shields.io/badge/OS-CentOS%207-blue?style=for-the-badge&logo=centos" alt="CentOS 7">
  <img src="https://img.shields.io/badge/Service-Samba%204.x-orange?style=for-the-badge&logo=linux" alt="Samba">
  <img src="https://img.shields.io/badge/Script-Bash%20Shell-green?style=for-the-badge&logo=gnu-bash" alt="Bash">
  <img src="https://img.shields.io/badge/Protocol-SMB%20%2F%20CIFS-red?style=for-the-badge" alt="SMB/CIFS">
  <img src="https://img.shields.io/badge/Version-11%20Chức%20Năng-purple?style=for-the-badge" alt="Bản 11 Chức năng">
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=for-the-badge" alt="License">
</p>

> **Đề tài**: Xây dựng kịch bản tự động hóa (Auto Script) cài đặt, cấu hình, quản trị phân quyền dịch vụ **Samba Server trên CentOS 7** và thiết lập chia sẻ dữ liệu hai chiều với máy trạm **Windows Client**.

---

## 📑 Mục lục
1. [Giới thiệu đề tài](#-giới-thiệu-đề-tài)
2. [Tính năng nổi bật (Bản 11 Chức năng)](#-tính-năng-nổi-bật-bản-11-chức-năng)
3. [Cấu trúc thư mục dự án](#-cấu-trúc-thư-mục-dự-án)
4. [Yêu cầu hệ thống & Chuẩn bị](#-yêu-cầu-hệ-thống--chuẩn-bị)
5. [Hướng dẫn cài đặt & Sử dụng nhanh](#-hướng-dẫn-cài-đặt--sử-dụng-nhanh)
6. [Chi tiết các chức năng trong Script](#-chi-tiết-các-chức-năng-trong-script)
   - [Bảng tổng hợp 11 chức năng chính](#bảng-tổng-hợp-11-chức-năng-chính)
   - [Menu con: Quản lý tài khoản & Phân quyền nâng cao (Chức năng 10)](#menu-con-quản-lý-tài-khoản--phân-quyền-nâng-cao-chức-năng-10)
7. [Quy trình Backtest & Demo thực tế](#-quy-trình-backtest--demo-thực-tế)
   - [Bước 1: Cài đặt & Kích hoạt Samba (Chức năng 1)](#bước-1-cài-đặt--kích-hoạt-samba-chức-năng-1)
   - [Bước 2: Tạo thư mục Anonymous (Chức năng 2 & 7)](#bước-2-tạo-thư-mục-anonymous-chức-năng-2--7)
   - [Bước 3: Tạo Group, User & Thư mục bảo mật (Chức năng 3 & 7)](#bước-3-tạo-group-user--thư-mục-bảo-mật-chức-năng-3--7)
   - [Bước 4: Kiểm tra truy cập từ máy Windows Client](#bước-4-kiểm-tra-truy-cập-từ-máy-windows-client)
   - [Bước 5: Windows chia sẻ ngược lại cho Linux (Chức năng 8)](#bước-5-windows-chia-sẻ-ngược-lại-cho-linux-chức-năng-8)
   - [Bước 6: Phân quyền Đọc/Ghi nâng cao (Chức năng 10)](#bước-6-phân-quyền-đọcghi-nâng-cao-chức-năng-10)
   - [Bước 7: Kiểm tra cú pháp (Chức năng 6) & Xóa Share (Chức năng 9)](#bước-7-kiểm-tra-cú-pháp-chức-năng-6--xóa-share-chức-năng-9)
   - [Bước 8: Khôi phục cấu hình tức thì - Rollback (Chức năng 11)](#bước-8-khôi-phục-cấu-hình-tức-thì---rollback-chức-năng-11)
8. [Xử lý sự cố thường gặp (Troubleshooting)](#-xử-lý-sự-cố-thường-gặp-troubleshooting)
9. [Giấy phép & Bản quyền (License & Usage)](#-giấy-phép--bản-quyền-license--usage)

---

## 📖 Giới thiệu đề tài

Trong môi trường mạng doanh nghiệp hỗn hợp (Heterogeneous Network), việc chia sẻ tệp tin và phân quyền truy cập giữa máy chủ Linux và các máy trạm Windows là nhu cầu tất yếu. **Samba** là giải pháp mã nguồn mở hàng đầu triển khai giao thức SMB/CIFS trên Linux.

Tuy nhiên, việc cấu hình Samba trên **CentOS 7** theo cách truyền thống đòi hỏi nhiều thao tác phức tạp:
- Khai báo file cấu hình `/etc/samba/smb.conf` dễ xảy ra sai sót cú pháp hoặc dính dòng làm hỏng cấu hình toàn bộ dịch vụ.
- Phải đồng bộ tài khoản người dùng giữa hệ điều hành Linux và cơ sở dữ liệu Samba (`smbpasswd` / `pdbedit`).
- Quản lý phân quyền 3 lớp: Quyền hệ thống POSIX (`chmod`, `chown`), Quyền dịch vụ Samba (`valid users`, `write list`, `read list`), và Nhãn bảo mật **SELinux** (`samba_share_t`).
- Thiếu cơ chế kiểm soát rủi ro, phân quyền chi tiết (Read-only vs Read-Write) và khả năng hoàn tác khi gặp lỗi.

**AutoScriptSamBa_CentOS7** là bộ công cụ tự động hóa toàn diện được thiết kế để giải quyết triệt để các vấn đề trên thông qua một giao diện menu tương tác thân thiện, bẫy lỗi đầu vào thông minh, phân quyền chuyên sâu và cơ chế **Rollback** an toàn.

---

## ✨ Tính năng nổi bật (Bản 11 Chức năng)

- ⚡ **Cài đặt 1-Click (Chức năng 1)**: Tự động cài đặt đầy đủ gói Samba, CIFS utils, kích hoạt dịch vụ và mở tường lửa FirewallD chỉ với một thao tác.
- 👥 **Phân quyền Đọc/Ghi nâng cao (Mới - Chức năng 10)**: 
  - Tách bạch rõ ràng danh sách tài khoản được phép Ghi (`write list`) và tài khoản Chỉ Đọc (`read list`).
  - Hỗ trợ tạo mới tài khoản Samba bảo mật (tự động khóa shell `/sbin/nologin`, không tạo thư mục home thừa).
  - Hỗ trợ gỡ bỏ tài khoản Samba và tùy chọn xóa sạch user trên hệ điều hành Linux.
- ⏪ **Khôi phục cấu hình tức thì - Rollback (Mới - Chức năng 11)**:
  - Tự động quét và liệt kê các bản sao lưu trong `/etc/samba/backups/` theo thứ tự thời gian mới nhất.
  - Hoàn tác file `smb.conf` về trạng thái trước đó chỉ trong 1 giây nếu cấu hình mới gặp trục trặc.
- 🛡️ **Bẫy lỗi Input & Chống dính dòng (Mới)**:
  - Tự động bẫy lỗi khi người dùng nhập khoảng trắng hoặc để trống tên thư mục/IP.
  - Tự động chèn dòng ngắt trước mỗi khối cấu hình mới, triệt tiêu hoàn toàn lỗi dính dòng trong `smb.conf`.
- 💾 **Cơ chế Sao lưu tự động (Auto Backup)**: Tự động tạo bản backup `smb.conf.bak_<timestamp>` trước mọi thao tác ghi hoặc xóa cấu hình.
- 🔍 **Kiểm tra cú pháp Testparm (Chức năng 6)**: Rà soát tính hợp lệ của toàn bộ file cấu hình trước khi khởi động lại dịch vụ.
- 🗑️ **Xóa bỏ Share an toàn & Dọn file (Chức năng 9)**: Ứng dụng `awk` bóc tách và xóa sạch block cấu hình của share cần gỡ, kèm tùy chọn dọn dẹp thư mục vật lý trên ổ đĩa.
- 🔄 **Chia sẻ hai chiều (2-Way Sharing - Chức năng 8)**: Hỗ trợ kết nối và **mount CIFS** để lấy dữ liệu từ thư mục chia sẻ trên Windows về Linux.

---

## 📂 Cấu trúc thư mục dự án

```text
AutoScriptSamBa_CentOS7/
│
├── samba_manager.sh       # Kịch bản chính quản trị tự động hóa Samba (Bản 11 chức năng)
└── README.md              # Hướng dẫn chi tiết sử dụng và triển khai đồ án
```

---

## ⚙️ Yêu cầu hệ thống & Chuẩn bị

### 1. Phía máy chủ Linux (CentOS 7)
- Hệ điều hành: **CentOS 7** (card mạng cấu hình chế độ `Host-Only` hoặc `NAT` cùng dải mạng với máy Windows).
- Quyền thực thi: Tài khoản `root` hoặc có quyền `sudo`.
- *(Không bắt buộc cấu hình trước)*: Bạn chỉ cần khởi chạy kịch bản và chọn **Chức năng 1**, hệ thống sẽ tự động cài đặt trọn gói các gói `samba`, `cifs-utils` và mở cổng FirewallD.

### 2. Phía máy trạm Windows Client
- Hệ điều hành: **Windows 10 / 11** hoặc Windows Server.
- Cùng dải mạng LAN / Mạng ảo với máy chủ CentOS 7 (kiểm tra thông mạng bằng lệnh `ping`).

---

## 📥 Hướng dẫn cài đặt & Sử dụng nhanh

### Bước 1: Clone dự án về máy CentOS 7
Mở Terminal trên CentOS 7 và thực hiện:
```bash
# Cài đặt git nếu chưa có
yum install -y git

# Clone repository
git clone https://github.com/vannam52/AutoScriptSamBa_CentOS7.git
```

### Bước 2: Di chuyển vào thư mục dự án và cấp quyền thực thi
```bash
cd AutoScriptSamBa_CentOS7
chmod +x samba_manager.sh
```

### Bước 3: Khởi chạy kịch bản quản trị
```bash
sudo ./samba_manager.sh
```

Giao diện menu quản trị 11 chức năng xuất hiện như sau:

```text
========================================================================
               CHƯƠNG TRÌNH AUTO SCRIPT QUẢN LÝ DỊCH VỤ SAMBA
========================================================================
  1. Kiểm tra môi trường & Cài đặt Samba
  2. Tự động tạo Thư mục chia sẻ Anonymous (Vô danh)
  3. Tự động tạo Group, User & Thư mục chia sẻ theo Group
  4. Xem danh sách Thư mục chia sẻ và User hiện tại
  5. Giám sát các máy Client đang kết nối (smbstatus)
  6. Kiểm tra lỗi cú pháp cấu hình (Testparm)
  7. Lưu cấu hình (Backup) & Khởi động lại dịch vụ (Apply)
  8. Tự động kết nối và nhận file từ máy Client (Windows)
  9. Xóa bỏ Thư mục chia sẻ (Gỡ cấu hình & Dọn file)
 10. Quản lý tài khoản và Phân quyền truy cập Samba
 11. Khôi phục cấu hình từ bản sao lưu (Rollback)
  0. Thoát chương trình
========================================================================
Vui lòng chọn chức năng (0-11): 
```

---

## 🛠️ Chi tiết các chức năng trong Script

### Bảng tổng hợp 11 chức năng chính

| Phím tắt | Tên chức năng | Mô tả hoạt động chi tiết |
| :---: | :--- | :--- |
| **`1`** | **Kiểm tra & Cài đặt Samba** | Cài đặt tự động `samba`, `samba-client`, `samba-common`, `cifs-utils` qua `yum`. Bật khởi động cùng hệ thống (`systemctl enable`), kích hoạt dịch vụ và mở Firewall cho dịch vụ Samba. |
| **`2`** | **Tạo Thư mục Anonymous** | Bẫy lỗi khoảng trắng. Tạo thư mục `/samba_share/<tên>`, cấp quyền `777`, gán nhãn SELinux `samba_share_t`, chống dính dòng và lưu cấu hình `guest ok = yes` vào `smb.conf`. *(Chạy Chức năng 7 để áp dụng)*. |
| **`3`** | **Tạo Group, User & Thư mục bảo mật** | Tạo Group, tạo Linux user có shell `/sbin/nologin` (bảo mật, không tạo thư mục cá nhân thừa), đặt mật khẩu Samba (`smbpasswd -a`), phân quyền thư mục `770` cho nhóm và gán `valid users = @<group>`. *(Chạy Chức năng 7 để áp dụng)*. |
| **`4`** | **Xem danh sách Share & User** | Trích xuất các section thư mục chia sẻ đang hoạt động từ `smb.conf` (loại bỏ `[global]`) và liệt kê toàn bộ tài khoản Samba qua `pdbedit -L`. |
| **`5`** | **Giám sát kết nối Client** | Chạy lệnh `smbstatus` theo dõi các phiên kết nối thời gian thực: địa chỉ IP máy Client, User đang truy cập, và danh sách các tệp tin đang mở/khóa (locked files). |
| **`6`** | **Kiểm tra lỗi cú pháp (Testparm)** | Gọi `testparm -s` kiểm tra toàn diện tính hợp lệ của file cấu hình `smb.conf`, phát hiện sớm các lỗi sai cú pháp. |
| **`7`** | **Lưu cấu hình & Khởi động lại dịch vụ** | Tự động tạo bản backup `smb.conf.bak_<timestamp>` vào `/etc/samba/backups/`, sau đó chạy `systemctl restart smb nmb` để áp dụng mọi thay đổi vào hệ thống. |
| **`8`** | **Nhận file từ Windows về Linux** | Bẫy lỗi IP/tên share rỗng. Tạo điểm gắn kết `/mnt/WinData`, unmount phiên cũ và dùng `mount.cifs` để kết nối lấy danh sách tệp tin từ máy Windows về Linux. |
| **`9`** | **Xóa bỏ Thư mục chia sẻ** | Liệt kê các share hiện có, dùng `awk` bóc tách xóa sạch block cấu hình của share được chọn trong `smb.conf`. Có tùy chọn hỏi xác nhận xóa luôn thư mục dữ liệu vật lý trên ổ cứng. |
| **`10`** | **Quản lý tài khoản & Phân quyền nâng cao** | Mở Menu con chuyên sâu: Tạo tài khoản Samba mới (xác nhận mật khẩu 2 lần), phân quyền Đọc/Ghi (`write list`, `read list`) cho share có sẵn, và xóa tài khoản Samba an toàn. |
| **`11`** | **Khôi phục cấu hình (Rollback)** | Quét toàn bộ thư mục `/etc/samba/backups/`, hiển thị danh sách các mốc thời gian sao lưu và cho phép khôi phục lại cấu hình gốc bất kỳ lúc nào chỉ với 1 thao tác. |
| **`0`** | **Thoát chương trình** | Dừng thực thi kịch bản. |

---

### Menu con: Quản lý tài khoản & Phân quyền nâng cao (Chức năng 10)

Khi chọn **`10`** tại menu chính, hệ thống sẽ mở ra giao diện quản trị phân quyền chuyên sâu:

```text
==================================================
         QUẢN LÝ TÀI KHOẢN & PHÂN QUYỀN NÂNG CAO
==================================================
  1. Tạo tài khoản người dùng Samba mới
  2. Phân quyền Đọc/Ghi cho thư mục Share có sẵn
  3. Xóa tài khoản người dùng Samba
  0. Quay lại Menu chính
--------------------------------------------------
```

1. **Tùy chọn 1 - Tạo tài khoản Samba mới**:
   - Tự động tạo tài khoản Linux dạng `nologin` (nếu chưa có).
   - Cơ chế nhập mật khẩu ẩn và xác nhận lại mật khẩu 2 lần chống gõ nhầm.
2. **Tùy chọn 2 - Phân quyền Đọc/Ghi cho Share có sẵn**:
   - Cho phép chỉ định danh sách user được phép **Ghi/Sửa/Xóa** (`write list = giamdoc, truongphong`).
   - Chỉ định danh sách user **Chỉ được Đọc** (`read list = nhanvien, thuctapsinh`).
   - Tự động thiết lập `guest ok = no` và cập nhật danh sách người dùng hợp lệ `valid users`.
3. **Tùy chọn 3 - Xóa tài khoản người dùng Samba**:
   - Liệt kê toàn bộ user Samba hiện có.
   - Cơ chế bảo vệ: Tuyệt đối chặn xóa tài khoản `root`.
   - Xóa user khỏi cơ sở dữ liệu Samba qua `smbpasswd -x`.
   - Hỏi xác nhận người quản trị có muốn xóa luôn tài khoản khỏi tầng hệ điều hành Linux (`userdel`) hay không.

---

## 🧪 Quy trình Backtest & Demo thực tế

Dưới đây là kịch bản kiểm thử mẫu (dựa theo quy trình chuẩn của đề tài):
- **IP Máy chủ CentOS 7**: `192.168.10.133`
- **IP Máy trạm Windows**: `192.168.10.1`

---

### Bước 1: Cài đặt & Kích hoạt Samba (Chức năng 1)
1. Khởi chạy kịch bản:
   ```bash
   sudo ./samba_manager.sh
   ```
2. Nếu triển khai trên máy chủ mới, nhập số **`1`** và nhấn `Enter`.
3. Hệ thống sẽ tự động cài đặt các gói cần thiết, bật dịch vụ và mở tường lửa FirewallD:
   ```text
   [*] Đang kiểm tra và cài đặt các gói Samba cần thiết...
   [+] Đã tự động mở cổng Firewall cho Samba.
   => THÀNH CÔNG! Hoàn tất cài đặt và khởi động Samba.
   ```

---

### Bước 2: Tạo thư mục Anonymous (Chức năng 2 & 7)
1. Tại menu chính, nhập số **`2`** và nhấn `Enter`.
2. Nhập tên thư mục muốn chia sẻ, ví dụ: `PublicData`.
3. Script tự động tạo `/samba_share/PublicData`, cấp quyền `777`, cấu hình SELinux và lưu nháp cấu hình.
4. **Lưu ý**: Nhập tiếp số **`7`** tại menu chính để Sao lưu và Khởi động lại dịch vụ Samba, áp dụng thư mục mới vào mạng.

---

### Bước 3: Tạo Group, User & Thư mục bảo mật (Chức năng 3 & 7)
1. Tại menu chính, nhập số **`3`** và nhấn `Enter`.
2. Lần lượt nhập các thông số:
   - **Tên Group**: `nhomlab`
   - **Tên User**: `user1`
   - **Mật khẩu**: Nhập `123456`
   - **Tên Thư mục chia sẻ**: `ThuMucNhom`
3. Hệ thống cấu hình User/Group (với cờ bảo mật `nologin`), phân quyền `770` và ghi cấu hình vào `smb.conf`.
4. Nhập tiếp số **`7`** để Restart dịch vụ Samba áp dụng cấu hình mới.

---

### Bước 4: Kiểm tra truy cập từ máy Windows Client
1. Trên máy Windows, nhấn tổ hợp phím **`Windows + R`** để mở hộp thoại *Run*.
2. Nhập địa chỉ IP của máy ảo CentOS 7:
   ```text
   \\192.168.10.133
   ```
   nhấn `Enter`.
3. **Kiểm tra Thư mục Vô danh (`PublicData`)**:
   - Nhấn đúp chuột vào thư mục `PublicData`.
   - Tạo mới 1 file văn bản (`test_anonymous.txt`) hoặc thư mục mới để xác nhận quyền ghi (`write`) thành công mà không cần đăng nhập.
4. **Kiểm tra Thư mục Nhóm (`ThuMucNhom`)**:
   - Nhấn vào thư mục `ThuMucNhom`. Windows sẽ hiển thị hộp thoại yêu cầu xác thực tài khoản mạng.
   - Nhập tài khoản: `user1` và mật khẩu: `123456`.
   - Sau khi truy cập thành công, tạo thử tệp tin bên trong để kiểm tra quyền đọc/ghi của nhóm.

---

### Bước 5: Windows chia sẻ ngược lại cho Linux (Chức năng 8)

Mục đích: Thiết lập chia sẻ một thư mục từ máy Windows và dùng tính năng **số 8** trên CentOS 7 để tự động mount và lấy dữ liệu về.

#### 5.1. Thao tác trên máy Windows:
1. Mở **Command Prompt (CMD)** bằng quyền quản trị (**Run as administrator**).
2. Tạo tài khoản người dùng phụ dùng riêng cho chia sẻ:
   ```cmd
   net user maykhach 123 /add
   ```
3. Tạo thư mục chia sẻ trên ổ `C:\`:
   - Tạo thư mục có tên `ShareWin` tại `C:\ShareWin`.
   - Tạo sẵn một vài file dữ liệu thử nghiệm trong thư mục này (ví dụ: `Tailieu_BaoCao.txt`).
4. **Cấu hình chia sẻ (Sharing)**:
   - Chuột phải vào thư mục `ShareWin` ➔ Chọn **Properties**.
   - Chuyển sang tab **Sharing** ➔ Chọn **Advanced Sharing...**.
   - Tích chọn ô **Share this folder**.
   - Bấm nút **Permissions** ➔ Chọn **Add...** ➔ Nhập `maykhach` ➔ Bấm **OK**.
   - Tích chọn **Allow Full Control** (hoặc Read/Change) ➔ Bấm **OK**.
5. **Cấu hình phân quyền bảo mật (Security)**:
   - Chuyển sang tab **Security** trên hộp thoại Properties ➔ Chọn **Edit...**.
   - Bấm **Add...** ➔ Nhập `maykhach` ➔ Bấm **OK**.
   - Tích chọn **Allow** cho các quyền (Modify, Read & execute, Write) ➔ Bấm **OK**.
6. Xác định địa chỉ IP máy Windows:
   - Trong CMD, gõ lệnh `ipconfig` để lấy IP (ví dụ: `192.168.10.1`).

#### 5.2. Thao tác trên CentOS 7:
1. Tại menu script `samba_manager.sh`, chọn số **`8`** và nhấn `Enter`.
2. Nhập thông tin kết nối theo hướng dẫn:
   - **IP máy Windows**: `192.168.10.1`
   - **Tên thư mục Share trên Windows**: `ShareWin`
   - **Tên tài khoản Windows**: `maykhach`
   - **Mật khẩu tài khoản Windows**: `123`
3. **Kết quả**:
   - Kịch bản sẽ tự động mount thư mục từ Windows vào `/mnt/WinData` trên CentOS 7 và liệt kê toàn bộ danh sách tệp tin nhận được:

```text
-> Đang tiến hành kết nối...
=> THÀNH CÔNG! Đã lấy được dữ liệu từ máy Windows.
=> Danh sách các file bạn vừa nhận được:
-rwxr-xr-x 1 root root   25 Sep 28 15:30 Tailieu_BaoCao.txt
```

---

### Bước 6: Phân quyền Đọc/Ghi nâng cao (Chức năng 10)

Để thiết lập mô hình doanh nghiệp thực tế (ví dụ thư mục `KeToan`: Trưởng phòng được Ghi, Nhân viên chỉ được Đọc):
1. Tại menu chính, chọn **`10`**.
2. Chọn **`1`** để tạo 2 tài khoản mới: `truongphong` và `nhanvien` (đặt mật khẩu).
3. Chọn **`2`** để phân quyền cho thư mục `ThuMucNhom`:
   - Danh sách user được Ghi: `truongphong`
   - Danh sách user Chỉ Đọc: `nhanvien`
4. Quay lại menu chính (chọn `0`), sau đó chọn **`7`** để khởi động lại Samba.
5. **Kiểm thử trên Windows**:
   - Đăng nhập bằng `nhanvien`: Xem được file nhưng không thể sửa/xóa/tạo file mới (báo lỗi Permission Denied).
   - Đăng nhập bằng `truongphong`: Tạo, sửa, xóa file hoàn toàn bình thường.

---

### Bước 7: Kiểm tra cú pháp (Chức năng 6) & Xóa Share (Chức năng 9)

1. **Kiểm tra cú pháp cấu hình (Chức năng 6)**:
   - Chọn phím **`6`**, hệ thống gọi `testparm -s` kiểm tra toàn bộ file cấu hình để đảm bảo không có sai sót trước khi vận hành.
2. **Xóa bỏ Thư mục chia sẻ (Chức năng 9)**:
   - Chọn phím **`9`**, xem danh sách share và nhập tên share muốn xóa (ví dụ `PublicData`).
   - Script tự động bóc tách và xóa sạch block cấu hình của share đó mà không ảnh hưởng đến các thư mục khác.
   - Tùy chọn hỏi: `Bạn có muốn xóa luôn thư mục dữ liệu trên ổ cứng không? (y/n)`.
   - Chọn tiếp **`7`** để áp dụng thay đổi.

---

### Bước 8: Khôi phục cấu hình tức thì - Rollback (Chức năng 11)

Khi gặp sự cố (ví dụ xóa nhầm share hoặc cấu hình sai quyền truy cập):
1. Tại menu chính, chọn số **`11`**.
2. Màn hình liệt kê toàn bộ các bản sao lưu theo mốc thời gian:
   ```text
   -> Danh sách các bản sao lưu (Xếp theo mới nhất):
   --------------------------------------------------
     1. Lúc: 2026-09-28_22:15:30 [MỚI NHẤT]
     2. Lúc: 2026-09-28_22:05:12
     3. Lúc: 2026-09-28_21:50:04
   --------------------------------------------------
   Chọn số thứ tự muốn khôi phục [Mặc định 1 - Mới nhất, 0 để Hủy]: 
   ```
3. Nhấn `Enter` (chọn bản mới nhất) hoặc chọn số thứ tự bản sao lưu mong muốn.
4. Hệ thống khôi phục nguyên vẹn file `smb.conf`. Nhập tiếp số **`7`** để nạp lại dịch vụ là hệ thống trở lại bình thường.

---

## ❓ Xử lý sự cố thường gặp (Troubleshooting)

### 1. Windows báo lỗi không tìm thấy đường dẫn mạng `\\192.168.10.x`
- **Nguyên nhân**: Hai máy không cùng dải mạng, hoặc tường lửa trên CentOS 7 đang chặn cổng Samba.
- **Khắc phục**:
  - Dùng lệnh `ping 192.168.10.133` từ Windows để kiểm tra kết nối mạng.
  - Trên CentOS 7, kiểm tra tường lửa hoặc chạy **Chức năng 1** trong script để tự động mở cổng:
    ```bash
    sudo firewall-cmd --permanent --add-service=samba
    sudo firewall-cmd --reload
    ```

### 2. Vào được thư mục nhưng báo lỗi "Permission Denied" khi ghi file
- **Nguyên nhân**: Xung đột quyền hệ thống Linux POSIX, nhãn bảo mật **SELinux**, hoặc người dùng đang nằm trong danh sách `read list`.
- **Khắc phục**:
  - Kiểm tra xem tài khoản có nằm trong danh sách được cấp quyền Ghi hay không (dùng Chức năng 10 để cấp lại).
  - Khôi phục nhãn bảo mật SELinux cho thư mục chia sẻ:
    ```bash
    chcon -Rt samba_share_t /samba_share/<tên_thư_mục>
    ```
  - Hoặc cho phép Samba ghi dữ liệu tạm thời qua SELinux boolean:
    ```bash
    setsebool -P samba_export_all_rw on
    ```

### 3. Báo lỗi `mount.cifs: command not found` khi chạy Chức năng 8
- **Nguyên nhân**: Hệ thống CentOS 7 chưa cài gói tiện ích CIFS.
- **Khắc phục**: Chạy **Chức năng 1** trong kịch bản để được cài đặt tự động trọn gói, hoặc chạy lệnh:
  ```bash
  yum install -y cifs-utils
  ```

### 4. Windows 10/11 chặn truy cập Guest (Anonymous)
- **Nguyên nhân**: Các bản cập nhật Windows mới mặc định tắt tính năng "Insecure guest logons".
- **Khắc phục**:
  - Mở `gpedit.msc` trên Windows.
  - Điều hướng tới: `Computer Configuration` ➔ `Administrative Templates` ➔ `Network` ➔ `Lanman Workstation`.
  - Tìm chính sách **"Enable insecure guest logons"** ➔ Chuyển thành **Enabled** ➔ Bấm **OK**.

### 5. Windows bị kẹt phiên đăng nhập cũ (Lỗi không đổi được User hoặc không hiện bảng mật khẩu)
- **Nguyên nhân**: Windows lưu cache thông tin đăng nhập SMB trong phiên làm việc.
- **Khắc phục**:
  - Mở Command Prompt (CMD) trên Windows và chạy lệnh xóa sạch kết nối mạng đang nhớ:
    ```cmd
    net use * /delete /y
    ```
  - Sau đó truy cập lại `\\<IP_CentOS>` để Windows hỏi lại tài khoản mới.

---

## 📜 Giấy phép & Bản quyền (License & Usage)

Dự án này được phân phối mã nguồn mở dưới giấy phép [MIT License](https://opensource.org/licenses/MIT).

Giấy phép MIT cấp cho người dùng quyền hạn tối đa trong việc khai thác phần mềm. Cụ thể, bạn được cấp quyền:
- 🟩 **Sử dụng thương mại (Commercial Use)**: Tự do triển khai và tích hợp công cụ này vào hệ thống máy chủ của công ty hoặc doanh nghiệp.
- 🟩 **Sửa đổi (Modification)**: Tự do thay đổi mã nguồn, tùy biến các luồng chức năng (`samba_manager.sh`) để phù hợp với kiến trúc hạ tầng mạng riêng biệt.
- 🟩 **Phân phối (Distribution)**: Chia sẻ, sao chép, đóng gói lại hoặc sử dụng làm tài liệu tham khảo cốt lõi cho các đồ án/luận văn học thuật.
- 🟩 **Sử dụng cá nhân (Private Use)**: Triển khai trên các hệ thống Lab cá nhân (VMware, VirtualBox, Proxmox).