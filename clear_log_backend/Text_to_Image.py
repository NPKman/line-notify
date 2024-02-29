from PIL import Image, ImageDraw, ImageFont
import sys
front_path="/home/oa-adm/clear_log_backend/front/arial.ttf"

def text_to_image(input_file, output_image):
    # Read text from input file
    with open(input_file, "r") as file:
        text_content = file.read()

    # Count the number of lines and columns in the text
    lines = text_content.split("\n")
    num_lines = len(lines)
    num_columns = len(lines[0].split("|"))

    # Determine image size based on the number of lines and columns
    font_size = 16
    line_spacing = 5
    column_width = 350
    image_width = (column_width + 10) * num_columns
    image_height = (font_size + line_spacing) * num_lines

    # Create a blank image
    image = Image.new("RGB", (image_width, image_height), "white")
    draw = ImageDraw.Draw(image)

    # Load a font
    font = ImageFont.truetype(front_path,font_size)

    # Set the starting position for text
    x, y = 10, 10

    # Write text to the image
    for line in lines:
        columns = line.split("|")
        for col_idx, column in enumerate(columns):
            draw.text((x + col_idx * (column_width + 10), y), column.strip(), font=font, fill="black")
        y += font_size + line_spacing

    # Save the image
    image.save(output_image)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert_to_image.py <input_file> <output_image>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_image = sys.argv[2]

    text_to_image(input_file, output_image)
