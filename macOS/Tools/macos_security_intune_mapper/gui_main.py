"""Entry point for the macOS Intune Mapper GUI application."""

import logging
import wx
import sys
from pathlib import Path

# Add current directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from gui.main_window import MainWindow

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


def main():
    """Main entry point for the GUI application."""
    try:
        app = wx.App()
        frame = MainWindow()
        frame.Show()
        app.MainLoop()
    except Exception as e:
        logger.error(f"Application error: {e}", exc_info=True)
        wx.MessageBox(f"Application error: {e}", "Error", wx.OK | wx.ICON_ERROR)
        sys.exit(1)


if __name__ == "__main__":
    main()
