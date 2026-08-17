# DAY 8: VNET PEERING & VPN GATEWAY

**Date:** June 26, 2026
**Status:** ✅ COMPLETE
**Time Spent:** 2 hours

## What I Learned
- VNet Peering connects VNets via private Azure backbone
- VPN Gateway connects on-premises to Azure via IPSec
- Peering is not transitive (A-B + B-C ≠ A-C)
- Global Peering connects different regions
- GatewaySubnet must be exactly named
- RouteBased VPN is recommended

## Files Created
- day8-vnet-peering.bicep
- day8-log.md

## Next Steps (Day 9)
**Topic:** VPN Gateway & Site-to-Site VPN