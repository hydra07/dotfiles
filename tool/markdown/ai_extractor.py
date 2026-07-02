import json
import sys
import os
import urllib.request
import urllib.error

def extract_mendix_data(json_path):
    print(f"⏳ Đang đọc dữ liệu thô từ: {json_path}")
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Tìm sheet có tên chứa "スケジュール" (Schedule) hoặc lấy sheet đầu tiên
    target_sheet = None
    for name in data["sheets"].keys():
        if "スケジュール" in name or "リソース" in name:
            target_sheet = name
            break
    if not target_sheet:
        target_sheet = list(data["sheets"].keys())[0]
        
    print(f"  -> Trích xuất từ sheet: {target_sheet}")
    cells = data["sheets"][target_sheet]["cells"]
    
    # Lọc bớt dữ liệu rác, chỉ giữ lại tọa độ (r, c), giá trị (val) và màu nền (bg) để tối ưu Token
    optimized_cells = []
    for cell in cells:
        # Chỉ lấy những ô có text hoặc có màu nền
        if "val" in cell or "bg" in cell:
            opt_cell = {"r": cell["r"], "c": cell["c"]}
            if "val" in cell: opt_cell["val"] = str(cell["val"])
            if "bg" in cell: opt_cell["bg"] = cell["bg"]
            optimized_cells.append(opt_cell)
            
    # Để an toàn cho API limit trong PoC, ta giới hạn số lượng cell gửi đi (ví dụ: 800 cells đầu tiên)
    cells_subset = optimized_cells[:800]
    
    prompt = f"""
Bạn là một kỹ sư tích hợp hệ thống (System Integration Engineer).
Dưới đây là bản trích xuất tọa độ các ô (Sparse Array) của một file Excel Tracking dự án giữa NTT và Macnica.
Mỗi object đại diện cho 1 ô: "r" (dòng), "c" (cột), "val" (giá trị text), "bg" (màu nền Hex).

Nhiệm vụ của bạn:
1. Đóng vai trò là một bộ Parser thông minh, tự động nội suy cấu trúc của bảng (cột nào là tiêu đề, cột nào là ID, dòng nào là timeline).
2. Trích xuất thông tin các dự án (Project/Task) có trong bảng.
3. Chú ý đến các ô có MÀU NỀN ("bg") ở các cột phía sau, vì đó thường là đánh dấu trạng thái/timeline của dự án trên Gantt Chart.
4. Trả về kết quả là một Mảng JSON phẳng (Flat JSON Array) chuẩn cấu trúc để import thẳng vào hệ thống Mendix.

Cấu trúc JSON Mendix mong muốn (ví dụ):
[
  {{
    "ProjectName": "Tên dự án hoặc Task",
    "Customer": "Tên khách hàng (nếu có)",
    "Status": "Trạng thái nội suy từ màu sắc hoặc chữ",
    "TimelineMarkers": [
       {{"Column": "Tọa độ cột", "Color": "Mã màu", "Note": "Ghi chú nếu có"}}
    ]
  }}
]

Dữ liệu thô (subset):
{json.dumps(cells_subset, ensure_ascii=False)}

Hãy CHỈ xuất ra mảng JSON hợp lệ, không giải thích gì thêm để hệ thống tự động parse.
"""

    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("❌ VUI LÒNG CUNG CẤP API KEY!")
        print("Cách chạy: set GEMINI_API_KEY=YOUR_KEY_HERE && python ai_extractor.py full_data.json")
        return

    print("🧠 Đang gửi dữ liệu thô cho LLM (Gemini) phân tích sâu...")
    
    # Gọi trực tiếp API REST của Gemini (không cần cài thêm thư viện)
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={api_key}"
    
    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"temperature": 0.1} # Nhiệt độ thấp để data chính xác
    }
    
    req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers={'Content-Type': 'application/json'})
    
    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            ai_text = result['candidates'][0]['content']['parts'][0]['text']
            
            # Xoá bớt thẻ markdown markdown ```json ... ``` nếu LLM trả về
            ai_text = ai_text.replace("```json\n", "").replace("```", "").strip()
            
            print("\n✅ === KẾT QUẢ MENDIX-FRIENDLY JSON TỪ AI === \n")
            print(ai_text)
            
            # Lưu ra file
            out_file = "mendix_ready_data.json"
            with open(out_file, "w", encoding="utf-8") as out:
                out.write(ai_text)
            print(f"\n💾 Đã lưu output chuẩn vào: {out_file}")
            
    except Exception as e:
        print(f"❌ Lỗi khi gọi API: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Sử dụng: python ai_extractor.py <file_json_tho.json>")
        sys.exit(1)
    extract_mendix_data(sys.argv[1])
