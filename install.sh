!/bin/sh

ls /mnt | awk '{print "/mnt/" $0 "/perforceserver"}' > /tmp/volumes.txt
echo "/opt/perforce/servers/perforceserver" >> /tmp/volumes.txt

printf "\nPlease select the installation location:\n"

i=1
while IFS= read -r line; do
    echo "$i. $line"
    eval volume_$i=\"$line\"
    i=$((i + 1))
done < /tmp/volumes.txt
count=$((i - 1))

printf "\nEnter the number: "
read choice

# Validate input
if [ "$choice" -lt 1 ] 2>/dev/null || [ "$choice" -gt "$count" ] 2>/dev/null;
then
    echo "Invalid selection."
    exit 1
fi

# Retrieve the selected volume using eval
eval selected_volume=\$volume_$choice
echo "You selected: $selected_volume"

ipv4=$(curl -s https://ipinfo.io/ip)

sudo apt-get update
sudo apt-get upgrade -y
wget -qO - https://package.perforce.com/perforce.pubkey | sudo apt-key add -
echo "deb http://package.perforce.com/apt/ubuntu bionic release" > /etc/apt/sources.list.d/perforce.list

sudo apt-get update
sudo apt-get install helix-p4d -y
mount -o remount,size=1G /tmp/
echo
echo
echo
echo "Please enter the following information:"
echo "Perforce Service name: perforceservice"
echo "Perforce Server root: ${selected_volume}"
echo "Create directory: y"
echo "Perforce Server unicode-mode: n"
echo "Perforce Server case-sensitive: y"
echo "Perforce Server address: ssl:${ipv4}:1666"
echo
echo
echo
sudo /opt/perforce/sbin/configure-helix-p4d.sh perforceservice -p ssl:${ipv4}:1666 -r ${selected_volume}