#!/bin/bash

{hue_install_path}/build/env/bin/hue syncdb --noinput
{hue_install_path}/build/env/bin/hue migrate