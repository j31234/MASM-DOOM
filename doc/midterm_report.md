# 中期报告——DOOM-Like游戏

> 作者信息

## 项目简介

（结合视频/图片，简单介绍）

## 开发环境

- Windows 11 21H2
- Visual Studio 2012
- MASM 32

## 实现原理

### 模块化

除了入口程序`main.asm`以外，其它模块都由一个`.inc` 文件加`.asm`文件组成，其中`*.inc`是头文件，只描述了外部可以调用的函数接口以及数据，`*.asm`则是模块的具体实现。

> 例如 player 模块包含 player.inc 和 player.asm，在 player.inc 中定义了`DrawPlayer`函数供渲染过程调用，player.asm 中包含了 DrawPlayer 的实现，以及一些模块的私有函数与私有数据

共包含以下几个模块：

- `main.asm`：Win32 程序入口，负责创建图形窗口，维护[Window Message Loop](https://learn.microsoft.com/en-us/windows/win32/winmsg/using-messages-and-message-queues#creating-a-message-loop)，并且每隔一个固定的间隔，调用`draw`模块的`DrawMain`函数绘制一帧的画面
- `draw`：绘制一帧的画面，向其它模块提供`DrawLine`接口用于在窗口上绘制RGB彩色的线条
- `player`：维护 player 的状态（位置、朝向）并绘制
- `map`：绘制地图（墙面）
- `config`：窗口大小，FPS，FOV，移动速度，鼠标敏感度等游戏配置项

### 使用GDI接口在窗口上绘图

MASM32 库中提供了`gdi.inc`与`gdi.lib`，包含了[Windows graphics device interface](https://learn.microsoft.com/en-us/windows/win32/gdi/windows-gdi)（GDI）。

GDI 是 Window 提供的低级绘图接口。想要使用 GDI 在窗口上绘图，需要先进行初始化：

```assembly
; main.asm 中绘制一帧画面（DrawMain）前的初始化过程
; Get HDC
INVOKE GetDC, hMainWnd
mov hdc, eax

; Set up DC pen / brush
INVOKE GetStockObject, DC_PEN
INVOKE SelectObject, hdc, eax
mov oldPen, eax
INVOKE GetStockObject, DC_BRUSH
INVOKE SelectObject, hdc, eax
mov oldBrush, eax

; Begin Painting
INVOKE DrawMain, memHdc

; Release Resources: brush/pen, dc
INVOKE SelectObject, hdc, oldBrush
INVOKE SelectObject, hdc, oldPen
INVOKE ReleaseDC, hMainWnd, hdc
```

这里使用 [GetDC](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdc) 获得当前窗口的设备上下文（device context，DC），DC可以理解为绘图过程的数据/状态集合（包括：代表窗口显示内容的RGB二维数组，画笔的颜色，刷子的颜色等等），有了 DC，就可以调用其它函数改变窗口显示内容。

`GetStockObject`和`SelectObject`用于初始化画笔和刷子，之后的绘图过程会用到。

完成初始化后，在窗口上绘图就十分简单了：

```assembly
; draw.asm
; Draw a line from (fromX, fromY) to (toX, toY) with RGB color.
DrawLine Proc, hdc:HDC, fromX:DWORD, fromY:DWORD, toX:DWORD, toY:DWORD, RGB: DWORD
  INVOKE SetDCPenColor, hdc, RGB
  INVOKE MoveToEx, hdc, fromX, fromY, 0
  INVOKE LineTo, hdc, toX, toY
  RET
DrawLine ENDP
```

上面的`DrawLine`函数向其它模块提供了一个简单易用的接口：从窗口的`(fromX, fromY)`位置向`(toX, toY)`位置（坐标的定义见[What Is a Window - Win32 apps | Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/learnwin32/what-is-a-window-#screen-and-window-coordinates)中的 client coordinates）画一条颜色为`RGB`的线。这个函数首先设定画笔的颜色，然后把画笔移动到`(fromX, fromY)`，最后画线到`(toX, toY)`。

### 浮点计算

（FPU，见教材12.2，此外还使用了教材中没有描述的`FSIN`, `FCOS`, `FSQRT`指令）

### Ray Casting算法

（看Youtube上那个视频7:49到16:02。可以用2D部分的代码做几个图插进来）



（更多实现原理内容）



## 技术难点

### 双重缓冲区

（用于消除画面闪烁，看`main.asm`处理`WM_TIMER`的代码）

画面闪烁：前景和后景绘制存在时间差。

使用双重缓冲区，可以先在内存中的缓冲区把一帧画面绘制好，然后把缓冲区中的所有内容一次送到显示设备。

### 固定Framerate

（使用SetTimer函数生成固定频率的WM_TIMER事件，然后[Drawing Without the WM_PAINT Message - Win32 apps | Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/gdi/drawing-without-the-wm-paint-message)）



（更多技术难点）



## 小组分工



## 参考资料

[Get Started with Win32 and C++ - Win32 apps | Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/learnwin32/learn-to-program-for-windows)

[Creating a DOOM-style 3D Game in Python from Scratch. Pygame Tutorial - YouTube](https://www.youtube.com/watch?v=ECqUrT7IdqQ)

