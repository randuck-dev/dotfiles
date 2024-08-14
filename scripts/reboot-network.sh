#!/bin/bash

echo "reprobing network"

modprobe -r ax88179_178a
modprobe ax88179_178a
