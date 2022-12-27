# State module allowing to lock simultaneous executions - helpful in Orchestration states
# Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>

from pathlib import Path

def lock(name, path='/var/lib/salt/'):
    ret = {'name': name, 'result': False, 'changes': {}, 'comment': ''}
    lockfile = path + name
    if Path(lockfile).exists():
        if __opts__["test"]:
            ret["comment"] = "Would have complained about {0} already existing".format(lockfile)
            ret["result"] = None
        else:
            ret['comment'] = 'Lockfile {0} already exists'.format(lockfile)
        return(ret)
    if __opts__["test"]:
        ret["comment"] = "Lockfile {0} would have been created".format(lockfile)
        ret["result"] = None
        return(ret)
    try:
        Path(lockfile).touch(exist_ok=False)
    except FileExistsError as error:
        ret['comment'] = 'Failed to create lockfile {0}, it already exists'.format(lockfile)
        return(ret)
    except Exception as error:
        ret['comment'] = 'Failed to create lockfile {0}, error: {1}'.format(lockfile, error)
        return(ret)
    if Path(lockfile).exists():
        ret['comment'] = 'Lockfile {0} created'.format(lockfile)
        ret['result'] = True
    else:
        ret['comment'] = 'Failed to create lockfile {0}'.format(lockfile)
    return(ret)

def unlock(name, path='/var/lib/salt/'):
    ret = {'name': name, 'result': False, 'changes': {}, 'comment': ''}
    lockfile = path + name
    if not Path(lockfile).exists():
        if __opts__["test"]:
            ret['comment'] = 'Lockfile {0} would have been removed if it existed'.format(lockfile)
            ret["result"] = None
        else:
            ret['comment'] = 'Lockfile {0} does not exist'.format(lockfile)
        return(ret)
    if __opts__["test"]:
        ret["comment"] = "Lockfile {0} would have been removed".format(lockfile)
        ret["result"] = None
        return(ret)
    try:
        Path(lockfile).unlink()
    except Exception as error:
        ret['comment'] = 'Failed to delete lockfile {0}, error: {1}'.format(lockfile, error)
        return(ret)
    if not Path(lockfile).exists():
        ret['comment'] = 'Lockfile {0} deleted'.format(lockfile)
        ret['result'] = True
    else:
        ret['comment'] = 'Failed to delete lockfile {0}'.format(lockfile)
    return(ret)

def check(name, path='/var/lib/salt/'):
    ret = {'name': name, 'result': False, 'changes': {}, 'comment': ''}
    lockfile = path + name
    if __opts__["test"]:
        ret["comment"] = "Would have checked for existence of lockfile {0}".format(lockfile)
        ret["result"] = None
        return(ret)
    if Path(lockfile).exists():
        ret['comment'] = 'Deployment of {0} is locked via {1} - maybe there is an existing execution'.format(name, lockfile)
    else:
        ret['comment'] = '{0} is not locked'.format(name)
        ret['result'] = True
    return(ret)

