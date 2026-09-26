#!/bin/bash

# Kiểm tra quyền root trước khi chạy
if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy kịch bản bằng quyền root (sudo ./samba_manager.sh)"
  exit
fi

while true; do
    clear
    echo "========================================================================"
    echo "               CHƯƠNG TRÌNH AUTO SCRIPT QUẢN LÝ DỊCH VỤ SAMBA"
    echo "========================================================================"
    echo "  1. Tự động tạo Thư mục chia sẻ Anonymous (Vô danh)"
    echo "  2. Tự động tạo Group, User & Thư mục chia sẻ theo Group"
    echo "  3. Xem danh sách Thư mục chia sẻ và User hiện tại"
    echo "  4. Giám sát các máy Client đang kết nối (smbstatus)"
    echo "  5. Khởi động lại (Restart) dịch vụ Samba"
    echo "  6. Tự động kết nối và nhận file từ máy Client (Windows)"
    echo "  0. Thoát chương trình"
    echo "========================================================================"
    read -p "Vui lòng chọn chức năng (0-6): " choice

    case $choice in
        1)
            echo "=================================================="
            echo "   TẠO THƯ MỤC CHIA SẺ ANONYMOUS"
            echo "=================================================="
            read -p "Nhập tên thư mục muốn chia sẻ (VD: PublicData): " folder_name
            mkdir -p /samba_share/$folder_name
            chmod -R 777 /samba_share/$folder_name
            chcon -Rt samba_share_t /samba_share/$folder_name 2>/dev/null

            echo "[$folder_name]" >> /etc/samba/smb.conf
            echo "    path = /samba_share/$folder_name" >> /etc/samba/smb.conf
            echo "    browseable = yes" >> /etc/samba/smb.conf
            echo "    writable = yes" >> /etc/samba/smb.conf
            echo "    guest ok = yes" >> /etc/samba/smb.conf
            echo "    read only = no" >> /etc/samba/smb.conf

            systemctl restart smb nmb
            echo "=> THÀNH CÔNG! Đã tạo xong thư mục Vô danh."
            ;;
        2)
            echo "=================================================="
            echo "   TẠO GROUP, USER & THƯ MỤC BẢO MẬT"
            echo "=================================================="
            read -p "Nhập tên Group muốn tạo (VD: nhomlab): " group_name
            read -p "Nhập tên User muốn tạo (VD: user1): " user_name
            read -p "Nhập tên Thư mục chia sẻ (VD: ThuMucNhom): " folder_name
            
            echo "-> Đang cấu hình Group và User..."
            groupadd $group_name 2>/dev/null
            useradd -m -g $group_name $user_name 2>/dev/null
            
            echo "Vui lòng đặt mật khẩu đăng nhập mạng cho tài khoản $user_name:"
            smbpasswd -a $user_name
            
            mkdir -p /samba_share/$folder_name
            chown -R root:$group_name /samba_share/$folder_name
            chmod -R 770 /samba_share/$folder_name
            chcon -Rt samba_share_t /samba_share/$folder_name 2>/dev/null
            
            echo "[$folder_name]" >> /etc/samba/smb.conf
            echo "    path = /samba_share/$folder_name" >> /etc/samba/smb.conf
            echo "    browseable = yes" >> /etc/samba/smb.conf
            echo "    writable = yes" >> /etc/samba/smb.conf
            echo "    valid users = @$group_name" >> /etc/samba/smb.conf
            
            systemctl restart smb nmb
            echo "=> THÀNH CÔNG! Đã tạo xong thư mục có yêu cầu xác thực."
            ;;
        3)
            echo "-> DANH SÁCH CÁC THƯ MỤC ĐANG CHIA SẺ (smb.conf):"
            grep -E "^\[" /etc/samba/smb.conf
            echo "--------------------------------------------------"
            echo "-> DANH SÁCH USER SAMBA:"
            pdbedit -L
            ;;
        4)
            echo "-> GIÁM SÁT KẾT NỐI SAMBA (smbstatus):"
            smbstatus
            ;;
        5)
            echo "-> Đang khởi động lại dịch vụ Samba..."
            systemctl restart smb nmb
            echo "=> THÀNH CÔNG! Dịch vụ đã được Restart."
            ;;
        6)
            echo "=================================================="
            echo "   KẾT NỐI VÀ NHẬN FILE TỪ WINDOWS VỀ LINUX"
            echo "=================================================="
            read -p "Nhập IP máy Windows (VD: 192.168.10.1): " win_ip
            read -p "Nhập tên thư mục Share trên Windows (VD: ShareToLinux): " win_share
            read -p "Nhập tên tài khoản Windows (VD: sv_lab): " win_user
            read -p "Nhập mật khẩu tài khoản Windows: " win_pass
            
            echo "-> Đang tiến hành kết nối..."
            mkdir -p /mnt/WinData
            # Ngắt kết nối cũ nếu có để tránh bị treo
            umount /mnt/WinData 2>/dev/null
            
            mount.cifs //$win_ip/$win_share /mnt/WinData -o username=$win_user,password=$win_pass
            
            if [ $? -eq 0 ]; then
                echo "=> THÀNH CÔNG! Đã lấy được dữ liệu từ máy Windows."
                echo "=> Danh sách các file bạn vừa nhận được:"
                ls -l /mnt/WinData
            else
                echo "=> THẤT BẠI! Vui lòng kiểm tra lại IP, Tài khoản, Mật khẩu hoặc Tường lửa trên Windows."
            fi
            ;;
        0)
            echo "Đã thoát chương trình. Tạm biệt!"
            exit 0
            ;;
        *)
            echo "Lựa chọn không hợp lệ!"
            ;;
    esac
    
    echo ""
    read -p "Nhấn phím Enter để tiếp tục..."
done