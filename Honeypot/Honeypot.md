# Azure-Sentinel

This project utilizes Azure and Sentinel for a low-interaction honeypot project designed to attract, detect, and analyze malicious activities by setting up a decoy system and network resource. This decoy mimics a vulnerable server exposed to the public internet, to lure attackers and study their methods and behavior. Here are the key aspects of this project:
  * Setting up decoy system: this is the configuration and deployment of systems and resources intentionally made to appear as appealing targets for cyber attackers. This can be servers, databases, IoT devices, or any other networked device.
  * Monitoring and logging: honeypots are equipped with extensive monitoring tools to log all interactions. This helps cybersecurity experts understand attack vectors, methods, tools, and behaviors of the attackers.
  * Research and analysis: data collected from honeypots are analyzed to gain insights into the latest threats and attack patterns. This information is crucial for developing better defensive strategies and improving cybersecurity protocols.

Types of Honeypots:
  * Low-Interaction Honeypots: simulate only basic services and are primarily used to collect information about automated attacks like worms or bots. They are easier to set up and manage but provide limited interaction data.
  * High-Interaction Honeypots: fully functional systems that provide a real operating environment for attackers. They offer deeper insights but come with higher risks and require more resources to maintain.

  ## Azure Deployment
  ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/network_diagram.png)

  ## VM Configuration & Deployment
  
  Setup and configure VM with:
   - Resource group
   - VM name
   - Region
   - Availability & Redundancy
   - Security Type
   - Image
   - Size
   - Username & Password
    

    |     Name    |    Function  |   IP Address   |  Operating System |
    |-------------|--------------|----------------|-------------------|
    | Honeypot-vm |     Decoy    |  00.000.000.00 |     Windows 10    |

   ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/vm_creation.png)
  
  Access Policies & Firewall Rules:
   * Create a network security group.
   * Delete the defaults.
   * Create a new inbound rule allowing any source, port range, destination, protocol, and low priority of 100 to expose the machine to the public internet.

    |     Name    | Publicly Accessible | Allowed IP Addresses |
    |-------------|---------------------|----------------------|
    | Honeypot-vm |         Yes         |        All           |

   ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/firewall_rule.png)

  ## Log Analytics Workspace

  * Enabling Log Collection in Security Center:
    - Create a Log Analytics Workspace to ingest VM logs and enable collection.
      
    ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/law_creation.png)
    
  * Connect the Log Analytics Workspace to the VM.
  
  ## Sentinel

  * Setting up Azure Sentiinel:
    - Create Azure Sentinel Workspace and connect it to the Log Analytics Workspace.
    - Log into the honeypot VM using the public IP and remote desktop.
    - Observe events in Windows Event Viewer:
      * Test Event Viewer with an incorrect login to honeypot VM to ensure everything is working.
    - Disabling Windows Firewall to open VM to traffic:
      * Test the machine by pinging its IP address with `ping [public IP of your machine] -t` which should timeout. This indicates the Windows firewall is enabled.
      * Disable firewall by going to Windows Defender Firewall Properties and turning off Domain, Public, and Private profile firewalls. You should be able to continously ping the VM.
        
      ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/disable_fw.png)
      
    - Download the Custom Log Exporter PowerShell file and open it in PowerShell ISE on the honeypot VM.
      
    ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/cle.png)

    - Edit the PowerShell file to inculde your API key from IPGEOLOCATION to obtain geographical information about the Source Host IP addresses collected.
    - Run the PS script and it should look like this:

     ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/ps_script.png)
    
    - Create a custom log in Log Analytics Workspace to bring in the custom log that includes the geodata that's collected:
      * When creating the custom log, upload a copy of the log file (ps1 file in honeypot VM), to help train Log Analytics what to look for in the log files.
    - Test the custom log by running it in LAW. You should see log entries populate.
    - You can query the logs using KQL
    - Looking at the logs, we can see the raw data as an output.
    - Extract and parse the raw data into fields like IP Address, Destination Host, and so forth.
    - To extract and parse the data, open Azure Sentinel and add the created query above include map as visualization and adjust settings and parameters accordingly.
  * Examining Attacks in Azure Sentinel:
    - After setting up Azure Sentinel with the custom logs and query, you should be able to see live attacks from around the world. The longer the VM is exposed the more discoverable it is and the more attackers who will attempt a brute force attack.

     ![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/final_map.png)

We can see most of the attacks are coming in from Russia. To migitate this attack, we can:
- Network-Based Mitigations:
  * Geo-blocking: IP Blocking by Region: configure your firewall or web server to block IP addresses from specific countries known for the attacks. This can be done using tools like iptables, firewalld, or cloud-based solutions like Cloudflare.
  * Rate Limiting: Limit Login Attempts: implement rate limiting on login endpoints to restrict the number of login attempts from a single IP address within a certain time frame.
  * Intrusion Detection and Prevention Systems (IDPS): use an IDPS to detect and block suspicious activities in real-time. Tools like Snort, Suricata, or cloud-based solutions can help monitor and prevent brute force attempts.
  * Traffic Filtering: use a WAF to filter and monitor HTTP requests and block malicious traffic. Cloud-based WAF services (e.g., AWS WAF, Azure WAF) are highly effective.
- Application-Based Mitigations:
  * Strong Authentication:
   - Multi-Factor Authentication (MFA): Require MFA for all user accounts to add an additional layer of security beyond just passwords.
   - Complex Password Policies: Enforce strong password policies requiring complex passwords that are harder to guess or crack.
  * Account Lockout Mechanisms: Implement temporary account lockout mechanisms after a set number of failed login attempts. Ensure this period is long enough to slow down brute force attacks but short enough to avoid user inconvenience.
  * Captcha: Add CAPTCHA challenges to login forms to differentiate between automated bots and legitimate users.
- Monitoring & Response:
  * Log Monitoring: Real-time Log Analysis: Continuously monitor logs for unusual activity and failed login attempts. Use SIEM (Security Information and Event Management) systems like Splunk or ELK Stack for centralized log management and analysis.
  * Alerting and Notifications: Configure alerts for abnormal login patterns or repeated failed login attempts. Ensure your IT team is notified immediately to respond to potential threats.
- Best Practices:
  * Regular Updates and Patching: Regularly update and patch your systems and applications to protect against known vulnerabilities that can be exploited during brute force attacks.
  * User Education and Training: Train users on recognizing phishing attempts and using strong, unique passwords for their accounts.
  * Access Control: Implement the principle of least privilege by restricting access rights for users to only what is necessary for their role.
- Here's an example of blocking IPs from a specific country using iptables as a defense in depth concept:

![Diagram](https://github.com/aele1401/Azure-Sentinel/blob/main/Images/example_config.png)


  

    
