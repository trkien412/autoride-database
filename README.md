# AutoRide – bài thực hành CSDL

## File nộp
- `autoride_db.sql`: DDL migration, dữ liệu mô phỏng, SELECT kiểm tra và trigger tùy chọn.
- `er_activity_mapping.md`: phân tích dưới 200 từ.
- `ai_prompt_log.md`: nhật ký tương tác AI.

## Cách chạy
1. Mở `autoride_db.sql` trong MySQL Workbench.
2. Chạy script trên database legacy được cung cấp.
3. Xem kết quả SELECT; tiền hoàn lại trong kịch bản mẫu là 8.000.000 VNĐ.
4. Lệnh ALTER chỉ chạy một lần trên bảng Rentals legacy. Nếu đã nâng cấp bảng trước đó, không chạy lại ALTER.
5. Trigger được tạo sau dữ liệu mẫu; thử thêm inspection cho hợp đồng BOOKED/COMPLETED để kiểm tra trigger từ chối.

Dữ liệu trong bài là dữ liệu giả lập.
