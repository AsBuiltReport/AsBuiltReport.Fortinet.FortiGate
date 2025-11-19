# :arrows_clockwise: Fortinet FortiGate As Built Report Changelog

## [0.5.3] - Unreleased

### Added
- Add dependabot configuration
- Add bluesky-post-action to Release workflow
- Add dependency module version validation (Write-ReportModuleInfo)

### Changed
- Update to AsBuiltReport (1.5.1) Release
- Update Github Actions workflow (Release.yml, PSScriptAnalyzer.yml)
- Update module to v0.5.3

## [0.5.2] - 2025-11-19

### Added
- Add Alias description of interface on Route (Monitor & Static) [126](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/126)

### Fixed
- Fix Report when use Old FortiGate Release (Before 7.0.x) [125](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/125)

## [0.5.1] - 2025-06-27

### Fixed
- Update PowerFGT (0.9.1) and AsBuiltReport (1.4.3) Release [119](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/119)

## [0.5.0] - 2025-06-27

### Added
- Firewall: Add FQDN information [90](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/90)
- Firewall: Add Policy Usage [95](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/95)
- Enhance firewall address (unknown & mac) [94](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/94)
- Policy summary: Fix typo and add VPN SSL (from and to) [99](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/99)
- Refactor interfaces for better readability[101](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/101)
- Feature/ip cidr conversion [103](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/103)
- Add new firewall Address Type (Dynamic & Interface-subnet) [108](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/108)
- Add BGP (router) Chapiter(s) [109](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/109)
- Add Router OSPF Chapiter [114](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/114)

### Fixed
- System(DHCP Reservation): Fix when no DHCP reservation (with PS 5.0) [93](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/93)
- System(DHCP): Fix display of Expire Time when use PS5 [100](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/100)
- FortiCare: don't need to ToLower() FortiCare Account [106](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/106)
- Fix(Forticare): Avoid warning when don't Support by [107](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/107)
- vscode: align settings with Template/Core [111](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/111)
- vscode(Forticare): align settings with Template/Core by [112](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/112)
- Fix support ps5 (system) [113](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/113)
- FortiCare: excluse ot_detection Service by [115](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/115)
- System: dhcp lease with PS5 [116](https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate/pull/116)

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
