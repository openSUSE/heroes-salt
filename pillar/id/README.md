A few words about the files in this directory.

Please note the template below contains some remarks behind the tags to help
you to setup everything correctly from the start.

Just note that we use the ```[]``` here to show that you should leave them
if there is nothing to put into that tag. Just the comments behind ```##```

```
grains:
  country: de              ## The country of the machine.
  hostusage: []            ## This will end up in the bash prompt (comma separated values).
                           ## Please keep this short to avoid long lines on the machine.
  roles: []                ## This corresponds to pillar/role/$role.sls and salt/role/$role.sls.
                           ## Both files have to exist because Salt will try to include them!
  reboot_safe: yes         ## Could anyone simply reboot the machine and everything comes back as expected?
  ## Everything below here is primarily ment for humans.
  aliases: []              ## Mostly used for DNS aliases at the moment.
  description: you name it ## A short description that gives other admins an idea about the
                           ## main usecase of the machine.
  documentation: []        ## Links to additional documentation about the machine and the services
                           ## running on it.
                           ## Everything that is helpful in case the machine/ service is down.
  responsible: []          ## logins from the main admins of the machine - please use FreeIPA logins here!
  partners: []             ## In case of HA-clusters, please name the partner machines.
  weburls: []              ## Name the URLs the machine is reachable from extern.
```
