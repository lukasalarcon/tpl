connect="192.168.100.61/foo"
srcText="foo.bar=XPLACEHOLDERX"
echo $srcText | sed "s/XPLACEHOLDERX/${connect//\//\/}/"
