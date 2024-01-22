# MultiGitConfig (mgc)

mgc is a command-line tool designed to manage multiple SSH and Git configurations. It simplifies working with different Git accounts, particularly useful for platforms like Bitbucket where multiple profiles might be necessary. With mgc, you can seamlessly switch between different SSH keys and Git user configurations, clone repositories using specific profiles, and manage these profiles effectively.


## Installation

To install mgc, clone this repository and add the mgc script to your path.

```bash
git clone https://github.com/kuskoman/mgc.git
cd mgc
export PATH=$PATH:$(pwd)/bin  # Consider adding this to your .bashrc or .bash_profile
```

## Usage

mgc supports various commands to manage your Git profiles:


### Creating a Profile

Create a new profile specifying an SSH key, email, and username. This profile stores your configuration which can be applied to repositories.

```bash
mgc create <profile_name> --ssh-key ~/.ssh/id_rsa_profileName --email user@example.com --username username
```

This command creates a new profile with the name `<profile_name>`. The SSH key path, email, and username are specified and stored as part of the profile.
Switching Profiles

Switch between SSH and Git configurations for different profiles. By default, mgc applies the profile to your current local repository. If no repository is detected, mgc will prompt to apply the profile globally.

```bash
mgc switch <profile_name> [--local | --global]
```

Use --global to apply the profile settings globally across all repositories. The --local flag enforces local scope, which is the default behavior.

### Cloning a Repository

Clone a repository using the SSH key from a specific profile. This command also sets the user email and name for the cloned repository based on the profile.

```bash
mgc clone <repository_url> <profile_name>
```

This command clones the repository at `<repository_url>` and configures it using the settings from `<profile_name>`.

### Listing Profiles

List all configured profiles. This is useful to see all your saved profiles.

```bash
mgc list
```

### Removing a Profile

Remove a profile if it's no longer needed. This action deletes the profile and its associated configurations.

```bash
mgc remove <profile_name>
```

### Help

For more detailed information on each command, you can use the help option:

```bash
mgc <command> --help
```

This will display usage instructions and examples for the specified command.
