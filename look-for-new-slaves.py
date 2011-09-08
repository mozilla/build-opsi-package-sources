#!/usr/bin/python

from grp import getgrnam
from md5 import md5
import os
from os import path
import posixfile
from pwd import getpwnam
import shutil
import socket
import sys

# OPSI assumes that all slaves are in the same domain as the server. This means
# that when we add new slaves we need to take their hostname and append our
# domain name, regardless of the fqdn of the slave.
DOMAIN_NAME=socket.getfqdn().replace(socket.gethostname(), '')
PCKEYS="/etc/opsi/pckeys"
CLIENT_CONFIG_DIR="/var/lib/opsi/config/clients"
BUILD_CONFIG_TEMPLATE=path.join(CLIENT_CONFIG_DIR,
                                "win2k3-ref-img.uib.local.ini")
BUILD_IX_CONFIG_TEMPLATE = path.join(CLIENT_CONFIG_DIR,
                                     "win32-ix-ref.uib.local.ini")
# TODO: create these files
TALOS_XP_CONFIG_TEMPLATE=path.join(CLIENT_CONFIG_DIR, "talos-r3-xp-ref.uib.local.ini")
TALOS_WIN7_CONFIG_TEMPLATE=path.join(CLIENT_CONFIG_DIR,
                                     "talos-r3-w7-ref.uib.local.ini")
OWNER=getpwnam("opsiconfd")[2] # The UID of opsiconfd
GROUP=getgrnam("pcpatch")[2] # The GID of pcpatch
MODE=0664

BUILD_HOST, BUILD_IX_HOST, TALOS_XP_HOST, TALOS_WIN7_HOST, UNKNOWN_HOST = range(5)

class MissingTemplateError(Exception):
    pass

def get_host_type(hostname):
    if 'slave' in hostname:
        if '-ix-' in hostname:
            return BUILD_IX_HOST
        else:
            return BUILD_HOST
    elif 'talos' in hostname or '-try' in hostname:
        if 'xp' in hostname:
            return TALOS_XP_HOST
        elif 'w7' in hostname:
            return TALOS_WIN7_HOST
    return UNKNOWN_HOST

def get_config_template(hostname):
    type = get_host_type(hostname)
    if type == BUILD_HOST:
        return BUILD_CONFIG_TEMPLATE
    elif type == BUILD_IX_HOST:
        return BUILD_IX_CONFIG_TEMPLATE
    elif type == TALOS_XP_HOST:
        return TALOS_XP_CONFIG_TEMPLATE
    elif type == TALOS_WIN7_HOST:
        return TALOS_WIN7_CONFIG_TEMPLATE
    else:
        return None

def load_file(filename, parser=lambda line: line):
    things = []
    f = None
    try:
        f = open(filename)
        for line in f:
            things.append(parser(line.rstrip()))
    except IOError, e:
        if f:
            f.close()
        raise IOError("Error when processing %s: \n%s" % (filename, e))
    if f:
        f.close()
    return things

def load_pckeys(filename):
    def splitter(line):
        return line.split('%s:' % DOMAIN_NAME, 1)[0]
    return load_file(filename, parser=splitter)

def generate_hash(str):
    return md5(str).hexdigest()

def add_to_pckeys(host, hash, pckeys):
    line = '%s:%s' % (host, hash)
    pckeys_file = None
    try:
        pckeys_file = open(pckeys, "a")
        pckeys_file.seek(0, posixfile.SEEK_END)
        pckeys_file.write("%s\n" % line)
    except IOError, e:
        pckeys_file.close()
        raise IOError("Error when writing host '%s' to %s: \n%s" % (host,
                                                                    pckeys, e))
    pckeys_file.close()

def create_host_config_file(host):
    template_config = get_config_template(host)
    if not template_config:
        raise MissingTemplateError("Could not find template '%s'" % \
          template_config)
    try:
        host_config_file = path.join(CLIENT_CONFIG_DIR, "%s.ini" % host)
        if path.exists(host_config_file):
            # This should only happen in cases where a slave has been recloned
            # and it *should* be safe to delete this file, but better safe
            # than sorry.
            backupFile = '%s.bak' % host_config_file
            i = 1
            while path.exists(backupFile):
                backupFile = '%s.bak.%d' % (host_config_file, i)
                i += 1
            shutil.move(host_config_file, backupFile)
        shutil.copy(template_config, host_config_file)
        os.chown(host_config_file, OWNER, GROUP)
        os.chmod(host_config_file, MODE)
    except (IOError, OSError), e:
        raise IOError("Error when creating '%s': \n%s" % (host_config_file, e))

def get_fqdn(host):
    return '%s%s' % (host, DOMAIN_NAME)

if __name__ == '__main__':
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option("-p", "--pckeys", action="store", dest="pckeys",
                      default=PCKEYS)
    parser.add_option("-f", "--host-file", action="store", dest="host_file")
    (options, args) = parser.parse_args()
    
    new_hosts = []
    if options.host_file:
        new_hosts = load_file(options.host_file)
    if len(args) < 1:
        if not new_hosts:
            print "Must specify at least one host"
            sys.exit(1)
    new_hosts.extend(args)

    existing_hosts = load_pckeys(options.pckeys)
    for host in new_hosts:
        if host in existing_hosts:
            continue
        try:
            print "Adding %s" % host
            hash = generate_hash(host)
            fqdn = get_fqdn(host)
            add_to_pckeys(fqdn, hash, options.pckeys)
            create_host_config_file(fqdn)
        except (IOError, MissingTemplateError), e:
            print >>sys.stderr, "Failed to create %s: \n%s" % (host, e)
        except:
            print >>sys.stderr, "Unhandled error:"
            raise
