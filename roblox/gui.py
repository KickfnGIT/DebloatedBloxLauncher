import sys
import os
import subprocess
from PyQt5.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QPushButton, QLabel, 
    QGraphicsBlurEffect, QGraphicsOpacityEffect
)
from PyQt5.QtGui import QIcon, QPixmap, QFont, QPainter, QColor
from PyQt5.QtCore import Qt, QPropertyAnimation, QRect, QParallelAnimationGroup
import psutil

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

ARROW_SVG = '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 22C17.5228 22 22 17.5228 22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715 2 12C2 17.5228 6.47715 22 12 22Z" stroke="#FF3B3B" stroke-width="2"/>
<path d="M16 12L10 8V16L16 12Z" fill="#FF3B3B"/>
</svg>'''
INFO_SVG = '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 21C16.9706 21 21 16.9706 21 12C21 7.02944 16.9706 3 12 3C7.02944 3 3 7.02944 3 12C3 16.9706 7.02944 21 12 21Z" stroke="#FF5252" stroke-width="2" stroke-linecap="round"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M12 7.5C12.5523 7.5 13 7.94772 13 8.5C13 9.05228 12.5523 9.5 12 9.5C11.4477 9.5 11 9.05228 11 8.5C11 7.94772 11.4477 7.5 12 7.5Z" fill="#FF5252"/>
<path d="M12 12V16.5" stroke="#FF5252" stroke-width="2" stroke-linecap="round"/>
</svg>'''

VERSION = "1.3"

class ModernButton(QPushButton):
    def __init__(self, left_icon, text, right_icon=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.setStyleSheet('''
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #2A1618,
                    stop:1 #1A0F10
                );
                color: #FFE6E6;
                border: 1.2px solid #4D2326;
                border-radius: 24px;
                padding: 14px 24px;
                font-size: 15px;
                font-family: "Segoe UI", "Inter", Arial, sans-serif;
                font-weight: 600;
                letter-spacing: 0.3px;
                outline: none;
                text-align: left;
            }
            QPushButton:focus {
                outline: none;
                border: 1.2px solid #662B2F;
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #331B1D,
                    stop:1 #201213
                );
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #3A1F22,
                    stop:1 #2A1618
                );
                border: 1.2px solid #662B2F;
            }
            QPushButton:pressed {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #1A0F10,
                    stop:1 #201213
                );
                padding: 14px 24px;
            }
        ''')
        layout = QHBoxLayout(self)
        layout.setContentsMargins(8, 0, 12, 0)
        layout.setSpacing(14)
        
        left = QLabel()
        left.setPixmap(left_icon)
        left.setStyleSheet('background: transparent; padding-left: 4px;')
        layout.addWidget(left)
        
        label = QLabel(text)
        label.setStyleSheet('''
            color: #E8EAED; 
            font-size: 15px; 
            font-family: "Segoe UI", "Inter", Arial, sans-serif;
            font-weight: 600; 
            background: transparent;
            letter-spacing: 0.3px;
        ''')
        layout.addWidget(label, 1)
        
        # Remove right icon
        # if right_icon:
        #     right = QLabel()
        #     right.setPixmap(right_icon)
        #     right.setStyleSheet('background: transparent;')
        #     layout.addWidget(right)

class BlurredWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.kill_roblox_process()
        self.setWindowTitle("Dbl")
        self.setFixedSize(380, 180)
        
        # Set window flags for a frameless window with transparency
        self.setWindowFlags(Qt.FramelessWindowHint)
        self.setAttribute(Qt.WA_TranslucentBackground)

        # Create the main background label that will be blurred
        self.bg_label = QLabel(self)
        self.bg_label.setGeometry(0, 0, 380, 180)
        self.bg_label.setStyleSheet(
            "background-color: rgba(12, 13, 15, 242); border-radius: 32px;"
        )
        
        # Apply blur only to the background label
        blur = QGraphicsBlurEffect()
        blur.setBlurRadius(0)
        self.bg_label.setGraphicsEffect(blur)

        # Content container that will stay sharp
        self.content = QWidget(self)
        self.content.setGeometry(0, 0, 380, 180)
        self.content.setStyleSheet('background: transparent;')

        # Main layout (added to content widget instead of self)
        main_layout = QHBoxLayout(self.content)
        main_layout.setContentsMargins(20, 16, 20, 16)
        main_layout.setSpacing(20)

        # Left panel: icon, name, version
        left_panel = QVBoxLayout()
        left_panel.setSpacing(6)
        left_panel.setContentsMargins(12, 0, 0, 0)  # Add left margin to move logo right
        
        # Use the custom logo from the application directory
        logo_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 
                                "skyboxfix", "images", 
                                "communityIcon_zh277xaatqt91_upscayl_4x_ultrasharp.png")
        
        if os.path.exists(logo_path):
            original_pixmap = QPixmap(logo_path)
            logo_pixmap = original_pixmap.scaled(72, 72, Qt.KeepAspectRatio, Qt.SmoothTransformation)
            icon_label = QLabel()
            icon_label.setStyleSheet('background: transparent;')
            icon_label.setPixmap(logo_pixmap)
        else:
            # Fallback to the exe icon from the current directory
            exe_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "RobloxPlayerInstaller.exe")
            if not os.path.exists(exe_path):
                # If not found in current directory, try LocalAppData
                exe_path = os.path.expandvars(r'%LOCALAPPDATA%/DBL/RobloxPlayerInstaller.exe')
            
            icon = QIcon(exe_path)
            icon_label = QLabel()
            icon_pixmap = icon.pixmap(72, 72)
            icon_label.setPixmap(icon_pixmap)
        left_panel.addWidget(icon_label, alignment=Qt.AlignLeft)
        name = QLabel("DBL")
        name.setStyleSheet('color: #fff; font-size: 20px; font-weight: bold; background: transparent;')
        left_panel.addWidget(name, alignment=Qt.AlignLeft)
        version = QLabel(f"Version {VERSION}")
        version.setStyleSheet('color: #bbb; font-size: 13px; background: transparent;')
        left_panel.addWidget(version, alignment=Qt.AlignLeft)
        left_panel.addStretch()

        # Right panel: main buttons at the bottom
        right_panel = QVBoxLayout()
        right_panel.addStretch(1)  # Reduced top stretch
        right_panel.setSpacing(12)  # Keep existing spacing between buttons
        arrow_icon = svg_icon(ARROW_SVG, 22)
        btn_launch = ModernButton(arrow_icon, "Launch Roblox")
        btn_launch.setFixedSize(220, 48)  # Fixed size for consistency
        btn_launch.clicked.connect(self.launch_roblox)
        btn_settings = ModernButton(svg_icon(INFO_SVG, 22), "Configure settings")
        btn_settings.setFixedSize(220, 48)  # Fixed size for consistency
        btn_settings.clicked.connect(self.open_settings)
        right_panel.addWidget(btn_launch)
        right_panel.addWidget(btn_settings)
        right_panel.addStretch(1)  # Equal bottom stretch to center the buttons

        main_layout.addLayout(left_panel, 1)
        main_layout.addLayout(right_panel, 2)        # Add 'X' button to close the application
        close_button = CircleCloseButton(self)
        close_button.move(346, 8)  # Moved up and to the right
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
        self.fade_in_with_expand()

    def fade_in_with_expand(self):
        # Create a fade-in effect combined with an expansion animation
        self.opacity_effect = QGraphicsOpacityEffect()
        self.setGraphicsEffect(self.opacity_effect)

        self.opacity_animation = QPropertyAnimation(self.opacity_effect, b"opacity")
        self.opacity_animation.setDuration(500)  # Duration in milliseconds
        self.opacity_animation.setStartValue(0)
        self.opacity_animation.setEndValue(1)

        self.geometry_animation = QPropertyAnimation(self, b"geometry")
        self.geometry_animation.setDuration(500)  # Duration in milliseconds
        screen = QApplication.primaryScreen().availableGeometry()
        start_geometry = QRect(screen.center().x() - self.geometry().width() // 2, screen.center().y() - self.geometry().height() // 2, self.geometry().width(), 0)
        end_geometry = QRect(screen.center().x() - self.geometry().width() // 2, screen.center().y() - self.geometry().height() // 2, self.geometry().width(), self.geometry().height())
        self.geometry_animation.setStartValue(start_geometry)
        self.geometry_animation.setEndValue(end_geometry)

        self.animation_group = QParallelAnimationGroup()
        self.animation_group.addAnimation(self.opacity_animation)
        self.animation_group.addAnimation(self.geometry_animation)
        self.animation_group.start()

    def close_with_animation(self):
        # Create a roll-up effect and adjust opacity
        self.opacity_effect = QGraphicsOpacityEffect()
        self.setGraphicsEffect(self.opacity_effect)

        self.geometry_animation = QPropertyAnimation(self, b"geometry")
        self.geometry_animation.setDuration(500)  # Duration in milliseconds
        start_geometry = self.geometry()
        end_geometry = QRect(start_geometry.x(), start_geometry.y() + start_geometry.height() // 2, start_geometry.width(), 0)  # Roll up into a bar
        self.geometry_animation.setStartValue(start_geometry)
        self.geometry_animation.setEndValue(end_geometry)

        self.opacity_animation = QPropertyAnimation(self.opacity_effect, b"opacity")
        self.opacity_animation.setDuration(500)  # Duration in milliseconds
        self.opacity_animation.setStartValue(1)
        self.opacity_animation.setEndValue(0)

        self.animation_group = QParallelAnimationGroup()
        self.animation_group.addAnimation(self.geometry_animation)
        self.animation_group.addAnimation(self.opacity_animation)
        self.animation_group.finished.connect(self.close)
        self.animation_group.start()

    def morph_to_settings(self):
        # Create a faster fade-out effect before transitioning
        self.opacity_effect = QGraphicsOpacityEffect()
        self.setGraphicsEffect(self.opacity_effect)

        self.opacity_animation = QPropertyAnimation(self.opacity_effect, b"opacity")
        self.opacity_animation.setDuration(300)  # Reduced duration for faster fade-out
        self.opacity_animation.setStartValue(1)
        self.opacity_animation.setEndValue(0)
        self.opacity_animation.finished.connect(self.launch_settings_ui)
        self.opacity_animation.start()

    def launch_settings_ui(self):
        # Launch the settings UI
        settings_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 
                                     "Change settings Or change textures", 
                                     "menu.py")
        pythonw = os.path.join(os.path.dirname(sys.executable), 'pythonw.exe')
        subprocess.Popen([pythonw, settings_path])
        self.close()

    def open_settings(self):
        self.morph_to_settings()

    def kill_roblox_process(self):
        # Kill RobloxPlayerBeta.exe if running
        for process in psutil.process_iter(['name']):
            if process.info['name'] == 'RobloxPlayerBeta.exe':
                process.kill()

    def launch_roblox(self):
        # Build the path to roblox launcher.bat in a user-independent way
        batch_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "roblox launcher.bat")
        import subprocess
        subprocess.Popen(['cmd', '/c', 'start', '/min', '', batch_path], shell=True)
        # Close the Python application after launching the batch file
        self.close_with_animation()

    def mousePressEvent(self, event):
        self.oldPos = event.globalPos()

    def mouseMoveEvent(self, event):
        if hasattr(self, 'oldPos'):
            delta = event.globalPos() - self.oldPos
            self.move(self.pos() + delta)
            self.oldPos = event.globalPos()

    def close_with_fade_out(self):
        # Create a fade-out effect before closing the UI
        self.opacity_effect = QGraphicsOpacityEffect()
        self.setGraphicsEffect(self.opacity_effect)

        self.opacity_animation = QPropertyAnimation(self.opacity_effect, b"opacity")
        self.opacity_animation.setDuration(500)  # Duration in milliseconds
        self.opacity_animation.setStartValue(1)
        self.opacity_animation.setEndValue(0)
        self.opacity_animation.finished.connect(self.close)
        self.opacity_animation.start()

class CircleCloseButton(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFixedSize(24, 24)
        self.setCursor(Qt.PointingHandCursor)
        
        layout = QHBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)
        
        self.label = QLabel("×", self)
        self.label.setAlignment(Qt.AlignCenter)
        self.label.setStyleSheet('''
            color: #FFE6E6;
            font-weight: bold;
            font-size: 20px;
            font-family: "Segoe UI", Arial;
            background: transparent;
            padding: 0;
            margin: 0;
        ''')
        layout.addWidget(self.label)
        
        self.setStyleSheet('''
            QWidget {
                background-color: #4D2326;
                border-radius: 12px;
            }
            QWidget:hover {
                background-color: #662B2F;
            }
        ''')

    def mousePressEvent(self, event):
        if self.parent():
            self.parent().close_with_fade_out()

if __name__ == "__main__":
    from PyQt5.QtSvg import QSvgWidget  # Ensure PyQt5.QtSvg is installed
    app = QApplication(sys.argv)
    window = BlurredWindow()
    window.show()
    sys.exit(app.exec_())