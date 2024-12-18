#!/bin/bash

# 检查参数是否正确
if [ "$#" -ne 2 ]; then
  echo "Usage: genxml.sh [directory] [parameter1]"
  exit 1
fi

DIRECTORY=$1
PARAM1=$2
OUTPUT_FILE="${PARAM1}.xml"

# 检查目录是否存在
if [ ! -d "$DIRECTORY" ]; then
  echo "Error: Directory '$DIRECTORY' does not exist."
  exit 1
fi

# 初始化 XML 文件内容
echo "<mxlibrary>[" > "$OUTPUT_FILE"

# 遍历目录中的图片文件
for IMAGE in "$DIRECTORY"/*.png; do
  if [ -f "$IMAGE" ]; then
    FILENAME=$(basename "$IMAGE")           # 获取文件名
    TITLE="${FILENAME%.*}"                 # 去掉扩展名作为标题
    URL="https://raw.githubusercontent.com/Chiunownow/StagePlotPirate/main/src/img/$PARAM1/$FILENAME"
    
    # 获取图片宽和高
    DIMENSIONS=$(sips -g pixelWidth -g pixelHeight "$IMAGE" 2>/dev/null)
    WIDTH=$(echo "$DIMENSIONS" | grep "pixelWidth" | awk '{print $2}')
    HEIGHT=$(echo "$DIMENSIONS" | grep "pixelHeight" | awk '{print $2}')
    
    # 检查宽高是否获取成功
    if [ -z "$WIDTH" ] || [ -z "$HEIGHT" ]; then
      echo "Error: Unable to get dimensions for $IMAGE"
      continue
    fi

    # 追加数据到 XML 文件
    echo "  {" >> "$OUTPUT_FILE"
    echo "    \"data\": \"$URL\"," >> "$OUTPUT_FILE"
    echo "    \"w\": $WIDTH," >> "$OUTPUT_FILE"
    echo "    \"h\": $HEIGHT," >> "$OUTPUT_FILE"
    echo "    \"title\": \"$TITLE\"" >> "$OUTPUT_FILE"
    echo "  }," >> "$OUTPUT_FILE"
  fi
done

# 移除最后一个逗号并结束 XML 文件
sed -i '' '$ s/,$//' "$OUTPUT_FILE"
echo "]</mxlibrary>" >> "$OUTPUT_FILE"

echo "XML file generated: $OUTPUT_FILE"
