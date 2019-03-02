#!/usr/bin/env python

import argparse
import json


def get_tfstate_data(statefile):
    try:
        with open(statefile) as state:
            inventory = json.load(state)
            resources = inventory['modules'][0].get('resources')

        return resources
    except IOError:
        return {}


def parse_tfstate_data(resources):
    instances = []

    attributes = [
        'ami',
        'availability_zone',
        'instance_type',
        'private_dns',
        'private_ip',
        'public_dns',
        'public_ip',
        'tags.Name',
        'tags.Purpose',
        'tags.Role',
        'tags.Type',
        'tags.Ami'
    ]

    for k, v in resources.items():
        if v['type'] == 'aws_instance':
            instance = {}
            instance['id'] = v['primary']['id']

            for attribute in attributes:
                if attribute in v['primary']['attributes']:
                    instance[attribute] = v['primary']['attributes'][attribute]
                else:
                    instance[attribute] = None

            instances.append(instance)
    return instances


def list(statefile):
    # inventory = {}

    resources = get_tfstate_data(statefile)
    instances = parse_tfstate_data(resources)
    inventory = create_inventory(instances)

    inventory['_meta'] = {}
    inventory['_meta']['hostvars'] = {}
    # hostvars = inventory['_meta']['hostvars']

    return inventory


def create_inventory(instances):
    inventory = {}
    grouping_attrs = [
        'availability_zone',
        'tags.Name',
        'tags.Purpose',
        'tags.Role',
        'tags.Type',
        'tags.Ami'
    ]
    for instance in instances:
        name = instance['public_ip']
        for attr in grouping_attrs:
            if attr in instance:
                group = instance[attr]
                if group:
                    if group in inventory:
                        inventory[group]['hosts'].append(name)
                    else:
                        inventory[group] = {}
                        inventory[group]['hosts'] = [name]

                    inventory[group]['vars'] = {"ansible_user": "centos"}

    return inventory


def host(statefile, host):
    # Not supported yet
    # Ansible expects a hash of variables that apply to the host
    # We need to print an empty hash to maintain Ansible compatibility
    # but Ansible doesn't care if there is nothing in it
    empty_dict = {}
    return empty_dict


def main():
    global debug_set

    response = {}

    statefile = 'terraform.tfstate'

    parser = argparse.ArgumentParser(
        description="Return dynamic inventory for Ansible")
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--list',
                       action='store_true',
                       default=False,
                       help='return full inventory')
    group.add_argument('--host',
                       action='store',
                       dest='host',
                       type=str,
                       help='return inventory of HOST')
    parser.add_argument('--debug',
                        action='store_true',
                        default=False,
                        help='print debug info while running')

    args = parser.parse_args()

    if args.debug:
        debug_set = args.debug
    else:
        debug_set = False

    if args.list:
        response = list(statefile)

    if args.host:
        response = host(statefile, host)

    if response:
        print(json.JSONEncoder().encode(response))


if __name__ == '__main__':
    main()
