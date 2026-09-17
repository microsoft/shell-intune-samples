#!/usr/bin/env python3

#use just like generate_guidance.py - point to a baseline file. Boom.
import argparse
import sys
import os
import os.path
import yaml
import glob
import json
import warnings
import datetime
from pathlib import Path

def get_rule_yaml(rule_file, custom=False):
    """ Takes a rule file, checks for a custom version, and returns the yaml for the rule
    """
    resulting_yaml = {}
    names = [os.path.basename(x) for x in glob.glob('../custom/rules/**/*.yaml', recursive=True)]
    file_name = os.path.basename(rule_file)
    
    if custom:
        print(f"Custom settings found for rule: {rule_file}")
        try:
            override_path = glob.glob('../custom/rules/**/{}'.format(file_name), recursive=True)[0]
        except IndexError:
            override_path = glob.glob('../custom/rules/{}'.format(file_name), recursive=True)[0]
        with open(override_path) as r:
            rule_yaml = yaml.load(r, Loader=yaml.SafeLoader)
    else:
        with open(rule_file) as r:
            rule_yaml = yaml.load(r, Loader=yaml.SafeLoader)
    
    try:
        og_rule_path = glob.glob('../rules/**/{}'.format(file_name), recursive=True)[0]
    except IndexError:
        #assume this is a completely new rule
        og_rule_path = glob.glob('../custom/rules/**/{}'.format(file_name), recursive=True)[0]
        resulting_yaml['customized'] = ["customized rule"]
    
    # get original/default rule yaml for comparison
    with open(og_rule_path) as og:
        og_rule_yaml = yaml.load(og, Loader=yaml.SafeLoader)

    for yaml_field in og_rule_yaml:
        #print('processing field {} for rule {}'.format(yaml_field, file_name))
        if yaml_field == "references":
            if not 'references' in resulting_yaml:
                resulting_yaml['references'] = {}
            for ref in og_rule_yaml['references']:
                try:
                    if og_rule_yaml['references'][ref] == rule_yaml['references'][ref]:
                        resulting_yaml['references'][ref] = og_rule_yaml['references'][ref]
                    else:
                        resulting_yaml['references'][ref] = rule_yaml['references'][ref]
                except KeyError:
                    #  reference not found in original rule yaml, trying to use reference from custom rule
                    try:
                        resulting_yaml['references'][ref] = rule_yaml['references'][ref]
                    except KeyError:
                        resulting_yaml['references'][ref] = og_rule_yaml['references'][ref]
                try: 
                    if "custom" in rule_yaml['references']:
                        resulting_yaml['references']['custom'] = rule_yaml['references']['custom']
                        if 'customized' in resulting_yaml:
                            if 'customized references' not in resulting_yaml['customized']:
                                resulting_yaml['customized'].append("customized references")
                        else:
                            resulting_yaml['customized'] = ["customized references"]
                except:
                    pass
            
        else: 
            try:
                if og_rule_yaml[yaml_field] == rule_yaml[yaml_field]:
                    #print("using default data in yaml field {}".format(yaml_field))
                    resulting_yaml[yaml_field] = og_rule_yaml[yaml_field]
                else:
                    #print('using CUSTOM value for yaml field {} in rule {}'.format(yaml_field, file_name))
                    resulting_yaml[yaml_field] = rule_yaml[yaml_field]
                    if 'customized' in resulting_yaml:
                        resulting_yaml['customized'].append("customized {}".format(yaml_field))
                    else:
                        resulting_yaml['customized'] = ["customized {}".format(yaml_field)]
            except KeyError:
                resulting_yaml[yaml_field] = og_rule_yaml[yaml_field]
    
    return resulting_yaml

def fill_in_odv(resulting_yaml, parent_values):
    if "osquery" in resulting_yaml:
        fields_to_process = ['title', 'discussion', 'check', 'fix','osquery']
    else:
        fields_to_process = ['title', 'discussion', 'check', 'fix']
    _has_odv = False
    if "odv" in resulting_yaml:
        try:
            if type(resulting_yaml['odv'][parent_values]) == int:
                odv = resulting_yaml['odv'][parent_values]
            else:
                odv = str(resulting_yaml['odv'][parent_values])
            _has_odv = True
        except KeyError:
            try:
                if type(resulting_yaml['odv']['custom']) == int:
                    odv = resulting_yaml['odv']['custom']
                else:
                    odv = str(resulting_yaml['odv']['custom'])
                _has_odv = True
            except KeyError:
                if type(resulting_yaml['odv']['recommended']) == int:
                    odv = resulting_yaml['odv']['recommended']
                else:
                    odv = str(resulting_yaml['odv']['recommended'])
                _has_odv = True
        else:
            pass

    if _has_odv:
        for field in fields_to_process:
            if "$ODV" in resulting_yaml[field]:
                resulting_yaml[field]=resulting_yaml[field].replace("$ODV", str(odv))

        for result_value in resulting_yaml['result']:
            if "$ODV" in str(resulting_yaml['result'][result_value]):
                resulting_yaml['result'][result_value] = odv

        if resulting_yaml['mobileconfig_info']:
            for mobileconfig_type in resulting_yaml['mobileconfig_info']:
                if isinstance(resulting_yaml['mobileconfig_info'][mobileconfig_type], dict):
                    for mobileconfig_value in resulting_yaml['mobileconfig_info'][mobileconfig_type]:
                        if "$ODV" in str(resulting_yaml['mobileconfig_info'][mobileconfig_type][mobileconfig_value]):
                            resulting_yaml['mobileconfig_info'][mobileconfig_type][mobileconfig_value] = odv


def main():
    parser = argparse.ArgumentParser(description='Given a profile, create JSON Vendor Manifest.')
    parser.add_argument("baseline", default=None, help="Baseline YAML file used to create the JSON Vendor Manifest.", type=argparse.FileType('rt'))
    parser.add_argument("--osquery", "-o", default=None, help="osquery mapping file.", type=argparse.FileType('rt'))
    
    results = parser.parse_args()
    osquery_data = {}
    if results.osquery:
        with open (results.osquery.name, 'r') as osquery_json_file:
            osquery_data = json.load(osquery_json_file)

    results = parser.parse_args()
    try:
        
        output_basename = os.path.basename(results.baseline.name)
        output_filename = os.path.splitext(output_basename)[0]
        baseline_name = os.path.splitext(output_basename)[0]
        file_dir = os.path.dirname(os.path.abspath(__file__))
        parent_dir = os.path.dirname(file_dir)
        # stash current working directory
        original_working_directory = os.getcwd()

        # switch to the scripts directory
        os.chdir(file_dir)
        build_path = os.path.join(parent_dir, 'build', f'{baseline_name}')
        output = build_path + "/" + baseline_name + ".json"

        if not (os.path.isdir(build_path)):
            try:
                os.makedirs(build_path)
            except OSError:
                print(f"Creation of the directory {build_path} failed")
        print('Profile YAML:', results.baseline.name)
        print('Output path:', output)
        
       
        
    except IOError as msg:
        parser.error(str(msg))


    version_file = "../VERSION.yaml"
    with open(version_file) as r:
        version_yaml = yaml.load(r, Loader=yaml.SafeLoader)


    profile_yaml = yaml.load(results.baseline, Loader=yaml.SafeLoader)
    
    json_manifest = {
    "benchmark": baseline_name,
    "parent_values": profile_yaml['parent_values'],
    "plist_location": "/Library/Preferences/org.{}.audit.plist".format(baseline_name),
    "log_location": "/Library/Logs/{}_baseline.log".format(baseline_name),
    "creation_date": datetime.datetime.now().replace(microsecond=0).isoformat(),
    "rules": []
    }

    for sections in profile_yaml['profile']:
        if sections['section'] == "Supplemental":
            continue
        
        for profile_rule in sections['rules']:
            

            if glob.glob('../custom/rules/**/{}.yaml'.format(profile_rule),recursive=True):
                rule = glob.glob('../custom/rules/**/{}.yaml'.format(profile_rule),recursive=True)[0]
                custom=True
            
            elif glob.glob('../rules/*/{}.yaml'.format(profile_rule)):
                rule = glob.glob('../rules/*/{}.yaml'.format(profile_rule))[0]
                custom=False
            
            rule_yaml = get_rule_yaml(rule, custom)

            
            if "inherent" in rule_yaml['tags'] or "n_a" in rule_yaml['tags'] or "permanent" in rule_yaml['tags']:
                continue

            try:
                parent_values = profile_yaml['parent_values']
            except KeyError:
                parent_values = "recommended"
            if results.osquery:
                for mapping in osquery_data['os_query_mappings']:
                    if mapping['id'] == rule_yaml['id']:
                        rule_yaml['osquery'] = mapping['query']
                        break

            fill_in_odv(rule_yaml,parent_values)
            mscp_result = ""
            try:

                for keys,value in rule_yaml['result'].items():
                    mscp_result = value
            
            except:
                mscp_result = ""

            references = ""
            for values in rule_yaml['references']:
                for v in rule_yaml['references'][values]:
                    if v == "N/A":
                        continue
                    elif v == "benchmark":
                        continue
                    elif v == "controls v8":
                        for v8 in rule_yaml['references'][values]["controls v8"]:
                            references = references + "{}|{},".format("cis_v8",v8)
                    else:
                        references = references + "{}|{},".format(values,v)
            references.rstrip()
            if references == "":
                references = "" 
            elif references[-1] == ",":
                references = references.rstrip(references[-1])

            if "inherent" in rule_yaml['tags']:
                continue
                

            elif "permanent" in rule_yaml['tags']:
                continue

            elif "n_a" in rule_yaml['tags']:
                continue

            elif "manual" in rule_yaml['tags']:
                continue
            
            else:
                rule_yaml['check'] = rule_yaml['check'].replace('\\','\\\\')
                tag_list = str()
                for tag in rule_yaml['tags']:
                    # tag_list.append(tag)
                    tag_list = tag_list + tag + ","

                tag_list = tag_list.rstrip()
                rule_dict = {
                    "id": rule_yaml['id'],
                    "title": rule_yaml['title'],
                    "discussion": rule_yaml['discussion'].replace('"','\\"').rstrip().replace("\n"," "),
                    "references": references,
                    
                    "tags": tag_list,
                    "check": rule_yaml['check'].replace('"','\\"').rstrip(),
                    "result": mscp_result
                }
                if "severity" in rule_yaml:
                    rule_dict['severity'] = rule_yaml['severity']
                
                if rule_yaml['mobileconfig'] == True:
                    for key,value in rule_yaml['mobileconfig_info'].items():
                        for k,v in value.items():
                            rule_dict["fix"] = {
                                "mobileconfig_info": {
                                    "domain": key,
                                    "key": k,
                                    "value": v
                                }
                    }
                else:
                    if "[source,bash]" in rule_yaml['fix']:
                        rule_dict["fix"] = {
                            "shell_script": rule_yaml['fix'].split("----")[1].replace('"','\\"').rstrip().replace("\n","\\n")
                        }
                if "osquery" in rule_yaml:
                    rule_dict['osquery'] = rule_yaml['osquery']

                json_manifest['rules'].append(rule_dict)


    with open(output,'w') as rite:
        json.dump(json_manifest, rite, indent=4)
        rite.close()
    
    os.chdir(original_working_directory)
            
if __name__ == "__main__":
    main()
