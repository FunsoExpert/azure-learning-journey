# E-Commerce Architecture Diagram
Internet (HTTPS)
│
▼
┌─────────────────────────────────────────┐
│ Application Gateway (WAF_v2) │
│ - SSL Termination │
│ - Path-based routing: /api/* → API │
│ - WAF Prevention Mode (OWASP 3.2) │
└─────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────┐
│ Hub VNet (10.0.0.0/16) │
│ ┌─────────────────────────────────┐ │
│ │ Azure Firewall (Standard) │ │
│ │ - Network rules │ │
│ │ - Application rules (FQDN) │ │
│ └─────────────────────────────────┘ │
│ │
│ VNet Peering │
│ │ │
└─────┼───────────────────────────────────┘
│
▼
┌─────────────────────────────────────────┐
│ Spoke VNet (10.1.0.0/16) │
│ ┌─────────────────────────────────┐ │
│ │ App Service Plan │ │
│ │ ├── Frontend (Node.js) │ │
│ │ └── API (Node.js) │ │
│ └─────────────────────────────────┘ │
│ │
│ ┌─────────────────────────────────┐ │
│ │ Azure SQL Database │ │
│ │ - Serverless tier │ │
│ │ - Geo-redundant backup │ │
│ └─────────────────────────────────┘ │
│ │
│ ┌─────────────────────────────────┐ │
│ │ Storage Account │ │
│ │ - Blob: product images │ │
│ │ - Queue: order processing │ │
│ └─────────────────────────────────┘ │
│ │
│ ┌─────────────────────────────────┐ │
│ │ Azure Key Vault │ │
│ │ - Connection strings │ │
│ │ - API keys │ │
│ │ - SSL certificates │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────────┘