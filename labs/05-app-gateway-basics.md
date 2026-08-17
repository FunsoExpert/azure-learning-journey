## 6 components used ---frontend to app gateway
* Front end IP, this could be private or public
* Listener, listens for traffic on port 443 eg protocol/port/hostname
* Rule, this connects listener to the back pool eg. if path is /api/*   then       backend api
* backend, where traffic ends
* HTTP setting, how to talk to backend
* Health probe, this runs every 30 secs for example

## ASCII diagram of how a request flows through App Gateway
[  PUBLIC INTERNET  ]
                |
                | (User Request: HTTPS /images)
                |
+---------------+---------------------+
|        [ Azure Application Gateway ]         |
|                                     |
|  1. Frontend IP (Public or Private) |
|          (Listens for Traffic)       |
|                |                    |
|  2. Listener (Port 443 / HTTPS)    |
|          (Handles SSL/TLS)          |
|                |                    |
|  3. Routing Rule (Path-based: /images) |
|          (Determines Action)        |
|                |                    |
|  4. WAF (Web Application Firewall)  |
|          (Inspects for Threats)     |
|          (Permitted Action)         |
|                |                    |
|  5. Backend HTTP Setting (Pool)     |
|          (Defines Routing Protocol) |
|                |                    |
+----------------+--------------------+
                |
                | (Traffic Directed)
                |
+---------------+---------------------+
|         [ Backend Pools ]           |
|                                     |
|  1. Images Pool (Correct Pool)     |
|    - [ Web VM 3 ] (Selected)       |
|    - [ Web VM 4 ]                   |
|                |                    |
|  2. API Pool (Ignored)              |
|    - [ API App 1 ]                 |
|    - [ API App 2 ]                 |
|                                     |
+-------------------------------------+
                |
                | (Request Processed)
                |
                v
       [ Web Server/App Serves Image ]




Internet
     ↓
[Application Gateway]
    ├── Frontend IP: 20.185.79.15
    ├── Listener: HTTPS / shop.com:443
    ├── Rule: Path-based routing
    │      ├── /api/* → Backend Pool A (API VMs)
    │      ├── /images/* → Backend Pool B (Image VMs)
    │      └── /* → Backend Pool C (Web VMs)
    ├── HTTP Setting: Backend port 8080, timeout 30s
    ├── Health Probe: GET /health every 30s
    └── WAF: Prevention mode (blocks SQL injection, XSS)
