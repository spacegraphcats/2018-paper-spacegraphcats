#! /usr/bin/env python
"""
Code to extract some number of species/genus/etc around a given query.

This was used to generate a list of critters for Fig 2(a).
"""
from __future__ import print_function, division
import sys
import argparse
import csv
from collections import Counter, defaultdict, namedtuple
import random

import sourmash_lib
from sourmash_lib import sourmash_args
from sourmash_lib.logging import notify, error, print_results
from sourmash_lib.lca import lca_utils
from sourmash_lib.lca.lca_utils import debug, set_debug
from sourmash_lib.lca.command_index import load_taxonomy_assignments


def gather_main(args):
    """
    """
    p = argparse.ArgumentParser()
    p.add_argument('--debug', action='store_true')
    p.add_argument('spreadsheet')
    p.add_argument('species')
    p.add_argument('--sbt')
    p.add_argument('-o', '--output', type=argparse.FileType('wt'))
    args = p.parse_args(args)

    if args.debug:
        set_debug(args.debug)

    assignments, num_rows = load_taxonomy_assignments(args.spreadsheet)

    found = False
    for ident, lineage in assignments.items():
        for vv in lineage:
            if vv.rank == 'species' and vv.name == args.species:
                found = True
                found_lineage = lineage
                break

    if not found:
        print('nothing found for {}; quitting'.format(args.species))
        sys.exit(-1)

    print('found:', ", ".join(lca_utils.zip_lineage(found_lineage)))

    lineage_search = dict(found_lineage)

    rank_found = defaultdict(list)
    rank_idents = defaultdict(list)
    taxlist = list(reversed(list(lca_utils.taxlist())))

    for ident, lineage in assignments.items():
        dd = dict(lineage)
        for k in taxlist:
            if dd.get(k) and dd.get(k) == lineage_search.get(k):
                rank_found[k].append(lineage)
                rank_idents[k].append(ident)
                break

    retrieve_idents = defaultdict(set)
    gimme_idents = {}
    for k in rank_found:
        print('at', k, 'found', len(rank_found.get(k)))

        num_to_extract = min(len(rank_idents[k]), 10)
        gimme = random.sample(rank_idents[k], num_to_extract)
        for g in gimme:
            gimme_idents[g] = k

    if not args.output or not args.sbt:
        print('no output arg or SBT arg given; quitting without extracting')
        sys.exit(-1)

    print('looking for:', len(gimme_idents))

    tree = sourmash_lib.load_sbt_index(args.sbt)

    w = csv.writer(args.output)
    for n, leaf in enumerate(tree.leaves()):
        if n % 1000 == 0:
            print('...', n)
        name = leaf.data.name()
        # hack for NCBI-style names, etc.        
        name = name.split(' ')[0].split('.')[0]

        if name in gimme_idents:
            level = gimme_idents[name]
            level_n = taxlist.index(level)
            filename = leaf.data.d['filename']

            w.writerow([level, level_n, filename, leaf.data.name()])
            print('FOUND!', leaf.data.name(), level)


if __name__ == '__main__':
    sys.exit(gather_main(sys.argv[1:]))
