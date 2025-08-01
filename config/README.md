# MTA Server Configuration Folder

This folder contains the core configuration files for your Multi Theft Auto (MTA) server. These files control server settings, permissions, resources, and other critical aspects of your server's operation.

## 📁 File Descriptions

### `mtaserver.conf`
- **Purpose**: Main server configuration file
- **Key Settings**:
  - Server name, password, and port
  - Maximum player slots
  - Server visibility (master list settings)
  - HTTP server configuration
  - Resource auto-start settings
  - Network settings (bandwidth limits, etc.)
- **Editing**: Modify with a text editor. Requires server restart to apply changes.

### `acl.xml`
- **Purpose**: Access Control List (ACL) for permissions management
- **Controls**:
  - User and group permissions
  - Resource access rights
  - Command execution privileges
- **Security**: Critical file - incorrect configuration may cause security issues
- **Editing**: Use MTA's admin panel for safer modifications, or edit manually with caution.

### `broker.xml`
- **Purpose**: Configuration for the MTA broker service (if used)
- **Features**:
  - Cross-server communication settings
  - Cluster management options
- **Note**: Only required if using broker functionality.

### `internal.db`
- **Purpose**: SQLite database for internal server data
- **Stores**:
  - User accounts
  - Server settings
  - Resource statistics
- **Editing**: Use SQLite database tools (e.g., DB Browser for SQLite)
- **Backup**: Regularly back up this file to prevent data loss.

### `banlist.xml`
- **Purpose**: Stores banned player information
- **Contains**:
  - Banned IP addresses
  - Banned serial numbers
  - Ban durations and reasons
- **Management**: Use the `ban` and `unban` commands in-game or via console.

### `vehiclecolors.conf`
- **Purpose**: Defines vehicle color combinations
- **Usage**: Determines available colors when spawning vehicles
- **Editing**: Modify color values in RGB format.

## 🔧 Configuration Guidelines

1. **Back Up First**
   - Always create backups before editing configuration files
   - Store backups outside the server directory

2. **Editing Files**
   - Use a plain text editor (Notepad++, VS Code, Sublime Text)
   - Avoid word processors (Microsoft Word, etc.)
   - Preserve XML formatting and syntax

3. **Server Restart**
   - Most changes require a server restart to take effect
   - Use `refresh` and `restart` commands for resource-specific changes

4. **Security Best Practices**
   - Restrict file permissions to server administrators only
   - Use strong passwords in `mtaserver.conf`
   - Regularly review `acl.xml` permissions
   - Keep server software updated

## ⚠️ Important Notes

- **Case Sensitivity**: File names are case-sensitive on Linux servers
- **Resource Conflicts**: Incorrect settings may prevent resources from starting
- **Validation**: Server validates configuration files on startup - check console for errors
- **Documentation**: Refer to the [official MTA wiki](https://wiki.multitheftauto.com/) for detailed parameter explanations

## 📚 Additional Resources

- [MTA Server Configuration Guide](https://wiki.multitheftauto.com/wiki/Server_mtaserver.conf)
- [ACL Configuration Tutorial](https://wiki.multitheftauto.com/wiki/Acl)
- [Troubleshooting Common Issues](https://wiki.multitheftauto.com/wiki/Server_Troubleshooting)

For support, visit the [MTA Community Forums](https://forum.mtasa.com/).

---

**Remember**: Test configuration changes in a development environment before applying to production servers. Incorrect settings may cause server instability or security vulnerabilities.
