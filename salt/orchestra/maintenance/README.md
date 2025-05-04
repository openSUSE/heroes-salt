The `update-clusters` orchestration state is intended for semi-automatically updating machines with `reboot_safe: no` - typically clusters, but it does not limit itself to such. The preferred approach for non-clustered (`reboot_safe: yes`) machines is using the os-update service.

To invoke the state, visit a site-specific Salt Master. The state can so far not be used from the master of masters.

Example:

```
salt-run -linfo state.orch orchestra.maintenance.update-clusters saltenv=production pillar='{"waves": "galera"}'
```

Here, `galera` will cover all machines in the `galera` cluster.
The argument can alternatively be a list to cover multiple clusters.

Each cluster will be dissected into "waves" to ensure only one node in each cluster is updated at a time, while nodes from different clusters may run simultaneously.
After updating and rebooting all nodes in a wave, all systemd services must come back as healthy, otherwise the run will be aborted. Further, hooks are implemented to check the health of specific cluster services - run once before all waves, and once after each update and reboot in a wave - again, aborting the run on failure.

The logic should be maintained in a way that preferably aborts in any uncertain situation.

Currently the following roles are covered with check hooks:
- `mariadb`

The state should not be used for clusters/roles without designated hooks.
