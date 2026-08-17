## MY E-COMMERCE MENTAL MAP

1. **User arrives** → **App Gateway** (SSL/WAF)  
2. **App Gateway routes:**  
   - `/api/*` → **App Service (API)**  
   - `/*` → **App Service (Web)**  
3. **App Services talk to:**  
   - **SQL Database** (data)  
   - **Storage Account** (images)  
   - **Key Vault** (secrets)  
4. **Everything is inside a Spoke VNet** → **Peered to Hub VNet**  
5. **Hub VNet has:**  
   - **Azure Firewall** (inspection/logging)  
   - **DDoS Protection**  
6. **Monitoring:**  
   - **App Insights** (performance)  
   - **Log Analytics** (central logs)  
   - **Alerts** (CPU > 80%, errors)