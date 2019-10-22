#!/bin/bash

JSON_FILE=$1
NAME=$2

cat <<EOF
<html>
<meta charset="UTF-8">
<h2>$NAME</h2>
<div id="json-render"></div>
<script type="text/javascript" src="json-formatter.js"></script>
<script>
const formatter = new JSONFormatter.default(
EOF

cat $JSON_FILE # My JSON

cat <<-EOF
,
    3, // Collapse depth
    {
        pathsToCollapse: [
            "properties.id"
        ]
    });
document.getElementsByClassName("content")[0].appendChild(formatter.render());
</script>

</html>
EOF