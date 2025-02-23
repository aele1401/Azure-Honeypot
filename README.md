# Azure Honeypot Deployment

## Overview
This project demonstrates how to deploy a honeypot in Microsoft Azure using Virtual Machines, Log Analytics Workspace, and Microsoft Sentinel. The goal is to attract and monitor malicious activities, providing insights into potential threats and attacker behaviors.

## Learning Objectives
- Configure and deploy Azure resources, including Virtual Machines and Log Analytics Workspaces.
- Gain hands-on experience with Microsoft Sentinel for security monitoring.
- Analyze Windows Security Event logs to identify potential threats.
- Utilize Kusto Query Language (KQL) to query and analyze log data.
- Visualize attack data using Azure Sentinel Workbooks.

## Getting Started

### Prerequisites:
- An active Microsoft Azure account.
- Basic knowledge of Azure services and PowerShell.
- Familiarity with Remote Desktop Protocol (RDP).
- Access to a third-party geolocation API (e.g., ipgeolocation.io).

## Honeypot

This project utilizes Azure resources and Sentinel for a low-interaction honeypot designed to attract, detect, and analyze malicious activities by setting up a decoy system and network resource. This decoy mimics a vulnerable server exposed to the public internet, to lure attackers and study their methods and behavior. Here are the key aspects of this project:
  * Setting up decoy system: this is the configuration and deployment of systems and resources intentionally made to appear as appealing targets for cyber attackers. This can also be servers, databases, IoT devices, or any other networked device.
  * Monitoring and logging: honeypots are equipped with extensive monitoring tools to log all interactions. This helps cybersecurity experts understand attack vectors, methods, tools, and behaviors of the attackers.
  * Research and analysis: data collected from honeypots are analyzed to gain insights into the latest threats and attack patterns. This information is crucial for developing better defensive strategies and improving cybersecurity protocols.

Types of Honeypots:
  * Low-Interaction Honeypots: simulate only basic services and are primarily used to collect information about automated attacks like worms or bots. They are easier to set up and manage but provide limited interaction data.
  * High-Interaction Honeypots: fully functional systems that provide a real operating environment for attackers. They offer deeper insights but come with higher risks and require more resources to maintain.

  ## Azure Deployment
  ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/network_diagram.png)

  ## VM Configuration & Deployment + Access Policies & Firewall Rules
  
  Login to Azure account. Setup and configure VM with:
   - Resource group: `HoneypotProject`
   - VM name: `honeypot-vm`
   - Region: `(US) Central US`
   - Availability & Redundancy: `Standard_D2s_v3`
   - Security Type: `Standard`
   - Image: `Windows 10 Pro, Version 20H2 - Gen1`
   - Size: `Standard_D2s_v3 - 2 vcpus, 8 Gib memory`
   - Username & Password: Set an admin username and password.
    

    |     Name    |    Function  |   IP Address   |  Operating System |
    |-------------|--------------|----------------|-------------------|
    | Honeypot-vm |     Decoy    |  00.000.000.00 |     Windows 10    |

   ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/vm_creation.png)
  
  Access Policies & Firewall Rules:
   * Create a network security group.
   * Delete the defaults because we want to expose this machine to the public.
   * Create a new inbound rule allowing any source, port range, destination, protocol, and low priority of 100 to expose the machine to the public internet.
   * Ensure that the VM is configured to allow all inbound traffic by adjusting the Network Security Group (NSG) settings:
     - Remove any existing inbound rules.
     - Add a new inbound rule with the following settings:
         * Destination Port Ranges:`*`
         * Protocol: `Any`
         * Action: `Allow`
         * Priority: `100`

    |     Name    | Publicly Accessible | Allowed IP Addresses |
    |-------------|---------------------|----------------------|
    | Honeypot-vm |         Yes         |        All           |

   ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/firewall_rule.png)

  ## Log Analytics Workspace - Enabling Log Collection in Security Center
  
  Create a Log Analytics Workspace to ingest VM logs, enable collection, and connect it to the VM:
  
  ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/law_creation.png)    

  ## Setting Up Azure Sentinel w/ Log Analytics Workspace & Windows Logs

  * Setting up Azure Sentinel:
    - Create Azure Sentinel Workspace and connect it to the Log Analytics Workspace.
    - Log into the honeypot VM using the public IP and remote desktop.
    - Observe the various events in Windows Event Viewer:
      * Test Event Viewer logs with an incorrect login to honeypot VM to ensure everything is working:
        
      ![Diagram](https://github.com/aele1401/Azure-Honeypot/blob/main/Images/eventviewer.png)
      ![Diagram](https://github.com/aele1401/Azure-Honeypot/blob/main/Images/eventviewer_failed_login.png)
      
 
    ## Disabling Local Firewalls & VM Traffic Configuration 
    - Disabling Windows Firewall to open VM to traffic:
      * Test the machine by pinging its IP address with `ping [public IP of your machine] -t` which should timeout.
      * If pinging times out, this indicates the Windows firewall is enabled and will have to be disabled to expose the machine to the public internet.
      * Disable firewall by going to Windows Defender Firewall Properties and turning off Domain, Public, and Private profile firewalls. You should be able to continuously ping the VM.
      * `netsh advfirewall show allprofiles` to show firewall status.
      * `netsh advfirewall set allprofiles state off` to set all firewall profiles off.
        
      ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/disable_fw.png)
      
    ## Integrating PowerShell Transform Logs w/ Log Analytics & Sentinel 
    - Download the Custom Log Exporter PowerShell file, [failed_logins_script.ps1](https://github.com/aele1401/Azure-Honeypot/blob/main/Scripts/failed_logins_script.ps1) file, and open it in PowerShell ISE on the honeypot VM.
    - In the PowerShell script, a filter will be used to filter failed RDP events from Windows Event Viewer.
    - In Windows Event Viewer, Event ID 4625 correlates to a logon failure so a query for 4625 will be created. Included is a function that creates a bunch of sample log files that will be used to train the Extract feature in Log Analytics workspace. If you don't have enough log files to "train" it, it will fail to extract certain fields for some reason -_-. We can avoid including these fake records on our map by filtering out all logs with a destination host of "samplehost." Script also includes an infinite loop that keeps checking the Event Viewer logs.
      
    ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/cle.png)

    - Edit the PowerShell file to inculde your API key from IPGEOLOCATION to obtain geographical information about the Source Host IP addresses collected.
    - Run the PS script and it should look like this:

     ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/ps_script.png)
    
    ## Creating Custom Logs, Querying w/ KQL, and Heat Map
    - Create a custom log in Log Analytics Workspace to bring in the custom log that includes the geodata that's collected:
      * When creating the custom log, upload a copy of the log file (ps1 file in honeypot VM), to help train Log Analytics what to look for in the log files.
    - Test the custom log by running it in Log Analytics Workspace. You should see log entries populate.
    - You can query the logs using KQL.
    - Looking at the logs, we can see the raw data as an output.
    - Extract and parse the raw data into fields like IP Address, Destination Host, and so forth.
    - To extract and parse the data, open Azure Sentinel and add the created query above include map as visualization and adjust settings and parameters accordingly.
  * Examining Attacks in Azure Sentinel:
    - After setting up Azure Sentinel with the custom logs, query, and map, you should be able to see live attacks from around the world. The longer the VM is exposed the more discoverable it is and the more attackers who will attempt a brute force attack.

     ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/final_map.png)

## Attacks & Mitigation
We can see most of the attacks are coming in from Russia. To migitate this attack, we can implement:
- Network-Based Mitigations:
  * Geo-blocking - We can IP block by region by configuring firewalls or web servers to block IP addresses from specific countries known for attacks. This can be done using tools like iptables, firewalld, or cloud-based solutions like Cloudflare.
  * Rate Limiting - Limit login attempts by implementing rate limiting on login endpoints to restrict the number of login attempts from a single IP address within a certain time frame.
  * Intrusion Detection and Prevention Systems (IDPS) - Use an IDPS to detect and block suspicious activities in real-time. Tools like Snort, Suricata, or cloud-based solutions can help monitor and prevent brute force attempts.
  * Traffic Filtering - Use a WAF to filter and monitor HTTP requests and block malicious traffic. Cloud-based WAF services (e.g., AWS WAF, Azure WAF) are highly effective.
- Application-Based Mitigations:
  * Strong Authentication:
    - Multi-Factor Authentication (MFA) - Require MFA for all user accounts to add an additional layer of security beyond just passwords.
    - Complex Password Policies - Enforce strong password policies requiring complex passwords that are harder to guess or crack.
  * Account Lockout Mechanisms - Implement temporary account lockout mechanisms after a set number of failed login attempts. Ensure this period is long enough to slow down brute force attacks but short enough to avoid user inconvenience.
  * Captcha - Add CAPTCHA challenges to login forms to differentiate between automated bots and legitimate users.
- Monitoring & Response:
  * Log Monitoring:
    - Real-time Log Analysis - Continuously monitor logs for unusual activity and failed login attempts. Use SIEM (Security Information and Event Management) systems like Splunk or ELK Stack for centralized log management and analysis.
  * Alerting and Notifications - Configure alerts for abnormal login patterns or repeated failed login attempts. Ensure your IT team is notified immediately to respond to potential threats.
- Best Practices:
  * Regular Updates and Patching - Regularly update and patch your systems and applications to protect against known vulnerabilities that can be exploited during brute force attacks.
  * User Education and Training - Train users on recognizing phishing attempts and using strong, unique passwords for their accounts.
  * Access Control - Implement the principle of least privilege by restricting access rights for users to only what is necessary for their role.
- Here's an example of blocking IPs from a specific country using iptables as a defense in depth concept:

![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/example_config.png)


  

    

