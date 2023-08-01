/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


## NOTE: This provides PoC demo environment for Assured Workload ##
##  This is not built for production workload ##
variable "organization_id" {
  description = "(Required)" #The organization for the resource
  type        = string
  default     = "XXXXXXXX"
}

#Required. Input only. The billing account used for the resources which are direct children of workload. This billing account is initially associated with the resources created as part of Workload creation. After the initial creation of these resources, the customer can change the assigned billing account. The resource name has the form `billingAccounts/{billing_account_id}`. For example, 'billingAccounts/012345-567890-ABCDEF`.
variable "billing_account" {
  description = "(Required)" 
  type        = string
  default     = "XXXXX-XXXXX-XXXXXX"
}


variable "members" {
  description = "An allowed list of members (users, service accounts). The signed-in identity originating the request must be a part of one of the provided members. If not specified, a request may come from any user (logged in/not logged in, etc.). Formats: user:{emailid}, serviceAccount:{emailid}"
  type        = list(string)
  default     = ["user:username@domain.com"]
}

#Required. The user-assigned display name of the Workload. When present it must be between 4 to 30 characters. Allowed characters are: lowercase and uppercase letters, numbers, hyphen, and spaces. Example: My Workload
variable "aw_mgmt_project_id" {
  description = "(Required)" 
  type        = string
  default     = "aw-mgmt-australia"
}

 #Required. The user-assigned display name top folder for application/department/workload. When present it must be between 4 to 30 characters. Allowed characters are: lowercase and uppercase letters, numbers, hyphen, and spaces. Example: My Workload
variable "app_folder_name" {
  description = "(Required)"
  type        = string
  default     = "Australia Data Residency"
}

#Required. The user-assigned display name of the Workload. When present it must be between 4 to 30 characters. Allowed characters are: lowercase and uppercase letters, numbers, hyphen, and spaces. Example: My Workload
variable "assured_workloads_workload_display_name" {
  description = "(Required)" 
  type        = string
  default     = "Australia Data Residency"
}

#Required. Immutable. Compliance Regime associated with this workload. Possible values: COMPLIANCE_REGIME_UNSPECIFIED, IL4, CJIS, FEDRAMP_HIGH, FEDRAMP_MODERATE, US_REGIONAL_ACCESS
variable "assured_workloads_workload_compliance_regime" {
  description = "AU_REGIONS_AND_SUPPORT" 
  type        = string

#Available Options: EU_REGIONS_AND_SUPPORT, US_REGIONAL_ACCESS, COMPLIANCE_REGIME_UNSPECIFIED, IL4, CJIS, FEDRAMP_HIGH,FEDRAMP_MODERATE, US_REGIONAL_ACCESS, HIPAA, HITRUST, CA_REGIONS_AND_SUPPORT, ITAR, AU_REGIONS_AND_US_SUPPORT, ASSURED_WORKLOADS_FOR_PARTNERS
  default     = "AU_REGIONS_AND_SUPPORT" 
}

variable "assured_workloads_workload_location" {
  description = "(Required)" #The location for the resource
  type        = string
  default     = "australia-southeast1" # either a single region or country code
  }

  variable "assured_workloads_label" {
  description = "Australia" #The location for the resource
  type        = string
  default     = "aw-australia" # either a single region or country code
  }

variable "network_region" {
  type    = string
  default = "australia-southeast1"
}

variable "vpc_network_name" {
  type    = string
  default = "vpc-network"
}

variable "network_zone" {
  type    = string
  default = "australia-southeast1-b"
}

variable "crypto_key_name" {
  type    = string
  default = "crypto_key"
}

variable "key_ring_name" {
  type    = string
  default = "ring"
}
