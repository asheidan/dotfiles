#!/bin/bash

question="Generate passwd for Mutt"

gpg=/usr/bin/gpg

#key=$(${askpass} "${question}")

${gpg} -r "Emil Eriksson" -e -q --batch --output "$1" -
