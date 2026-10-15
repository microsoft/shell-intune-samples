#!/bin/zsh

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#
# mscp_to_intune_json_conversion.sh — This script converts the mSCP Vendor Manifest JSON
# into the JSON for custom settings within Microsoft Intune Compliance and Conditional Access.
#
# To run this script ./mscp_to_intune_json_conversion.sh "path to mscp_vendor_manifest.json" > "path to output.json"
#
# Collaboration on this script does not imply the National Institute of Standards 
# and Technology endorsement of the products or services offered by Microsoft. 
# Any mention of specific tools or software is for informational purposes and does 
# not constitute a recommendation by NIST. 

jq '{
  Rules: [
    .rules[]
    | select(
        (.tags // "")
        | split(",")
        | all(. != "inherent" and . != "n_a" and . != "permanent" and . != "supplemental" and . != "manual")
      )
    | {
        SettingName: .id,
        Operator: "isEquals",
        DataType: (
          if (.result | type) == "number" then
            if (.result | floor) == .result then
              "Int64"
            else
              "Double"
            end
          elif .result == "true" then
            "Boolean"
          elif .result == "false" then
            "Boolean"
          else
            "String"
          end
        ),        
        Operand: (
          if (.result | type) == "number" then
            .result | tostring
          elif .result == "true" then
            true
          elif .result == "false" then
            false
          else
            .result
          end
        ),
        MoreInfoUrl: ( "https://github.com/usnistgov/macos_security/blob/main/src/mscp/data/rules/" + (.id | split("_")[0]) + "/" + .id + ".yaml" ),
        RemediationStrings: [
          {
            Language: "en_US",
            Title: .title,
            Description: .discussion
          }
        ]
      }
  ]
}' "$1"