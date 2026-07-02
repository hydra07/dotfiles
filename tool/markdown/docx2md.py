import argparse
import mammoth
from markdownify import markdownify as md
import os
import base64
import sys


def convert_docx_to_md(input_path, output_path, use_base64, media_dir):
    if not os.path.exists(input_path):
        print(f"❌ Lỗi: Không tìm thấy file '{input_path}'")
        sys.exit(1)

    # Nếu không dùng base64, tạo thư mục chứa ảnh
    if not use_base64 and not os.path.exists(media_dir):
        os.makedirs(media_dir)

    image_counter = [1]

    def handle_image(image):
        extension = image.content_type.split("/")[-1]

        if use_base64:
            # Chế độ 1: Nhúng Base64 trực tiếp vào Markdown
            with image.open() as image_bytes:
                encoded_string = base64.b64encode(image_bytes.read()).decode("utf-8")
            return {"src": f"data:image/{extension};base64,{encoded_string}"}
        else:
            # Chế độ 2: Lưu ảnh ra thư mục
            image_name = f"image_{image_counter[0]}.{extension}"
            image_path = os.path.join(media_dir, image_name)

            with open(image_path, "wb") as f:
                with image.open() as image_bytes:
                    f.write(image_bytes.read())

            image_counter[0] += 1
            return {"src": image_path}

    try:
        print(f"⏳ Đang xử lý file: {input_path}...")
        with open(input_path, "rb") as docx_file:
            result = mammoth.convert_to_html(
                docx_file, convert_image=mammoth.images.img_element(handle_image)
            )
            html_content = result.value

        markdown_text = md(html_content, heading_style="ATX")

        with open(output_path, "w", encoding="utf-8") as f:
            f.write(markdown_text)

        print(f"✅ Xong! Đã lưu Markdown tại: {output_path}")
        if not use_base64:
            print(f"🖼️ Ảnh được lưu tại thư mục: {media_dir}/")

    except Exception as e:
        print(f"❌ Có lỗi xảy ra trong quá trình chuyển đổi: {e}")


if __name__ == "__main__":
    # Thiết lập CLI arguments
    parser = argparse.ArgumentParser(
        description="Tool convert DOCX sang Markdown (Hỗ trợ ảnh)"
    )

    # Các tham số bắt buộc (Vị trí)
    parser.add_argument("input", help="Đường dẫn tới file DOCX đầu vào")
    parser.add_argument("output", help="Đường dẫn tới file Markdown đầu ra")

    # Các tham số tùy chọn (Flags)
    parser.add_argument(
        "--base64",
        action="store_true",
        help="Nhúng ảnh trực tiếp vào Markdown dưới dạng Base64 (thay vì lưu file riêng)",
    )
    parser.add_argument(
        "--media-dir",
        default="media",
        help="Tên thư mục lưu ảnh nếu không dùng --base64 (Mặc định: 'media')",
    )

    args = parser.parse_args()

    # Chạy hàm convert
    convert_docx_to_md(args.input, args.output, args.base64, args.media_dir)
