# Core module of my ansible playbook structure

A set of playbooks to maintain our servers.

## How to run a play

```bash
Usage:
  ./tools/run_playbook.sh <-p path/to/playbook> [-l <limit>] [--install-requirements] [-b]

	-p,	--playbook
			Path to playbook directory, relative to repo root
	-l,	--limit
			Limit playboot to specific hosts or groups
			e.g.: "-l host0,host1,group0,group1"
	-b,	--bootstrap
			Bootstrap Server. This is for Server where the base role was never executed on.
		--install-requirements
			Install ansible-galaxy requirements
```

## Plabook structure

[![plabook structure and dependencies][nomnomlimg]][nomnoml]

```
#titel: nomnoml

#direction: right
#.play: visual=note
#.dir: fill=#878787 stroke=#f2f2f2 dashed
#.roleapp: fill=#eb4034
#.rolesystem: fill=#c2c2c2

[<dir> playbook]

[<package> playbook/inventory|
  - host
]

[<play> playbook/bootstrap.yml]
[<play> playbook/upgrade.yml]
[<play> playbook/plabook.yml]

[<rolesystem> system.base]
[<rolesystem> system.base.x86_64_server]

[system.base.x86_64_server]-->[system.base]

[<roleapp> app.role]

[playbook/inventory]-[playbook]
[playbook]->[playbook/bootstrap.yml]
[playbook]->[playbook/upgrade.yml]
[playbook/bootstrap.yml]->[playbook/plabook.yml]
[playbook/upgrade.yml]->[playbook/plabook.yml]
[playbook/plabook.yml]->[system.base.x86_64_server]
[playbook/plabook.yml]->[app.role]
```

## Role naming scheme

```
          Role which will install/configure a/n program/app.
          |
username.<app|system>.role_name
              |
              Role which will configure the system.
```

## Useful commands

### Encrypt variables with Ansible Vault

```bash
ansible-vault encrypt_string --vault-id @prompt 'string_to_encrypt' --name 'the_secret'
```

### Encrypt files with Ansible Vault

```bash
ansible-vault encrypt <file>
```

### Debug a variable

```yaml
- name: debug
  ansible.builtin.debug:
    var: variable_to_debug
```

### End playbook here

```yml
- ansible.builtin.meta: end_play
```

### pre requiements

Install requirements from ansible galaxy:  
```bash
ansible-galaxy install -r "./requirements.yml"
```

### Run a playbook with ansible vault

```bash
ansible-playbook --vault-id @prompt -i ./inventory ./[bootstrap|site].yml
```

### Run a playbook with ansible vault but limit a specific host

```bash
ansible-playbook --vault-id @prompt -i ./inventory --limit <inventory_name_of_host_or_name_of_group> ./[bootstrap|site].yml
```

## Upload folder via rsync to server

```bash
rsync -avzh ../playbooks user@host.tld:~/
```

## Known issues

### python fork bug

#### Bug
  
```
objc[53614]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called.
objc[53614]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
```

#### Fix

```bash
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
```

[nomnoml]: https://www.nomnoml.com/#view/%23titel%3A%20nomnoml%0A%0A%23direction%3A%20right%0A%23.play%3A%20visual%3Dnote%0A%23.dir%3A%20fill%3D%23878787%20stroke%3D%23f2f2f2%20dashed%0A%23.roleapp%3A%20fill%3D%23eb4034%0A%23.rolesystem%3A%20fill%3D%23c2c2c2%0A%0A%5B%3Cdir%3E%20playbook%5D%0A%0A%5B%3Cpackage%3E%20playbook%2Finventory%7C%0A%20%20-%20host%0A%5D%0A%0A%5B%3Cplay%3E%20playbook%2Fbootstrap.yml%5D%0A%5B%3Cplay%3E%20playbook%2Fupgrade.yml%5D%0A%5B%3Cplay%3E%20playbook%2Fplabook.yml%5D%0A%0A%5B%3Crolesystem%3E%20system.base%5D%0A%5B%3Crolesystem%3E%20system.base.x86_64_server%5D%0A%0A%5Bsystem.base.x86_64_server%5D--%3E%5Bsystem.base%5D%0A%0A%5B%3Croleapp%3E%20app.role%5D%0A%0A%5Bplaybook%2Finventory%5D-%5Bplaybook%5D%0A%5Bplaybook%5D-%3E%5Bplaybook%2Fbootstrap.yml%5D%0A%5Bplaybook%5D-%3E%5Bplaybook%2Fupgrade.yml%5D%0A%5Bplaybook%2Fbootstrap.yml%5D-%3E%5Bplaybook%2Fplabook.yml%5D%0A%5Bplaybook%2Fupgrade.yml%5D-%3E%5Bplaybook%2Fplabook.yml%5D%0A%5Bplaybook%2Fplabook.yml%5D-%3E%5Bsystem.base.x86_64_server%5D%0A%5Bplaybook%2Fplabook.yml%5D-%3E%5Bapp.role%5D
[nomnomlimg]: ./nomnoml.svg
