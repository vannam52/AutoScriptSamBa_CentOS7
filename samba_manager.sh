#!/bin/bash

# ========================================================================
# CHƯƠNG TRÌNH AUTO SCRIPT QUẢN LÝ DỊCH VỤ SAMBA (BẢN 11 CHỨC NĂNG)
# Tích hợp: Bẫy lỗi Input, Chống dính dòng, Phân quyền Nâng cao & Rollback
# ========================================================================

# Các biến môi trường
SMB_CONF="/etc/samba/smb.conf"
BACKUP_DIR="/etc/samba/backups"

# Kiểm tra quyền root trước khi chạy
if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy kịch bản bằng quyền root (sudo ./samba_manager.sh)"
  exit
fi

# Hàm Sao lưu cấu hình tự động (Giữ tối đa 20 bản sao lưu gần nhất)
function backup_config() {
    mkdir -p $BACKUP_DIR
    timestamp=$(date +%F_%T)
    backup_path="$BACKUP_DIR/smb.conf.bak_$timestamp"
    cp $SMB_CONF "$backup_path"
    echo "-> [HỆ THỐNG] Đã tự động tạo bản sao lưu cấu hình tại: $backup_path"

    # Tự động dọn dẹp, chỉ giữ lại 20 bản sao lưu mới nhất
    ls -t "$BACKUP_DIR"/smb.conf.bak_* 2>/dev/null | tail -n +21 | while read -r old_bak; do
        [ -n "$old_bak" ] && rm -f "$old_bak"
    done
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
    echo "  7. Lưu cấu hình (Backup) & Khởi động lại dịch vụ (Apply)"
    echo "  8. Tự động kết nối và nhận file từ máy Client (Windows)"
    echo "  9. Xóa bỏ Thư mục chia sẻ (Gỡ cấu hình & Dọn file)"
    echo " 10. Quản lý tài khoản và Phân quyền truy cập Samba"
    echo " 11. Khôi phục cấu hình từ bản sao lưu (Rollback)"
    echo "  0. Thoát chương trình"
    echo "========================================================================"
    read -p "Vui lòng chọn chức năng (0-11): " choice

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
            
            if [ -z "$folder_name" ] || [[ "$folder_name" == *" "* ]]; then
                echo "=> LỖI: Tên thư mục không được để trống và không chứa khoảng trắng!"
            else
                mkdir -p /samba_share/$folder_name
                chmod -R 777 /samba_share/$folder_name
                chcon -Rt samba_share_t /samba_share/$folder_name 2>/dev/null

                # Đảm bảo mục [global] có map to guest để Windows không bị hỏi mật khẩu
                grep -q "map to guest" $SMB_CONF || sed -i '/\[global\]/a \    map to guest = bad user' $SMB_CONF

                # Xuống dòng trước khi nối chuỗi để tránh dính dòng vào cấu hình cũ
                echo "" >> $SMB_CONF
                echo "[$folder_name]" >> $SMB_CONF
                echo "    path = /samba_share/$folder_name" >> $SMB_CONF
                echo "    browseable = yes" >> $SMB_CONF
                echo "    writable = yes" >> $SMB_CONF
                echo "    guest ok = yes" >> $SMB_CONF
                echo "    read only = no" >> $SMB_CONF

                echo "=> THÀNH CÔNG! Vui lòng chạy Chức năng 7 để áp dụng."
            fi
            ;;
        3)
            echo "=================================================="
            echo "   TẠO GROUP, USER & THƯ MỤC BẢO MẬT"
            echo "=================================================="
            read -p "Nhập tên Group muốn tạo (VD: nhomlab): " group_name
            read -p "Nhập tên User muốn tạo (VD: user1): " user_name
            read -p "Nhập tên Thư mục chia sẻ (VD: ThuMucNhom): " folder_name
            
            if [ -z "$group_name" ] || [ -z "$user_name" ] || [ -z "$folder_name" ] || [[ "$folder_name" == *" "* ]]; then
                echo "=> LỖI: Các trường không được để trống và tên thư mục không chứa khoảng trắng!"
            else
                echo "-> Đang cấu hình Group và User..."
                groupadd $group_name 2>/dev/null
                
                # Nâng cấp bảo mật: Không tạo thư mục home và khóa shell nologin
                useradd -M -s /sbin/nologin -g $group_name $user_name 2>/dev/null
                
                echo "Vui lòng đặt mật khẩu đăng nhập mạng cho tài khoản $user_name:"
                smbpasswd -a $user_name
                
                mkdir -p /samba_share/$folder_name
                chown -R root:$group_name /samba_share/$folder_name
                chmod -R 770 /samba_share/$folder_name
                chcon -Rt samba_share_t /samba_share/$folder_name 2>/dev/null
                
                echo "" >> $SMB_CONF
                echo "[$folder_name]" >> $SMB_CONF
                echo "    path = /samba_share/$folder_name" >> $SMB_CONF
                echo "    browseable = yes" >> $SMB_CONF
                echo "    writable = yes" >> $SMB_CONF
                echo "    valid users = @$group_name" >> $SMB_CONF
                
                echo "=> THÀNH CÔNG! Đã lưu nháp cấu hình. Vui lòng chạy Chức năng 7 để áp dụng."
            fi
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
            
            if [ -z "$win_ip" ] || [ -z "$win_share" ]; then
                echo "=> LỖI: IP và Tên Share không được để trống!"
            else
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
            fi
            ;;


	9)
            echo "=================================================="
            echo "             XÓA THƯ MỤC CHIA SẺ SAMBA"
            echo "=================================================="
            echo "-> Danh sách các Share hiện có:"
            grep -E "^\[.*\]" $SMB_CONF | grep -v '\[global\]'
            echo "--------------------------------------------------"
            read -p "Nhập chính xác tên Share muốn xóa (không kèm dấu []): " del_name
            del_name=$(echo "$del_name" | tr -d '[] ')

            if [ -z "$del_name" ]; then
                echo "=> Thao tác bị hủy do không nhập tên."
            elif ! grep -q "^\[$del_name\]" $SMB_CONF; then
                echo "=> LỖI: Không tìm thấy thư mục [$del_name] trong file cấu hình!"
            else
                # 1. Trích xuất đường dẫn vật lý (path) của share trước khi xóa cấu hình
                share_real_path=$(awk -v target="[$del_name]" '
                    $0 == target { in_block=1; next }
                    in_block && /^\[/ { in_block=0 }
                    in_block && /^[[:space:]]*path[[:space:]]*=/ {
                        split($0, arr, "=");
                        gsub(/^[[:space:]]+|[[:space:]]+$/, "", arr[2]);
                        print arr[2];
                        exit;
                    }
                ' $SMB_CONF)

                # Dự phòng: nếu không tìm thấy path trong file thì gán theo thư mục mặc định
                [ -z "$share_real_path" ] && share_real_path="/samba_share/$del_name"

                # 2. Dùng awk để xóa nguyên block cấu hình an toàn
                awk -v target="[$del_name]" '
                    $0 == target { skip=1; next }
                    skip && /^\[/ { skip=0 }
                    !skip { print }
                ' $SMB_CONF > $SMB_CONF.tmp && mv -f $SMB_CONF.tmp $SMB_CONF

                echo "=> Đã gỡ bỏ cấu hình của thư mục [$del_name] trong smb.conf."

                # 3. Hỏi xóa thư mục vật lý và thực hiện lệnh rm -rf
                read -p "Bạn có muốn xóa luôn thư mục dữ liệu trên ổ cứng ($share_real_path) không? (y/N): " del_f
                if [[ "$del_f" =~ ^[yY]$ ]]; then
                    if [ -d "$share_real_path" ]; then
                        rm -rf "$share_real_path"
                        echo "=> Đã xóa sạch thư mục dữ liệu thực tế tại: $share_real_path"
                    else
                        echo "=> Thư mục vật lý không tồn tại trên ổ đĩa."
                    fi
                else
                    echo "-> Giữ lại dữ liệu thực tế trên ổ cứng."
                fi

                echo "--------------------------------------------------"
                echo "=> THÀNH CÔNG! Đã hoàn tất xóa Share [$del_name]."
                echo "=> Vui lòng chạy Chức năng 7 để nạp lại dịch vụ Samba."
            fi
            ;;
	10)
            while true; do
                clear
                echo "=================================================="
                echo "         QUẢN LÝ TÀI KHOẢN & PHÂN QUYỀN NÂNG CAO"
                echo "=================================================="
                echo "  1. Tạo tài khoản người dùng Samba mới"
                echo "  2. Phân quyền Đọc/Ghi cho thư mục Share có sẵn"
                echo "  3. Xóa tài khoản người dùng Samba"
                echo "  0. Quay lại Menu chính"
                echo "--------------------------------------------------"
                read -p "Nhập lựa chọn của bạn [0-3]: " sub_opt

                case $sub_opt in
                    1)
                        echo "--------------------------------------------------"
                        echo "-> KHỞI TẠO TÀI KHOẢN SAMBA MỚI"
                        read -p "Nhập tên tài khoản cần tạo (VD: giamdoc): " new_u
                        new_u=$(echo "$new_u" | tr -d ' ')

                        if [ -z "$new_u" ]; then
                            echo "=> CẢNH BÁO: Tên tài khoản không được để trống!"
                        else
                            # 1. Kiểm tra và tạo tài khoản Linux nếu chưa có
                            if ! id "$new_u" &>/dev/null; then
                                useradd -M -s /sbin/nologin "$new_u"
                                echo "-> Đã tạo tài khoản hệ thống cho [$new_u]."
                            else
                                echo "-> Tài khoản [$new_u] đã tồn tại trên Linux."
                            fi

                            # 2. Vòng lặp nhập và xác nhận lại mật khẩu
                            while true; do
                                read -s -p "Nhập mật khẩu Samba cho [$new_u]: " pass1
                                echo ""
                                read -s -p "Nhập lại mật khẩu để xác nhận: " pass2
                                echo ""

                                if [ -z "$pass1" ]; then
                                    echo "=> LỖI: Mật khẩu không được để trống! Vui lòng nhập lại."
                                elif [ "$pass1" != "$pass2" ]; then
                                    echo "=> LỖI: Hai mật khẩu không khớp nhau! Vui lòng nhập lại."
                                else
                                    printf "%s\n%s\n" "$pass1" "$pass2" | smbpasswd -a -s "$new_u" &>/dev/null
                                    if [ $? -eq 0 ]; then
                                        echo "=> THÀNH CÔNG! Đã tạo và đặt mật khẩu Samba cho [$new_u]."
                                    else
                                        echo "=> LỖI: Không thể thiết lập mật khẩu Samba cho [$new_u]."
                                    fi
                                    break
                                fi
                            done
                        fi
                        echo ""
                        read -p "Nhấn phím Enter để tiếp tục..."
                        ;;

                    2)
                        echo "--------------------------------------------------"
                        echo "-> PHÂN QUYỀN ĐỌC/GHI CHO THƯ MỤC CÓ SẴN"
                        echo "-> Danh sách các Share hiện có:"
                        grep -E "^\[.*\]" $SMB_CONF | grep -v '\[global\]'
                        echo "--------------------------------------------------"
                        read -p "Nhập chính xác tên Share cần phân quyền (không kèm dấu []): " s_name
                        s_name=$(echo "$s_name" | tr -d '[] ')

                        if [ -z "$s_name" ]; then
                            echo "=> Thao tác bị hủy do không nhập tên."
                        elif ! grep -q "^\[$s_name\]" $SMB_CONF; then
                            echo "=> LỖI: Không tìm thấy thư mục [$s_name] trong file cấu hình!"
                        else
                            echo "--------------------------------------------------"
                            echo "CẤU HÌNH NGƯỜI DÙNG (Phân cách nhiều user bằng dấu phẩy)"
                            read -p "Nhập danh sách user được GHI (VD: giamdoc): " w_users
                            read -p "Nhập danh sách user CHỈ ĐỌC (VD: nhanvien): " r_users

                            if [ -z "$w_users" ] && [ -z "$r_users" ]; then
                                echo "=> CẢNH BÁO: Bạn chưa nhập user nào! Hủy thao tác."
                            else
				awk -v target="[$s_name]" \
                                -v w_u="$w_users" \
                                -v r_u="$r_users" '
                                BEGIN { in_target = 0 }
                                /^\[.*\]/ {
                                    if ($0 == target) {
                                        in_target = 1
                                        print $0
                                        print "    guest ok = no"
                                        if (w_u != "" && r_u != "") {
                                            print "    valid users = " w_u ", " r_u
                                        } else if (w_u != "") {
                                            print "    valid users = " w_u
                                        } else if (r_u != "") {
                                            print "    valid users = " r_u
                                        }

                                        if (w_u != "") print "    write list = " w_u
                                        if (r_u != "") print "    read list = " r_u
                                        next
                                    } else {
                                        in_target = 0
                                    }
                                }
                                in_target {
                                    # Lọc bỏ các dòng cấu hình quyền cũ để không bị xung đột
                                    if ($0 ~ /^[[:space:]]*(guest ok|public|valid users|write list|read list)/) {
                                        next
                                    }
                                }
                                { print $0 }
                                ' $SMB_CONF > $SMB_CONF.tmp && mv -f $SMB_CONF.tmp $SMB_CONF

                                echo "--------------------------------------------------"
                                echo "=> THÀNH CÔNG! Đã cập nhật phân quyền nâng cao cho Share [$s_name]."
                                echo "=> Lưu ý: Hãy chạy Chức năng 7 ở Menu chính để nạp lại dịch vụ."
                            fi
                        fi
                        echo ""
                        read -p "Nhấn phím Enter để tiếp tục..."
                        ;;

                    3)
                        echo "--------------------------------------------------"
                        echo "-> XÓA TÀI KHOẢN NGƯỜI DÙNG SAMBA"
                        echo "Danh sách user Samba hiện có trong hệ thống:"
                        pdbedit -L | cut -d: -f1 | sed 's/^/  - /'
                        echo "--------------------------------------------------"
                        read -p "Nhập tên user Samba muốn xóa: " del_u
                        del_u=$(echo "$del_u" | tr -d ' ')

                        if [ -z "$del_u" ]; then
                            echo "=> Thao tác bị hủy do không nhập tên user."
                        elif [ "$del_u" == "root" ]; then
                            echo "=> CẢNH BÁO NGUY HIỂM: Không được phép xóa tài khoản root!"
                        elif ! pdbedit -L | grep -qw "^$del_u"; then
                            echo "=> LỖI: User [$del_u] không tồn tại trong danh sách Samba!"
                        else
                            # 1. Xóa khỏi cơ sở dữ liệu Samba
                            smbpasswd -x "$del_u" &>/dev/null	
                            echo "=> Đã xóa [$del_u] khỏi cơ sở dữ liệu Samba."

                            # 2. Tùy chọn xóa tài khoản Linux
                            read -p "Bạn có muốn xóa luôn tài khoản [$del_u] khỏi hệ điều hành Linux? (y/N): " confirm_del
                            if [[ "$confirm_del" =~ ^[yY]$ ]]; then
                                userdel -r -f "$del_u" &>/dev/null
                                echo "=> Đã xóa [$del_u] khỏi Linux."
                            else
                                echo "-> Giữ lại tài khoản [$del_u] trên tầng Linux."
                            fi
                            echo "=> THÀNH CÔNG! Hoàn tất xóa user [$del_u]."
                        fi
                        echo ""
                        read -p "Nhấn phím Enter để tiếp tục..."
                        ;;

                    0)
                        echo "=> Đang quay lại Menu chính..."
                        break
                        ;;

                    *)
                        echo "=> LỖI: Lựa chọn không hợp lệ, vui lòng chọn từ 0 đến 3!"
                        sleep 1
                        ;;
                esac
            done
            ;;

        11)
            echo "=================================================="
            echo "   KHÔI PHỤC CẤU HÌNH TỪ BẢN SAO LƯU (ROLLBACK)"
            echo "=================================================="
            if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
                echo "=> CẢNH BÁO: Chưa có bản sao lưu nào trong hệ thống!"
            else
                echo "-> Danh sách các bản sao lưu (Tối đa 20 bản mới nhất):"
                echo "--------------------------------------------------"

                # Lấy danh sách file theo thứ tự mới nhất nằm trên cùng (tối đa 20 bản)
                backups=($(ls -t "$BACKUP_DIR"/smb.conf.bak_* 2>/dev/null | head -n 20))

                if [ ${#backups[@]} -eq 0 ]; then
                    echo "=> Không tìm thấy file sao lưu hợp lệ dạng smb.conf.bak_*!"
                else
                    for i in "${!backups[@]}"; do
                        fname=$(basename "${backups[$i]}")
                        # Tách lấy mốc thời gian từ tên file để hiển thị trực quan
                        time_tag=${fname#smb.conf.bak_}
                        if [ $i -eq 0 ]; then
                            echo "  $((i+1)). Lúc: $time_tag [MỚI NHẤT]"
                        else
                            echo "  $((i+1)). Lúc: $time_tag"
                        fi
                    done
                    echo "--------------------------------------------------"
                    read -p "Chọn số thứ tự muốn khôi phục [Mặc định 1 - Mới nhất, 0 để Hủy]: " choice

                    # Nếu nhấn Enter để trống thì mặc định chọn bản 1 (mới nhất)
                    [ -z "$choice" ] && choice=1

                    if [ "$choice" -eq 0 ] 2>/dev/null; then
                        echo "=> Đã hủy thao tác rollback."
                    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#backups[@]}" ]; then
                        selected_file="${backups[$((choice-1))]}"
                        cp -f "$selected_file" "$SMB_CONF"

                        echo "--------------------------------------------------"
                        echo "=> THÀNH CÔNG! Đã khôi phục từ bản: $(basename "$selected_file")"
                        echo "=> Vui lòng chạy Chức năng 7 (hoặc restart Samba) để nạp lại dịch vụ."
                    else
                        echo "=> LỖI: Lựa chọn không hợp lệ!"
                    fi
                fi
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
