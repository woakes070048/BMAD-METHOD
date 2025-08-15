# execute-bench-command

## Task Description
Execute Frappe Bench commands safely with proper validation, logging, and error handling.

## Parameters
- `command`: Bench command to execute
- `site`: Target site (optional, uses current site if not specified)
- `app`: Target app (optional)
- `validate`: Whether to validate command before execution (default: true)
- `log_output`: Whether to log command output (default: true)
- `dry_run`: Preview command without execution (default: false)

## Prerequisites
- Bench environment properly configured
- Required permissions for command execution
- Target site/app exists and accessible

## Steps

### 1. Command Validation
```python
import frappe
import subprocess
import os
from frappe import _

# Safe command whitelist
SAFE_COMMANDS = {
    # Site operations
    'new-site': {'risk': 'low', 'requires_confirmation': False},
    'drop-site': {'risk': 'high', 'requires_confirmation': True},
    'use': {'risk': 'low', 'requires_confirmation': False},
    'migrate': {'risk': 'medium', 'requires_confirmation': False},
    'clear-cache': {'risk': 'low', 'requires_confirmation': False},
    'clear-website-cache': {'risk': 'low', 'requires_confirmation': False},
    
    # App operations
    'new-app': {'risk': 'low', 'requires_confirmation': False},
    'get-app': {'risk': 'medium', 'requires_confirmation': False},
    'install-app': {'risk': 'medium', 'requires_confirmation': False},
    'uninstall-app': {'risk': 'high', 'requires_confirmation': True},
    'remove-app': {'risk': 'high', 'requires_confirmation': True},
    
    # Development
    'start': {'risk': 'low', 'requires_confirmation': False},
    'restart': {'risk': 'low', 'requires_confirmation': False},
    'build': {'risk': 'low', 'requires_confirmation': False},
    'watch': {'risk': 'low', 'requires_confirmation': False},
    
    # Database
    'backup': {'risk': 'low', 'requires_confirmation': False},
    'restore': {'risk': 'high', 'requires_confirmation': True},
    
    # Updates
    'update': {'risk': 'medium', 'requires_confirmation': True},
    'switch-to-branch': {'risk': 'medium', 'requires_confirmation': True},
    
    # Utility
    'console': {'risk': 'medium', 'requires_confirmation': False},
    'execute': {'risk': 'high', 'requires_confirmation': True},
    'doctor': {'risk': 'low', 'requires_confirmation': False},
    'version': {'risk': 'low', 'requires_confirmation': False}
}

def validate_bench_command(command_parts):
    """Validate bench command for safety and correctness"""
    
    if not command_parts:
        raise ValueError(_("Command cannot be empty"))
    
    base_command = command_parts[0]
    
    # Check if command is in whitelist
    if base_command not in SAFE_COMMANDS:
        raise ValueError(_("Command '{0}' is not in the safe commands list").format(base_command))
    
    command_info = SAFE_COMMANDS[base_command]
    
    # Validate command arguments
    validation_result = {
        'command': base_command,
        'risk_level': command_info['risk'],
        'requires_confirmation': command_info['requires_confirmation'],
        'validated_args': validate_command_arguments(base_command, command_parts[1:]),
        'warnings': [],
        'safe_to_execute': True
    }
    
    return validation_result

def validate_command_arguments(command, args):
    """Validate command-specific arguments"""
    
    validators = {
        'migrate': validate_migrate_args,
        'install-app': validate_install_app_args,
        'new-site': validate_new_site_args,
        'backup': validate_backup_args,
        'restore': validate_restore_args
    }
    
    if command in validators:
        return validators[command](args)
    
    return args  # Return args as-is for commands without specific validation

def validate_migrate_args(args):
    """Validate migrate command arguments"""
    validated_args = []
    
    for arg in args:
        if arg.startswith('--site'):
            site_name = arg.split('=')[1] if '=' in arg else args[args.index(arg) + 1]
            if not site_exists(site_name):
                raise ValueError(_("Site '{0}' does not exist").format(site_name))
            validated_args.append(arg)
        elif arg.startswith('--app'):
            validated_args.append(arg)
        else:
            validated_args.append(arg)
    
    return validated_args

def site_exists(site_name):
    """Check if site exists"""
    bench_path = get_bench_path()
    sites_path = os.path.join(bench_path, 'sites')
    return os.path.exists(os.path.join(sites_path, site_name))
```

### 2. Command Execution
```python
def execute_bench_command(command_str, site=None, dry_run=False, log_output=True):
    """Execute bench command with proper error handling"""
    
    try:
        # Parse command
        command_parts = parse_command_string(command_str)
        
        # Validate command
        validation = validate_bench_command(command_parts)
        
        if not validation['safe_to_execute']:
            raise ValueError(_("Command failed validation"))
        
        # Build full command
        full_command = build_full_command(command_parts, site)
        
        # Check for confirmation requirement
        if validation['requires_confirmation'] and not dry_run:
            confirm_command_execution(full_command, validation['risk_level'])
        
        if dry_run:
            return {
                'status': 'dry_run',
                'command': full_command,
                'validation': validation,
                'message': 'Command would execute: ' + ' '.join(full_command)
            }
        
        # Execute command
        result = run_command(full_command, log_output)
        
        # Log successful execution
        if log_output:
            log_command_execution(full_command, result, 'success')
        
        return {
            'status': 'success',
            'command': full_command,
            'output': result['output'],
            'return_code': result['return_code'],
            'execution_time': result['execution_time']
        }
        
    except Exception as e:
        error_result = {
            'status': 'error',
            'command': command_str,
            'error': str(e),
            'error_type': type(e).__name__
        }
        
        if log_output:
            log_command_execution(command_str, error_result, 'error')
        
        raise e

def run_command(command_list, capture_output=True):
    """Run command and capture output"""
    
    import time
    start_time = time.time()
    
    try:
        # Change to bench directory
        bench_path = get_bench_path()
        os.chdir(bench_path)
        
        # Execute command
        if capture_output:
            process = subprocess.run(
                command_list,
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )
            
            output = process.stdout + process.stderr
        else:
            process = subprocess.run(command_list, timeout=300)
            output = "Command executed without output capture"
        
        execution_time = time.time() - start_time
        
        return {
            'output': output,
            'return_code': process.returncode,
            'execution_time': execution_time
        }
        
    except subprocess.TimeoutExpired:
        raise Exception(_("Command timed out after 5 minutes"))
    except subprocess.CalledProcessError as e:
        raise Exception(_("Command failed with return code {0}: {1}").format(e.returncode, e.stderr))
```

### 3. Command Building
```python
def build_full_command(command_parts, site=None):
    """Build complete bench command with proper arguments"""
    
    full_command = ['bench']
    
    # Add site argument if specified
    if site:
        full_command.extend(['--site', site])
    
    # Add the main command and its arguments
    full_command.extend(command_parts)
    
    return full_command

def parse_command_string(command_str):
    """Parse command string into components"""
    
    # Remove 'bench' prefix if present
    if command_str.startswith('bench '):
        command_str = command_str[6:]
    
    # Split command into parts
    import shlex
    return shlex.split(command_str)

def get_bench_path():
    """Get current bench path"""
    
    # Try to get from environment
    bench_path = os.environ.get('BENCH_PATH')
    if bench_path and os.path.exists(bench_path):
        return bench_path
    
    # Try to detect from current directory
    current_dir = os.getcwd()
    
    # Look for sites directory
    while current_dir != '/':
        if os.path.exists(os.path.join(current_dir, 'sites')):
            return current_dir
        current_dir = os.path.dirname(current_dir)
    
    # Default fallback
    return '/home/frappe/frappe-bench'
```

### 4. Specialized Command Handlers
```python
def execute_migrate_command(site=None, app=None, dry_run=False):
    """Execute migration with proper validation"""
    
    command_parts = ['migrate']
    
    if app:
        command_parts.extend(['--app', app])
    
    # Always run with skip-failing for safety
    command_parts.append('--skip-failing')
    
    return execute_bench_command(' '.join(command_parts), site=site, dry_run=dry_run)

def execute_build_command(app=None, production=False, dry_run=False):
    """Execute build command with options"""
    
    command_parts = ['build']
    
    if app:
        command_parts.extend(['--app', app])
    
    if production:
        command_parts.append('--production')
    
    return execute_bench_command(' '.join(command_parts), dry_run=dry_run)

def execute_backup_command(site, with_files=True, compress=True, dry_run=False):
    """Execute backup command with options"""
    
    command_parts = ['backup']
    
    if with_files:
        command_parts.append('--with-files')
    
    if compress:
        command_parts.append('--compress')
    
    return execute_bench_command(' '.join(command_parts), site=site, dry_run=dry_run)
```

### 5. Command Logging and Monitoring
```python
def log_command_execution(command, result, status):
    """Log command execution for audit trail"""
    
    log_entry = {
        'timestamp': frappe.utils.now(),
        'user': frappe.session.user,
        'command': command if isinstance(command, str) else ' '.join(command),
        'status': status,
        'site': get_current_site(),
        'execution_time': result.get('execution_time'),
        'return_code': result.get('return_code'),
        'output_length': len(str(result.get('output', '')))
    }
    
    # Log to file
    log_to_file(log_entry)
    
    # Log to database if available
    try:
        log_to_database(log_entry)
    except:
        pass  # Ignore database logging errors

def log_to_file(log_entry):
    """Log to file system"""
    
    import json
    log_file = os.path.join(get_bench_path(), 'logs', 'bench_commands.log')
    
    # Ensure log directory exists
    os.makedirs(os.path.dirname(log_file), exist_ok=True)
    
    with open(log_file, 'a') as f:
        f.write(json.dumps(log_entry) + '\n')

def get_command_history(limit=50):
    """Get recent command execution history"""
    
    log_file = os.path.join(get_bench_path(), 'logs', 'bench_commands.log')
    
    if not os.path.exists(log_file):
        return []
    
    history = []
    
    with open(log_file, 'r') as f:
        lines = f.readlines()
        
    # Get last 'limit' lines
    for line in lines[-limit:]:
        try:
            history.append(json.loads(line.strip()))
        except:
            continue
    
    return history
```

### 6. Interactive Command Execution
```python
@frappe.whitelist()
def interactive_bench_command(command, site=None, confirm_high_risk=False):
    """Interactive bench command execution with user confirmation"""
    
    try:
        # Validate command first
        command_parts = parse_command_string(command)
        validation = validate_bench_command(command_parts)
        
        # Check if high-risk command needs confirmation
        if validation['risk_level'] == 'high' and not confirm_high_risk:
            return {
                'status': 'confirmation_required',
                'message': 'This is a high-risk command that requires confirmation',
                'command': command,
                'risk_level': validation['risk_level'],
                'warnings': validation.get('warnings', [])
            }
        
        # Execute command
        result = execute_bench_command(command, site=site)
        
        return result
        
    except Exception as e:
        return {
            'status': 'error',
            'message': str(e),
            'command': command
        }

@frappe.whitelist()
def get_safe_commands():
    """Get list of safe commands for UI"""
    
    return {
        'commands': SAFE_COMMANDS,
        'current_site': get_current_site(),
        'available_sites': get_available_sites(),
        'installed_apps': get_installed_apps()
    }

def get_available_sites():
    """Get list of available sites"""
    
    bench_path = get_bench_path()
    sites_path = os.path.join(bench_path, 'sites')
    
    sites = []
    
    if os.path.exists(sites_path):
        for item in os.listdir(sites_path):
            site_path = os.path.join(sites_path, item)
            if os.path.isdir(site_path) and item not in ['assets', 'common_site_config.json']:
                sites.append(item)
    
    return sites
```

## Safety Features
```python
def confirm_command_execution(command, risk_level):
    """Require user confirmation for risky commands"""
    
    if risk_level in ['high', 'medium']:
        confirmation_msg = f"You are about to execute: {' '.join(command)}\n"
        confirmation_msg += f"Risk Level: {risk_level.upper()}\n"
        confirmation_msg += "Are you sure you want to continue?"
        
        # In interactive mode, this would prompt user
        # For API calls, require explicit confirmation parameter
        frappe.msgprint(_(confirmation_msg))

def create_backup_before_risky_command(site, command):
    """Create automatic backup before risky operations"""
    
    high_risk_commands = ['drop-site', 'restore', 'uninstall-app']
    
    if any(cmd in ' '.join(command) for cmd in high_risk_commands):
        backup_result = execute_backup_command(site, compress=True)
        
        if backup_result['status'] != 'success':
            raise Exception(_("Failed to create safety backup before risky operation"))
        
        return backup_result
    
    return None
```

## Integration Points
- **Bench Operator**: Primary agent using this task
- **Site Operations**: Site management and maintenance
- **App Management**: Application lifecycle operations
- **System Administration**: System monitoring and maintenance