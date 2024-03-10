#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
from difflib import SequenceMatcher
from re import escape
import fspatch
import contextpatch
def patchcfs(name): 
  contextpatch.main("rom/images/" + name, "rom/images/config/" + name + "_file_contexts")
  fspatch.main("rom/images/" + name, "rom/images/config/" + name + "_fs_config")
patchcfs("system")
patchcfs("product")
patchcfs("vendor")
