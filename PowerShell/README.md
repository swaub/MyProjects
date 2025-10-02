# PowerShell Scripts

PowerShell scripts for Windows administration, automation, and system management.

## Categories

### [SystemTools](SystemTools/)
System administration and management utilities.

**Example projects:**
- System information collectors
- Event log analyzers
- Service managers
- Performance monitors

### [NetworkTools](NetworkTools/)
Network management and diagnostics.

**Example projects:**
- Port scanners
- Network inventory tools
- Connectivity testers
- DNS utilities

### [FileManagement](FileManagement/)
File system operations and management.

**Example projects:**
- Advanced file searches
- Bulk operations
- Permission managers
- Disk space analyzers

### [Automation](Automation/)
Automated tasks and workflows.

**Example projects:**
- Scheduled tasks
- Automated deployments
- Backup automation
- Report generators

### [ActiveDirectory](ActiveDirectory/)
Active Directory management scripts.

**Example projects:**
- User management
- Group operations
- AD reporting
- Permission auditing

## Best Practices

- Use approved verbs (Get, Set, New, Remove, etc.)
- Add help comments with `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`
- Include error handling with try/catch
- Test with `-WhatIf` when making changes
- Support pipeline input where appropriate
