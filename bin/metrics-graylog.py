#!/usr/bin/env python

import os
import sys


script = os.path.splitext(os.path.abspath( __file__ ))[0]
print script
os.execv(script + '.rb', sys.argv)
