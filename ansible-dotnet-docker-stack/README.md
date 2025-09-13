# Ansible + Docker Compose: .NET Core app with Postgres/MySQL

This repo contains an Ansible playbook and roles to create (locally or on a remote host) a Docker Compose stack that runs:
- a .NET 8 minimal API (sample included)
- either **PostgreSQL** or **MySQL**

## Prerequisites
- Ansible 2.15+
- Python 3.10+
- (Optional) Docker Engine installed locally; otherwise the playbook can install it on Ubuntu/Debian.
- For remote hosts: SSH access and Python on the target.

## Quick start (local)
```bash
cd ansible-dotnet-docker-stack
ansible-galaxy collection install -r requirements.yml

# Run with defaults (Postgres)
ansible-playbook -i inventory.ini site.yml

# Or choose MySQL
ansible-playbook -i inventory.ini site.yml -e db_engine=mysql
```

Once finished:
- API: http://localhost:8080/
- Health: http://localhost:8080/health
- DB check: http://localhost:8080/db-check

### Switching DB ports or credentials
Edit `group_vars/all.yml` and change variables like `postgres_port`, `mysql_port`, `db_user`, `db_password`, `db_name`, etc.

### Remote host
Replace `inventory.ini` with your host(s), e.g.:
```
[web]
myserver ansible_host=10.0.0.5 ansible_user=ubuntu
```
Then run the same `ansible-playbook` command.

### Clean up
```bash
cd deploy
docker compose down -v
```

### Notes
- The role uses `community.docker.docker_compose_v2` to build and start the stack.
- The sample .NET minimal API exposes `/db-check` that tries to open a connection using `ConnectionStrings__DefaultConnection`.
