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
6. [Chi tiết các chức năng trong Script](#-chi-tiết-các-chức-năng-trong-script)
7. [Quy trình Backtest & Demo thực tế](#-quy-trình-backtest--demo-thực-tế)
   - [Bước 1: Tạo thư mục chia sẻ Anonymous (Vô danh)](#bước-1-tạo-thư-mục-chia-sẻ-anonymous-vô-danh)
   - [Bước 2: Tạo Group, User và Thư mục bảo mật](#bước-2-tạo-group-user-và-thư-mục-bảo-mật)
   - [Bước 3: Kiểm tra truy cập từ máy Windows Client](#bước-3-kiểm-tra-truy-cập-từ-máy-windows-client)
   - [Bước 4: Windows chia sẻ ngược lại cho Linux (Chức năng 6)](#bước-4-windows-chia-sẻ-ngược-lại-cho-linux-chức-năng-6)
8. [Xử lý sự cố thường gặp (Troubleshooting)](#-xử-lý-sự-cố-thường-gặp-troubleshooting)
9. [Giấy phép & Bản quyền (License & Usage)](#-giấy-phép--bản-quyền-license--usage)

---

## 📖 Giới thiệu đề tài

Trong môi trường quản trị mạng doanh nghiệp hỗn hợp (Heterogeneous Network), việc chia sẻ tệp tin và phân quyền truy cập giữa máy chủ Linux và các máy trạm Windows là nhu cầu tất yếu. **Samba** là giải pháp mã nguồn mở hàng đầu triển khai giao thức SMB/CIFS trên Linux.

Tuy nhiên, việc cấu hình Samba trên **CentOS 7** theo cách truyền thống đòi hỏi nhiều thao tác phức tạp:
- Khai báo file cấu hình `/etc/samba/smb.conf` dễ xảy ra sai sót cú pháp.
- Phải đồng bộ tài khoản người dùng giữa Linux OS và cơ sở dữ liệu Samba (`smbpasswd` / `pdbedit`).
- Quản lý phân quyền 3 lớp: Quyền hệ thống POSIX (`chmod`, `chown`), Quyền dịch vụ Samba (`valid users`, `writable`), và Nhãn bảo mật **SELinux** (`samba_share_t`).

**AutoScriptSamBa_CentOS7** ra đời nhằm tự động hóa toàn diện quy trình này thông qua một giao diện menu tương tác thân thiện, nhanh chóng, chính xác và an toàn.

---

## ✨ Tính năng nổi bật

- ⚡ **Tự động hóa hoàn toàn**: Tạo thư mục, phân quyền POSIX, cấu hình SELinux context và nạp lại dịch vụ chỉ trong vài giây.
- 👥 **Quản lý phân quyền linh hoạt**:
  - Hỗ trợ tạo thư mục **Public/Anonymous** (không cần đăng nhập).
  - Hỗ trợ tạo **Group, User** và thư mục bảo mật riêng theo nhóm quyền.
- 🔄 **Chia sẻ hai chiều (2-Way Sharing)**: Không chỉ chia sẻ từ Linux cho Windows, script còn hỗ trợ **mount CIFS** để lấy dữ liệu từ thư mục chia sẻ trên Windows về Linux.
- 📊 **Giám sát & Quản trị tiện lợi**: Xem danh sách share, danh sách tài khoản Samba và theo dõi phiên kết nối thời gian thực bằng `smbstatus`.
- 🛡️ **Tương thích bảo mật**: Tự động gán nhãn SELinux `samba_share_t` tránh lỗi bị SELinux chặn truy cập file.

---

## 📂 Cấu trúc thư mục dự án

```text
AutoScriptSamBa_CentOS7/
│
├── SamBa_Project/
│   └── samba_manager.sh       # Kịch bản chính quản trị tự động hóa Samba
│
└── README.md                  # Hướng dẫn chi tiết sử dụng và triển khai đồ án
```

---

## ⚙️ Yêu cầu hệ thống & Chuẩn bị

### 1. Phía máy chủ Linux (CentOS 7)
- Hệ điều hành: **CentOS 7** (đã cấu hình card mạng chế độ `Host-Only` hoặc `NAT` cùng dải mạng với máy Windows).
- Quyền thực thi: Tài khoản `root` hoặc có quyền `sudo`.
- Đã cài đặt các gói cần thiết:
  ```bash
  yum install -y samba samba-client samba-common cifs-utils
  ```
- Kích hoạt và mở cổng tường lửa (Firewall):
  ```bash
  systemctl start firewalld
  firewall-cmd --permanent --add-service=samba
  firewall-cmd --reload
  ```
- Bật cờ SELinux hỗ trợ chia sẻ thư mục home (nếu cần):
  ```bash
  setsebool -P samba_enable_home_dirs on
  ```

### 2. Phía máy trạm Windows Client
- Hệ điều hành: **Windows 10 / 11** hoặc Windows Server.
- Cùng dải mạng LAN / Mạng ảo với máy chủ CentOS 7 (kiểm tra bằng lệnh `ping`).

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

Giao diện menu quản trị xuất hiện như sau:

```text
========================================================================
               CHƯƠNG TRÌNH AUTO SCRIPT QUẢN LÝ DỊCH VỤ SAMBA
========================================================================
  1. Tự động tạo Thư mục chia sẻ Anonymous (Vô danh)
  2. Tự động tạo Group, User & Thư mục chia sẻ theo Group
  3. Xem danh sách Thư mục chia sẻ và User hiện tại
  4. Giám sát các máy Client đang kết nối (smbstatus)
  5. Khởi động lại (Restart) dịch vụ Samba
  6. Tự động kết nối và nhận file từ máy Client (Windows)
  0. Thoát chương trình
========================================================================
Vui lòng chọn chức năng (0-6): 
```

---

## 🛠️ Chi tiết các chức năng trong Script

| Phím tắt | Tên chức năng | Mô tả hoạt động |
| :---: | :--- | :--- |
| **`1`** | **Tạo Thư mục Anonymous** | Nhập tên thư mục muốn share. Script tự động tạo đường dẫn `/samba_share/<tên>`, cấp quyền `777`, cấu hình nhãn SELinux `samba_share_t`, ghi mục cấu hình `guest ok = yes` vào `/etc/samba/smb.conf` và khởi động lại dịch vụ Samba. |
| **`2`** | **Tạo Group, User & Thư mục bảo mật** | Nhập tên Group, tên User, tên thư mục. Script tạo Group, tạo Linux User, đặt mật khẩu Samba (`smbpasswd -a`), cấp quyền thư mục `770` thuộc nhóm sở hữu, gán `valid users = @<group>` và restart dịch vụ. |
| **`3`** | **Xem danh sách Share & User** | Trích xuất các section chia sẻ từ `/etc/samba/smb.conf` và hiển thị toàn bộ user trong cơ sở dữ liệu Samba qua lệnh `pdbedit -L`. |
| **`4`** | **Giám sát kết nối Client** | Gọi lệnh `smbstatus` hiển thị các phiên kết nối, địa chỉ IP Client, user đang kết nối và các file đang bị khóa (locked files). |
| **`5`** | **Khởi động lại dịch vụ Samba** | Thực thi lệnh `systemctl restart smb nmb` để áp dụng ngay cấu hình mới. |
| **`6`** | **Nhận file từ Windows về Linux** | Nhập thông tin chia sẻ từ máy Windows (IP, tên share, user, pass). Script tự động tạo điểm gắn kết `/mnt/WinData`, unmount phiên cũ và dùng `mount.cifs` để kết nối lấy danh sách file về Linux. |
| **`0`** | **Thoát chương trình** | Dừng thực thi kịch bản. |

---

## 🧪 Quy trình Backtest & Demo thực tế

Dưới đây là kịch bản kiểm thử mẫu (dựa theo tài liệu kiểm thử của đề tài):
- **IP Máy chủ CentOS 7**: `192.168.10.133`
- **IP Máy trạm Windows**: `192.168.10.1`

---

### Bước 1: Tạo thư mục chia sẻ Anonymous (Vô danh)
1. Trên terminal CentOS 7, chạy kịch bản:
   ```bash
   sudo ./samba_manager.sh
   ```
2. Nhập số **`1`** và nhấn `Enter`.
3. Nhập tên thư mục muốn chia sẻ, ví dụ: `PublicData`.
4. Hệ thống thông báo: `=> THÀNH CÔNG! Đã tạo xong thư mục Vô danh.`

---

### Bước 2: Tạo Group, User và Thư mục bảo mật
1. Tại menu chính, nhập số **`2`** và nhấn `Enter`.
2. Lần lượt nhập các thông số:
   - **Tên Group**: `nhomlab`
   - **Tên User**: `user1`
   - **Mật khẩu**: Nhập `123456` (2 lần xác nhận)
   - **Tên Thư mục chia sẻ**: `ThuMucNhom`
3. Hệ thống thông báo: `=> THÀNH CÔNG! Đã tạo xong thư mục có yêu cầu xác thực.`

---

### Bước 3: Kiểm tra truy cập từ máy Windows Client
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

### Bước 4: Windows chia sẻ ngược lại cho Linux (Chức năng 6)

Mục đích: Thiết lập chia sẻ một thư mục từ máy Windows và dùng tính năng **số 6** trên CentOS 7 để tự động mount và lấy dữ liệu về.

#### 4.1. Thao tác trên máy Windows:
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

#### 4.2. Thao tác trên CentOS 7:
1. Tại menu script `samba_manager.sh`, chọn số **`6`** và nhấn `Enter`.
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

## ❓ Xử lý sự cố thường gặp (Troubleshooting)

### 1. Windows báo lỗi không tìm thấy đường dẫn mạng `\\192.168.10.x`
- **Nguyên nhân**: Hai máy không cùng dải mạng, hoặc tường lửa trên CentOS 7 đang chặn cổng Samba (139, 445 TCP và 137, 138 UDP).
- **Khắc phục**:
  - Dùng lệnh `ping 192.168.10.133` từ Windows để kiểm tra kết nối mạng.
  - Trên CentOS 7, kiểm tra tường lửa:
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

### 3. Chức năng 6 báo lỗi: `mount.cifs: command not found`
- **Nguyên nhân**: Hệ thống CentOS 7 chưa cài gói tiện ích CIFS.
- **Khắc phục**:
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