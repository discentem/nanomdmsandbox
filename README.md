## Run Salt

## Linux 

### Sync files

```
rsync -e "ssh -i ~/.ssh/do" -r ~/nanomdmsandbox/salt/* root@SERVER_IP:/srv
```

```shell
sudo salt-call --local state.apply
```

## macOS

From root of this project:

```shell
sudo salt-call --local state.apply --file-root salt/salt --pillar-root salt/pillar --log-level info -c ${PWD}/salt
```

# Micromdm architecture

- micromdm binary. Provides TLS + SCEP + mdm server API.
    - when devices check-in or have some other event, micromdm sends these events to it's own webhook.
    - Some other service (such as mdmdirector) can listen to the webhook and take actions based on the events.

# Nano Architecture

- nanomdm binary. Provides only an mdm server API.
    - when devices check-in or have some other event, nanomdm sends these events to its own webhook.
    - some other service can listen to the webhook and take actions based on the events.
- You need to bring your own TLS via reverse proxy/load balancer
