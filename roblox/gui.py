import sys
import os
from PyQt5.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QPushButton, QLabel, QGraphicsBlurEffect
)
from PyQt5.QtGui import QIcon, QPixmap, QFont, QPainter
from PyQt5.QtCore import Qt

def svg_icon(svg_data, size):
    from PyQt5.QtSvg import QSvgRenderer
    from PyQt5.QtGui import QImage, QPainter
    image = QImage(size, size, QImage.Format_ARGB32)
    image.fill(Qt.transparent)
    renderer = QSvgRenderer(bytearray(svg_data, encoding='utf-8'))
    painter = QPainter(image)
    renderer.render(painter)
    painter.end()
    return QPixmap.fromImage(image)

ARROW_SVG = '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M5 12H19" stroke="#7FFF7F" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M12 5L19 12L12 19" stroke="#7FFF7F" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>'''
INFO_SVG = '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="10" stroke="#7FFF7F" stroke-width="2"/><rect x="11" y="10" width="2" height="6" rx="1" fill="#7FFF7F"/><rect x="11" y="7" width="2" height="2" rx="1" fill="#7FFF7F"/></svg>'''

class ModernButton(QPushButton):
    def __init__(self, left_icon, text, right_icon=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.setStyleSheet('''
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #1a1a1a, stop:1 #0f0f0f);
                color: #fff;
                border: none;
                border-radius: 12px;
                padding: 12px 18px;
                font-size: 16px;
                font-weight: 600;
                outline: none;
                text-align: left;
            }
            QPushButton:focus {
                outline: none;
                border: none;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #252525, stop:1 #1a1a1a);
            }
        ''')
        layout = QHBoxLayout(self)
        layout.setContentsMargins(12, 0, 12, 0)
        layout.setSpacing(12)
        
        left = QLabel()
        left.setPixmap(left_icon)
        left.setStyleSheet('background: transparent;')
        layout.addWidget(left)
        
        label = QLabel(text)
        label.setStyleSheet('color: #fff; font-size: 16px; font-weight: 600; background: transparent;')
        layout.addWidget(label, 1)
        
        if right_icon:
            right = QLabel()
            right.setPixmap(right_icon)
            right.setStyleSheet('background: transparent;')
            layout.addWidget(right)

class BlurredWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Dbl")
        self.setFixedSize(460, 160)
        
        # Set window flags for a frameless window with transparency
        self.setWindowFlags(Qt.FramelessWindowHint)
        self.setAttribute(Qt.WA_TranslucentBackground)

        # Create the main background label that will be blurred
        self.bg_label = QLabel(self)
        self.bg_label.setGeometry(0, 0, 460, 160)
        self.bg_label.setStyleSheet(
            "background-color: rgba(10, 10, 10, 250); border-radius: 16px;"
        )
        
        # Apply blur only to the background label
        blur = QGraphicsBlurEffect()
        blur.setBlurRadius(0)
        self.bg_label.setGraphicsEffect(blur)

        # Content container that will stay sharp
        self.content = QWidget(self)
        self.content.setGeometry(0, 0, 460, 160)
        self.content.setStyleSheet('background: transparent;')

        # Main layout (added to content widget instead of self)
        main_layout = QHBoxLayout(self.content)
        main_layout.setContentsMargins(20, 16, 20, 16)
        main_layout.setSpacing(20)

        # Left panel: icon, name, version
        left_panel = QVBoxLayout()
        left_panel.setSpacing(6)
        exe_path = os.path.expandvars(r'%LOCALAPPDATA%/DBL/RobloxPlayerInstaller.exe')
        icon = QIcon(exe_path)
        icon_label = QLabel()
        icon_pixmap = icon.pixmap(48, 48)
        icon_label.setPixmap(icon_pixmap)
        left_panel.addWidget(icon_label, alignment=Qt.AlignLeft)
        name = QLabel("Dbl")
        name.setStyleSheet('color: #fff; font-size: 20px; font-weight: bold; background: transparent;')
        left_panel.addWidget(name, alignment=Qt.AlignLeft)
        version = QLabel("Version 1")
        version.setStyleSheet('color: #bbb; font-size: 13px; background: transparent;')
        left_panel.addWidget(version, alignment=Qt.AlignLeft)
        left_panel.addStretch()

        # Right panel: main buttons at the bottom
        right_panel = QVBoxLayout()
        right_panel.addStretch(2)  # Add more stretch above the buttons
        right_panel.setSpacing(24)
        arrow_icon = svg_icon(ARROW_SVG, 22)
        btn_launch = ModernButton(arrow_icon, "Launch Roblox", arrow_icon)
        btn_launch.clicked.connect(self.launch_roblox)
        btn_settings = ModernButton(svg_icon(INFO_SVG, 22), "Configure settings", arrow_icon)
        btn_settings.clicked.connect(self.open_settings)
        right_panel.addWidget(btn_launch)
        right_panel.addWidget(btn_settings)
        # right_panel.addStretch()  # Remove this to keep buttons at the bottom

        main_layout.addLayout(left_panel, 1)
        main_layout.addLayout(right_panel, 2)        # Add 'X' button to close the application
        close_button = CircleCloseButton(self)
        close_button.move(438, 10)
        # close_button.setStyleSheet('''
        #     QPushButton {
        #         background-color: #b30000;
        #         color: white;
        #         border: none;
        #         border-radius: 10px;
        #         font-weight: bold;
        #         font-size: 15px;
        #         font-family: monospace;
        #         padding: 0;
        #         margin: 0;
        #         min-width: 20px;
        #         min-height: 20px;
        #         max-width: 20px;
        #         max-height: 20px;
        #         line-height: 20px;
        #         vertical-align: middle;
        #     }
        #     QPushButton:hover {
        #         background-color: #800000;
        #     }
        # ''')
        # close_button.setCursor(Qt.PointingHandCursor)
        # close_button.setFixedSize(20, 20)
        # close_button.clicked.connect(self.close)

    def open_settings(self):
        # Get the path to the settings menu batch file relative to the current executable
        settings_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 
                                   "Change settings Or change textures", 
                                   "Main menu.bat")
        
        # Use startprocess to run the batch file
        import subprocess
        subprocess.Popen(['cmd', '/c', 'start', '', settings_path], 
                        shell=True, 
                        creationflags=subprocess.CREATE_NO_WINDOW)
        
        # Close the Python application
        QApplication.quit()

    def launch_roblox(self):
        # Build the path to roblox launcher.bat in a user-independent way
        batch_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "roblox launcher.bat")
        import subprocess
        subprocess.Popen(['cmd', '/c', 'start', '', batch_path], shell=True)

    def mousePressEvent(self, event):
        self.oldPos = event.globalPos()

    def mouseMoveEvent(self, event):
        if hasattr(self, 'oldPos'):
            delta = event.globalPos() - self.oldPos
            self.move(self.pos() + delta)
            self.oldPos = event.globalPos()

class CircleCloseButton(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFixedSize(20, 20)
        self.setCursor(Qt.PointingHandCursor)
        self.label = QLabel("×", self)
        self.label.setAlignment(Qt.AlignCenter)
        self.label.setGeometry(0, 0, 20, 20)
        self.label.setStyleSheet('''
            color: white;
            font-weight: bold;
            font-size: 15px;
            font-family: monospace;
            background: transparent;
        ''')
        self.setStyleSheet('''
            background-color: #b30000;
            border-radius: 10px;
        ''')

    def mousePressEvent(self, event):
        if self.parent():
            self.parent().close()

if __name__ == "__main__":
    from PyQt5.QtSvg import QSvgWidget  # Ensure PyQt5.QtSvg is installed
    app = QApplication(sys.argv)
    window = BlurredWindow()
    window.show()
    sys.exit(app.exec_())