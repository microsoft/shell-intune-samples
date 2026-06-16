"""Export dialog for generating Intune JSON and mobileconfig files."""

import logging
import wx
from pathlib import Path
from typing import List, Optional

from ..core.exporter import IntuneExporter
from ..models.policy import Policy
from ..models.rule import Rule
from ..models.baseline import Baseline

logger = logging.getLogger(__name__)


class ExportDialog(wx.Dialog):
    """Dialog for exporting policies to Intune and mobileconfig formats."""
    
    def __init__(self, parent, policies: List[Policy], unmapped_rules: List[Rule], baseline: Optional[Baseline] = None, all_rules: Optional[List[Rule]] = None, settings_catalog=None):
        """Initialize the export dialog.
        
        Args:
            parent: Parent window
            policies: List of policies to export (Settings Catalog mapped)
            unmapped_rules: List of unmapped rules (for mobileconfig export)
            baseline: Optional baseline for naming
            all_rules: All rules from the baseline (for dependency analysis)
            settings_catalog: Optional SettingsCatalog for validation
        """
        super().__init__(
            parent,
            title="Export Policies",
            size=(700, 600)
        )
        
        self.policies = policies
        self.unmapped_rules = unmapped_rules
        self.baseline = baseline
        self.all_rules = all_rules or (unmapped_rules + [r for p in policies for r in [None] if hasattr(p, 'source_rule')])  # Collect all rules
        self.settings_catalog = settings_catalog
        
        self._create_ui()
    
    def _create_ui(self):
        """Create the export dialog UI."""
        panel = wx.Panel(self)
        main_sizer = wx.BoxSizer(wx.VERTICAL)
        
        # Summary section
        summary_box = wx.StaticBox(panel, label="Export Summary")
        summary_sizer = wx.StaticBoxSizer(summary_box, wx.VERTICAL)
        
        summary_text = (
            f"Settings Catalog Policies: {len(self.policies)}\n"
            f"Unmapped Rules (mobileconfig): {len(self.unmapped_rules)}\n"
        )
        if self.baseline:
            summary_text = f"Baseline: {self.baseline.name}\n\n" + summary_text
        
        self.summary_ctrl = wx.TextCtrl(
            panel,
            value=summary_text,
            style=wx.TE_MULTILINE | wx.TE_READONLY
        )
        summary_sizer.Add(self.summary_ctrl, 1, wx.EXPAND | wx.ALL, 5)
        
        main_sizer.Add(summary_sizer, 0, wx.ALL | wx.EXPAND, 10)
        
        # Export format options - Settings Catalog
        format_box = wx.StaticBox(panel, label="Settings Catalog Export Format")
        format_sizer = wx.StaticBoxSizer(format_box, wx.VERTICAL)
        
        self.combined_radio = wx.RadioButton(panel, label="Combined - Single JSON file for all Settings Catalog policies", style=wx.RB_GROUP)
        self.combined_radio.SetValue(True)
        format_sizer.Add(self.combined_radio, 0, wx.ALL, 5)
        
        self.split_radio = wx.RadioButton(panel, label="Split by Section - Separate JSON file per section")
        format_sizer.Add(self.split_radio, 0, wx.ALL, 5)
        
        main_sizer.Add(format_sizer, 0, wx.ALL | wx.EXPAND, 10)
        
        # Mobileconfig format options
        if self.unmapped_rules:
            mc_format_box = wx.StaticBox(panel, label="Mobileconfig Export Format")
            mc_format_sizer = wx.StaticBoxSizer(mc_format_box, wx.VERTICAL)
            
            self.mc_combined_radio = wx.RadioButton(panel, label="Combined - Single .mobileconfig file", style=wx.RB_GROUP)
            self.mc_combined_radio.SetValue(True)
            mc_format_sizer.Add(self.mc_combined_radio, 0, wx.ALL, 5)
            
            self.mc_by_type_radio = wx.RadioButton(panel, label="By Type - One file per rule type (system_settings, os, pwpolicy, etc.)")
            mc_format_sizer.Add(self.mc_by_type_radio, 0, wx.ALL, 5)
            
            self.mc_individual_radio = wx.RadioButton(panel, label="Individual - Separate file for each rule")
            mc_format_sizer.Add(self.mc_individual_radio, 0, wx.ALL, 5)
            
            main_sizer.Add(mc_format_sizer, 0, wx.ALL | wx.EXPAND, 10)
        
        # Output location
        location_box = wx.StaticBox(panel, label="Output Location")
        location_sizer = wx.StaticBoxSizer(location_box, wx.HORIZONTAL)
        
        self.location_text = wx.TextCtrl(panel, value=str(Path.cwd() / "export"), style=wx.TE_READONLY)
        location_sizer.Add(self.location_text, 1, wx.EXPAND | wx.ALL, 5)
        
        browse_btn = wx.Button(panel, label="Browse...")
        browse_btn.Bind(wx.EVT_BUTTON, self.on_browse_location)
        location_sizer.Add(browse_btn, 0, wx.ALL, 5)
        
        main_sizer.Add(location_sizer, 0, wx.ALL | wx.EXPAND, 10)
        
        # Buttons
        btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        
        export_btn = wx.Button(panel, wx.ID_OK, "Export")
        export_btn.Bind(wx.EVT_BUTTON, self.on_export)
        export_btn.SetDefault()
        btn_sizer.Add(export_btn, 0, wx.ALL, 5)
        
        cancel_btn = wx.Button(panel, wx.ID_CANCEL, "Cancel")
        btn_sizer.Add(cancel_btn, 0, wx.ALL, 5)
        
        main_sizer.Add(btn_sizer, 0, wx.ALIGN_RIGHT | wx.ALL, 10)
        
        panel.SetSizer(main_sizer)
        self.Centre()
    
    def on_browse_location(self, event):
        """Browse for output location."""
        dlg = wx.DirDialog(
            self,
            "Select Export Directory",
            defaultPath=self.location_text.GetValue()
        )
        
        if dlg.ShowModal() == wx.ID_OK:
            self.location_text.SetValue(dlg.GetPath())
        
        dlg.Destroy()
    
    def on_export(self, event):
        """Perform the export."""
        output_path = Path(self.location_text.GetValue())
        
        # Create output directory if it doesn't exist
        try:
            output_path.mkdir(parents=True, exist_ok=True)
        except Exception as e:
            wx.MessageBox(f"Failed to create output directory: {e}", "Error", wx.OK | wx.ICON_ERROR)
            return
        
        try:
            exporter = IntuneExporter(self.settings_catalog)
            
            # Analyze dependencies if we have rules
            if self.all_rules:
                logger.info(f"Analyzing dependencies for {len(self.all_rules)} rules...")
                dependencies = exporter.analyze_dependencies(self.all_rules)
                if dependencies:
                    logger.info(f"Found {len(dependencies)} rules with dependencies")
                    for rule_id, deps in dependencies.items():
                        logger.info(f"  {rule_id} depends on: {', '.join(deps)}")
            
            # Determine export mode
            split_by_section = self.split_radio.GetValue()
            
            # Export Settings Catalog policies
            if self.policies:
                # Generate policy name from baseline if available
                baseline_name = self.baseline.title if self.baseline and hasattr(self.baseline, 'title') else \
                                self.baseline.name if self.baseline else "macOS Security Baseline"
                
                # Generate filename from baseline name (replace underscores with hyphens)
                baseline_filename = self.baseline.name.replace('_', '-') if self.baseline else "macos-baseline"
                
                if split_by_section:
                    # Group policies by section
                    policies_by_section = {}
                    for policy in self.policies:
                        section = policy.section or "general"
                        if section not in policies_by_section:
                            policies_by_section[section] = []
                        policies_by_section[section].append(policy)
                    
                    # Export each section
                    for section, section_policies in policies_by_section.items():
                        filename = f"{baseline_filename}-{section}.json"
                        file_path = output_path / filename
                        
                        section_name = f"{baseline_name} - {section.replace('_', ' ').title()}"
                        json_data = exporter.export_to_intune_json(section_policies, baseline_name=section_name)
                        file_path.write_text(json_data, encoding='utf-8')
                        logger.info(f"Exported {len(section_policies)} policies to {filename}")
                else:
                    # Combined export - use baseline_name.json
                    filename = f"{baseline_filename}.json"
                    file_path = output_path / filename
                    
                    policy_name = f"{baseline_name} - Generated Policy"
                    json_data = exporter.export_to_intune_json(self.policies, baseline_name=policy_name)
                    file_path.write_text(json_data, encoding='utf-8')
                    logger.info(f"Exported {len(self.policies)} settings to {filename}")
            
            # Export mobileconfig for unmapped rules
            if self.unmapped_rules:
                # Generate filename from baseline name
                baseline_filename = self.baseline.name.replace('_', '-') if self.baseline else "macos-baseline"
                
                # Determine mobileconfig export mode
                mc_combined = hasattr(self, 'mc_combined_radio') and self.mc_combined_radio.GetValue()
                mc_by_type = hasattr(self, 'mc_by_type_radio') and self.mc_by_type_radio.GetValue()
                mc_individual = not mc_combined and not mc_by_type  # Default
                
                if mc_combined:
                    # Export all rules into one mobileconfig - use baseline_name.mobileconfig
                    filename = f"{baseline_filename}.mobileconfig"
                    file_path = output_path / filename
                    mobileconfig_content = exporter.export_combined_mobileconfig(self.unmapped_rules)
                    file_path.write_text(mobileconfig_content, encoding='utf-8')
                    logger.info(f"Exported combined mobileconfig with {len(self.unmapped_rules)} rules to {filename}")
                    
                elif mc_by_type:
                    # Group rules by type prefix
                    rules_by_type = {}
                    for rule in self.unmapped_rules:
                        if rule.has_mobileconfig:
                            # Extract type from rule ID (e.g., "system_settings" from "system_settings_firewall_enable")
                            parts = rule.id.split('_')
                            if len(parts) >= 2:
                                rule_type = f"{parts[0]}_{parts[1]}"  # e.g., "system_settings", "pwpolicy", etc.
                            else:
                                rule_type = parts[0] if parts else "other"
                            
                            if rule_type not in rules_by_type:
                                rules_by_type[rule_type] = []
                            rules_by_type[rule_type].append(rule)
                    
                    # Export each type group
                    for rule_type, type_rules in rules_by_type.items():
                        filename = f"{baseline_filename}-{rule_type}.mobileconfig"
                        file_path = output_path / filename
                        mobileconfig_content = exporter.export_combined_mobileconfig(type_rules)
                        file_path.write_text(mobileconfig_content, encoding='utf-8')
                        logger.info(f"Exported {len(type_rules)} rules to {filename}")
                        
                else:
                    # Individual files - use baseline prefix
                    for rule in self.unmapped_rules:
                        if rule.has_mobileconfig:
                            filename = f"{baseline_filename}-{rule.id}.mobileconfig"
                            file_path = output_path / filename
                            
                            # Generate mobileconfig
                            mobileconfig_content = exporter.export_to_mobileconfig(rule)
                            file_path.write_text(mobileconfig_content, encoding='utf-8')
                            logger.info(f"Exported mobileconfig for {rule.id}")
            
            # Show success message
            wx.MessageBox(
                f"Export completed successfully!\n\n"
                f"Settings Catalog policies: {len(self.policies)}\n"
                f"Mobileconfig files: {len([r for r in self.unmapped_rules if r.has_mobileconfig])}\n\n"
                f"Location: {output_path}",
                "Export Complete",
                wx.OK | wx.ICON_INFORMATION
            )
            
            self.EndModal(wx.ID_OK)
            
        except Exception as e:
            logger.error(f"Export failed: {e}", exc_info=True)
            wx.MessageBox(f"Export failed: {e}", "Error", wx.OK | wx.ICON_ERROR)
