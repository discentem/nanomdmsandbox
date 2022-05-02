## Run Salt

From the root of `nanomdmsandbox`

```shell
sudo salt-call --local state.apply --file-root salt/salt --pillar-root salt/pillar --log-level trace -c ${PWD}/salt
```