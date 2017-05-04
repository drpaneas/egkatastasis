#!/bin/bash
# Example: ./script.sh zypper-log-1.13.22-1.1.noarch.log

PKG="$1"
#reply=$(curl -XGET "http://localhost:9200/_search" -d '{"query": {"match": {"path": {"query": "/logs/blender-lang-2.78c-3.2.noarch.log"}}}}')
construct="curl -XGET \"http://localhost:9200/_search\" -d '{\"query\": {\"match\": {\"source\": {\"query\": \"/logs/$PKG\"}}}}'"
message=$(eval $construct | jq '.hits' | jq '.hits' | jq '.[] | ._source | .message')
echo -e "$message"
