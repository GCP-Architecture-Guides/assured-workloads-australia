```
This is not an officially supported Google product.
This code creates a proof of concept demo environment for an Assured Workloads folder. This demo code is not built for production workloads. 
```

# Compliance in Australia with Assured Workloads Architecture Guide

# Summary

Assured Workloads helps you comply with different regulatory compliance frameworks by implementing logical controls that segment networks and users from in-scope sensitive data. Core to our strategy for Assured Workloads is to build security and compliance controls as software. Software allows us to scale globally and combine technologies to help our customers achieve specific compliance outcomes. 
This approach has enabled us to make Assured Workloads available in more countries, and expand the list of available services across multiple compliance frameworks. As a result, Assured Workloads can help organizations more easily achieve and maintain compliance with relevant regimes around the world without refactoring.

This guide will provide written instructions and Terraform code for creating an Assured Workloads folder for an Australian-based workload. We recommend that you use VPC Service Controls (VPC-SC) to create a strong boundary around the regulated environment.

This guide will provide written instructions and Terraform/Python code for:

1. Creating an Assured Workloads folder for an Australian compliance use case
2. Setting up a VPC-SC perimeter around the Assured Workloads boundary
3. Adding new projects to the VPC-SC perimeter, both manually and via automation
4. Setting up Access Context Manager policy to enforce data residency controls for developers

# Architecture 

## Design Diagram

![image](./images/architecture-diagram.png)

## Product and services

[Assured Workloads](https://cloud.google.com/assured-workloads) provides Google Cloud customers with the ability to apply security controls to an environment  in support of compliance requirements without compromising the quality of their cloud experience. Australia Regions with Assured Support enforces data residency for customer data at-rest to our two cloud regions in Australia (Sydney and Melbourne). It’s coupled with our new Assured Support service, which means that customer support will be provided from only five countries (United States, Australia, Canada, New Zealand, and the United Kingdom). 

[VPC Service Controls](https://cloud.google.com/vpc-service-controls) (VPC-SC) provides an extra layer of security defense for Google Cloud services that is independent of [Identity and Access Management (IAM)](https://cloud.google.com/iam/docs/). While Identity and Access Management enables granular identity-based access control, VPC-SC enables broader context-based perimeter security, such as controlling data ingress and egress across the perimeter. VPC-SC adds a logical boundary around Google Cloud APIs that are managed at the organization level and applied and enforced at the project level. 

Before proceeding with this guide, you should:

-  Ensure that the Google Cloud services you are planning to use are [in scope for Australia Regions with Assured Support](https://cloud.google.com/assured-workloads/docs/supported-products)
-  Ensure that you've read and understand the [purpose and usage of VPC-SC](https://cloud.google.com/vpc-service-controls/docs/overview) and its [service perimeters](https://cloud.google.com/vpc-service-controls/docs/service-perimeters).


## Design considerations

Because VPC-SC protection affects cloud services functionality, we recommend that you plan the enablement of VPC-SC in advance, and consider VPC Service Controls during architecture design. It's important to keep VPC-SC design as simple as possible. We recommend that you avoid perimeter designs that use multiple bridges, perimeter network projects or a DMZ perimeter, and complex access levels. Read more about designing and architecting service perimeters [here](https://cloud.google.com/vpc-service-controls/docs/architect-perimeters).

Assured Workloads folders modify Google Cloud's inherent global infrastructure to deliver products and services with compliance requirements by adjusting Google Cloud products' global behavior and access paths. This includes disabling global APIs, including the products' underlying dependencies, to provide data residency. Customers are still responsible for configuring IAM permissions, networking, and GCP services to meet their compliance requirements.

## Prerequisites

### Assured Workloads

Before proceeding, it is important to understand that Asutralia Regions with Assured Support is a [Premium Platform Control.](https://cloud.google.com/assured-workloads/docs/concept-platform-controls#premium_tier) Platform Controls are a combination of Google Cloud infrastructure data location and personnel access primitives that support compliance by enforcing and restricting access by customers or Google personnel. To launch a Premium Platform Control, you must:

-  Ensure you have [Enhanced or Premium Support ](https://cloud.google.com/support)
-  [Enable Access Transparency](https://cloud.google.com/cloud-provider-access-management/access-transparency/docs/enable)

If you wish to use Assured Workloads [Premium Platform Controls](https://cloud.google.com/assured-workloads/docs/concept-platform-controls#premium_tier) but don't currently have a Premium subscription, sign up for a 60-day [Premium Free Trial](https://inthecloud.withgoogle.com/assured-workloads-60-day-trial-interest/sign-up.html?_gl=1*1q0ww8q*_ga*MTk5NjYyOTEzMi4xNjc5NDMzMTky*_ga_WH2QY8WWF5*MTY3OTUwODI5OC40LjEuMTY3OTUwODMyNy4wLjAuMA..&_ga=2.182814626.58027757.1679433192-1996629132.1679433192). 

Many Google Cloud services send out notifications to share important information with Google Cloud users. With [Essential Contacts](https://cloud.google.com/resource-manager/docs/managing-notification-contacts), you can customize who receives notifications by providing your own list of contacts. This is important because different individuals and teams within your organization care about different types of notifications. To reduce the impact of personnel changes, we recommend adding groups as contacts, then managing the membership of those groups to determine who receives notifications. This practice helps ensure that notifications always go to active employees.

1. Enable the [Essential Contacts API](https://console.cloud.google.com/flows/enableapi?apiid=essentialcontacts.googleapis.com&_ga=2.178924196.1685767107.1678727190-215554569.1678472440)
1. Visit the [Essential Contacts page](https://console.cloud.google.com/iam-admin/essential-contacts?_ga=2.217834006.1685767107.1678727190-215554569.1678472440)
1. Ensure the Google Cloud Organization is selected
1. [Add an Essential Contact](https://cloud.google.com/resource-manager/docs/managing-notification-contacts#add) for **Legal**

We recommend adding three Contacts for the Legal category: representatives from your Legal, Compliance, and Security departments. **This group will receive notifications of compliance violations**, so this will ensure that Legal and Compliance remain informed, and acts as an immediate notification to Security for remediation actions. We also recommend that you enact a plan of action for addressing these alerts.

### VPC Service Controls

-  Read about[ configuring service perimeters](https://cloud.google.com/vpc-service-controls/docs/service-perimeters).
-  Read about [management of VPC networks in service perimeters](https://cloud.google.com/vpc-service-controls/docs/vpc-perimeters-management).
-  Read about [granting access to VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs/access-control).
-  If you want to configure external access to your protected services when you create your perimeter, [first create one or more access levels](https://cloud.google.com/access-context-manager/docs/create-access-level) before you create the perimeter.

# Deployment

## Terraform Deployment Instructions
Sign in to your organization and assign yourself the following roles: 
1. Access Transparency Admin: roles/axt.admin
2. Assured Workloads Admin: roles/assuredworkloads.admin
3. Resource Manager Organization Viewer: roles/resourcemanager.organizationViewer
4. VPC Service Controls: roles/accesscontextmanager.policyAdmin
5. Create Log Sinks: roles/logging.configWriter

The following steps should be executed in Cloud Shell in the Google Cloud Console.

1. To deploy the architecture open up Cloud shell and clone the [git repository](https://github.com/Urena-luis/assured-workloads-australia) using the command below.

```
git clone https://github.com/Urena-Luis/assured-workloads-australia
```

1. Navigate to the assured-workloads-australia folder.

```
cd assured-workloads-australia
```

1. In the assured-workloads-australia folder navigate to variable.tf file and update variables organization_id, billing_account and members for access in assured workload.

```
organization_id = "XXXXXXXXXXX"

billing_account = "XXXX-XXXXXX-XXXXX"

Members = ["user:name@domain.com"]
```

> Note: All the other variables are given a default value. If you wish to change, update the corresponding variables in the variable.tf file.

1. To find your organization id and billing_id, run the following command.

```
gcloud projects get-ancestors [ANY_PROJECT_ID_IN_ORG]

gcloud alpha billing accounts list
```

1. While in the assured-workloads-australia, run the commands below in order. When prompted for confirmation enter "yes" to proceed.

```
terraform init

terraform apply -target=data.google_projects.in_perimeter_folder

terraform apply
```

> If prompted, authorize the API call.

1. Once deployment is finished it will publish the output summary of assets orchestrated. It deploys the resources within 10 minutes.

1.  After completing the demo, navigate to the assured-workloads-australia folder and run the command below to destroy all resources.

```
 terraform destroy
 ```

# Best Practices

We also strongly recommend that you do not nest an Assured Workloads folder within another Assured Workloads folder - even if they are the same compliance framework - as this will cause errors. You can, however, nest Assured Workloads folders and non-Assured Workloads folders with each other.

We also recommend you set up logging and alerts for any changes to the Assured Workloads folder or according IAM permissions, including Org Admin changes. These alerts should be routed to an appropriate stakeholder other than Org Admin. This is because Org Admin can change the org level policies that are important for continuing compliance.

# Governance, Risk Management, and Compliance

## Discover Compliance Violations

Assured Workloads monitors a compliance framework's [organization policy constraints](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints), and highlights a violation if a change to a resource is non-compliant. You can then resolve these violations, or create exceptions for them where appropriate.

Monitor the organization policy constraints, and highlight violations if a change to a resource is non-compliant. Violations may be viewed by navigating to the Assured Workloads [Monitoring page](https://console.cloud.google.com/compliance/monitoring?_ga=2.26184249.524481087.1680725155-1422847751.1680725155) and clicking the **Violation ID **to view the status of your compliance violations

Act and remediate these violations by following the remediation steps in the **Violation Details. **Please visit this [page](https://cloud.google.com/assured-workloads/docs/monitor-folder#monitored_violations) for the complete list of Monitored Violations. 

## Exceptions to the Restrict Resource Usage Organization Policy

We recommend maintaining Organization Policy Restrictions in place, as they help restrict access to unauthorized services and regions. However, you may selectively disable restrictions that prevent the usage of resources that aren't compliant with certain  compliance frameworks. **This is not recommended because it makes the Assured Workloads folder less restrictive and puts your environment in non-compliant scope**. However, it is available to customers who accept the risk of using non-compliant products. Customers may proceed with this by:

-  Having the appropriate IAM roles:
    -  Org Policy Administrator: roles/orgpolicy.policyAdmin
    -  Assured Workloads Admin: roles/assuredworkloads.admin

-  Modifying the policy based on [these instructions](https://cloud.google.com/resource-manager/docs/organization-policy/restricting-resources#setting_the_organization_policy)
-  [Adding an Assured Workloads Monitoring Violation Exception](https://cloud.google.com/assured-workloads/docs/monitor-folder#exception) to ensure the change has a documented business justification and isn't reported as "Unresolved" 

For an introduction on Organization Policy Restrictions, please [watch this video](https://www.youtube.com/watch?v=VX7444hVsD0). For more information on Restriction Resource Usage for Assured Workloads, including limitations, please read this [guide](https://cloud.google.com/assured-workloads/docs/restrict-resource-usage).

## Restrict TLS Versions

Google Cloud supports multiple TLS protocol versions. To meet compliance requirements, you may want to deny handshake requests from clients that use older TLS versions.

-  Ensure you have the appropriate IAM role:
    -  Org Policy Administrator: roles/orgpolicy.policyAdmin

-  Follow this [guide to restrict certain TLS versions ](https://cloud.google.com/assured-workloads/docs/restrict-tls-versions#restrict)

# Cost

<table>
  <thead>
    <tr>
      <th><strong>GCP Service</strong></th>
      <th><strong>Type</strong></th>
      <th><strong>Total Cost  USD </strong></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Assured Workloads </td>
      <td>Premium Subscription</td>
      <td>20% uplift based on spend within the Assured Workloads folder</td>
    </tr>
    <tr>
      <td>VPC Service Controls</td>
      <td></td>
      <td>Free</td>
    </tr>
  </tbody>
</table>

The cost estimate may change with time and may vary per region, please review the cost of each resource at [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator).

# Related Resources

-  [Assured Workloads Quick Start Guide](https://services.google.com/fh/files/misc/assured_workloads_quick_start_guide_0423.pdf)
-  [Australia Regions with Assured Support Information](https://cloud.google.com/assured-workloads/docs/compliance-programs#aus-regions-support)
-  [Personnel Data Access Controls](https://cloud.google.com/assured-workloads/docs/personnel-access-data-controls)
-  [Control Data Access using Access Approval](https://cloud.google.com/assured-workloads/docs/access-approval)
-  [Supported Products](https://cloud.google.com/assured-workloads/docs/supported-products)
-  [VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs/overview)
-  [Best Practices for Enabling VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs/enable)
# 
