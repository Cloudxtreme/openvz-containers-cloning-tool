#!/bin/sh

command -v tar >/dev/null 2>&1 || { echo >&2 "Please install tar first."; exit 1; }
command -v vzctl >/dev/null 2>&1 || { echo >&2 "Please install vzctl first."; exit 1; }

echo "Source container's ID: "
read SOURCE_ID
echo "Destination container's ID: "
read DESTINATION_ID
echo "Destination container's IP address: "
read DESTINATION_IP

vzctl stop $SOURCE_ID
mkdir /vz/root/$DESTINATION_ID
cp /etc/vz/conf/$SOURCE_ID.conf /etc/vz/conf/$DESTINATION_ID.conf
mkdir /vz/private/$DESTINATION_ID

echo "Compressing source container ..."
tar --numeric-owner -zcf /vz/private/$SOURCE_ID.tar -C /vz/private/$SOURCE_ID .

echo "Uncompressing destination container ..."
tar --numeric-owner -zxf /vz/private/$SOURCE_ID.tar -C /vz/private/$DESTINATION_ID

echo "Deleting temp files ..."
rm /vz/private/$SOURCE_ID.tar

echo "Applying new IP address ..."
sed -i "s/^\(IP_ADDRESS\s*=\s*\).*\$/\1$DESTINATION_IP/" /etc/vz/conf/$DESTINATION_ID.conf

vzctl start $SOURCE_ID
vzctl start $DESTINATION_ID

echo "Done !"