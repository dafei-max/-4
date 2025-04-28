// 简单排版系统 - Processing版本
// 提供基本的文本和图片排版功能

// 画布比例和网格设置
final int GRID_COLS = 25; // 横向25列网格
final int GRID_ROWS = 43; // 纵向43行网格
final int CELL_SPACING = 4; // 单元格间距

// 页面边距设置（不同边距）
final int MARGIN_TOP = 50;    // 上边距
final int MARGIN_BOTTOM = 74; // 下边距
final int MARGIN_LEFT = 74;   // 左边距
final int MARGIN_RIGHT = 74;  // 右边距

// 颜色设置
color bgColor = #FFFFFF;  // 背景色
color gridColor = #EEEEEE; // 网格线颜色
color textPrimary = #333333; // 主文本颜色
color textSecondary = #666666; // 次要文本颜色
color accentColor = #3366FF; // 强调色

// 画布尺寸
int canvasWidth = 900;  // 调整为900px
int canvasHeight = 1500; // 调整为1500px

// 网格相关变量
float gridWidth, gridHeight, cellWidth, cellHeight;

// 内容存储
ArrayList<TextBlock> textBlocks = new ArrayList<TextBlock>();
ArrayList<ImageBlock> imageBlocks = new ArrayList<ImageBlock>();

// 字体
PFont titleFont, bodyFont;

void setup() {
  size(900, 1500); // 设置画布大小为900*1500
  surface.setTitle("简易排版工具");
  
  // 计算版心尺寸（考虑不同的边距）
  gridWidth = width - (MARGIN_LEFT + MARGIN_RIGHT);
  gridHeight = height - (MARGIN_TOP + MARGIN_BOTTOM);
  
  // 计算单元格尺寸
  cellWidth = (gridWidth - (GRID_COLS - 1) * CELL_SPACING) / GRID_COLS;
  cellHeight = (gridHeight - (GRID_ROWS - 1) * CELL_SPACING) / GRID_ROWS;
  
  // 加载字体
  titleFont = createFont("微软雅黑", 24, true);
  bodyFont = createFont("微软雅黑", 14, true);
  
  // 清空内容（不添加示例内容）
  clearContent();
}

void draw() {
  // 绘制背景和网格
  background(bgColor);
  drawGrid();
  
  // 绘制所有内容块
  drawAllBlocks();
  
  // 绘制版心边框
  noFill();
  stroke(100, 100);
  strokeWeight(1);
  rect(MARGIN_LEFT, MARGIN_TOP, gridWidth, gridHeight);
}

// 绘制网格
void drawGrid() {
  stroke(gridColor);
  strokeWeight(0.5);
  
  // 绘制垂直线
  for (int i = 0; i <= GRID_COLS; i++) {
    float x = MARGIN_LEFT + i * (cellWidth + CELL_SPACING);
    line(x, MARGIN_TOP, x, height - MARGIN_BOTTOM);
  }
  
  // 绘制水平线
  for (int i = 0; i <= GRID_ROWS; i++) {
    float y = MARGIN_TOP + i * (cellHeight + CELL_SPACING);
    line(MARGIN_LEFT, y, width - MARGIN_RIGHT, y);
  }
}

// 绘制所有内容块
void drawAllBlocks() {
  // 绘制文本块
  for (TextBlock block : textBlocks) {
    drawTextBlock(block);
  }
  
  // 绘制图片块
  for (ImageBlock block : imageBlocks) {
    drawImageBlock(block);
  }
}

// 绘制文本块
void drawTextBlock(TextBlock block) {
  // 计算位置（考虑不同边距）
  float x = MARGIN_LEFT + block.col * (cellWidth + CELL_SPACING);
  float y = MARGIN_TOP + block.row * (cellHeight + CELL_SPACING);
  float w = block.colSpan * cellWidth + (block.colSpan - 1) * CELL_SPACING;
  float h = block.rowSpan * cellHeight + (block.rowSpan - 1) * CELL_SPACING;
  
  // 绘制背景（如果有）
  if (block.hasBg) {
    fill(block.bgColor);
    noStroke();
    rect(x, y, w, h);
  }
  
  // 设置文本属性
  if (block.alignment != TextBlock.JUSTIFIED) {
    textAlign(block.alignment);  // 使用内置对齐方式
  } else {
    textAlign(LEFT);  // 两端对齐时，先使用左对齐作为基础
  }
  
  fill(block.textColor);
  
  // 根据类型选择字体和大小
  if (block.type.equals("title")) {
    textFont(titleFont);
    textSize(block.fontSize > 0 ? block.fontSize : 28);
  } else if (block.type.equals("subtitle")) {
    textFont(titleFont);
    textSize(block.fontSize > 0 ? block.fontSize : 22);
  } else {
    textFont(bodyFont);
    textSize(block.fontSize > 0 ? block.fontSize : 16);
  }
  
  // 处理中文的换行逻辑 - 修改为中文适用的字符级换行
  float lineHeight = textAscent() + textDescent() + 10; // 增加行高适应大字号
  
  if (block.fontSize >= 28) {
    // 增加行间距，使大字体更易读
    lineHeight += 16;
  }
  
  // 对于中文文本，按字符处理而不是按单词
  String text = block.text;
  float yPos = y + 40; // 调整起始位置，给大字体留出空间
  
  // 检测有没有手动换行符
  String[] paragraphs = split(text, '\n');
  
  for (String paragraph : paragraphs) {
    // 对于两端对齐的处理
    if (block.alignment == TextBlock.JUSTIFIED) {
      drawJustifiedText(paragraph, x + 5, yPos, w - 20, lineHeight, h, y);
      yPos += lineHeight * 1.5; // 段落间距
    } else {
      // 原有的处理逻辑
      String line = "";
      
      // 逐字处理段落
      for (int i = 0; i < paragraph.length(); i++) {
        char c = paragraph.charAt(i);
        String testLine = line + c;
        
        // 检查添加此字符后是否超出宽度
        if (textWidth(testLine) > w - 20) {
          // 如果超出宽度，绘制当前行并开始新行
          if (line.length() > 0) {
            text(line, x + 5, yPos);
            line = "" + c; // 新行以当前字符开始
            yPos += lineHeight;
            
            // 防止文本溢出
            if (yPos > y + h - lineHeight) {
              return; // 如果超出高度，直接结束绘制
            }
          }
        } else {
          // 如果没超出宽度，继续添加到当前行
          line = testLine;
        }
      }
      
      // 绘制段落的最后一行
      if (line.length() > 0) {
        text(line, x + 5, yPos);
        yPos += lineHeight * 1.5; // 段落之间多加一些空间
      }
    }
  }
  
  // 绘制边框（如果需要）
  if (block.hasBorder) {
    stroke(block.borderColor);
    strokeWeight(1);
    noFill();
    rect(x, y, w, h);
  }
}

// 绘制两端对齐文本的方法
void drawJustifiedText(String paragraph, float x, float y, float maxWidth, float lineHeight, float maxHeight, float startY) {
  ArrayList<ArrayList<Character>> lines = new ArrayList<ArrayList<Character>>();
  ArrayList<Character> currentLine = new ArrayList<Character>();
  
  // 按字符分行
  float currentWidth = 0;
  for (int i = 0; i < paragraph.length(); i++) {
    char c = paragraph.charAt(i);
    float charWidth = textWidth(c);
    
    if (currentWidth + charWidth > maxWidth) {
      // 当前行已满，加入到lines并创建新行
      lines.add(currentLine);
      currentLine = new ArrayList<Character>();
      currentLine.add(c);
      currentWidth = charWidth;
    } else {
      // 继续添加到当前行
      currentLine.add(c);
      currentWidth += charWidth;
    }
  }
  
  // 添加最后一行
  if (currentLine.size() > 0) {
    lines.add(currentLine);
  }
  
  // 绘制所有行
  float yPos = y;
  for (int i = 0; i < lines.size(); i++) {
    ArrayList<Character> line = lines.get(i);
    
    // 最后一行不进行两端对齐，直接左对齐
    if (i == lines.size() - 1) {
      String textLine = "";
      for (char c : line) {
        textLine += c;
      }
      text(textLine, x, yPos);
    } else {
      drawJustifiedLine(line, x, yPos, maxWidth);
    }
    
    yPos += lineHeight;
    if (yPos > startY + maxHeight - lineHeight) {
      return; // 防止溢出
    }
  }
}

// 绘制单行两端对齐文本
void drawJustifiedLine(ArrayList<Character> chars, float x, float y, float maxWidth) {
  int numChars = chars.size();
  if (numChars <= 1) {
    // 只有一个字符时直接绘制
    text(chars.get(0), x, y);
    return;
  }
  
  // 计算所有字符的总宽度
  float totalCharWidth = 0;
  for (char c : chars) {
    totalCharWidth += textWidth(c);
  }
  
  // 计算需要分配的总空间
  float totalSpacing = maxWidth - totalCharWidth;
  
  // 计算每个字符间的额外空间
  float extraSpacePerGap = totalSpacing / (numChars - 1);
  
  // 绘制每个字符
  float currentX = x;
  for (int i = 0; i < numChars; i++) {
    char c = chars.get(i);
    text(c, currentX, y);
    currentX += textWidth(c);
    
    // 在每个字符后添加额外空间（最后一个字符除外）
    if (i < numChars - 1) {
      currentX += extraSpacePerGap;
    }
  }
}

// 绘制图片块
void drawImageBlock(ImageBlock block) {
  if (block.image == null) return;
  
  // 计算位置（考虑不同边距）
  float x = MARGIN_LEFT + block.col * (cellWidth + CELL_SPACING);
  float y = MARGIN_TOP + block.row * (cellHeight + CELL_SPACING);
  float w = block.colSpan * cellWidth + (block.colSpan - 1) * CELL_SPACING;
  float h = block.rowSpan * cellHeight + (block.rowSpan - 1) * CELL_SPACING;
  
  // 绘制图片
  if (block.isCircular) {
    // 圆形图片
    float diameter = min(w, h);
    float cx = x + w/2;
    float cy = y + h/2;
    
    // 创建圆形裁剪
    PGraphics mask = createGraphics(int(diameter), int(diameter));
    mask.beginDraw();
    mask.background(0);
    mask.fill(255);
    mask.noStroke();
    mask.ellipse(diameter/2, diameter/2, diameter, diameter);
    mask.endDraw();
    
    // 应用裁剪
    PImage imgCopy = block.image.copy();
    imgCopy.resize(int(diameter), 0);
    imgCopy.mask(mask);
    
    // 绘制
    imageMode(CENTER);
    image(imgCopy, cx, cy);
    imageMode(CORNER);
  } else {
    // 矩形图片
    image(block.image, x, y, w, h);
  }
  
  // 绘制边框（如果需要）
  if (block.hasBorder) {
    stroke(block.borderColor);
    strokeWeight(1);
    noFill();
    
    if (block.isCircular) {
      float diameter = min(w, h);
      float cx = x + w/2;
      float cy = y + h/2;
      ellipse(cx, cy, diameter, diameter);
    } else {
      rect(x, y, w, h);
    }
  }
}

// 清空所有内容
void clearContent() {
  textBlocks.clear();
  imageBlocks.clear();
  
  // 添加主标题
  TextBlock mainTitle = new TextBlock("title", 
    "变革与新生", 
    0, 1, 22, 3);
  mainTitle.fontSize = 48;
  mainTitle.alignment = CENTER;
  textBlocks.add(mainTitle);
  
  // 添加副标题
  TextBlock subtitle = new TextBlock("subtitle", 
    "代际性的制度革新", 
    0, 4, 22, 2);
  subtitle.fontSize = 38;
  subtitle.alignment = CENTER;
  textBlocks.add(subtitle);
  
  // 添加第一段正文
  TextBlock paragraph1 = new TextBlock("body", 
    "去年3月，外交公寓12号 (以下简称DRC No. 12) 宣布成立新一届理事会，同时创始人彭晓阳将空间的所有权及相关权益交给理事会。一个独立空间在即将进入第十年之际进行这样的自我变革，让北京独立空间的'生存'状态又一次进入我们的视野。", 
    0, 7, 22, 8);
  paragraph1.fontSize = 32;
  paragraph1.alignment = TextBlock.JUSTIFIED;
  textBlocks.add(paragraph1);
  
  // 添加第二段正文
  TextBlock paragraph2 = new TextBlock("body", 
    "'生存'这个常常与独立空间联系在一起的词总是令人紧张，也确实符合独立空间所面临的常见挑战：资源不足、物理空间缺乏长期保障、运营稳定性与创始人个人状态密切相关……但同时，与挑战常伴的状态也赋予了独立空间不断解决问题的生命力。除了主动进行具有理想主义色彩的代际性制度改革的DRC No. 12；成立于2020年疫情期间，位于798艺术区的蔡锦空间四年来几乎以创始人蔡锦的一人之力运营，以极高的活跃度和自由度组织了一个又一个艺术家个人项目；同时，一个名字颇有些玩世不恭的独立空间Okra-Homa Projects在二环内的胡同里悄悄诞生，推行着自身的空间实践。本文试图从以上三个独立空间的描绘和与创始人们的对话开始，对北京独立空间的现状进行一次观察和讨论。", 
    0, 16, 22, 25);
  paragraph2.fontSize = 32;
  paragraph2.alignment = TextBlock.JUSTIFIED;
  textBlocks.add(paragraph2);
}

// 添加新的文本块
void addTextBlock(String type, String text, float col, float row, float colSpan, float rowSpan) {
  TextBlock block = new TextBlock(type, text, col, row, colSpan, rowSpan);
  textBlocks.add(block);
}

// 添加新的图片块
void addImageBlock(PImage img, float col, float row, float colSpan, float rowSpan) {
  if (img != null) {
    ImageBlock block = new ImageBlock(img, col, row, colSpan, rowSpan);
    imageBlocks.add(block);
  }
}

// 键盘事件
void keyPressed() {
  if (key == 's' || key == 'S') {
    // 保存画布截图
    String filename = "layout_" + year() + month() + day() + hour() + minute() + second() + ".png";
    save(filename);
    println("已保存排版图像: " + filename);
  } else if (key == 'c' || key == 'C') {
    // 清空内容
    clearContent();
  }
}

// 文本块类
class TextBlock {
  String type; // "title", "subtitle", "body"
  String text;
  float col, row;
  float colSpan, rowSpan;
  int alignment = LEFT;  // LEFT, RIGHT, CENTER, 或 3 (两端对齐)
  color textColor = #333333;
  int fontSize = 0; // 0表示使用默认
  boolean hasBg = false;
  color bgColor = #FFFFFF;
  boolean hasBorder = false;
  color borderColor = #CCCCCC;
  
  // 常量定义
  static final int JUSTIFIED = 3;  // 自定义常量表示两端对齐
  
  TextBlock(String type, String text, float col, float row, float colSpan, float rowSpan) {
    this.type = type;
    this.text = text;
    this.col = col;
    this.row = row;
    this.colSpan = colSpan;
    this.rowSpan = rowSpan;
  }
}

// 图片块类
class ImageBlock {
  PImage image;
  float col, row;
  float colSpan, rowSpan;
  boolean isCircular = false;
  boolean hasBorder = false;
  color borderColor = #CCCCCC;
  
  ImageBlock(PImage image, float col, float row, float colSpan, float rowSpan) {
    this.image = image;
    this.col = col;
    this.row = row;
    this.colSpan = colSpan;
    this.rowSpan = rowSpan;
  }
} 