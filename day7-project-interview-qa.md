# Day 7 Interview Q&As: E-Commerce Architecture

## Q1: Walk me through how you'd design a secure, scalable e-commerce platform on Azure.

**A:** "I'd start with a hub-spoke architecture for security. The hub contains the Azure Firewall for centralized logging and filtering. The spoke contains the workloads. For ingress, I'd use Application Gateway with WAF (Prevention mode) for SSL termination, DDoS protection, and path-based routing. The frontend is a static web app served from App Service, and the API is a separate App Service. For the database, I'd use Azure SQL Database with geo-redundant backups and point-in-time restore. For storage, I'd use Azure Blob Storage with a CDN for product images. All secrets are stored in Key Vault with Managed Identity for access. Monitoring is done with Application Insights and Log Analytics with alerts for high CPU, errors, and health probe failures."

## Q2: How would you handle a spike in traffic?

**A:** "I'd configure autoscale on the App Service plan based on CPU or memory. I'd also set up health probes on Application Gateway to remove unhealthy instances from rotation. For the database, I'd use serverless SQL to automatically scale compute. If traffic is predictable, I'd schedule scaling rules for peak hours."

## Q3: How would you secure the database?

**A:** "Firewall rules to only allow traffic from the App Service IPs. I'd also use Managed Identity for authentication (no passwords in code). The connection string is stored in Key Vault and accessed via Managed Identity. I'd enable auditing and threat detection on the SQL server. For backups, I'd use geo-redundant backups with 7-day retention."

## Q4: How would you ensure high availability?

**A:** "Deploy App Service across multiple availability zones (3 zones if possible). Use Application Gateway with 2+ instances. Enable geo-redundant backups for SQL and Storage. Set up Application Insights availability tests to monitor from multiple locations. If a region fails, manually failover the database and repoint traffic to a secondary region."

## Q5: What would you monitor and alert on?

**A:** "I'd monitor CPU, memory, request count, response times (p95), 5xx error rates, and health probe failures. Alerts would trigger for: CPU > 80% for 5 minutes, error rate > 5% for 10 minutes, health probe failure, and any attack detected by WAF. I'd also monitor costs to avoid budget overruns."

## Q6: What would you do if Application Gateway health probes were failing?

**A:** "First, check if the backend is actually healthy. Then check the probe configuration - path, port, interval, threshold. I'd also check if the App Service is responding correctly with a 200 OK on /health. If the backend takes 30+ seconds to start, I'd adjust the probe interval or threshold. Finally, I'd check NSG rules to ensure App Gateway can reach the backend IP."

## Q7: You mention Key Vault - how does App Service access it?

**A:** "I'd enable System-assigned Managed Identity on the App Service. Then grant the identity `Get` and `List` permissions on the Key Vault via RBAC or access policies. The application code uses the default credential to authenticate. No secrets are stored in code or configuration files."

## Q8: How do you handle SSL certificate renewal?

**A:** "Using Key Vault with auto-renewal. The certificate is stored in Key Vault and assigned to Application Gateway. Key Vault can renew certificates automatically if they're from an integrated CA. I'd also set up alerts for certificate expiry 30 days before renewal."

## Q9: What's the difference between App Service and VMs for this architecture?

**A:** "App Service is easier to manage - no OS patches, built-in scaling, integrated logging. VMs give more control but require more management. For a standard e-commerce app with predictable traffic, App Service is the right choice. If we needed specific OS extensions or custom networking, I'd consider VMs."

## Q10: How would you estimate costs?

**A:** "I'd use the Azure Pricing Calculator. Key cost drivers are: App Service Plan (P1v2), Application Gateway (WAF_v2), Azure SQL (Serverless GP), Storage (GRS), and Firewall (Standard). I'd estimate about $600/month for the architecture I described, but I'd confirm with the calculator and adjust based on actual workload."

## Q11: How would you handle CI/CD?

**A:** "I'd use GitHub Actions or Azure DevOps for CI/CD. The pipeline would: build the frontend and API, run tests, deploy to a staging slot, run integration tests, then swap to production. I'd also add infrastructure-as-code (Bicep) deployment to the pipeline to ensure infrastructure is in sync with application code."

## Q12: What would you include in the disaster recovery plan?

**A:** "RTO (Recovery Time Objective): 4 hours. RPO (Recovery Point Objective): 1 hour. Backups: SQL database restored from geo-redundant backup, Storage Account restored from LRS/GRS, App Service deployment from GitHub branch. Playbook: document step-by-step restore procedure, test quarterly, use automation where possible."