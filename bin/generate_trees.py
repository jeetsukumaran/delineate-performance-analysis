#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import json
import collections
import dendropy
from dendropy.interop import rstats

def generate_source_trees_r(
        output_prefix,
        ntrees,
        splitting_rate,
        speciation_completion_rate,
        extinction_rate,
        age,
        ):
    rscript = """\
    library(PBD)
    library(ape)
    pars = c(
        {good_species_speciation_initiation_rate},
        {speciation_completion_rate},
        {incipient_species_speciation_initiation_rate},
        {good_species_extinction_rate},
        {incipient_species_extinction_rate}
        )
    for (idx in 1:{num_reps}) {{
        res = pbd_sim(pars, {age})
        print(write.tree(res$tree, file=""))
    }}
    """.format(
        num_reps=ntrees,
        good_species_speciation_initiation_rate=splitting_rate,
        speciation_completion_rate=speciation_completion_rate,
        incipient_species_speciation_initiation_rate=splitting_rate,
        good_species_extinction_rate=extinction_rate,
        incipient_species_extinction_rate=extinction_rate,
        age=age,
    )
    returncode, stdout, stderr = rstats.call(rscript)
    data = {}
    data["params"] = {}
    data["params"]["good_species_speciation_initiation_rate"] = splitting_rate
    data["params"]["speciation_completion_rate"] = speciation_completion_rate
    data["params"]["incipient_species_speciation_initiation_rate"] = splitting_rate
    data["params"]["good_species_extinction_rate"] = extinction_rate
    data["params"]["incipient_species_extinction_rate"] = extinction_rate
    data["params"]["age"] = age
    data["trees"] = []
    tree_idx = 0
    for row in stdout.split("\n"):
        if not row:
            continue
        tree_idx += 1
        row = row[5:-1]
        tree = dendropy.Tree.get(data=row,
                schema="newick",
                rooting="force-rooted")
        species_leaf_maps = {}
        for leaf in tree.leaf_node_iter():
            leaf.taxon.label = leaf.taxon.label.replace("-", ".")
            species_label = leaf.taxon.label.split(".")[0]
            try:
                species_leaf_maps[species_label].append(leaf.taxon.label)
            except KeyError:
                species_leaf_maps[species_label] = [leaf.taxon.label]
        sorted_species_lineages_map = collections.OrderedDict()
        for k in sorted(species_leaf_maps.keys()):
            sorted_species_lineages_map[k] = sorted(species_leaf_maps[k])
        entry = collections.OrderedDict()
        entry["tree_idx"] = tree_idx
        entry["tree_filepath"] = "{}.{:04d}.nex".format(output_prefix, tree_idx)
        entry["run_config_filepath"] = "{}.{:04d}.json".format(output_prefix, tree_idx)
        entry["lineage_taxon_namespace"] = [t.label for t in tree.taxon_namespace]
        entry["lineage_tree"] = tree.as_string("newick").replace("\n", "")
        entry["species_taxon_namespace"] = sorted(species_leaf_maps.keys())
        entry["species_lineages_map"] = sorted_species_lineages_map
        data["trees"].append(entry)
        tree.write(path=entry["tree_filepath"], schema="nexus")
        config = {
                "species_leaf_sets": sorted(sorted_species_lineages_map.values())
        }
        with open(entry["run_config_filepath"], "w") as dest:
            json.dump(config, dest, indent=2)
    with open(output_prefix + ".json", "w") as dest:
        json.dump(data, dest, indent=2)
    return data
