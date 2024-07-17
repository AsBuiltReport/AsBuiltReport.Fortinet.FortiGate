# :arrows_clockwise: Fortinet FortiGate As Built Report Changelog

## [0.4.1] - 2024-07-17

### Fixed
- Fix FortiCare with PowerShell 5.0 [87](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/87)

## [0.4.0] - 2024-07-15

### Added
- Add DHCP Server (Reservation, Leases...) [82](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/82)
- FortiCare: Add information about FortiGuard Services [78](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/78)
- Add System HA (Configuration and Members) info [79](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/79)

### Changed
- Firewall: display number of rules with comment contain Copy, Clone... [75](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/75)
- Add ISDB support for Policy Source & Destination [77](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/77)
- Invoke: Add Name and Serial of all members on top of report [81](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/81)

### Fixed
- samples: fix empty samples... [71](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/71)
- Route: Fix when Static Route is SD-WAN (Zone) [76](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/76)
- Fix typo found on System Chapiter [80](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/80)

## [0.3.0] - 2024-02-29

### Added
- Add Policy summary (number of policy, comments, nat...) [67](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/67)
- Add SD-WAN Chapiter (Configuration, Members, Rules...) [#59](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/59)
- Add Firewall Address/AddressGroup/IP Pool/Virtual reference [#56](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/56)

### Changed
- Enhance Policy layout (normal, interface pair, sequence grouping) [66](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/66)
- Route(Static): Enhance display when using Blackhole, ISDB... [#58](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/58)
- Route(monitor): fix when there is Blackhole on Route Monitor [#57](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/57)

### Fixed
- Fix forticare: don't check BranchUpdateVersion [64](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/64)

## [0.2.2] - 2023-10-03

- Interface(System): Fix if when no interface is specified [#53](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/53)

## [0.2.1] - 2023-08-21

### Fixed

- VPN SSL: VPN(SSL): fix ColumnWidths for Portal Summary [#35](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/35) And Users [#48](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/48)
- SAML(User): Don't get when use old Fortigate release (< 6.2.0) [#36](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/36)
- VDOM options - Interfaces  [#44](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/issues/44)

## [0.2.0] - 2023-05-17

- User: Add SAML Table [#23](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/23)
- VDOM: Add the possibility to realize same export for a VDOM [#25](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/25) - Fixes [#20](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/issues/20)
- VPN: Add VPN IPsec Table (Phase1/Phase 2) [#26](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/26) - Fixes [#21](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/issues/21)
- VPN: Add VPN SSL Table [#30](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/30) - Fixes [#21](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/issues/21)
- User: Enhance RADIUS and LDAP Table (add SubLevel) [#28](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/28)
- SubLevel: only use 1 and 2 Sublevel with not sub category/options [#27]https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/27

## [0.1.1] - 2022-09-20

### Fixed

- Connection: Add Options for custom Port [#16](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/16) - Fixes [#15](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/issues/15)
- FortiCare: add Try/Catch for Firmware Upgrade Paths [#17](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/17) - Fixes [#14](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/issues/14)

## [0.1.0] - 2022-07-31

- Initial Release with support of FortiCare, System, Route, Firewall and User
