# 🚀 AutoScriptSamBa_CentOS7

<p align="center">
  <img src="https://img.shields.io/badge/OS-CentOS%207-blue?style=for-the-badge&logo=centos" alt="CentOS 7">
  <img src="https://img.shields.io/badge/Service-Samba%204.x-orange?style=for-the-badge&logo=linux" alt="Samba">
  <img src="https://img.shields.io/badge/Script-Bash%20Shell-green?style=for-the-badge&logo=gnu-bash" alt="Bash">
  <img src="https://img.shields.io/badge/Protocol-SMB%20%2F%20CIFS-red?style=for-the-badge" alt="SMB/CIFS">
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=for-the-badge" alt="License">
</p>

> **Đề tài**: Xây dựng kịch bản tự động hóa (Auto Script) cài đặt, cấu hình, quản trị phân quyền dịch vụ **Samba Server trên CentOS 7** và thiết lập chia sẻ dữ liệu hai chiều với máy trạm **Windows Client**.

---

## 📑 Mục lục
1. [Giới thiệu đề tài](#-giới-thiệu-đề-tài)
2. [Tính năng nổi bật](#-tính-năng-nổi-bật)
3. [Cấu trúc thư mục dự án](#-cấu-trúc-thư-mục-dự-án)
4. [Yêu cầu hệ thống & Chuẩn bị](#-yêu-cầu-hệ-thống--chuẩn-bị)
5. [Hướng dẫn cài đặt & Sử dụng nhanh](#-hướng-dẫn-cài-đặt--sử-dụng-nhanh)
6. [Chi tiết các chức năng trong Script (Bản 9 Chức năng)](#-chi-tiết-các-chức-năng-trong-script-bản-9-chức-năng)
7. [Quy trình Backtest & Demo thực tế](#-quy-trình-backtest--demo-thực-tế)
   - [Bước 1: Kiểm tra môi trường & Cài đặt Samba (Chức năng 1)](#bước-1-kiểm-tra-môi-trường--cài-đặt-samba-chức-năng-1)
   - [Bước 2: Tạo thư mục chia sẻ Anonymous (Chức năng 2 & 7)](#bước-2-tạo-thư-mục-chia-sẻ-anonymous-chức-năng-2--7)
   - [Bước 3: Tạo Group, User và Thư mục bảo mật (Chức năng 3 & 7)](#bước-3-tạo-group-user-và-thư-mục-bảo-mật-chức-năng-3--7)
   - [Bước 4: Kiểm tra truy cập từ máy Windows Client](#bước-4-kiểm-tra-truy-cập-từ-máy-windows-client)
   - [Bước 5: Windows chia sẻ ngược lại cho Linux (Chức năng 8)](#bước-5-windows-chia-sẻ-ngược-lại-cho-linux-chức-năng-8)
   - [Bước 6: Kiểm tra cú pháp (Chức năng 6) & Xóa Share an toàn (Chức năng 9)](#bước-6-kiểm-tra-cú-pháp-chức-năng-6--xóa-share-an-toàn-chức-năng-9)
8. [Xử lý sự cố thường gặp (Troubleshooting)](#-xử-lý-sự-cố-thường-gặp-troubleshooting)
9. [Giấy phép & Bản quyền (License & Usage)](#-giấy-phép--bản-quyền-license--usage)

---

## 📖 Giới thiệu đề tài

Trong môi trường quản trị mạng doanh nghiệp hỗn hợp (Heterogeneous Network), việc chia sẻ tệp tin và phân quyền truy cập giữa máy chủ Linux và các máy trạm Windows là nhu cầu tất yếu. **Samba** là giải pháp mã nguồn mở hàng đầu triển khai giao thức SMB/CIFS trên Linux.

Tuy nhiên, việc cấu hình Samba trên **CentOS 7** theo cách truyền thống đòi hỏi nhiều thao tác phức tạp:
- Khai báo file cấu hình `/etc/samba/smb.conf` dễ xảy ra sai sót cú pháp dẫn đến dịch vụ không khởi động được.
- Phải đồng bộ tài khoản người dùng giữa hệ điều hành Linux và cơ sở dữ liệu Samba (`smbpasswd` / `pdbedit`).
- Quản lý phân quyền 3 lớp: Quyền hệ thống POSIX (`chmod`, `chown`), Quyền dịch vụ Samba (`valid users`, `writable`), và Nhãn bảo mật **SELinux** (`samba_share_t`).
- Rủi ro mất mát dữ liệu hoặc hỏng file cấu hình gốc khi chỉnh sửa bằng tay mà không sao lưu.

**AutoScriptSamBa_CentOS7** ra đời nhằm tự động hóa toàn diện quy trình này thông qua một giao diện menu tương tác thân thiện, tích hợp sẵn cơ chế sao lưu tự động, kiểm tra cú pháp và gỡ bỏ cấu hình an toàn.

---

## ✨ Tính năng nổi bật

- ⚡ **Tự động cài đặt 1-Click (Mới)**: Tự động tải, cài đặt gói Samba, CIFS utils và tự cấu hình mở tường lửa FirewallD mà không cần gõ lệnh thủ công.
- 💾 **Tự động sao lưu an toàn (Auto Backup - Mới)**: Mỗi khi thêm mới hoặc xóa share, script tự động tạo bản sao lưu `smb.conf.bak_<timestamp>` vào `/etc/samba/backups` để phòng ngừa rủi ro.
- 🔍 **Kiểm tra cú pháp Testparm (Mới)**: Tích hợp công cụ `testparm` kiểm tra lỗi cú pháp file cấu hình trước khi nạp vào hệ thống.
- 🗑️ **Gỡ bỏ Share an toàn & Dọn file (Mới)**: Thuật toán thông minh lọc và xóa đúng block cấu hình của thư mục được chọn, đồng thời hỏi ý kiến người dùng trước khi dọn dẹp thư mục vật lý trên đĩa.
- 👥 **Quản lý phân quyền linh hoạt**:
  - Hỗ trợ tạo thư mục **Public/Anonymous** (không cần đăng nhập).
  - Hỗ trợ tạo **Group, User** và thư mục bảo mật riêng theo nhóm quyền.
- 🔄 **Chia sẻ hai chiều (2-Way Sharing)**: Hỗ trợ kết nối và **mount CIFS** để lấy dữ liệu từ thư mục chia sẻ trên Windows về Linux.
- 📊 **Giám sát & Quản trị tiện lợi**: Xem danh sách share, danh sách tài khoản Samba và theo dõi phiên kết nối thời gian thực bằng `smbstatus`.
- 🛡️ **Tương thích SELinux**: Tự động gán nhãn SELinux `samba_share_t` tránh lỗi bị SELinux chặn quyền đọc/ghi.

---

## 📂 Cấu trúc thư mục dự án

```text
AutoScriptSamBa_CentOS7/
│
├── SamBa_Project/
│   └── samba_manager.sh       # Kịch bản chính quản trị tự động hóa Samba (Bản 9 chức năng)
│
└── README.md                  # Hướng dẫn chi tiết sử dụng và triển khai đồ án
```

---

## ⚙️ Yêu cầu hệ thống & Chuẩn bị

### 1. Phía máy chủ Linux (CentOS 7)
- Hệ điều hành: **CentOS 7** (đã cấu hình card mạng chế độ `Host-Only` hoặc `NAT` cùng dải mạng với máy Windows).
- Quyền thực thi: Tài khoản `root` hoặc có quyền `sudo`.
- *(Tùy chọn)* Cài đặt thủ công trước nếu cần (hoặc bạn có thể dùng trực tiếp **Chức năng 1** của kịch bản để được tự động cài đặt trọn gói):
  ```bash
  yum install -y samba samba-client samba-common cifs-utils
  systemctl enable smb nmb
  systemctl start smb nmb
  firewall-cmd --permanent --add-service=samba
  firewall-cmd --reload
  setsebool -P samba_enable_home_dirs on
  ```

### 2. Phía máy trạm Windows Client
- Hệ điều hành: **Windows 10 / 11** hoặc Windows Server.
- Cùng dải mạng LAN / Mạng ảo với máy chủ CentOS 7 (kiểm tra thông mạng bằng lệnh `ping`).

---

## 📥 Hướng dẫn cài đặt & Sử dụng nhanh

### Bước 1: Clone dự án về máy CentOS 7
Mở Terminal trên CentOS 7 và chạy lệnh:
```bash
# Cài git nếu máy chưa có
yum install -y git

# Clone repository
git clone https://github.com/vannam52/AutoScriptSamBa_CentOS7.git
```

### Bước 2: Di chuyển vào thư mục dự án và cấp quyền thực thi
```bash
cd AutoScriptSamBa_CentOS7/SamBa_Project
chmod +x samba_manager.sh
```

### Bước 3: Khởi chạy kịch bản quản trị
```bash
sudo ./samba_manager.sh
```

Giao diện menu quản trị 9 chức năng xuất hiện như sau:

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
  7. Sao lưu (Backup) & Khởi động lại dịch vụ
  8. Tự động kết nối và nhận file từ máy Client (Windows)
  9. Xóa bỏ Thư mục chia sẻ (Gỡ cấu hình & Dọn file)
  0. Thoát chương trình
========================================================================
Vui lòng chọn chức năng (0-9): 
```

---

## 🛠️ Chi tiết các chức năng trong Script (Bản 9 Chức năng)

| Phím tắt | Tên chức năng | Mô tả hoạt động chi tiết |
| :---: | :--- | :--- |
| **`1`** | **Kiểm tra & Cài đặt Samba** | Tự động cài đặt gói `samba`, `samba-client`, `samba-common`, `cifs-utils` qua `yum`. Kích hoạt khởi động cùng hệ thống (`enable`), bật dịch vụ (`start`) và tự động mở cổng FirewallD cho dịch vụ Samba. |
| **`2`** | **Tạo Thư mục Anonymous** | Nhập tên thư mục muốn share. Script tự động tạo đường dẫn `/samba_share/<tên>`, cấp quyền `777`, gán nhãn SELinux `samba_share_t`, sao lưu cấu hình cũ, ghi cấu hình `guest ok = yes` vào `/etc/samba/smb.conf`. *(Cần chạy Chức năng 7 để nạp cấu hình mới)*. |
| **`3`** | **Tạo Group, User & Thư mục bảo mật** | Nhập Group, User, Thư mục. Script tạo Group, tạo tài khoản Linux, đặt mật khẩu Samba (`smbpasswd -a`), phân quyền thư mục `770` cho nhóm, gán `valid users = @<group>`, sao lưu cấu hình và ghi vào `smb.conf`. *(Cần chạy Chức năng 7 để nạp cấu hình mới)*. |
| **`4`** | **Xem danh sách Share & User** | Trích xuất các section thư mục chia sẻ từ `smb.conf` (loại bỏ `[global]`) và hiển thị toàn bộ người dùng Samba bằng lệnh `pdbedit -L`. |
| **`5`** | **Giám sát kết nối Client** | Gọi lệnh `smbstatus` hiển thị các phiên kết nối thời gian thực: địa chỉ IP máy Client, User đang truy cập, và danh sách các tệp tin đang mở/khóa (locked files). |
| **`6`** | **Kiểm tra lỗi cú pháp (Testparm)** | Chạy công cụ `testparm -s` để rà soát toàn bộ file `smb.conf`, đưa ra thông báo cấu hình hợp lệ hoặc chỉ rõ dòng lệnh bị lỗi nếu có sai sót. |
| **`7`** | **Sao lưu & Restart dịch vụ** | Tự động tạo một bản sao lưu `smb.conf.bak_<timestamp>` vào thư mục `/etc/samba/backups/`, sau đó khởi động lại dịch vụ Samba (`systemctl restart smb nmb`) để áp dụng mọi thay đổi mới nhất. |
| **`8`** | **Nhận file từ Windows về Linux** | Nhập thông tin chia sẻ từ máy Windows (IP, tên share, user, pass). Script tự động tạo điểm gắn kết `/mnt/WinData`, unmount phiên cũ và dùng `mount.cifs` để kết nối lấy danh sách tệp tin về Linux. |
| **`9`** | **Xóa bỏ Thư mục chia sẻ** | Liệt kê các share hiện có, nhập tên share cần xóa. Script tự động sao lưu, sử dụng `awk` để bóc tách và gỡ bỏ hoàn toàn block cấu hình của share đó trong `smb.conf`. Tùy chọn hỏi xóa luôn thư mục dữ liệu vật lý trên ổ đĩa. |
| **`0`** | **Thoát chương trình** | Dừng thực thi kịch bản. |

---

## 🧪 Quy trình Backtest & Demo thực tế

Dưới đây là kịch bản kiểm thử mẫu (dựa theo tài liệu kiểm thử của đề tài):
- **IP Máy chủ CentOS 7**: `192.168.10.133`
- **IP Máy trạm Windows**: `192.168.10.1`

---

### Bước 1: Kiểm tra môi trường & Cài đặt Samba (Chức năng 1)
1. Trên terminal CentOS 7, khởi chạy kịch bản:
   ```bash
   sudo ./samba_manager.sh
   ```
2. Nếu máy chủ chưa cài đặt Samba hoặc chưa mở Firewall, nhập số **`1`** và nhấn `Enter`.
3. Hệ thống sẽ tự động tải các gói dịch vụ, cấu hình khởi động và mở cổng Firewall:
   ```text
   [*] Đang kiểm tra và cài đặt các gói Samba cần thiết...
   [+] Đã tự động mở cổng Firewall cho Samba.
   => THÀNH CÔNG! Hoàn tất cài đặt và khởi động Samba.
   ```

---

### Bước 2: Tạo thư mục chia sẻ Anonymous (Chức năng 2 & 7)
1. Tại menu chính, nhập số **`2`** và nhấn `Enter`.
2. Nhập tên thư mục muốn chia sẻ, ví dụ: `PublicData`.
3. Script tự động tạo thư mục `/samba_share/PublicData`, phân quyền `777`, gán SELinux context và ghi cấu hình.
4. **Lưu ý**: Nhập tiếp số **`7`** để Sao lưu và Khởi động lại dịch vụ Samba, áp dụng cấu hình vừa tạo.

---

### Bước 3: Tạo Group, User và Thư mục bảo mật (Chức năng 3 & 7)
1. Tại menu chính, nhập số **`3`** và nhấn `Enter`.
2. Lần lượt nhập các thông số:
   - **Tên Group**: `nhomlab`
   - **Tên User**: `user1`
   - **Mật khẩu**: Nhập `123456` (2 lần xác nhận)
   - **Tên Thư mục chia sẻ**: `ThuMucNhom`
3. Hệ thống cấu hình User/Group, phân quyền `770` và ghi cấu hình vào `smb.conf`.
4. Nhập tiếp số **`7`** để Restart dịch vụ Samba áp dụng người dùng và quyền mới.

---

### Bước 4: Kiểm tra truy cập từ máy Windows Client
1. Trên máy Windows, nhấn tổ hợp phím **`Windows + R`** để mở hộp thoại *Run*.
2. Nhập chính xác địa chỉ IP của máy ảo CentOS 7:
   ```text
   \\192.168.10.133
   ```
   nhấn `Enter`.
3. **Kiểm tra Thư mục Vô danh (`PublicData`)**:
   - Nhấn đúp chuột vào thư mục `PublicData`.
   - Thử tạo mới 1 file văn bản (`test_anonymous.txt`) hoặc thư mục mới để xác nhận quyền ghi (`write`) thành công mà không cần đăng nhập.
4. **Kiểm tra Thư mục Nhóm (`ThuMucNhom`)**:
   - Nhấn vào thư mục `ThuMucNhom`. Windows sẽ hiển thị hộp thoại yêu cầu xác thực tài khoản mạng.
   - Nhập tài khoản: `user1` và mật khẩu: `123456`.
   - Sau khi truy cập thành công, tạo thử tệp tin bên trong để kiểm tra quyền đọc/ghi của nhóm.

> [!NOTE]
> **Giải thích thư mục `user1` xuất hiện bên cạnh các thư mục chia sẻ:**
> Khi đăng nhập bằng tài khoản `user1`, bạn có thể thấy xuất hiện thêm một thư mục mang tên `user1`. Đây là tính năng mục `[homes]` được bật mặc định trong file cấu hình gốc `/etc/samba/smb.conf` của Samba, cho phép mỗi người dùng truy cập trực tiếp vào thư mục cá nhân `/home/user1` của chính mình.

---

### Bước 5: Windows chia sẻ ngược lại cho Linux (Chức năng 8)

Mục đích: Thiết lập chia sẻ một thư mục từ máy Windows và dùng tính năng **số 8** trên CentOS 7 để tự động mount và lấy dữ liệu về.

#### 5.1. Thao tác trên máy Windows:
1. Mở cửa sổ **Command Prompt (CMD)** bằng quyền quản trị (**Run as administrator**).
2. Tạo một tài khoản người dùng phụ dùng riêng cho chia sẻ:
   ```cmd
   net user maykhach 123 /add
   ```
3. Tạo thư mục chia sẻ trên ổ `C:\`:
   - Tạo thư mục có tên `ShareWin` tại `C:\ShareWin`.
   - Tạo sẵn một vài file dữ liệu thử nghiệm trong thư mục này (ví dụ: `Tailieu_BaoCao.txt`).
4. **Cấu hình chia sẻ (Sharing)**:
   - Nhấp chuột phải vào thư mục `ShareWin` ➔ Chọn **Properties**.
   - Chuyển sang tab **Sharing** ➔ Chọn **Advanced Sharing...**.
   - Tích chọn ô **Share this folder**.
   - Bấm vào nút **Permissions** ➔ Chọn **Add...** ➔ Nhập `maykhach` ➔ Bấm **OK**.
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
-rwxr-xr-x 1 root root   25 Sep 26 15:30 Tailieu_BaoCao.txt
```

---

### Bước 6: Kiểm tra cú pháp (Chức năng 6) & Xóa Share an toàn (Chức năng 9)

1. **Kiểm tra cú pháp cấu hình (Chức năng 6)**:
   - Chọn phím **`6`**, hệ thống gọi `testparm -s` kiểm tra toàn bộ file cấu hình.
   - Giúp đảm bảo file không có lỗi cú pháp trước khi đưa vào vận hành thực tế.
2. **Xóa bỏ Thư mục chia sẻ (Chức năng 9)**:
   - Chọn phím **`9`**, màn hình hiển thị danh sách các Share đang có.
   - Nhập tên share muốn xóa (ví dụ `PublicData`).
   - Script tự động sao lưu `smb.conf`, sau đó dùng `awk` gỡ bỏ chính xác đoạn cấu hình của share đó.
   - Tùy chọn hỏi: `Bạn có muốn xóa luôn thư mục dữ liệu trên ổ cứng không? (y/n)`.
   - Sau khi xóa, chọn tiếp **`7`** để khởi động lại dịch vụ Samba.

---

## ❓ Xử lý sự cố thường gặp (Troubleshooting)

### 1. Windows báo lỗi không tìm thấy đường dẫn mạng `\\192.168.10.x`
- **Nguyên nhân**: Hai máy không cùng dải mạng, hoặc tường lửa trên CentOS 7 đang chặn cổng Samba (139, 445 TCP và 137, 138 UDP).
- **Khắc phục**:
  - Dùng lệnh `ping 192.168.10.133` từ Windows để kiểm tra kết nối mạng.
  - Trên CentOS 7, kiểm tra tường lửa hoặc chạy **Chức năng 1** trong script để tự động mở cổng:
    ```bash
    sudo firewall-cmd --permanent --add-service=samba
    sudo firewall-cmd --reload
    ```

### 2. Vào được thư mục nhưng báo lỗi "Permission Denied" khi ghi file
- **Nguyên nhân**: Xung đột quyền hệ thống Linux POSIX hoặc do cơ chế bảo vệ của **SELinux**.
- **Khắc phục**:
  - Kiểm tra quyền thư mục: `ls -ld /samba_share/<tên_thư_mục>`.
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
- **Khắc phục**: Chạy **Chức năng 1** trong kịch bản để được cài tự động, hoặc chạy lệnh:
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