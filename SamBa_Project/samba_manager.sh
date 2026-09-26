#!/bin/bash

# ========================================================================
# CHƯƠNG TRÌNH AUTO SCRIPT QUẢN LÝ DỊCH VỤ SAMBA (BẢN 9 CHỨC NĂNG)
# ========================================================================

# Các biến môi trường
SMB_CONF="/etc/samba/smb.conf"
BACKUP_DIR="/etc/samba/backups"

# Kiểm tra quyền root trước khi chạy
if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy kịch bản bằng quyền root (sudo ./samba_manager.sh)"
  exit
fi

# Hàm Sao lưu cấu hình tự động
function backup_config() {
    mkdir -p $BACKUP_DIR
    timestamp=$(date +%F_%T)
    backup_path="$BACKUP_DIR/smb.conf.bak_$timestamp"
    cp $SMB_CONF "$backup_path"
    echo "-> [HỆ THỐNG] Đã tự động tạo bản sao lưu cấu hình tại: $backup_path"
}

while true; do
    clear
    echo "========================================================================"
    echo "               CHƯƠNG TRÌNH AUTO SCRIPT QUẢN LÝ DỊCH VỤ SAMBA"
    echo "========================================================================"
    echo "  1. Kiểm tra môi trường & Cài đặt Samba"
    echo "  2. Tự động tạo Thư mục chia sẻ Anonymous (Vô danh)"
    echo "  3. Tự động tạo Group, User & Thư mục chia sẻ theo Group"
    echo "  4. Xem danh sách Thư mục chia sẻ và User hiện tại"
    echo "  5. Giám sát các máy Client đang kết nối (smbstatus)"
    echo "  6. Kiểm tra lỗi cú pháp cấu hình (Testparm)"
    echo "  7. Sao lưu (Backup) & Khởi động lại dịch vụ"
    echo "  8. Tự động kết nối và nhận file từ máy Client (Windows)"
    echo "  9. Xóa bỏ Thư mục chia sẻ (Gỡ cấu hình & Dọn file)"
    echo "  0. Thoát chương trình"
    echo "========================================================================"
    read -p "Vui lòng chọn chức năng (0-9): " choice

    case $choice in
        1)
            echo "=================================================="
            echo "   CÀI ĐẶT VÀ KÍCH HOẠT DỊCH VỤ SAMBA"
            echo "=================================================="
            echo "[*] Đang kiểm tra và cài đặt các gói Samba cần thiết..."
            yum install -y samba samba-common samba-client cifs-utils > /dev/null 2>&1
            systemctl enable smb nmb > /dev/null 2>&1
            systemctl start smb nmb
            
            if systemctl is-active --quiet firewalld; then
                firewall-cmd --permanent --add-service=samba > /dev/null 2>&1
                firewall-cmd --reload > /dev/null 2>&1
                echo "[+] Đã tự động mở cổng Firewall cho Samba."
            fi
            
            echo "=> THÀNH CÔNG! Hoàn tất cài đặt và khởi động Samba."
            ;;
        2)
            echo "=================================================="
            echo "   TẠO THƯ MỤC CHIA SẺ ANONYMOUS"
            echo "=================================================="
            read -p "Nhập tên thư mục muốn chia sẻ (VD: PublicData): " folder_name
            mkdir -p /samba_share/$folder_name
            chmod -R 777 /samba_share/$folder_name
            chcon -Rt samba_share_t /samba_share/$folder_name 2>/dev/null

            backup_config

            echo "[$folder_name]" >> $SMB_CONF
            echo "    path = /samba_share/$folder_name" >> $SMB_CONF
            echo "    browseable = yes" >> $SMB_CONF
            echo "    writable = yes" >> $SMB_CONF
            echo "    guest ok = yes" >> $SMB_CONF
            echo "    read only = no" >> $SMB_CONF

            echo "=> THÀNH CÔNG! Đã tạo cấu hình. Vui lòng chạy Chức năng 7 để áp dụng."
            ;;
        3)
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
            
            backup_config
            
            echo "[$folder_name]" >> $SMB_CONF
            echo "    path = /samba_share/$folder_name" >> $SMB_CONF
            echo "    browseable = yes" >> $SMB_CONF
            echo "    writable = yes" >> $SMB_CONF
            echo "    valid users = @$group_name" >> $SMB_CONF
            
            echo "=> THÀNH CÔNG! Đã tạo cấu hình. Vui lòng chạy Chức năng 7 để áp dụng."
            ;;
        4)
            echo "-> DANH SÁCH CÁC THƯ MỤC ĐANG CHIA SẺ (smb.conf):"
            grep -E "^\[" $SMB_CONF | grep -v '\[global\]'
            echo "--------------------------------------------------"
            echo "-> DANH SÁCH USER SAMBA:"
            pdbedit -L
            ;;
        5)
            echo "-> GIÁM SÁT KẾT NỐI SAMBA (smbstatus):"
            smbstatus
            ;;
        6)
            echo "=================================================="
            echo "   KIỂM TRA LỖI CÚ PHÁP CẤU HÌNH"
            echo "=================================================="
            echo "[*] Đang chạy công cụ testparm để rà soát file smb.conf..."
            testparm -s
            if [ $? -eq 0 ]; then
                echo "=> KẾT QUẢ: Tuyệt vời! Cấu hình hoàn toàn hợp lệ, không có lỗi."
            else
                echo "=> CẢNH BÁO: Phát hiện lỗi trong file cấu hình. Vui lòng sửa lại!"
            fi
            ;;
        7)
            echo "=================================================="
            echo "   SAO LƯU VÀ KHỞI ĐỘNG LẠI DỊCH VỤ"
            echo "=================================================="
            backup_config
            
            echo "[*] Đang khởi động lại dịch vụ Samba..."
            systemctl restart smb nmb
            if [ $? -eq 0 ]; then
                echo "=> THÀNH CÔNG! Dịch vụ Samba đã được Restart."
            else
                echo "=> THẤT BẠI! Có lỗi xảy ra, hãy dùng chức năng 6 để kiểm tra."
            fi
            ;;
        8)
            echo "=================================================="
            echo "   KẾT NỐI VÀ NHẬN FILE TỪ WINDOWS VỀ LINUX"
            echo "=================================================="
            read -p "Nhập IP máy Windows (VD: 192.168.10.1): " win_ip
            read -p "Nhập tên thư mục Share trên Windows (VD: ShareToLinux): " win_share
            read -p "Nhập tên tài khoản Windows (VD: sv_lab): " win_user
            read -p "Nhập mật khẩu tài khoản Windows: " win_pass
            
            echo "-> Đang tiến hành kết nối..."
            mkdir -p /mnt/WinData
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
        9)
            echo "=================================================="
            echo "   XÓA BỎ THƯ MỤC CHIA SẺ (XÓA SHARE)"
            echo "=================================================="
            echo "-> Danh sách các Share hiện có:"
            grep -E "^\[.*\]" $SMB_CONF | grep -v '\[global\]'
            echo "--------------------------------------------------"
            read -p "Nhập chính xác tên Share muốn xóa (không kèm dấu []): " del_name
            
            if [ -z "$del_name" ]; then
                echo "=> Thao tác bị hủy do không nhập tên."
            elif ! grep -q "^\[$del_name\]" $SMB_CONF; then
                echo "=> LỖI: Không tìm thấy thư mục [$del_name] trong file cấu hình!"
            else
                backup_config
                
                # Dùng awk để xóa nguyên block cấu hình an toàn
                awk -v target="[$del_name]" '
                    $0 == target { skip=1; next }
                    skip && /^\[/ { skip=0 }
                    !skip { print }
                ' $SMB_CONF > $SMB_CONF.tmp && mv -f $SMB_CONF.tmp $SMB_CONF
                
                echo "=> Đã gỡ bỏ cấu hình của thư mục [$del_name]."
                
                read -p "Bạn có muốn xóa luôn thư mục dữ liệu trên ổ cứng không? (y/n): " del_f
                if [[ "$del_f" == "y" || "$del_f" == "Y" ]]; then
                    read -p "Nhập đường dẫn tuyệt đối cần xóa (VD: /samba_share/Data): " f_del
                    if [ -d "$f_del" ]; then
                        rm -rf "$f_del"
                        echo "=> Đã dọn dẹp sạch sẽ thư mục vật lý tại $f_del."
                    else
                        echo "=> LỖI: Đường dẫn không tồn tại trên hệ thống."
                    fi
                fi
                echo "=> THÀNH CÔNG! Vui lòng chạy Chức năng 7 để áp dụng thay đổi."
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