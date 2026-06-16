"""Main window for macOS Intune Mapper GUI."""

import logging
import wx
from pathlib import Path
from dataclasses import dataclass
from typing import Optional, Dict, Any, List

from ..core.baseline_loader import BaselineLoader
from ..core.rules_loader import RulesLoader
from ..core.settings_catalog import SettingsCatalog
from ..core.policy_mapper import PolicyMapper
from ..models.baseline import Baseline
from ..models.rule import Rule
from ..models.policy import Policy, PolicySetting
from .export_dialog import ExportDialog

logger = logging.getLogger(__name__)


@dataclass
class SettingItem:
    """Represents an individual setting with its catalog definition and values."""
    rule_id: str  # Source rule ID
    rule_title: str  # Source rule title
    setting_definition_id: str  # Setting ID from catalog
    setting_name: str  # displayName from catalog
    description: str  # description from catalog
    default_value: str  # default option in readable format
    baseline_value: str  # value from baseline/rule
    value_override: Optional[Any] = None  # User's custom value
    included: bool = True  # Include in export
    status: str = "Mapped"  # "Mapped" or "Unmapped"
    policy_setting: Optional[PolicySetting] = None  # Original PolicySetting object
    setting_definition: Optional[Dict[str, Any]] = None  # Full catalog definition
    section: str = ""  # Rule section


class MainWindow(wx.Frame):
    """Main application window."""
    
    def __init__(self):
        """Initialize the main window."""
        super().__init__(
            None, 
            title="macOS Security Baselines to Intune Mapper",
            size=(1600, 900)
        )
        
        # Application state
        self.macos_security_path: Optional[Path] = self._load_macos_security_path()
        self.baseline_loader = self._create_baseline_loader()
        self.rules_loader = self._create_rules_loader()
        self.settings_catalog: Optional[SettingsCatalog] = None
        self.current_baseline: Optional[Baseline] = None
        self.setting_items: List[SettingItem] = []  # All settings with their status
        self.rule_policies: Dict[str, Policy] = {}  # Policies mapped from rules
        self.custom_rules: List[Rule] = []  # Rules without mobileconfig support
        
        # Setup UI
        self._create_menu_bar()
        self._create_ui()
        self._create_status_bar()
        
        # Center the window
        self.Centre()
    
    def _load_macos_security_path(self) -> Optional[Path]:
        """Load the saved macos_security path from config."""
        config_file = Path.home() / ".macos_security_intune_mapper" / "config.txt"
        if config_file.exists():
            try:
                saved_path = Path(config_file.read_text().strip())
                if saved_path.exists() and (saved_path / "baselines").exists():
                    logger.info(f"Loaded macos_security path from config: {saved_path}")
                    return saved_path
            except Exception as e:
                logger.warning(f"Failed to load saved path: {e}")
        
        # Try default location
        default_path = Path(__file__).parent.parent.parent / "macos_security"
        if default_path.exists():
            return default_path
        
        return None
    
    def _save_macos_security_path(self, path: Path):
        """Save the macos_security path to config."""
        config_file = Path.home() / ".macos_security_intune_mapper" / "config.txt"
        config_file.parent.mkdir(parents=True, exist_ok=True)
        config_file.write_text(str(path))
        logger.info(f"Saved macos_security path: {path}")
    
    def _create_baseline_loader(self) -> BaselineLoader:
        """Create baseline loader with configured path."""
        if self.macos_security_path:
            return BaselineLoader(str(self.macos_security_path))
        return BaselineLoader()
    
    def _create_rules_loader(self) -> RulesLoader:
        """Create rules loader with configured path."""
        if self.macos_security_path:
            return RulesLoader(str(self.macos_security_path))
        return RulesLoader()
    
    def _create_menu_bar(self):
        """Create the application menu bar."""
        menu_bar = wx.MenuBar()
        
        # File menu
        file_menu = wx.Menu()
        load_catalog_item = file_menu.Append(wx.ID_ANY, "Load Settings Catalog...\tCtrl+O", "Load Settings Catalog from JSON file")
        self.Bind(wx.EVT_MENU, self.on_load_catalog, load_catalog_item)
        
        file_menu.AppendSeparator()
        exit_item = file_menu.Append(wx.ID_EXIT, "E&xit\tCtrl+Q", "Exit the application")
        self.Bind(wx.EVT_MENU, self.on_exit, exit_item)
        
        menu_bar.Append(file_menu, "&File")
        
        # Help menu
        help_menu = wx.Menu()
        about_item = help_menu.Append(wx.ID_ABOUT, "&About", "About this application")
        self.Bind(wx.EVT_MENU, self.on_about, about_item)
        
        menu_bar.Append(help_menu, "&Help")
        
        self.SetMenuBar(menu_bar)
    
    def _create_ui(self):
        """Create the main UI layout."""
        panel = wx.Panel(self)
        main_sizer = wx.BoxSizer(wx.VERTICAL)
        
        # Top controls
        top_sizer = self._create_top_controls(panel)
        main_sizer.Add(top_sizer, 0, wx.ALL | wx.EXPAND, 10)
        
        # Policy list with tabs
        policy_sizer = self._create_policy_list(panel)
        main_sizer.Add(policy_sizer, 1, wx.ALL | wx.EXPAND, 10)
        
        panel.SetSizer(main_sizer)
    
    def _create_top_controls(self, parent):
        """Create top control panel with baseline and catalog selection."""
        main_sizer = wx.BoxSizer(wx.VERTICAL)
        
        # Row 1: Settings Catalog (moved to top)
        row1_sizer = wx.BoxSizer(wx.HORIZONTAL)
        
        catalog_label = wx.StaticText(parent, label="Settings Catalog:")
        row1_sizer.Add(catalog_label, 0, wx.ALIGN_CENTER_VERTICAL | wx.RIGHT, 5)
        
        self.catalog_status = wx.StaticText(parent, label="Not Loaded")
        self.catalog_status.SetForegroundColour(wx.RED)
        row1_sizer.Add(self.catalog_status, 1, wx.ALIGN_CENTER_VERTICAL | wx.RIGHT, 10)
        
        catalog_json_btn = wx.Button(parent, label="Load from JSON")
        catalog_json_btn.Bind(wx.EVT_BUTTON, self.on_load_catalog)
        row1_sizer.Add(catalog_json_btn, 0, wx.RIGHT, 5)
        
        catalog_azure_btn = wx.Button(parent, label="Load from Azure")
        catalog_azure_btn.Bind(wx.EVT_BUTTON, self.on_load_catalog_from_azure)
        row1_sizer.Add(catalog_azure_btn, 0)
        
        main_sizer.Add(row1_sizer, 0, wx.EXPAND | wx.BOTTOM, 10)
        
        # Row 2: macOS Security folder
        row2_sizer = wx.BoxSizer(wx.HORIZONTAL)
        
        folder_label = wx.StaticText(parent, label="macOS Security Folder:")
        row2_sizer.Add(folder_label, 0, wx.ALIGN_CENTER_VERTICAL | wx.RIGHT, 5)
        
        self.folder_text = wx.TextCtrl(parent, value=str(self.macos_security_path) if self.macos_security_path else "", style=wx.TE_READONLY)
        row2_sizer.Add(self.folder_text, 1, wx.EXPAND | wx.RIGHT, 5)
        
        folder_btn = wx.Button(parent, label="Browse...")
        folder_btn.Bind(wx.EVT_BUTTON, self.on_select_folder)
        row2_sizer.Add(folder_btn, 0)
        
        main_sizer.Add(row2_sizer, 0, wx.EXPAND | wx.BOTTOM, 10)
        
        # Row 3: Baseline selection and actions
        row3_sizer = wx.BoxSizer(wx.HORIZONTAL)
        
        # Baseline selection
        baseline_label = wx.StaticText(parent, label="Baseline:")
        row3_sizer.Add(baseline_label, 0, wx.ALIGN_CENTER_VERTICAL | wx.RIGHT, 5)
        
        self.baseline_choice = wx.Choice(parent, choices=[])
        self.baseline_choice.Bind(wx.EVT_CHOICE, self.on_baseline_selected)
        row3_sizer.Add(self.baseline_choice, 0, wx.RIGHT, 10)
        
        # Load button
        self.load_baseline_btn = wx.Button(parent, label="Load Baseline")
        self.load_baseline_btn.Bind(wx.EVT_BUTTON, self.on_load_baseline)
        row3_sizer.Add(self.load_baseline_btn, 0, wx.RIGHT, 10)
        
        # Export button
        self.export_btn = wx.Button(parent, label="Export...")
        self.export_btn.Bind(wx.EVT_BUTTON, self.on_export)
        row3_sizer.Add(self.export_btn, 0)
        
        main_sizer.Add(row3_sizer, 0, wx.EXPAND)
        
        # Load available baselines
        self._refresh_baselines()
        
        return main_sizer
    
    def _create_policy_list(self, parent):
        """Create the policy list with tabs for Settings Catalog and Custom Configuration."""
        sizer = wx.BoxSizer(wx.VERTICAL)
        
        # Create a panel to hold both notebook and loading overlay
        container_panel = wx.Panel(parent)
        container_sizer = wx.BoxSizer(wx.VERTICAL)
        
        # Create notebook for tabs
        self.notebook = wx.Notebook(container_panel)
        
        # Tab 1: Settings Catalog Policies
        settings_catalog_panel = wx.Panel(self.notebook)
        settings_catalog_sizer = wx.BoxSizer(wx.VERTICAL)
        
        self.settings_catalog_list = wx.ListCtrl(
            settings_catalog_panel,
            style=wx.LC_REPORT | wx.LC_SINGLE_SEL
        )
        
        # Create image list for checkboxes
        self._create_checkbox_images()
        
        self.settings_catalog_list.AppendColumn("Include", width=60)
        self.settings_catalog_list.AppendColumn("Setting Name", width=250)
        self.settings_catalog_list.AppendColumn("Description", width=350)
        self.settings_catalog_list.AppendColumn("Default Value", width=120)
        self.settings_catalog_list.AppendColumn("Baseline Value", width=120)
        self.settings_catalog_list.AppendColumn("Value Override", width=120)
        self.settings_catalog_list.AppendColumn("Rule ID", width=200)
        
        settings_catalog_sizer.Add(self.settings_catalog_list, 1, wx.EXPAND | wx.ALL, 5)
        
        # Buttons for Settings Catalog tab
        settings_btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        
        btn_toggle_sc = wx.Button(settings_catalog_panel, label="Toggle Include")
        btn_toggle_sc.Bind(wx.EVT_BUTTON, lambda e: self.on_toggle_include(e, 'settings'))
        settings_btn_sizer.Add(btn_toggle_sc, 0, wx.ALL, 5)
        
        btn_edit_sc = wx.Button(settings_catalog_panel, label="Edit Value...")
        btn_edit_sc.Bind(wx.EVT_BUTTON, lambda e: self.on_edit_value(e, 'settings'))
        settings_btn_sizer.Add(btn_edit_sc, 0, wx.ALL, 5)
        
        btn_reset_sc = wx.Button(settings_catalog_panel, label="Reset to Baseline")
        btn_reset_sc.Bind(wx.EVT_BUTTON, lambda e: self.on_reset_value(e, 'settings'))
        settings_btn_sizer.Add(btn_reset_sc, 0, wx.ALL, 5)
        
        btn_select_all_sc = wx.Button(settings_catalog_panel, label="Select All")
        btn_select_all_sc.Bind(wx.EVT_BUTTON, lambda e: self.on_select_all(e, 'settings'))
        settings_btn_sizer.Add(btn_select_all_sc, 0, wx.ALL, 5)
        
        btn_deselect_all_sc = wx.Button(settings_catalog_panel, label="Deselect All")
        btn_deselect_all_sc.Bind(wx.EVT_BUTTON, lambda e: self.on_deselect_all(e, 'settings'))
        settings_btn_sizer.Add(btn_deselect_all_sc, 0, wx.ALL, 5)
        
        settings_catalog_sizer.Add(settings_btn_sizer, 0, wx.ALL, 5)
        settings_catalog_panel.SetSizer(settings_catalog_sizer)
        
        # Tab 2: Custom Configuration (.mobileconfig)
        mobileconfig_panel = wx.Panel(self.notebook)
        mobileconfig_sizer = wx.BoxSizer(wx.VERTICAL)
        
        self.mobileconfig_list = wx.ListCtrl(
            mobileconfig_panel,
            style=wx.LC_REPORT | wx.LC_SINGLE_SEL
        )
        
        # Use same image list as settings_catalog_list
        self.mobileconfig_list.SetImageList(self.image_list, wx.IMAGE_LIST_SMALL)
        
        self.mobileconfig_list.AppendColumn("Include", width=60)
        self.mobileconfig_list.AppendColumn("Setting Name", width=250)
        self.mobileconfig_list.AppendColumn("Description", width=350)
        self.mobileconfig_list.AppendColumn("Default Value", width=120)
        self.mobileconfig_list.AppendColumn("Baseline Value", width=120)
        self.mobileconfig_list.AppendColumn("Value Override", width=120)
        self.mobileconfig_list.AppendColumn("Rule ID", width=200)
        
        mobileconfig_sizer.Add(self.mobileconfig_list, 1, wx.EXPAND | wx.ALL, 5)
        
        # Buttons for Custom Configuration tab
        mobileconfig_btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        
        btn_toggle_mc = wx.Button(mobileconfig_panel, label="Toggle Include")
        btn_toggle_mc.Bind(wx.EVT_BUTTON, lambda e: self.on_toggle_include(e, 'mobileconfig'))
        mobileconfig_btn_sizer.Add(btn_toggle_mc, 0, wx.ALL, 5)
        
        btn_edit_mc = wx.Button(mobileconfig_panel, label="Edit Value...")
        btn_edit_mc.Bind(wx.EVT_BUTTON, lambda e: self.on_edit_value(e, 'mobileconfig'))
        mobileconfig_btn_sizer.Add(btn_edit_mc, 0, wx.ALL, 5)
        
        btn_reset_mc = wx.Button(mobileconfig_panel, label="Reset to Baseline")
        btn_reset_mc.Bind(wx.EVT_BUTTON, lambda e: self.on_reset_value(e, 'mobileconfig'))
        mobileconfig_btn_sizer.Add(btn_reset_mc, 0, wx.ALL, 5)
        
        btn_select_all_mc = wx.Button(mobileconfig_panel, label="Select All")
        btn_select_all_mc.Bind(wx.EVT_BUTTON, lambda e: self.on_select_all(e, 'mobileconfig'))
        mobileconfig_btn_sizer.Add(btn_select_all_mc, 0, wx.ALL, 5)
        
        btn_deselect_all_mc = wx.Button(mobileconfig_panel, label="Deselect All")
        btn_deselect_all_mc.Bind(wx.EVT_BUTTON, lambda e: self.on_deselect_all(e, 'mobileconfig'))
        mobileconfig_btn_sizer.Add(btn_deselect_all_mc, 0, wx.ALL, 5)
        
        mobileconfig_sizer.Add(mobileconfig_btn_sizer, 0, wx.ALL, 5)
        mobileconfig_panel.SetSizer(mobileconfig_sizer)
        
        # Tab 3: Unmapped Custom Baselines (no mobileconfig support)
        custom_panel = wx.Panel(self.notebook)
        custom_sizer = wx.BoxSizer(wx.VERTICAL)
        
        self.custom_list = wx.ListCtrl(
            custom_panel,
            style=wx.LC_REPORT | wx.LC_SINGLE_SEL
        )
        self.custom_list.AppendColumn("Rule ID", width=300)
        self.custom_list.AppendColumn("Title", width=400)
        self.custom_list.AppendColumn("Status", width=100)
        self.custom_list.AppendColumn("Section", width=150)
        self.custom_list.AppendColumn("Notes", width=300)
        
        custom_sizer.Add(self.custom_list, 1, wx.EXPAND | wx.ALL, 5)
        
        # Info label for custom tab
        custom_info = wx.StaticText(
            custom_panel,
            label="These rules have no mobileconfig support and cannot be configured via MDM."
        )
        custom_sizer.Add(custom_info, 0, wx.ALL | wx.ALIGN_CENTER, 10)
        
        custom_panel.SetSizer(custom_sizer)
        
        # Add tabs to notebook
        self.notebook.AddPage(settings_catalog_panel, "Settings Catalog Policies")
        self.notebook.AddPage(mobileconfig_panel, ".mobileconfig Settings")
        self.notebook.AddPage(custom_panel, "Unmapped Custom Baselines")
        
        container_sizer.Add(self.notebook, 1, wx.EXPAND | wx.ALL, 5)
        
        # Create loading overlay panel (initially hidden)
        self.loading_overlay = wx.Panel(container_panel, style=wx.BORDER_SIMPLE)
        self.loading_overlay.SetBackgroundColour(wx.Colour(240, 240, 240))
        loading_overlay_sizer = wx.BoxSizer(wx.VERTICAL)
        
        # Add some spacing at top
        loading_overlay_sizer.AddStretchSpacer(1)
        
        # Loading content
        loading_content_sizer = wx.BoxSizer(wx.VERTICAL)
        
        # Loading text
        self.loading_text = wx.StaticText(self.loading_overlay, label="Loading...")
        font = self.loading_text.GetFont()
        font.PointSize += 2
        font = font.Bold()
        self.loading_text.SetFont(font)
        loading_content_sizer.Add(self.loading_text, 0, wx.ALIGN_CENTER | wx.ALL, 10)
        
        # Loading gauge
        self.loading_gauge = wx.Gauge(self.loading_overlay, range=100, size=(300, 25), style=wx.GA_HORIZONTAL | wx.GA_SMOOTH)
        loading_content_sizer.Add(self.loading_gauge, 0, wx.ALIGN_CENTER | wx.ALL, 10)
        
        loading_overlay_sizer.Add(loading_content_sizer, 0, wx.ALIGN_CENTER)
        
        # Add spacing at bottom
        loading_overlay_sizer.AddStretchSpacer(1)
        
        self.loading_overlay.SetSizer(loading_overlay_sizer)
        self.loading_overlay.Hide()
        
        container_panel.SetSizer(container_sizer)
        
        sizer.Add(container_panel, 1, wx.EXPAND)
        
        # Tracking dictionaries for setting items by list index
        self._settings_item_by_index = {}
        self._mobileconfig_item_by_index = {}
        self._custom_rule_id_by_index = {}
        
        return sizer
    
    def _create_checkbox_images(self):
        """Create checkbox images for the Include column."""
        # Create image list
        self.image_list = wx.ImageList(16, 16)
        
        # Create unchecked image - Red X (index 0)
        unchecked_bmp = wx.Bitmap(16, 16)
        dc = wx.MemoryDC(unchecked_bmp)
        dc.SetBackground(wx.Brush(wx.WHITE))
        dc.Clear()
        # Draw red X
        dc.SetPen(wx.Pen(wx.Colour(200, 0, 0), 2))  # Red color
        dc.DrawLine(4, 4, 12, 12)  # Top-left to bottom-right
        dc.DrawLine(12, 4, 4, 12)  # Top-right to bottom-left
        dc.SelectObject(wx.NullBitmap)
        self.image_list.Add(unchecked_bmp)
        
        # Create checked image - Green checkmark (index 1)
        checked_bmp = wx.Bitmap(16, 16)
        dc = wx.MemoryDC(checked_bmp)
        dc.SetBackground(wx.Brush(wx.WHITE))
        dc.Clear()
        # Draw green checkmark
        dc.SetPen(wx.Pen(wx.Colour(0, 150, 0), 2))  # Green color
        dc.DrawLine(3, 8, 6, 11)   # Left part of check
        dc.DrawLine(6, 11, 13, 4)  # Right part of check
        dc.SelectObject(wx.NullBitmap)
        self.image_list.Add(checked_bmp)
        
        # Assign to lists
        self.settings_catalog_list.SetImageList(self.image_list, wx.IMAGE_LIST_SMALL)
    
    def _create_status_bar(self):
        """Create status bar."""
        self.CreateStatusBar()
        self.SetStatusText("Ready")
    
    def _refresh_baselines(self):
        """Refresh the list of available baselines."""
        if not self.macos_security_path:
            return
        
        try:
            baselines = self.baseline_loader.list_baselines()
            self.baseline_choice.Clear()
            for baseline in baselines:
                self.baseline_choice.Append(baseline)
            
            if baselines:
                self.baseline_choice.SetSelection(0)
        except Exception as e:
            logger.error(f"Failed to load baselines: {e}")
            wx.MessageBox(f"Failed to load baselines: {e}", "Error", wx.OK | wx.ICON_ERROR)
    
    def on_select_folder(self, event):
        """Handle folder selection for macos_security path."""
        dlg = wx.DirDialog(self, "Select macos_security folder", defaultPath=str(self.macos_security_path) if self.macos_security_path else "")
        
        if dlg.ShowModal() == wx.ID_OK:
            path = Path(dlg.GetPath())
            
            # Verify it has a baselines folder
            if not (path / "baselines").exists():
                wx.MessageBox(
                    "Selected folder does not contain a 'baselines' subfolder.\nPlease select the macos_security root folder.",
                    "Invalid Folder",
                    wx.OK | wx.ICON_ERROR
                )
                dlg.Destroy()
                return
            
            self.macos_security_path = path
            self.folder_text.SetValue(str(path))
            self._save_macos_security_path(path)
            
            # Recreate loaders with new path
            self.baseline_loader = self._create_baseline_loader()
            self.rules_loader = self._create_rules_loader()
            
            # Refresh baseline list
            self._refresh_baselines()
        
        dlg.Destroy()
    
    def on_baseline_selected(self, event):
        """Handle baseline selection from dropdown."""
        pass  # Selection is retrieved in on_load_baseline
    
    def on_load_baseline(self, event):
        """Load the selected baseline and map rules."""
        if not self.settings_catalog:
            wx.MessageBox(
                "Please load a Settings Catalog first (File -> Load Settings Catalog...)",
                "No Settings Catalog",
                wx.OK | wx.ICON_INFORMATION
            )
            return
        
        selection = self.baseline_choice.GetSelection()
        if selection == wx.NOT_FOUND:
            wx.MessageBox("Please select a baseline first", "No Baseline Selected", wx.OK | wx.ICON_INFORMATION)
            return
        
        baseline_name = self.baseline_choice.GetString(selection)
        
        # Show loading UI
        self._show_loading_state(True)
        
        try:
            # Load baseline
            self.SetStatusText(f"Loading baseline {baseline_name}...")
            self.loading_text.SetLabel("Loading baseline...")
            wx.SafeYield()  # Allow UI to update
            
            self.current_baseline = self.baseline_loader.load_baseline(baseline_name)
            
            # Load all rules referenced in the baseline
            self.loading_text.SetLabel(f"Loading {len(self.current_baseline.get_all_rules())} rules...")
            self.loading_gauge.SetValue(20)
            wx.SafeYield()
            
            rule_ids = self.current_baseline.get_all_rules()
            rules = self.rules_loader.load_rules_bulk(rule_ids)
            
            # Create policy mapper
            self.loading_text.SetLabel("Mapping rules to settings...")
            self.loading_gauge.SetValue(40)
            wx.SafeYield()
            
            policy_mapper = PolicyMapper(self.settings_catalog, prefer_ddm=True)
            
            # Map each rule and extract individual settings
            self.setting_items.clear()
            self.rule_policies.clear()
            self.custom_rules.clear()  # Clear custom rules list
            
            # Use a dict to deduplicate settings by setting_definition_id
            settings_dict: Dict[str, SettingItem] = {}
            
            total_rules = len(rules)
            for idx, rule in enumerate(rules.values()):
                # Update progress
                progress = 40 + int((idx / total_rules) * 40)
                self.loading_gauge.SetValue(progress)
                if idx % 10 == 0:  # Update text every 10 rules
                    self.loading_text.SetLabel(f"Processing rule {idx+1}/{total_rules}...")
                    wx.SafeYield()
                
                # Resolve ODV values for this rule based on baseline
                resolved_rule = self._resolve_rule_odvs(rule, self.current_baseline)
                
                policy = policy_mapper.map_rule_to_policy(resolved_rule)
                
                if policy:
                    # Store the policy
                    self.rule_policies[rule.id] = policy
                    
                    # Create a SettingItem for each setting in the policy
                    # Extract children from group settings
                    for policy_setting in policy.settings:
                        setting_items = self._create_setting_items_from_policy_setting(
                            resolved_rule, policy_setting, "Mapped"
                        )
                        for item in setting_items:
                            # Deduplicate by setting_definition_id
                            # If duplicate, keep the one with more info or merge rule IDs
                            if item.setting_definition_id in settings_dict:
                                # Merge rule IDs to show which rules configure this setting
                                existing = settings_dict[item.setting_definition_id]
                                if resolved_rule.id not in existing.rule_id:
                                    existing.rule_id += f", {resolved_rule.id}"
                                    existing.rule_title += f" + {resolved_rule.title}"
                            else:
                                settings_dict[item.setting_definition_id] = item
                elif resolved_rule.has_mobileconfig:
                    # Unmapped but has mobileconfig - create settings from mobileconfig_info
                    settings = self._create_setting_items_from_mobileconfig(resolved_rule)
                    for item in settings:
                        if item.setting_definition_id not in settings_dict:
                            settings_dict[item.setting_definition_id] = item
                else:
                    # Rules without mobileconfig go to custom tab
                    self.custom_rules.append(resolved_rule)
            
            # Convert dict back to list
            self.setting_items = list(settings_dict.values())
            
            # Populate the list
            self.loading_text.SetLabel("Populating UI...")
            self.loading_gauge.SetValue(90)
            wx.SafeYield()
            
            self._populate_policy_list()
            
            self.loading_gauge.SetValue(100)
            
            mapped_count = sum(1 for item in self.setting_items if item.status == "Mapped")
            unmapped_count = sum(1 for item in self.setting_items if item.status == "Unmapped")
            custom_count = len(self.custom_rules)
            total_count = len(self.setting_items) + custom_count
            self.SetStatusText(
                f"Loaded {baseline_name}: {mapped_count} mapped, {unmapped_count} unmapped (.mobileconfig), "
                f"{custom_count} custom (no mobileconfig) - {len(rules)} total rules"
            )
            
        except Exception as e:
            logger.error("Failed to load baseline", exc_info=True)
            wx.MessageBox(f"Failed to load baseline: {e}", "Error", wx.OK | wx.ICON_ERROR)
        finally:
            # Hide loading UI
            self._show_loading_state(False)
    
    def _show_loading_state(self, loading: bool):
        """Show or hide loading indicators and disable/enable controls.
        
        Args:
            loading: True to show loading state, False to hide
        """
        if loading:
            # Reset and show loading overlay
            self.loading_gauge.SetValue(0)
            self.loading_text.SetLabel("Loading...")
            
            # Position overlay over the notebook
            notebook_rect = self.notebook.GetRect()
            self.loading_overlay.SetSize(notebook_rect)
            self.loading_overlay.SetPosition(notebook_rect.GetPosition())
            self.loading_overlay.Show()
            self.loading_overlay.Raise()  # Bring to front
            
            # Disable controls
            self.baseline_choice.Enable(False)
            self.load_baseline_btn.Enable(False)
            self.export_btn.Enable(False)
        else:
            # Hide loading overlay
            self.loading_overlay.Hide()
            
            # Enable controls
            self.baseline_choice.Enable(True)
            self.load_baseline_btn.Enable(True)
            self.export_btn.Enable(True)
        
        # Refresh layout
        self.Layout()
        self.Refresh()
    
    def _resolve_rule_odvs(self, rule: Rule, baseline: Baseline) -> Rule:
        """Resolve $ODV placeholders in rule's mobileconfig_info and ddm_info using baseline values.
        
        Args:
            rule: Original rule
            baseline: Current baseline
            
        Returns:
            New Rule instance with resolved ODV values
        """
        if not rule.odv or not isinstance(rule.odv, dict):
            return rule
        
        # Get the baseline's parent_values (e.g., "cis_lvl2")
        baseline_key = baseline.parent_values or baseline.name
        
        # Get the ODV value for this baseline
        odv_value = rule.odv.get(baseline_key) or rule.odv.get('recommended')
        
        if odv_value is None:
            return rule
        
        # Create a copy of mobileconfig_info with resolved ODVs
        resolved_mobileconfig_info = self._replace_odv_in_dict(rule.mobileconfig_info, odv_value)
        
        # Create a copy of ddm_info with resolved ODVs
        resolved_ddm_info = self._replace_odv_in_dict(rule.ddm_info, odv_value)
        
        # Create a new rule with resolved values
        from dataclasses import replace
        return replace(rule, mobileconfig_info=resolved_mobileconfig_info, ddm_info=resolved_ddm_info)
    
    def _replace_odv_in_dict(self, data: Any, odv_value: Any) -> Any:
        """Recursively replace $ODV placeholders in a dictionary or value.
        
        Args:
            data: Data structure (dict, list, str, etc.)
            odv_value: Value to replace $ODV with
            
        Returns:
            Data structure with $ODV replaced
        """
        if isinstance(data, dict):
            return {k: self._replace_odv_in_dict(v, odv_value) for k, v in data.items()}
        elif isinstance(data, list):
            return [self._replace_odv_in_dict(item, odv_value) for item in data]
        elif isinstance(data, str) and data == "$ODV":
            return odv_value
        else:
            return data
    
    def _create_setting_items_from_policy_setting(
        self, rule: Rule, policy_setting: PolicySetting, status: str
    ) -> List[SettingItem]:
        """Create SettingItem(s) from a PolicySetting and rule.
        
        Args:
            rule: Source rule
            policy_setting: Mapped policy setting
            status: "Mapped" or "Unmapped"
            
        Returns:
            List of SettingItem objects (may be multiple if this is a group with children)
        """
        # Get the setting definition from catalog
        setting_def = self.settings_catalog._settings_index.get(policy_setting.setting_definition_id)
        if not setting_def:
            return []
        
        odata_type = setting_def.get('@odata.type', '')
        
        # Check if this is a group setting
        if 'SettingGroupCollection' in odata_type:
            # This is a group - extract children
            return self._extract_children_from_group_setting(rule, policy_setting, setting_def, status)
        else:
            # Regular setting - create one SettingItem
            default_value = self._format_default_value(setting_def)
            baseline_value = self._extract_baseline_value_from_setting_instance(
                policy_setting.setting_instance, setting_def
            )
            
            return [SettingItem(
                rule_id=rule.id,
                rule_title=rule.title,
                setting_definition_id=policy_setting.setting_definition_id,
                setting_name=setting_def.get('displayName', policy_setting.name or ''),
                description=setting_def.get('description', '')[:100] + '...' if len(setting_def.get('description', '')) > 100 else setting_def.get('description', ''),
                default_value=default_value,
                baseline_value=baseline_value,
                included=True,
                status=status,
                policy_setting=policy_setting,
                setting_definition=setting_def,
                section=rule.get_section()
            )]
    
    def _extract_children_from_group_setting(
        self, rule: Rule, policy_setting: PolicySetting, group_def: Dict[str, Any], status: str
    ) -> List[SettingItem]:
        """Extract child settings from a group setting.
        
        Args:
            rule: Source rule
            policy_setting: Group policy setting
            group_def: Group setting definition
            status: "Mapped" or "Unmapped"
        """
        children = []
        
        # Extract child setting instances from the group
        group_instance = policy_setting.setting_instance
        group_collection_value = group_instance.get('groupSettingCollectionValue', [])
        
        if not group_collection_value:
            return []
        
        # Get first group value (usually only one)
        group_value = group_collection_value[0] if group_collection_value else {}
        child_instances = group_value.get('children', [])
        
        for child_instance in child_instances:
            child_def_id = child_instance.get('settingDefinitionId')
            if not child_def_id:
                continue
            
            # Get the child setting definition
            child_def = self.settings_catalog._settings_index.get(child_def_id)
            if not child_def:
                continue
            
            # Check if this child is itself a group - if so, recursively extract its children
            child_odata_type = child_def.get('@odata.type', '')
            if 'SettingGroupCollection' in child_odata_type:
                # This child is a group - create a temporary PolicySetting and recursively extract
                temp_policy_setting = PolicySetting(
                    setting_definition_id=child_def_id,
                    setting_instance=child_instance,
                    name=child_def.get('name'),
                    description=child_def.get('description')
                )
                # Recursively extract children from this nested group
                nested_children = self._extract_children_from_group_setting(rule, temp_policy_setting, child_def, status)
                children.extend(nested_children)
            else:
                # Regular child setting - create SettingItem
                default_value = self._format_default_value(child_def)
                baseline_value = self._extract_baseline_value_from_setting_instance(child_instance, child_def)
                
                children.append(SettingItem(
                    rule_id=rule.id,
                    rule_title=rule.title,
                    setting_definition_id=child_def_id,
                    setting_name=child_def.get('displayName', child_def.get('name', '')),
                    description=child_def.get('description', '')[:100] + '...' if len(child_def.get('description', '')) > 100 else child_def.get('description', ''),
                    default_value=default_value,
                    baseline_value=baseline_value,
                    included=True,
                    status=status,
                    policy_setting=None,  # Child doesn't have own PolicySetting
                    setting_definition=child_def,
                    section=rule.get_section()
                ))
        
        return children
    
    def _create_setting_items_from_mobileconfig(self, rule: Rule) -> List[SettingItem]:
        """Create SettingItems from a rule's mobileconfig_info (for unmapped settings).
        
        Args:
            rule: Rule with mobileconfig_info but no successful mapping
        """
        settings = []
        
        # Extract settings from mobileconfig_info
        for domain, domain_content in rule.mobileconfig_info.items():
            if isinstance(domain_content, dict):
                for setting_key, setting_value in domain_content.items():
                    if isinstance(setting_value, dict):
                        # Nested structure - recurse
                        for sub_key, sub_value in setting_value.items():
                            settings.append(SettingItem(
                                rule_id=rule.id,
                                rule_title=rule.title,
                                setting_definition_id=f"{domain}_{sub_key}",
                                setting_name=sub_key,
                                description=f"mobileconfig setting from {domain}",
                                default_value="N/A",
                                baseline_value=str(sub_value),
                                included=True,
                                status="Unmapped",
                                section=rule.get_section()
                            ))
                    else:
                        settings.append(SettingItem(
                            rule_id=rule.id,
                            rule_title=rule.title,
                            setting_definition_id=f"{domain}_{setting_key}",
                            setting_name=setting_key,
                            description=f"mobileconfig setting from {domain}",
                            default_value="N/A",
                            baseline_value=str(setting_value),
                            included=True,
                            status="Unmapped",
                            section=rule.get_section()
                        ))
            else:
                settings.append(SettingItem(
                    rule_id=rule.id,
                    rule_title=rule.title,
                    setting_definition_id=domain,
                    setting_name=domain,
                    description="mobileconfig setting",
                    default_value="N/A",
                    baseline_value=str(domain_content),
                    included=True,
                    status="Unmapped",
                    section=rule.get_section()
                ))
        
        return settings
    
    def _format_default_value(self, setting_def: Dict[str, Any]) -> str:
        """Format the default value from a setting definition.
        
        Args:
            setting_def: Setting definition from catalog
        """
        default_option_id = setting_def.get('defaultOptionId')
        if not default_option_id:
            return "N/A"
        
        # Find the option and extract its display name
        options = setting_def.get('options', [])
        for option in options:
            if option.get('itemId') == default_option_id:
                # Try to get a friendly name
                display_name = option.get('displayName', option.get('name', ''))
                return display_name
        
        return default_option_id.split('_')[-1] if '_' in default_option_id else default_option_id
    
    def _extract_baseline_value_from_setting_instance(
        self, setting_instance: Dict[str, Any], setting_def: Dict[str, Any]
    ) -> str:
        """Extract the baseline value from a setting instance.
        
        Args:
            setting_instance: Setting instance with value
            setting_def: Setting definition from catalog
        """
        odata_type = setting_instance.get('@odata.type', '')
        
        if 'Choice' in odata_type:
            # Choice setting - extract from choiceSettingValue
            choice_value = setting_instance.get('choiceSettingValue', {})
            value_id = choice_value.get('value', '')
            
            # Find the option and get display name
            options = setting_def.get('options', [])
            for option in options:
                if option.get('itemId') == value_id:
                    return option.get('displayName', option.get('name', value_id))
            
            return value_id.split('_')[-1] if '_' in value_id else value_id
        elif 'Simple' in odata_type:
            # Simple setting - extract from simpleSettingValue
            simple_value = setting_instance.get('simpleSettingValue', {})
            return str(simple_value.get('value', 'N/A'))
        elif 'Group' in odata_type:
            # Group setting - this is a parent, children will be separate settings
            return "[Group]"
        
        return "N/A"
    
    def _populate_policy_list(self):
        """Populate the policy list with current setting items."""
        # Clear all lists
        self.settings_catalog_list.DeleteAllItems()
        self.mobileconfig_list.DeleteAllItems()
        self.custom_list.DeleteAllItems()
        self._settings_item_by_index.clear()
        self._mobileconfig_item_by_index.clear()
        self._custom_rule_id_by_index.clear()
        
        settings_index = 0
        mobileconfig_index = 0
        custom_index = 0
        
        # Sort settings by rule ID, then setting name
        sorted_settings = sorted(self.setting_items, key=lambda x: (x.rule_id, x.setting_name))
        
        for setting_item in sorted_settings:
            # Tab 1: Settings Catalog - mapped settings
            if setting_item.status == "Mapped":
                # Column 0: Include (with checkbox icon)
                icon_idx = 1 if setting_item.included else 0
                self.settings_catalog_list.InsertItem(settings_index, "", icon_idx)
                # Column 1: Setting Name
                self.settings_catalog_list.SetItem(settings_index, 1, setting_item.setting_name)
                # Column 2: Description
                self.settings_catalog_list.SetItem(settings_index, 2, setting_item.description)
                # Column 3: Default Value
                self.settings_catalog_list.SetItem(settings_index, 3, setting_item.default_value)
                # Column 4: Baseline Value
                self.settings_catalog_list.SetItem(settings_index, 4, setting_item.baseline_value)
                # Column 5: Value Override
                override_val = str(setting_item.value_override) if setting_item.value_override is not None else ""
                self.settings_catalog_list.SetItem(settings_index, 5, override_val)
                # Column 6: Rule ID
                self.settings_catalog_list.SetItem(settings_index, 6, setting_item.rule_id)
                
                self._settings_item_by_index[settings_index] = setting_item
                settings_index += 1
            
            # Tab 2: .mobileconfig Settings - unmapped settings
            elif setting_item.status == "Unmapped":
                # Column 0: Include (with checkbox icon)
                icon_idx = 1 if setting_item.included else 0
                self.mobileconfig_list.InsertItem(mobileconfig_index, "", icon_idx)
                # Column 1: Setting Name
                self.mobileconfig_list.SetItem(mobileconfig_index, 1, setting_item.setting_name)
                # Column 2: Description
                self.mobileconfig_list.SetItem(mobileconfig_index, 2, setting_item.description)
                # Column 3: Default Value
                self.mobileconfig_list.SetItem(mobileconfig_index, 3, setting_item.default_value)
                # Column 4: Baseline Value
                self.mobileconfig_list.SetItem(mobileconfig_index, 4, setting_item.baseline_value)
                # Column 5: Value Override
                override_val = str(setting_item.value_override) if setting_item.value_override is not None else ""
                self.mobileconfig_list.SetItem(mobileconfig_index, 5, override_val)
                # Column 6: Rule ID
                self.mobileconfig_list.SetItem(mobileconfig_index, 6, setting_item.rule_id)
                
                self._mobileconfig_item_by_index[mobileconfig_index] = setting_item
                mobileconfig_index += 1
        
        # Tab 3: Unmapped Custom Baselines - rules without mobileconfig
        self.custom_list.DeleteAllItems()
        for idx, rule in enumerate(self.custom_rules):
            self.custom_list.InsertItem(idx, rule.id)
            self.custom_list.SetItem(idx, 1, rule.title[:80])  # Truncate long titles
            self.custom_list.SetItem(idx, 2, "No mobileconfig")
            self.custom_list.SetItem(idx, 3, rule.get_section())
            self.custom_list.SetItem(idx, 4, "Cannot be configured via MDM")
    
    def on_toggle_include(self, event, list_type='settings'):
        """Toggle the include status of the selected setting."""
        if list_type == 'settings':
            list_ctrl = self.settings_catalog_list
            lookup = self._settings_item_by_index
        else:
            list_ctrl = self.mobileconfig_list
            lookup = self._mobileconfig_item_by_index
        
        index = list_ctrl.GetFirstSelected()
        
        if index == -1:
            wx.MessageBox("Please select a setting first", "Info", wx.OK | wx.ICON_INFORMATION)
            return
        
        setting_item = lookup.get(index)
        if not setting_item:
            return
        
        # Toggle included status
        setting_item.included = not setting_item.included
        
        # Update the checkbox icon
        icon_idx = 1 if setting_item.included else 0
        list_ctrl.SetItemImage(index, icon_idx)
    
    def on_edit_value(self, event, list_type='settings'):
        """Edit the value for the selected setting."""
        if list_type == 'settings':
            list_ctrl = self.settings_catalog_list
            lookup = self._settings_item_by_index
        else:
            list_ctrl = self.mobileconfig_list
            lookup = self._mobileconfig_item_by_index
        
        index = list_ctrl.GetFirstSelected()
        if index == -1:
            wx.MessageBox("Please select a setting first", "Info", wx.OK | wx.ICON_INFORMATION)
            return
        
        setting_item = lookup.get(index)
        if not setting_item or not setting_item.setting_definition:
            wx.MessageBox("Cannot edit this setting", "Error", wx.OK | wx.ICON_ERROR)
            return
        
        # Show value editor dialog
        dlg = SettingValueEditorDialog(self, setting_item)
        if dlg.ShowModal() == wx.ID_OK:
            new_value = dlg.get_value()
            # Only set override if value is not empty/blank
            if new_value is not None and str(new_value).strip() != "":
                setting_item.value_override = new_value
            else:
                setting_item.value_override = None
            
            # Update only this row instead of full refresh
            self._update_setting_row(list_ctrl, index, setting_item)
        dlg.Destroy()
    
    def on_reset_value(self, event, list_type='settings'):
        """Reset the selected setting to its baseline value."""
        if list_type == 'settings':
            list_ctrl = self.settings_catalog_list
            lookup = self._settings_item_by_index
        else:
            list_ctrl = self.mobileconfig_list
            lookup = self._mobileconfig_item_by_index
        
        index = list_ctrl.GetFirstSelected()
        if index == -1:
            wx.MessageBox("Please select a setting first", "Info", wx.OK | wx.ICON_INFORMATION)
            return
        
        setting_item = lookup.get(index)
        if not setting_item:
            return
        
        # Reset custom value
        setting_item.value_override = None
        
        # Update only this row instead of full refresh
        self._update_setting_row(list_ctrl, index, setting_item)
    
    def _update_setting_row(self, list_ctrl: wx.ListCtrl, index: int, setting_item: SettingItem):
        """Update a single row in the list control.
        
        Args:
            list_ctrl: The list control to update
            index: The row index to update
            setting_item: The updated setting item
        """
        # Update checkbox icon (1 = included/green checkmark, 0 = excluded/red X)
        list_ctrl.SetItemImage(index, 1 if setting_item.included else 0)
        
        # Update Value Override column (column 5)
        override_val = str(setting_item.value_override) if setting_item.value_override is not None else ""
        list_ctrl.SetItem(index, 5, override_val)
    
    def on_select_all(self, event, list_type='settings'):
        """Select all settings in the current tab."""
        for setting_item in self.setting_items:
            if list_type == 'settings' and setting_item.status == "Mapped":
                setting_item.included = True
            elif list_type == 'mobileconfig' and setting_item.status == "Unmapped":
                setting_item.included = True
        
        self._populate_policy_list()
    
    def on_deselect_all(self, event, list_type='settings'):
        """Deselect all settings in the current tab."""
        for setting_item in self.setting_items:
            if list_type == 'settings' and setting_item.status == "Mapped":
                setting_item.included = False
            elif list_type == 'mobileconfig' and setting_item.status == "Unmapped":
                setting_item.included = False
        
        self._populate_policy_list()
    
    def on_export(self, event):
        """Export policies and mobileconfig."""
        if not self.setting_items:
            wx.MessageBox("Please load a baseline first", "No Data", wx.OK | wx.ICON_INFORMATION)
            return
        
        # Group settings by rule to reconstruct policies
        included_rule_ids = set()
        settings_by_rule: Dict[str, List[SettingItem]] = {}
        
        for setting_item in self.setting_items:
            if setting_item.included and setting_item.status == "Mapped":
                # Split combined rule IDs (e.g., "rule1, rule2" -> ["rule1", "rule2"])
                rule_ids = [rid.strip() for rid in setting_item.rule_id.split(',')]
                for rule_id in rule_ids:
                    included_rule_ids.add(rule_id)
                    if rule_id not in settings_by_rule:
                        settings_by_rule[rule_id] = []
                    settings_by_rule[rule_id].append(setting_item)
        
        # Get policies for included rules and apply value overrides
        included_policies = []
        for rule_id in included_rule_ids:
            policy = self.rule_policies.get(rule_id)
            if policy:
                # Apply value overrides from settings
                policy_copy = self._apply_value_overrides_to_policy(policy, settings_by_rule.get(rule_id, []))
                included_policies.append(policy_copy)
        
        # Get unmapped rules (rules that have mobileconfig but no mapping)
        # Collect directly from all rules to avoid deduplication issues
        unmapped_rules = []
        if self.rules_loader._rules_cache and self.current_baseline:
            for rule_id in self.current_baseline.get_all_rules():
                # Skip rules that were successfully mapped
                if rule_id in self.rule_policies:
                    continue
                    
                # Get the rule from cache
                rule = self.rules_loader._rules_cache.get(rule_id)
                if rule and rule.has_mobileconfig:
                    # Check if user wants to include this rule (check SettingItems)
                    # Look for any SettingItem with this rule_id that is included
                    should_include = True  # Default to include
                    for setting_item in self.setting_items:
                        if setting_item.rule_id == rule_id and setting_item.status == "Unmapped":
                            should_include = setting_item.included
                            break
                    
                    if should_include:
                        unmapped_rules.append(rule)
        
        # Get all rules from the loaded baseline for dependency analysis
        all_rules = list(self.rules_loader._rules_cache.values()) if self.rules_loader._rules_cache else []
        
        # Show export dialog
        dlg = ExportDialog(self, included_policies, unmapped_rules, self.current_baseline, all_rules, self.settings_catalog)
        dlg.ShowModal()
        dlg.Destroy()
    
    def _apply_value_overrides_to_policy(self, policy: Policy, settings: List[SettingItem]) -> Policy:
        """Apply value overrides from SettingItems to a Policy.
        
        Args:
            policy: Original policy
            settings: List of SettingItems with potential overrides
            
        Returns:
            New Policy instance with overrides applied
        """
        from copy import deepcopy
        from ..models.policy import PolicySetting
        
        # Create a deep copy of the policy
        policy_copy = deepcopy(policy)
        
        # Build a map of setting_definition_id to override value
        overrides = {}
        for setting in settings:
            if setting.value_override is not None:
                overrides[setting.setting_definition_id] = setting.value_override
                logger.info(f"Override for {setting.setting_name}: {setting.baseline_value} -> {setting.value_override}")
        
        if not overrides:
            return policy_copy
        
        # Apply overrides to policy settings (including children in groups)
        for policy_setting in policy_copy.settings:
            self._apply_overrides_to_setting_instance(policy_setting.setting_instance, overrides, settings)
        
        return policy_copy
    
    def _apply_overrides_to_setting_instance(self, setting_instance: Dict[str, Any], overrides: Dict[str, Any], settings: List[SettingItem]):
        """Recursively apply overrides to a setting instance and its children.
        
        Args:
            setting_instance: Setting instance dict (may contain children)
            overrides: Map of setting_definition_id to override value
            settings: List of SettingItems with setting definitions
        """
        odata_type = setting_instance.get('@odata.type', '')
        
        # Check if this is a group setting with children
        if 'GroupSettingCollection' in odata_type:
            group_values = setting_instance.get('groupSettingCollectionValue', [])
            for group_value in group_values:
                children = group_value.get('children', [])
                for child in children:
                    # Recursively apply to each child
                    self._apply_overrides_to_setting_instance(child, overrides, settings)
        else:
            # This is a leaf setting - check if it needs an override
            setting_def_id = setting_instance.get('settingDefinitionId')
            if setting_def_id and setting_def_id in overrides:
                override_value = overrides[setting_def_id]
                
                # Get the setting definition for choice settings
                setting_def = None
                for setting_item in settings:
                    if setting_item.setting_definition_id == setting_def_id:
                        setting_def = setting_item.setting_definition
                        break
                
                logger.info(f"Applying override to {setting_def_id}: {override_value}")
                self._update_setting_instance_value(setting_instance, override_value, setting_def)
    
    def _update_setting_instance_value(self, setting_instance: Dict[str, Any], new_value: Any, setting_definition: Optional[Dict[str, Any]] = None):
        """Update a setting instance with a new value.
        
        Args:
            setting_instance: Setting instance dict
            new_value: New value to set
            setting_definition: Setting definition for choice settings (to map display name to itemId)
        """
        odata_type = setting_instance.get('@odata.type', '')
        
        if 'ChoiceSetting' in odata_type:
            # For choice settings, need to map display name/value to itemId
            item_id = new_value  # Default to new_value if we can't find mapping
            
            if setting_definition:
                options = setting_definition.get('options', [])
                # Try to find matching option by display name, name, or value
                for option in options:
                    display_name = option.get('displayName', '')
                    name = option.get('name', '')
                    option_value = option.get('optionValue', {}).get('value', '')
                    
                    if (str(new_value).lower() == str(display_name).lower() or 
                        str(new_value).lower() == str(name).lower() or
                        str(new_value).lower() == str(option_value).lower()):
                        item_id = option.get('itemId')
                        logger.info(f"Mapped choice value '{new_value}' to itemId '{item_id}'")
                        break
                else:
                    logger.warning(f"Could not map choice value '{new_value}' to any option itemId, using raw value")
            
            setting_instance['choiceSettingValue'] = {
                '@odata.type': '#microsoft.graph.deviceManagementConfigurationChoiceSettingValue',
                'value': item_id,
                'children': []
            }
        elif 'SimpleSetting' in odata_type:
            # For simple settings, set the appropriate value type
            if isinstance(new_value, bool):
                setting_instance['simpleSettingValue'] = {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationBooleanSettingValue',
                    'value': new_value
                }
            elif isinstance(new_value, int):
                setting_instance['simpleSettingValue'] = {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue',
                    'value': new_value
                }
            else:
                setting_instance['simpleSettingValue'] = {
                    '@odata.type': '#microsoft.graph.deviceManagementConfigurationStringSettingValue',
                    'value': str(new_value)
                }
    
    def on_load_catalog(self, event):
        """Load Settings Catalog from JSON file."""
        dlg = wx.FileDialog(
            self,
            "Select Settings Catalog JSON",
            defaultDir=str(Path.cwd()),
            wildcard="JSON files (*.json)|*.json",
            style=wx.FD_OPEN | wx.FD_FILE_MUST_EXIST
        )
        
        if dlg.ShowModal() == wx.ID_OK:
            path = Path(dlg.GetPath())
            
            try:
                self.SetStatusText(f"Loading Settings Catalog from {path.name}...")
                self.settings_catalog = SettingsCatalog.from_file(path)
                
                # Count settings
                total_settings = len(self.settings_catalog._settings_index)
                ddm_count = len(self.settings_catalog._ddm_settings)
                mobileconfig_count = len(self.settings_catalog._mobileconfig_settings)
                
                # Update catalog status indicator
                self._update_catalog_status(total_settings, ddm_count, mobileconfig_count)
                
                self.SetStatusText(f"Loaded {total_settings} settings ({ddm_count} DDM, {mobileconfig_count} mobileconfig)")
                
                wx.MessageBox(
                    f"Successfully loaded Settings Catalog:\n\n"
                    f"Total: {total_settings} settings\n"
                    f"DDM: {ddm_count}\n"
                    f"Mobileconfig: {mobileconfig_count}",
                    "Success",
                    wx.OK | wx.ICON_INFORMATION
                )
            except Exception as e:
                logger.error(f"Failed to load Settings Catalog: {e}", exc_info=True)
                wx.MessageBox(f"Failed to load Settings Catalog: {e}", "Error", wx.OK | wx.ICON_ERROR)
        
        dlg.Destroy()
    
    def on_load_catalog_from_azure(self, event):
        """Load Settings Catalog from Microsoft Intune via Azure."""
        wx.MessageBox(
            "Azure/Intune integration is not yet implemented.\n\n"
            "This feature will allow you to:\n"
            "• Sign in with Azure AD\n"
            "• Fetch Settings Catalog directly from Intune\n"
            "• Stay up-to-date with latest definitions\n\n"
            "For now, please use 'Load from JSON' with an exported catalog file.",
            "Coming Soon",
            wx.OK | wx.ICON_INFORMATION
        )
    
    def _update_catalog_status(self, total_settings, ddm_count, mobileconfig_count):
        """Update the catalog status indicator."""
        status_text = f"Loaded: {total_settings} settings"
        self.catalog_status.SetLabel(status_text)
        self.catalog_status.SetForegroundColour(wx.Colour(0, 128, 0))  # Green
    
    def on_exit(self, event):
        """Exit the application."""
        self.Close()
    
    def on_about(self, event):
        """Show about dialog."""
        info = wx.adv.AboutDialogInfo()
        info.SetName("macOS Intune Mapper")
        info.SetVersion("1.0.0")
        info.SetDescription("Map macOS security baselines to Microsoft Intune policies")
        info.SetWebSite("https://github.com/usnistgov/macos_security")
        
        wx.adv.AboutBox(info)


class SettingValueEditorDialog(wx.Dialog):
    """Dialog for editing individual setting values."""
    
    def __init__(self, parent, setting_item: SettingItem):
        """Initialize the setting value editor dialog."""
        super().__init__(
            parent,
            title=f"Edit Value: {setting_item.setting_name}",
            size=(600, 400)
        )
        
        self.setting_item = setting_item
        self.value_control = None
        
        self._create_ui()
        self.Centre()
    
    def _create_ui(self):
        """Create the dialog UI."""
        sizer = wx.BoxSizer(wx.VERTICAL)
        
        # Setting info
        info_box = wx.StaticBox(self, label="Setting Information")
        info_sizer = wx.StaticBoxSizer(info_box, wx.VERTICAL)
        
        info_sizer.Add(wx.StaticText(self, label=f"Name: {self.setting_item.setting_name}"), 0, wx.ALL, 5)
        info_sizer.Add(wx.StaticText(self, label=f"Description: {self.setting_item.description}"), 0, wx.ALL, 5)
        info_sizer.Add(wx.StaticText(self, label=f"Default: {self.setting_item.default_value}"), 0, wx.ALL, 5)
        info_sizer.Add(wx.StaticText(self, label=f"Baseline: {self.setting_item.baseline_value}"), 0, wx.ALL, 5)
        info_sizer.Add(wx.StaticText(self, label=f"Rule: {self.setting_item.rule_id}"), 0, wx.ALL, 5)
        
        sizer.Add(info_sizer, 0, wx.ALL | wx.EXPAND, 10)
        
        # Value editor
        value_box = wx.StaticBox(self, label="New Value")
        value_sizer = wx.StaticBoxSizer(value_box, wx.VERTICAL)
        
        # Check setting type
        setting_def = self.setting_item.setting_definition
        if not setting_def:
            value_sizer.Add(wx.StaticText(self, label="Cannot edit: no setting definition"), 0, wx.ALL, 5)
        else:
            odata_type = setting_def.get('@odata.type', '')
            
            if 'Choice' in odata_type:
                # Create dropdown with options
                options = setting_def.get('options', [])
                choices = [opt.get('displayName', opt.get('name', '')) for opt in options]
                self.value_control = wx.Choice(self, choices=choices)
                
                # Set current value
                current_val = self.setting_item.value_override if self.setting_item.value_override else self.setting_item.baseline_value
                try:
                    idx = choices.index(current_val)
                    self.value_control.SetSelection(idx)
                except (ValueError, IndexError):
                    if choices:
                        self.value_control.SetSelection(0)
                
                value_sizer.Add(self.value_control, 0, wx.ALL | wx.EXPAND, 5)
            else:
                # Text input for simple settings
                current_val = self.setting_item.value_override if self.setting_item.value_override else self.setting_item.baseline_value
                self.value_control = wx.TextCtrl(self, value=str(current_val), style=wx.TE_LEFT)
                # Force text to show from beginning by selecting all then moving to start
                wx.CallAfter(self._fix_text_display)
                value_sizer.Add(self.value_control, 0, wx.ALL | wx.EXPAND, 5)
        
        sizer.Add(value_sizer, 1, wx.ALL | wx.EXPAND, 10)
        
        # Buttons
        btn_sizer = wx.StdDialogButtonSizer()
        
        save_btn = wx.Button(self, wx.ID_OK, "Save")
        save_btn.SetDefault()
        btn_sizer.AddButton(save_btn)
        
        cancel_btn = wx.Button(self, wx.ID_CANCEL, "Cancel")
        btn_sizer.AddButton(cancel_btn)
        
        btn_sizer.Realize()
        sizer.Add(btn_sizer, 0, wx.ALL | wx.ALIGN_RIGHT, 10)
        
        self.SetSizer(sizer)
    
    def _fix_text_display(self):
        """Fix text display to show from the beginning."""
        if self.value_control and isinstance(self.value_control, wx.TextCtrl):
            # Select all text first
            self.value_control.SetSelection(-1, -1)
            # Then move cursor to start
            self.value_control.SetInsertionPoint(0)
    
    def get_value(self):
        """Get the edited value."""
        if not self.value_control:
            return None
        
        if isinstance(self.value_control, wx.Choice):
            return self.value_control.GetStringSelection()
        elif isinstance(self.value_control, wx.TextCtrl):
            text = self.value_control.GetValue()
            # Try to convert to appropriate type
            if text.lower() in ('true', 'false'):
                return text.lower() == 'true'
            try:
                return int(text)
            except ValueError:
                return text
        
        return None


class ValueEditorDialog(wx.Dialog):
    """Dialog for editing rule values."""
    
    def __init__(self, parent, rule_item: RuleItem, settings_catalog=None, baseline=None):
        """Initialize the value editor dialog."""
        super().__init__(
            parent,
            title=f"Edit Value: {rule_item.rule.title}",
            size=(700, 650)
        )
        
        self.rule_item = rule_item
        self.settings_catalog = settings_catalog
        self.baseline = baseline
        self.value_controls = {}
        
        self._create_ui()
    
    def _create_ui(self):
        """Create the UI for the value editor."""
        panel = wx.Panel(self)
        sizer = wx.BoxSizer(wx.VERTICAL)
        
        # Rule info
        info_box = wx.StaticBox(panel, label="Rule Information")
        info_sizer = wx.StaticBoxSizer(info_box, wx.VERTICAL)
        
        rule_id_text = wx.StaticText(panel, label=f"ID: {self.rule_item.rule.id}")
        info_sizer.Add(rule_id_text, 0, wx.ALL, 5)
        
        sizer.Add(info_sizer, 0, wx.ALL | wx.EXPAND, 10)
        
        # Baseline value display
        baseline_box = wx.StaticBox(panel, label="Baseline Value")
        baseline_sizer = wx.StaticBoxSizer(baseline_box, wx.VERTICAL)
        baseline_text = wx.TextCtrl(
            panel, 
            value=self.rule_item.get_baseline_value(self.baseline),
            style=wx.TE_READONLY | wx.TE_MULTILINE
        )
        baseline_sizer.Add(baseline_text, 1, wx.EXPAND | wx.ALL, 5)
        sizer.Add(baseline_sizer, 0, wx.ALL | wx.EXPAND, 10)
        
        # Dependencies (if any)
        deps = self._get_dependencies()
        if deps:
            deps_box = wx.StaticBox(panel, label="Dependencies")
            deps_sizer = wx.StaticBoxSizer(deps_box, wx.VERTICAL)
            for dep in deps:
                dep_text = wx.StaticText(panel, label=dep)
                deps_sizer.Add(dep_text, 0, wx.ALL, 2)
            sizer.Add(deps_sizer, 0, wx.ALL | wx.EXPAND, 10)
        
        # Custom value editors
        custom_box = wx.StaticBox(panel, label="Custom Values")
        custom_sizer = wx.StaticBoxSizer(custom_box, wx.VERTICAL)
        
        # Extract setting values from mobileconfig_info
        self._create_value_editors(panel, custom_sizer)
        
        sizer.Add(custom_sizer, 1, wx.ALL | wx.EXPAND, 10)
        
        # Buttons
        btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        
        btn_save = wx.Button(panel, wx.ID_OK, "Save")
        btn_save.SetDefault()
        btn_sizer.Add(btn_save, 0, wx.ALL, 5)
        
        btn_cancel = wx.Button(panel, wx.ID_CANCEL, "Cancel")
        btn_sizer.Add(btn_cancel, 0, wx.ALL, 5)
        
        sizer.Add(btn_sizer, 0, wx.ALIGN_RIGHT | wx.ALL, 10)
        
        panel.SetSizer(sizer)
        self.Centre()
    
    def _create_value_editors(self, parent, sizer):
        """Create appropriate input controls based on value types."""
        rule = self.rule_item.rule
        
        if not rule.has_mobileconfig:
            no_config_text = wx.StaticText(parent, label="No mobileconfig data available")
            sizer.Add(no_config_text, 0, wx.ALL, 5)
            return
        
        # Parse mobileconfig_info to create appropriate controls
        for top_key, top_content in rule.mobileconfig_info.items():
            if isinstance(top_content, dict):
                for sub_key, sub_content in top_content.items():
                    if isinstance(sub_content, dict):
                        for setting_key, setting_value in sub_content.items():
                            self._add_value_control(parent, sizer, setting_key, setting_value)
                    else:
                        self._add_value_control(parent, sizer, sub_key, sub_content)
            else:
                self._add_value_control(parent, sizer, top_key, top_content)
    
    def _add_value_control(self, parent, sizer, key: str, value: Any):
        """Add an appropriate control for the given value type."""
        row_sizer = wx.BoxSizer(wx.HORIZONTAL)
        
        label = wx.StaticText(parent, label=f"{key}:")
        label.SetMinSize((150, -1))
        row_sizer.Add(label, 0, wx.ALIGN_CENTER_VERTICAL | wx.ALL, 5)
        
        # Try to get Settings Catalog options if we have a mapped policy
        setting_options = self._get_setting_options(key) if self.settings_catalog and self.rule_item.policy else None
        
        # Check if this is an ODV and get possible values
        odv_values = None
        if isinstance(value, str) and "$ODV" in str(value):
            odv_values = self._get_odv_values()
        
        if odv_values:
            # Organization-Defined Value with options from baseline
            ctrl = wx.Choice(parent, choices=odv_values)
            if odv_values:
                ctrl.SetSelection(0)  # Select first (recommended) value
            self.value_controls[key] = ("odv_choice", ctrl, odv_values)
            row_sizer.Add(ctrl, 1, wx.EXPAND | wx.ALL, 5)
        elif isinstance(value, str) and "$ODV" in str(value):
            # ODV without predefined values - text input with hint
            ctrl = wx.TextCtrl(parent, value="")
            odv_hint = self._get_odv_hint()
            ctrl.SetHint(f"Enter value ({odv_hint})" if odv_hint else "Enter value")
            self.value_controls[key] = ("text", ctrl)
            row_sizer.Add(ctrl, 1, wx.EXPAND | wx.ALL, 5)
        elif setting_options:
            # Use Settings Catalog options
            choices = [opt['displayName'] for opt in setting_options]
            ctrl = wx.Choice(parent, choices=choices)
            # Try to select current value
            current_display = next((opt['displayName'] for opt in setting_options if str(opt.get('value')) == str(value)), None)
            if current_display:
                ctrl.SetStringSelection(current_display)
            self.value_controls[key] = ("catalog_choice", ctrl, setting_options)
            row_sizer.Add(ctrl, 1, wx.EXPAND | wx.ALL, 5)
        elif isinstance(value, bool):
            # Boolean value - use choice control
            ctrl = wx.Choice(parent, choices=["true", "false"])
            ctrl.SetSelection(0 if value else 1)
            self.value_controls[key] = ("bool", ctrl)
            row_sizer.Add(ctrl, 1, wx.EXPAND | wx.ALL, 5)
        elif isinstance(value, int):
            # Integer value
            ctrl = wx.SpinCtrl(parent, value=str(value), min=-999999, max=999999)
            ctrl.SetValue(value)
            self.value_controls[key] = ("int", ctrl)
            row_sizer.Add(ctrl, 1, wx.EXPAND | wx.ALL, 5)
        elif isinstance(value, float):
            # Float value
            ctrl = wx.TextCtrl(parent, value=str(value))
            self.value_controls[key] = ("float", ctrl)
            row_sizer.Add(ctrl, 1, wx.EXPAND | wx.ALL, 5)
        else:
            # String or other
            ctrl = wx.TextCtrl(parent, value=str(value))
            self.value_controls[key] = ("text", ctrl)
            row_sizer.Add(ctrl, 1, wx.EXPAND | wx.ALL, 5)
        
        sizer.Add(row_sizer, 0, wx.EXPAND | wx.ALL, 2)
    
    def _get_setting_options(self, key: str) -> Optional[List[Dict]]:
        """Get options from Settings Catalog for this setting."""
        if not self.settings_catalog or not self.rule_item.policy:
            return None
        
        # Find the setting in the policy
        for policy_setting in self.rule_item.policy.settings:
            setting_id = policy_setting.setting_definition_id
            setting_def = self.settings_catalog._settings_index.get(setting_id)
            
            if setting_def and 'options' in setting_def:
                options = setting_def['options']
                # Return options with their values
                return [
                        {
                            'displayName': opt.get('displayName', opt.get('name', '')),
                            'value': opt.get('optionValue', {}).get('value', opt.get('value', ''))
                        }
                        for opt in options
                    ]
        return None
    
    def _get_odv_values(self) -> Optional[List[str]]:
        """Get ODV values from baseline YAML."""
        if not self.baseline or not self.rule_item.rule:
            return None
        
        # Check if rule has ODV data
        rule = self.rule_item.rule
        if not hasattr(rule, 'odv') or not rule.odv:
            return None
        
        # Rule ODV is a dict with hint, recommended, and baseline-specific values
        if isinstance(rule.odv, dict):
            values = []
            # Add recommended value first
            if 'recommended' in rule.odv:
                values.append(f"{rule.odv['recommended']} (recommended)")
            
            # Add baseline-specific values
            baseline_name = self.baseline.name if hasattr(self.baseline, 'name') else None
            if baseline_name and baseline_name in rule.odv:
                baseline_val = rule.odv[baseline_name]
                if str(baseline_val) not in [v.split()[0] for v in values]:
                    values.append(f"{baseline_val} ({baseline_name})")
            
            # Add other defined values
            for key, val in rule.odv.items():
                if key not in ['hint', 'recommended'] and str(val) not in [v.split()[0] for v in values]:
                    values.append(str(val))
            
            return values if values else None
        
        return None
    
    def _get_odv_hint(self) -> str:
        """Get ODV hint from rule."""
        rule = self.rule_item.rule
        if hasattr(rule, 'odv') and isinstance(rule.odv, dict):
            return rule.odv.get('hint', '')
        return ''
    
    def _get_dependencies(self) -> List[str]:
        """Get dependency information for the policy."""
        deps = []
        if not self.rule_item.policy or not self.rule_item.policy.settings or not self.settings_catalog:
            return deps
        
        # Get the catalog_data value array
        catalog_data = getattr(self.settings_catalog, 'catalog_data', {})
        all_settings = catalog_data.get('value', [])
        
        for policy_setting in self.rule_item.policy.settings:
            setting_id = policy_setting.setting_definition_id
            setting_def = next((s for s in all_settings if s.get('id') == setting_id), None)
            
            if setting_def:
                dependent_on = setting_def.get('dependentOn', [])
                if dependent_on:
                    for dep in dependent_on:
                        parent_id = dep.get('parentSettingId', '')
                        deps.append(f"Depends on: {parent_id}")
        
        return deps
    
    def get_value(self) -> Dict[str, Any]:
        """Get the edited value as a dictionary."""
        result = {}
        
        for key, control_data in self.value_controls.items():
            if len(control_data) == 3:  # catalog_choice or odv_choice with options
                value_type, ctrl, options = control_data
                selection = ctrl.GetSelection()
                if value_type == "odv_choice":
                    # Extract numeric value from "60 (recommended)" format
                    if selection >= 0 and selection < len(options):
                        odv_str = options[selection].split()[0]  # Get "60" from "60 (recommended)"
                        try:
                            result[key] = int(odv_str)
                        except ValueError:
                            result[key] = odv_str
                elif selection >= 0 and selection < len(options):
                    result[key] = options[selection]['value']
            elif len(control_data) == 2:
                value_type, ctrl = control_data
                if value_type == "bool":
                    result[key] = ctrl.GetSelection() == 0  # 0 = true, 1 = false
                elif value_type == "int":
                    result[key] = ctrl.GetValue()
                elif value_type == "float":
                    try:
                        result[key] = float(ctrl.GetValue())
                    except ValueError:
                        result[key] = ctrl.GetValue()  # Keep as string if invalid
                else:  # text
                    result[key] = ctrl.GetValue()
        
        return result
