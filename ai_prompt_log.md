# AI Prompt Log – AutoRide

## 1. Chọn kiểu dữ liệu cho tiền
**Prompt:** Vì sao các trường tiền cọc, phí trễ và phí hư hỏng nên dùng DECIMAL thay vì FLOAT/DOUBLE?

**Tóm tắt:** DECIMAL lưu số thập phân với độ chính xác cố định, phù hợp tính toán và đối soát tiền. FLOAT/DOUBLE có thể phát sinh sai số biểu diễn.

## 2. Thiết kế bảng Inspections
**Prompt:** Khi nào nên tách biên bản kiểm tra xe thành bảng riêng, và nên dùng quan hệ 1-1 hay 1-N?

**Tóm tắt:** Một hợp đồng có thể có nhiều lần kiểm tra, chẳng hạn lúc giao và lúc nhận xe, nên chọn Rentals 1-N Inspections. Bảng riêng lưu thời gian, người kiểm tra và mô tả hư hỏng mà không làm bảng Rentals phình to.

## 3. Ràng buộc trạng thái nghiệp vụ
**Prompt:** Làm sao ngăn tạo biên bản kiểm tra khi hợp đồng chưa ở trạng thái ACTIVE?

**Tóm tắt:** Có thể dùng trigger BEFORE INSERT để đọc trạng thái hợp đồng và SIGNAL lỗi nếu trạng thái không phải ACTIVE. Ứng dụng cũng nên kiểm tra quy tắc này để báo lỗi thân thiện hơn.

## 4. Tính tiền hoàn lại
**Prompt:** Làm thế nào để tránh kết quả NULL khi tính tiền hoàn lại nếu một trường phí có giá trị NULL?

**Tóm tắt:** Thiết kế các trường phí là NOT NULL DEFAULT 0.00; nếu làm việc với dữ liệu cũ có NULL thì dùng COALESCE(field, 0). Công thức là tiền cọc trừ phí trễ và phí hư hỏng.
